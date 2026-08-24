#!/bin/bash

# ==========================================
# EIAMS - Infrastructure Health Report
# ==========================================

LOG_FILE="./logs/eiams.log"

mkdir -p ./logs

echo "==========================================" | tee -a "$LOG_FILE"
echo "       EIAMS INFRASTRUCTURE HEALTH"
echo "==========================================" | tee -a "$LOG_FILE"
echo "Generated: $(date)" | tee -a "$LOG_FILE"
echo

echo "Hostname:"
hostname | tee -a "$LOG_FILE"
echo

echo "System Uptime:"
uptime -p | tee -a "$LOG_FILE"
echo

echo "CPU Information:"
lscpu | grep -E "Model name|CPU\(s\)" | head -2 | tee -a "$LOG_FILE"
echo

echo "Memory Usage:"
free -h | tee -a "$LOG_FILE"
echo

echo "Disk Usage:"
df -h / | tee -a "$LOG_FILE"
echo

echo "Running Services:"
systemctl list-units --type=service --state=running --no-pager | head -15 | tee -a "$LOG_FILE"
echo

echo "Listening Network Ports:"
ss -tuln | tee -a "$LOG_FILE"
echo

echo "Firewall:"
if command -v ufw &>/dev/null; then
    sudo ufw status | tee -a "$LOG_FILE"
else
    echo "UFW not installed" | tee -a "$LOG_FILE"
fi

echo
echo "==========================================" | tee -a "$LOG_FILE"
echo "           HEALTH REPORT COMPLETE"
echo "==========================================" | tee -a "$LOG_FILE"

