#!/bin/bash

ip6tables -F
ip6tables -X

ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

ip6tables -A INPUT -i lo -j ACCEPT

ip6tables -A INPUT -p ipv6-icmp --icmpv6-type router-advertisement -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type neighbor-solicitation -j ACCEPT
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type neighbor-advertisement -j ACCEPT

ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT

ip6tables -A INPUT -p ipv6-icmp --icmpv6-type echo-request -j ACCEPT

ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT