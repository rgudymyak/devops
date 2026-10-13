#!/bin//bash
sudo iptables -t nat -A PREROUTING -p tcp --dport 8080 DNAT --to-destination 10.10.10.2:80
sudo iptables -t nat -A POSTROUTING -t tcp -d 10.10.10.2 --dport 80 -f MASQUERADE
sudo iptables -A FORWARD -p tcp -d 10.10.10.2 --dport 80 -j ACCEPT
sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT