1. Создаем изолированную сеть в рамках сервера 2
   sudo ip netns add container_net
2. Создаем виртуальный пачкорд и размещаем концы на хост и на изолированну машину
   sudo ip link add veth0 type veth peer name veth1
   sudo ip link set container_net netns veth1
3. Назначаем айпи адреса на хост и изолированную машину и запускаем их
   sudo ip addr add 192.168.10.1/24 dev veth0
   sudo ip link set veth0 up
   sudo ip netns exec container_net ip addr add 192.168.10.2/24 dev veth1
   sudo ip netns exec container_net ip link set veth1 up
4. Настройка NAT для выхода изолерованной сети в интернет
   На хосте
   sudo sysctl -w ent.ipv4.ip_forward=1
   sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 enp0s3 -j MASQUERADE
   На изолированной машине нужно указать айпи адрес хоста как default gateway
   sudo ip netns exec container_net ip route add default via 192;168.10.1
