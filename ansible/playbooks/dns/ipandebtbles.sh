sudo apt update
sudo apt install iptables-persistent
# Allow from trusted source (your DNS peer)
sudo iptables -A INPUT -p vrrp -s 10.0.0.15 -d 224.0.0.18 -j ACCEPT
sudo iptables -A INPUT -p vrrp -s 10.0.0.17 -d 224.0.0.18 -j ACCEPT
sudo iptables -A INPUT -p vrrp -s 10.0.0.18 -d 224.0.0.18 -j ACCEPT
sudo iptables -A INPUT -p vrrp -d 224.0.0.18 -j DROP

sudo ip6tables -A INPUT -p vrrp -s fe80::be24:11ff:fe83:e894 -d ff02::12 -j ACCEPT
sudo ip6tables -A INPUT -p vrrp -s fe80::be24:11ff:fe06:37eb -d ff02::12 -j ACCEPT
sudo ip6tables -A INPUT -p vrrp -s fe80::be24:11ff:fe4c:7635 -d ff02::12 -j ACCEPT
sudo ip6tables -A INPUT -p vrrp -d ff02::12 -j DROP

sudo su -
sudo iptables-save > /etc/iptables/rules.v4
sudo ip6tables-save > /etc/iptables/rules.v6
exit
sudo iptables -L -v


#ebtables
# Allow trusted MACs
#sudo ebtables -A INPUT -s bc:24:11:06:37:eb -p 0x0800 --ip-proto 112 --ip-destination 224.0.0.18 -j ACCEPT
#sudo ebtables -A INPUT -s bc:24:11:83:e8:94 -p 0x0800 --ip-proto 112 --ip-destination 224.0.0.18 -j ACCEPT

# Drop all others
#sudo ebtables -A INPUT -p 0x0800 --ip-proto 112 --ip-destination 224.0.0.18 -j DROP
