#!/bin/bash
sudo nmcli connection modify enp0s3 ipv4.gateway "10.10.10.2"
sudo nmcli connection modify enp0s3 ipv4.dns "8.8.8.8 8.8.4.4"
sudo nmcli connection up enp0s3