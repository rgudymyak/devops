#!/bin/bash
sudo cat <<EOF>> /etc/sysctl.d/centos_ip_forwarding.conf
net.ipv4.ip_forward=1
EOF

sudo cat <<EOF>> /etc/nftables.conf
table ip filter {
    chain forward {
        type filter hook forward priority filter; policy drop;
        ct state established,related accept
        iifname "enp0s8" oifname "enp0s3" accept
    }
}

table ip nat {
    chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        oifname "enp0s3" masquerade
    }
}
EOF

sudo systemctl enable --now nftables
