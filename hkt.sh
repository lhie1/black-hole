chattr -i /etc/resolv.conf
dhclient -r && \
rm -rf /var/lib/dhcp/* && \
dhclient