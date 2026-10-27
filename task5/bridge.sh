#!/bin/bash
# Создаем тип соединения bridge с именем br0 и именем соединения br0
sudo nmcli connection add type bridge ifname br0 con-name br0
#Присваиваем айпи адрес шлюза на мост br0
sudo nmcli connection modify br0 ipv4.method manual ipv4.addresses 10.10.10.1/24
# Привязываем интерфейс как ведомый к мосту. Сервер 2
sudo nmcli add type bridge-slave ifname enp0s8 master br0
# Привязываем интерфейс как ведомый к мосту. Сервер 3
sudo nmcli connection add type bridge-slave ifname enp0s9 master br0
# Поднимаем интерфейс br0
sudo nmcli connection up br0


Вообще в интернете еще можно найти сокращенную форму записи connection - con, как ранее было