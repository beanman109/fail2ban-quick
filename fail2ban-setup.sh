#!/bin/bash
#
# fail2ban-nftables-setup.sh
# A script to install and configure Fail2ban + nftables on Debian 12
# (No email configuration included)

set -e

echo "=== 1. Updating system and installing packages ==="
apt update
apt -y install rsyslog nftables fail2ban

echo "=== 2. Enabling and starting rsyslog ==="
systemctl enable rsyslog
systemctl start rsyslog

# Optional: Wait briefly so rsyslog can initialize (not strictly necessary)
# sleep 2

echo "=== 3. Enabling and starting nftables ==="
systemctl enable nftables
systemctl start nftables

echo "=== 4. Creating a custom /etc/fail2ban/jail.local (no email setup) ==="
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime  = 10m
findtime = 10m
maxretry = 5
backend  = auto
ignoreip = 127.0.0.1/8 ::1

# Use nftables instead of iptables
banaction         = nftables-multiport
banaction_allports = nftables-allports

[sshd]
enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 5
EOF

echo "=== 5. Restarting Fail2ban ==="
systemctl restart fail2ban

echo "=== 6. Checking Fail2ban status ==="
systemctl status fail2ban --no-pager

echo "=== Done! ==="
echo "Fail2ban should now be actively monitoring SSH logs with nftables."
