#!/bin/bash

# ==========================================
# EIAMS - Central System Dashboard
# ==========================================

EIAMS_ROOT="/mnt/d/AWSProject/EIAMS"
SECURITY_SCRIPT="$EIAMS_ROOT/modules/security_check.sh"
ALERT_LOG="$EIAMS_ROOT/logs/alerts.log"

# ==========================================
# System Metrics
# ==========================================

get_cpu_usage() {

    cpu_usage=$(top -bn1 | awk -F',' '
        /Cpu\(s\)/ {
            for (i = 1; i <= NF; i++) {
                if ($i ~ /id/) {
                    gsub(/[^0-9.]/, "", $i)
                    print 100 - $i
                    exit
                }
            }
        }
    ')

    if [ -z "$cpu_usage" ]; then
        cpu_usage=0
    fi

    printf "%.0f%%" "$cpu_usage"
}

get_memory_usage() {

    free | awk '/Mem:/ {
        printf "%.0f%%", ($3/$2)*100
    }'
}

get_disk_usage() {

    df / | awk 'NR==2 {print $5}'
}

get_uptime() {

    uptime -p
}

# ==========================================
# Service Metrics
# ==========================================

get_running_services() {

    systemctl list-units \
        --type=service \
        --state=running \
        --no-legend \
        --no-pager 2>/dev/null | wc -l
}

get_failed_services() {

    systemctl --failed \
        --type=service \
        --no-legend \
        --no-pager 2>/dev/null | wc -l
}

# ==========================================
# Network Metrics
# ==========================================

get_network_status() {

    if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        echo "ONLINE"
    else
        echo "OFFLINE"
    fi
}

get_listening_ports() {

    ss -tulpn 2>/dev/null | \
        awk 'NR>1 {print $5}' | sort -u | wc -l
}

# ==========================================
# Alert Metrics
# ==========================================

get_active_alerts() {

    if [ ! -f "$ALERT_LOG" ]; then
        echo "0"
        return
    fi

    grep -c '|ACTIVE|' "$ALERT_LOG" 2>/dev/null
}

get_acknowledged_alerts() {

    if [ ! -f "$ALERT_LOG" ]; then
        echo "0"
        return
    fi

    grep -c '|ACKNOWLEDGED|' "$ALERT_LOG" 2>/dev/null
}

# ==========================================
# Dependency Metrics
# ==========================================

get_dependency_status() {

    healthy=0
    warning=0
    critical=0

    services=(
        "docker.service containerd.service"
        "systemd-resolved.service systemd-timesyncd.service"
        "rsyslog.service systemd-journald.service"
    )

    for dependency in "${services[@]}"; do

        service=$(echo "$dependency" | awk '{print $1}')
        required=$(echo "$dependency" | awk '{print $2}')

        service_ok=false
        dependency_ok=false

        if systemctl is-active --quiet "$service"; then
            service_ok=true
        fi

        if systemctl is-active --quiet "$required"; then
            dependency_ok=true
        fi

        if $service_ok && $dependency_ok; then
            ((healthy++))
        elif $service_ok; then
            ((warning++))
        else
            ((critical++))
        fi

    done

    echo "$healthy|$warning|$critical"
}

# ==========================================
# Security Score
# ==========================================

get_security_score() {

    local score=0

    # Firewall Check
    if command -v ufw &>/dev/null; then

        local firewall_status
        firewall_status=$(sudo ufw status 2>/dev/null | head -1)

        if echo "$firewall_status" | grep -qi "active"; then
            score=$((score + 20))
        fi
    fi

    # SSH Check
    if [ -f /etc/ssh/sshd_config ]; then

        if ! grep -Eiq \
            "^[[:space:]]*PermitRootLogin[[:space:]]+yes" \
            /etc/ssh/sshd_config; then

            score=$((score + 20))
        fi

    else

        score=$((score + 20))

    fi

    # Failed Login Check
    local failed_logins=0

    if command -v journalctl &>/dev/null; then

        failed_logins=$(journalctl --no-pager 2>/dev/null |
            grep -Ei "failed password|authentication failure" |
            wc -l)

    fi

    if [ "$failed_logins" -eq 0 ]; then
        score=$((score + 20))
    fi

    # Listening Ports Check
    local listening_ports=0

    if command -v ss &>/dev/null; then

        listening_ports=$(ss -tuln 2>/dev/null |
            grep -E "LISTEN|UNCONN" |
            wc -l)

    fi

    if [ "$listening_ports" -le 10 ]; then
        score=$((score + 20))
    fi

    # Sensitive File Permissions
    if [ -f /etc/shadow ]; then

        local shadow_permissions
        shadow_permissions=$(stat -c "%a" /etc/shadow 2>/dev/null)

        if [ "$shadow_permissions" -le 640 ]; then
            score=$((score + 20))
        fi

    fi

    # Security Status

    if [ "$score" -ge 80 ]; then
        echo "$score/100 (GOOD)"

    elif [ "$score" -ge 60 ]; then
        echo "$score/100 (WARNING)"

    else
        echo "$score/100 (CRITICAL)"
    fi
}

