#!/bin/bash

iptables -F
iptables -X

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -i lo -j ACCEPT

iptables -A INPUT -p tcp --dport 22 -j ACCEPT

iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT


iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT