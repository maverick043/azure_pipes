# azure_pipes
Azure pipeline build files


subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.50 192.168.1.100;
    option subnet-mask 255.255.255.0;
    option routers 192.168.1.1;
    option domain-name-servers 192.168.1.1;
    next-server 192.168.1.10;  # Replace with your PXE server's IP
    filename "pxelinux.0";
}