# ==========================================
# Overall Status
# ==========================================

calculate_overall_status() {

    local cpu="$1"
    local memory="$2"
    local disk="$3"
    local failed="$4"
    local network="$5"
    local critical="$6"
    local active_alerts="$7"
    local security_score="$8"

    cpu=${cpu%\%}
    memory=${memory%\%}
    disk=${disk%\%}

    security_score=${security_score%%/*}

    # Critical conditions

    if [ "$network" = "OFFLINE" ]; then
        echo "CRITICAL"
        return
    fi

    if [ "$critical" -gt 0 ]; then
        echo "CRITICAL"
        return
    fi

    if [ "$security_score" -lt 60 ]; then
        echo "CRITICAL"
        return
    fi

    # Warning conditions

    if [ "$failed" -gt 0 ] ||
       [ "$active_alerts" -gt 0 ] ||
       [ "$cpu" -ge 80 ] ||
       [ "$memory" -ge 80 ] ||
       [ "$disk" -ge 80 ] ||
       [ "$security_score" -lt 80 ]; then

        echo "WARNING"
        return
    fi

    echo "HEALTHY"
}

# ==========================================
# Dashboard
# ==========================================

show_dashboard() {

    clear

    echo "=========================================="
    echo "          EIAMS SYSTEM DASHBOARD"
    echo "=========================================="
    echo

    # System

    cpu=$(get_cpu_usage)
    memory=$(get_memory_usage)
    disk=$(get_disk_usage)
    uptime_value=$(get_uptime)

    echo "SYSTEM"
    echo "------------------------------------------"
    echo "Hostname:          $(hostname)"
    echo "Uptime:            $uptime_value"
    echo "CPU Usage:         $cpu"
    echo "Memory Usage:      $memory"
    echo "Disk Usage:        $disk"
    echo

    # Services

    running=$(get_running_services)
    failed=$(get_failed_services)

    echo "SERVICES"
    echo "------------------------------------------"
    echo "Running Services:  $running"
    echo "Failed Services:   $failed"
    echo

    # Network

    network=$(get_network_status)
    ports=$(get_listening_ports)

    echo "NETWORK"
    echo "------------------------------------------"
    echo "Connectivity:      $network"
    echo "Listening Ports:   $ports"
    echo

    # Security

    security_score=$(get_security_score)

    echo "SECURITY"
    echo "------------------------------------------"
    echo "Security Score:    $security_score"
    echo

    # Dependencies

    dependency_data=$(get_dependency_status)

    healthy=$(echo "$dependency_data" | cut -d'|' -f1)
    warning=$(echo "$dependency_data" | cut -d'|' -f2)
    critical=$(echo "$dependency_data" | cut -d'|' -f3)

    echo "DEPENDENCIES"
    echo "------------------------------------------"
    echo "Healthy:           $healthy"
    echo "Warning:           $warning"
    echo "Critical:          $critical"
    echo

    # Alerts

    active=$(get_active_alerts)
    acknowledged=$(get_acknowledged_alerts)

    echo "ALERTS"
    echo "------------------------------------------"
    echo "Active:            $active"
    echo "Acknowledged:      $acknowledged"
    echo

    # Overall

    overall=$(calculate_overall_status \
        "$cpu" \
        "$memory" \
        "$disk" \
        "$failed" \
        "$network" \
        "$critical" \
        "$active" \
        "$security_score")

    echo "=========================================="
    echo "OVERALL SYSTEM STATUS: $overall"
    echo "=========================================="
    echo

}

# ==========================================
# Main
# ==========================================

show_dashboard

read -p "Press Enter to return to the main menu..."
