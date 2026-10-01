#!/bin/bash
ping -c 3 -W 2 8.8.8.8            	# internet
ping -c 3 -W 2 192.230.4.2	# abbey
ping -c 3 -W 2 192.230.5.2        	# penny
cat /etc/resolv.conf              	# prab, tedd, 192.168.122.1
dig +short www.K38.com          	# penny
dig +short static.K38.com         	# abbey
dig +short vault.K38.com          	# 2 ip
dig +short core.K38.com           	# 2 ip
dig +short SOA K38.com @192.230.1.2
dig +short SOA K38.com @192.230.1.3
curl -I -m 5 http://vault.K38.com/arsip/		# 200
curl -I -m 5 http://core.K38.com/profil		# 200