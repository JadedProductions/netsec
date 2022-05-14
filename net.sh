## net.sh
## by jadedProductions
## simple rate limiter for ipsets
### sudo apt install iptables ipset -y

sudo sysctl -w net.ipv4.icmp_echo_ignore_all=1
ipset destroy ratelimit
ipset destroy blockip
ipset create blockip nethash
ipset create ratelimit nethash
iptables -N port-scanning
iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
iptables -A port-scanning -j DROP
iptables -A INPUT -m set --match-set blockip src -j DROP
iptables -I INPUT -m set --match-set ratelimit src -p tcp --dport 80 -m hashlimit --hashlimit 1/hour --hashlimit-name ratelimithash -j DROP
iptables -I INPUT -m set --match-set ratelimit src -p tcp --dport 6667 -j DROP
iptables -I INPUT -m set --match-set ratelimit src -p tcp --dport 443 -m hashlimit --hashlimit 1/hour --hashlimit-name ratelimithash -j DROP
iptables -I INPUT -m set --match-set ratelimit src -p tcp --dport 6697 -m hashlimit --hashlimit 1/hour --hashlimit-name ratelimithash -j DROP
iptables -I INPUT -m set --match-set ratelimit src -p tcp --dport 22 -m hashlimit --hashlimit 1/hour --hashlimit-name ratelimithash -j DROP
iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
iptables -t mangle -A PREROUTING -s 224.0.0.0/3 -j DROP
iptables -t mangle -A PREROUTING -s 169.254.0.0/16 -j DROP
iptables -t mangle -A PREROUTING -s 172.16.0.0/12 -j DROP
iptables -t mangle -A PREROUTING -s 192.0.2.0/24 -j DROP
iptables -t mangle -A PREROUTING -s 192.168.0.0/16 -j DROP
iptables -t mangle -A PREROUTING -s 10.0.0.0/8 -j DROP
iptables -t mangle -A PREROUTING -s 0.0.0.0/8 -j DROP
iptables -t mangle -A PREROUTING -s 240.0.0.0/5 -j DROP
iptables -t mangle -A PREROUTING -s 127.0.0.0/8 ! -i lo -j DROP
iptables -t mangle -A PREROUTING -p icmp -j DROP
iptables -t mangle -A PREROUTING -f -j DROP
iptables -A INPUT -p tcp -m connlimit --connlimit-above 16 -j REJECT --reject-with tcp-reset
iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP
iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 2/s --limit-burst 255 -j ACCEPT
iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP
