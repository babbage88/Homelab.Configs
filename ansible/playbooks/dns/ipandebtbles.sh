# Allow from trusted source (your DNS peer)
sudo iptables -A INPUT -p vrrp -s 10.0.0.15 -d 224.0.0.18 -j ACCEPT
sudo iptables -A INPUT -p vrrp -s 10.0.0.17 -d 224.0.0.18 -j ACCEPT
sudo iptables -A INPUT -p vrrp -s 10.0.0.18 -d 224.0.0.18 -j ACCEPT

sudo iptables -A INPUT -p vrrp -d 224.0.0.18 -j DROP


      fe80::be24:11ff:fe83:e894,
      fe80::be24:11ff:fe06:37eb,
      fe80::be24:11ff:fe4c:7635
sudo ip6tables -A INPUT -p vrrp -s fe80::be24:11ff:fe83:e894 -d ff02::12 -j ACCEPT
sudo ip6tables -A INPUT -p vrrp -s fe80::be24:11ff:fe06:37eb -d ff02::12 -j ACCEPT
sudo ip6tables -A INPUT -p vrrp -s fe80::be24:11ff:fe4c:7635 -d ff02::12 -j ACCEPT

sudo ip6tables -A INPUT -p vrrp -d ff02::12 -j DROP
