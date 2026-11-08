server1
Настраиваем тегированную подсеть VLAN10 VLAN20 через nmcli
sudo nmcli connection add type vlan con-name enp0s8.10 dev enp0s8 id 10 ipv4.method manual ipv4.addresses 192.168.10.1
sudo nmcli connection add type vlan con-name enp0s8.20 dev enp0s8 id 20 ipv4.method manual ipv4.addresses 192.168.20.1
Запускаем две подсети через nmcli
sudo nmcli connection up enp0s8.10
sudo nmcli connection up enp0s8.20

server2
Тоже самое проделываем на втором сервере
sudo nmcli connection add type vlan con-name enp0s3.10 dev enp0s3 id 10 ipv4.method manual ipv4.addresses 192.168.10.2
sudo nmcli connection add type vlan con-name enp0s3.20 dev enp0s3 id 20 ipv4.mathod manual ipv4.addresses 192.168.20.2
Запускаем две подсети через nmcli
sudo nmcli connection up enp0s3.10
sudo nmcli connection up enp0s3.20

Далее мы можем проверить что наши подсети запущены через команду
sudo nmcli connection show

Далее мы можем проверить что машины пингуются в одной подсети
ping -I enp0s8.10 192.168.10.2/24 запускаем на первой машине проверку vlan10
ping -I enp0s3.20 192.168.20.1/24 запускаем на второй машине проверку vlan20

Настройка правил iptables для того чтобы трафик из VLAN 10 не мог маршрутизироваться в VLAN 20.
server1
sudo iptables -A FORWARD -i enp0s8.10 -o enp0s8.20 -j REJECT --reject-with icmp-port-unreachable
sudo iptables -A FORWARD -i enp0s8.20 -o enp0s8.10 -j REJECT --reject-with icmp-port-unreachable
