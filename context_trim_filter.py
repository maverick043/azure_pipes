"""
title: Context Trim Filter
description: Hard limit on chat context. Drops the oldest messages when a request exceeds a token budget. Keeps system messages, never removes the latest user message, and always cuts at a user message so tool calls and tool results are never split.
version: 1.0
"""

from typing import Optional

from pydantic import BaseModel, Field

try:
    import tiktoken  # ships with Open WebUI
except ImportError:
    tiktoken = None


class Filter:
    class Valves(BaseModel):
        priority: int = Field(
            default=0,
            description="Lower runs first. Keep at 0 so trimming happens before other filters.",
        )
        budget_tokens: int = Field(
            default=60000,
            description="Total token budget for the request (should stay below LiteLLM max_input_tokens).",
        )
        headroom_tokens: int = Field(
            default=15000,
            description="Reserved for what Open WebUI adds after this filter (RAG context, native tool definitions). History is trimmed to budget minus headroom.",
        )
        max_messages: int = Field(
            default=0,
            description="Optional cap on the number of non-system messages. 0 = no cap.",
        )
        debug: bool = Field(
            default=False,
            description="Print trim decisions to the Open WebUI logs.",
        )

    def __init__(self):
        self.valves = self.Valves()
        self._enc = None
        if tiktoken is not None:
            try:
                # Approximation for Qwen; fine for a budget with headroom.
                self._enc = tiktoken.get_encoding("cl100k_base")
            except Exception:
                self._enc = None

    # ---- token counting -------------------------------------------------

    def _count_text(self, text) -> int:
        if not text:
            return 0
        if not isinstance(text, str):
            text = str(text)
        if self._enc is not None:
            return len(self._enc.encode(text, disallowed_special=()))
        return len(text) // 4 + 1

    def _message_tokens(self, msg: dict) -> int:
        tokens = 0
        content = msg.get("content")
        if isinstance(content, list):
            for part in content:
                if not isinstance(part, dict):
                    continue
                if part.get("type") == "text":
                    tokens += self._count_text(part.get("text"))
                elif part.get("type") == "image_url":
                    tokens += 1600  # worst-case allowance per image
        else:
            tokens += self._count_text(content)

        # Tool calls carry their arguments separately from content.
        for tc in msg.get("tool_calls") or []:
            fn = tc.get("function") or {}
            tokens += self._count_text(fn.get("name"))
            tokens += self._count_text(fn.get("arguments"))

        return tokens + 4  # role/formatting overhead

    # ---- filter ---------------------------------------------------------

    async def inlet(self, body: dict, __user__: Optional[dict] = None) -> dict:
        messages = body.get("messages") or []
        if not messages:
            return body

        limit = self.valves.budget_tokens - self.valves.headroom_tokens
        if limit <= 0:
            return body  # misconfigured: pass through untouched

        system_msgs = [m for m in messages if m.get("role") == "system"]
        other = [m for m in messages if m.get("role") != "system"]

        user_idx = [i for i, m in enumerate(other) if m.get("role") == "user"]
        if not user_idx:
            return body
        last_user = user_idx[-1]  # never trim this or anything after it

        sizes = [self._message_tokens(m) for m in other]
        system_tokens = sum(self._message_tokens(m) for m in system_msgs)
        original_total = system_tokens + sum(sizes)

        start = 0
        if self.valves.max_messages > 0:
            start = max(0, len(other) - self.valves.max_messages)
        start = min(start, last_user)

        total = system_tokens + sum(sizes[start:])

        # Drop oldest messages until under the limit.
        while total > limit and start < last_user:
            total -= sizes[start]
            start += 1

        # Always begin at a user message, so an assistant tool call is never
        # separated from its tool results (orphans cause provider 400s).
        while start < last_user and other[start].get("role") != "user":
            total -= sizes[start]
            start += 1

        if start > 0:
            body["messages"] = system_msgs + other[start:]
            if self.valves.debug:
                print(
                    f"[context-trim] dropped {start} messages, "
                    f"~{original_total} -> ~{total} tokens (limit {limit})"
                )
        elif self.valves.debug:
            print(f"[context-trim] no trim needed, ~{original_total} tokens")

        return body
