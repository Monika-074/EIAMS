#!/bin/bash

# ==========================================
# EIAMS - Security Check Module
# ==========================================

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECURITY_LOG="$BASE_DIR/logs/security.log"

mkdir -p "$BASE_DIR/logs"
touch "$SECURITY_LOG"

log_security_event() {
    local event="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $event" >> "$SECURITY_LOG"
}

check_firewall() {
    echo
    echo "========== FIREWALL STATUS =========="

    if command -v ufw &>/dev/null; then
        sudo ufw status verbose
        log_security_event "Firewall status checked"
    else
        echo "UFW is not installed."
        log_security_event "Firewall check: UFW not installed"
    fi

    echo
}

check_ssh() {
    echo
    echo "========== SSH CONFIGURATION =========="

    if [ -f /etc/ssh/sshd_config ]; then

        echo "SSH configuration file found."

        echo
        echo "PermitRootLogin:"
        grep -Ei "^[[:space:]]*PermitRootLogin" /etc/ssh/sshd_config || \
            echo "Not explicitly configured"

        echo
        echo "PasswordAuthentication:"
        grep -Ei "^[[:space:]]*PasswordAuthentication" /etc/ssh/sshd_config || \
            echo "Not explicitly configured"

        log_security_event "SSH configuration checked"

    else
        echo "SSH server configuration not found."
        log_security_event "SSH configuration check: SSH server not installed"
    fi

    echo
}

check_failed_logins() {
    echo
    echo "========== FAILED LOGIN ATTEMPTS =========="

    failed_logins=0

    if command -v journalctl &>/dev/null; then
        failed_logins=$(journalctl --no-pager 2>/dev/null |
            grep -Ei "failed password|authentication failure" |
            wc -l)

        if [ "$failed_logins" -eq 0 ]; then
            echo "No recent failed login records found."
        else
            echo "Failed login attempts found: $failed_logins"
        fi

        log_security_event "Failed login check: $failed_logins attempts found"

    else
        echo "journalctl is not available."
        log_security_event "Failed login check: journalctl unavailable"
    fi

    echo
}

check_ports() {
    echo
    echo "========== OPEN NETWORK PORTS =========="

    if command -v ss &>/dev/null; then
        ss -tuln
        log_security_event "Open network ports checked"
    else
        echo "ss command is not available."
        log_security_event "Open ports check: ss unavailable"
    fi

    echo
}

check_sudo_users() {
    echo
    echo "========== USERS WITH SUDO ACCESS =========="

    if getent group sudo &>/dev/null; then
        getent group sudo
        log_security_event "Sudo users checked"
    else
        echo "sudo group not found."
        log_security_event "Sudo users check: sudo group not found"
    fi

    echo
}

check_sensitive_permissions() {
    echo
    echo "========== SENSITIVE FILE PERMISSIONS =========="

    echo "/etc/passwd:"
    ls -l /etc/passwd

    echo
    echo "/etc/shadow:"
    ls -l /etc/shadow 2>/dev/null || \
        echo "Cannot access /etc/shadow"

    log_security_event "Sensitive file permissions checked"

    echo
}

