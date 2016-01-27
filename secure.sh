#!/bin/bash

# SETTINGS
SSH_PORT='22'
TCP_VPN_PORT='443'
UDP_VPN_PORT='1194'

# SSHD
sed -i "s/Port 22/Port $SSH_PORT/g" /etc/ssh/sshd_config
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
service ssh restart

# FIREWALL
ufw default deny incoming \
  && ufw default allow outgoing \
  && ufw allow "$SSH_PORT/tcp" \
  && ufw allow "$TCP_VPN_PORT/tcp" \
  && ufw allow "$UDP_VPN_PORT/udp" \
  && ufw reload \
  && ufw --force disable \
  && ufw --force enable

# FAIL2BAN - TODO: Better config
apt-get install fail2ban -y \
  && service fail2ban stop \
  && service fail2ban start