#!/bin/sh
# 配置防火墙
iptables -D INPUT -p tcp --dport ${PORT} -j ACCEPT
iptables -D INPUT -p udp --dport ${PORT} -j ACCEPT
iptables -D FORWARD -s ${VPNNETWORK} -j ACCEPT
iptables -D FORWARD -d ${VPNNETWORK} -j ACCEPT
#iptables -t nat -D POSTROUTING -s ${VPNNETWORK} -o ${INTERFACE} -j MASQUERADE

iptables -I INPUT -p tcp --dport ${PORT} -j ACCEPT
iptables -I INPUT -p udp --dport ${PORT} -j ACCEPT
iptables -I FORWARD -s ${VPNNETWORK} -j ACCEPT
iptables -I FORWARD -d ${VPNNETWORK} -j ACCEPT
#iptables -t nat -A POSTROUTING -s ${VPNNETWORK} -o ${INTERFACE} -j MASQUERADE

# 执行CMD命令
/usr/sbin/ocserv --config /etc/ocserv/ocserv.conf -f -d 1


