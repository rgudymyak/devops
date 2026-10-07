sudo sysctl -w net.ipv4.ip_forward=1
Далее нужно расскоментировать в файле
/etc/sysctl.conf строку net.ipv4.ip_forward=1

Далее устанавливаем правила для iptables
sudo iptables -P FORWARD DROP
sudo iptables -A FORWARD -m conntrack -ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o enp0s3 MASQUERADE