security_summary() {

    echo
    echo "=========================================="
    echo "          EIAMS SECURITY SCORE"
    echo "=========================================="

    score=0

    # ------------------------------------------
    # 1. Firewall Check
    # ------------------------------------------

    echo
    echo "[1] Firewall:"

    if command -v ufw &>/dev/null; then

        firewall_status=$(sudo ufw status | head -1)

        if echo "$firewall_status" | grep -qi "active"; then
            echo "Status: PASS"
            score=$((score + 20))
        else
            echo "Status: WARNING - Firewall inactive"
        fi

    else
        echo "Status: WARNING - UFW not installed"
    fi

    # ------------------------------------------
    # 2. SSH Check
    # ------------------------------------------

    echo
    echo "[2] SSH Configuration:"

    if [ -f /etc/ssh/sshd_config ]; then

        echo "SSH configuration found."

        if grep -Eiq \
            "^[[:space:]]*PermitRootLogin[[:space:]]+yes" \
            /etc/ssh/sshd_config; then

            echo "Status: WARNING - Root login enabled"

        else

            echo "Status: PASS"
            score=$((score + 20))

        fi

    else

        echo "Status: PASS - SSH server not installed"
        score=$((score + 20))

    fi

    # ------------------------------------------
    # 3. Failed Login Check
    # ------------------------------------------

    echo
    echo "[3] Failed Login Attempts:"

    failed_logins=0

    if command -v journalctl &>/dev/null; then

        failed_logins=$(journalctl --no-pager 2>/dev/null |
            grep -Ei "failed password|authentication failure" |
            wc -l)

    fi

    if [ "$failed_logins" -eq 0 ]; then

        echo "Failed attempts: 0"
        echo "Status: PASS"
        score=$((score + 20))

    else

        echo "Failed attempts: $failed_logins"
        echo "Status: WARNING"

    fi

    # ------------------------------------------
    # 4. Open Ports Check
    # ------------------------------------------

    echo
    echo "[4] Listening Network Ports:"

    listening_ports=0

    if command -v ss &>/dev/null; then

        listening_ports=$(ss -tuln 2>/dev/null |
            grep -E "LISTEN|UNCONN" |
            wc -l)

    fi

    echo "Listening endpoints: $listening_ports"

    if [ "$listening_ports" -le 10 ]; then

        echo "Status: PASS"
        score=$((score + 20))

    else

        echo "Status: WARNING - Many open endpoints"

    fi

    # ------------------------------------------
    # 5. Sensitive File Permissions
    # ------------------------------------------

    echo
    echo "[5] Sensitive File Permissions:"

    if [ -f /etc/shadow ]; then

        shadow_permissions=$(stat -c "%a" /etc/shadow 2>/dev/null)

        echo "/etc/shadow permissions: $shadow_permissions"

        if [ "$shadow_permissions" -le 640 ]; then

            echo "Status: PASS"
            score=$((score + 20))

        else

            echo "Status: WARNING"

        fi

    else

        echo "Status: Unable to check /etc/shadow"

    fi

    # ------------------------------------------
    # Final Security Score
    # ------------------------------------------

    echo
    echo "=========================================="
    echo "          SECURITY SCORE"
    echo "=========================================="
    echo

    echo "Security Score: $score/100"

    if [ "$score" -ge 80 ]; then

        security_status="GOOD"

    elif [ "$score" -ge 60 ]; then

        security_status="WARNING"

    else

        security_status="CRITICAL"

    fi

    echo "Security Status: $security_status"

    log_security_event \
        "Security summary generated: score=$score/100 status=$security_status"

    echo
    echo "=========================================="
}

# ==========================================
# Main Security Menu
# ==========================================

while true; do

    clear

    echo "=========================================="
    echo "            SECURITY CHECK"
    echo "=========================================="
    echo

    echo "1. Check Firewall Status"
    echo "2. Check SSH Configuration"
    echo "3. Check Failed Login Attempts"
    echo "4. Check Open Ports"
    echo "5. Check Users with Sudo Access"
    echo "6. Check Sensitive File Permissions"
    echo "7. Security Summary"
    echo "8. Back to Main Menu"

    echo

    read -p "Enter your choice: " choice

    case "$choice" in

        1)
            check_firewall
            read -p "Press Enter to continue..."
            ;;

        2)
            check_ssh
            read -p "Press Enter to continue..."
            ;;

        3)
            check_failed_logins
            read -p "Press Enter to continue..."
            ;;

        4)
            check_ports
            read -p "Press Enter to continue..."
            ;;

        5)
            check_sudo_users
            read -p "Press Enter to continue..."
            ;;

        6)
            check_sensitive_permissions
            read -p "Press Enter to continue..."
            ;;

        7)
            security_summary
            read -p "Press Enter to continue..."
            ;;

        8)
            break
            ;;

        *)
            echo "Invalid option."
            sleep 2
            ;;

    esac

done
