#!/bin/bash

# ==========================================
# EIAMS - Security Check Module
# ==========================================

check_firewall() {
    echo
    echo "========== FIREWALL STATUS =========="

    if command -v ufw &>/dev/null; then

        firewall_status=$(sudo ufw status | head -1)

        echo "$firewall_status"

        if echo "$firewall_status" | grep -qi "active"; then
            echo "Security Status: PROTECTED"
        else
            echo "Security Status: WARNING - Firewall inactive"
        fi

    else
        echo "Status: NOT INSTALLED"
        echo "Security Status: WARNING"
    fi

    echo
}

check_ssh() {
    echo
    echo "========== SSH CONFIGURATION =========="

    if [ -f /etc/ssh/sshd_config ]; then

        echo "SSH server configuration found."

        echo
        echo "PermitRootLogin:"
        grep -Ei "^[[:space:]]*PermitRootLogin" \
            /etc/ssh/sshd_config || \
            echo "Not explicitly configured"

        echo
        echo "PasswordAuthentication:"
        grep -Ei "^[[:space:]]*PasswordAuthentication" \
            /etc/ssh/sshd_config || \
            echo "Not explicitly configured"

    else
        echo "Status: NOT INSTALLED"
    fi

    echo
}

check_failed_logins() {
    echo
    echo "========== FAILED LOGIN ATTEMPTS =========="

    failed_logins=0

    if command -v journalctl &>/dev/null; then

        failed_logins=$(journalctl --no-pager 2>/dev/null | \
            grep -Ei "failed password|authentication failure" | \
            wc -l)

    fi

    echo "Failed login attempts: $failed_logins"

    if [ "$failed_logins" -eq 0 ]; then
        echo "Security Status: GOOD"
    elif [ "$failed_logins" -le 5 ]; then
        echo "Security Status: WARNING"
    else
        echo "Security Status: CRITICAL"
    fi

    echo
}

check_ports() {
    echo
    echo "========== OPEN NETWORK PORTS =========="

    if command -v ss &>/dev/null; then
        ss -tuln
    else
        echo "ss command is not available."
    fi

    echo
}

check_sudo_users() {
    echo
    echo "========== USERS WITH SUDO ACCESS =========="

    if getent group sudo &>/dev/null; then
        getent group sudo
    else
        echo "sudo group not found."
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

    echo
}

security_summary() {

    echo
    echo "=========================================="
    echo "          EIAMS SECURITY SUMMARY"
    echo "=========================================="

    score=0

    # ==========================================
    # 1. Firewall
    # ==========================================

    echo
    echo "[1] Firewall"

    if command -v ufw &>/dev/null; then

        firewall_status=$(sudo ufw status | head -1)

        if echo "$firewall_status" | grep -qi "active"; then

            echo "Status: ACTIVE"
            echo "Risk: LOW"

            score=$((score + 20))

        else

            echo "Status: INACTIVE"
            echo "Risk: HIGH"

        fi

    else

        echo "Status: NOT INSTALLED"
        echo "Risk: MEDIUM"

    fi

    # ==========================================
    # 2. SSH
    # ==========================================

    echo
    echo "[2] SSH Server"

    if [ -f /etc/ssh/sshd_config ]; then

        echo "Status: INSTALLED"

        if grep -Eiq \
            "^[[:space:]]*PermitRootLogin[[:space:]]+yes" \
            /etc/ssh/sshd_config; then

            echo "Root Login: ENABLED"
            echo "Risk: HIGH"

        else

            echo "Root Login: NOT ENABLED"
            echo "Risk: LOW"

            score=$((score + 20))

        fi

    else

        echo "Status: NOT INSTALLED"
        echo "Risk: LOW"

        score=$((score + 20))

    fi

    # ==========================================
    # 3. Failed Login Attempts
    # ==========================================

    echo
    echo "[3] Failed Login Attempts"

    failed_logins=0

    if command -v journalctl &>/dev/null; then

        failed_logins=$(journalctl --no-pager 2>/dev/null | \
            grep -Ei "failed password|authentication failure" | \
            wc -l)

    fi

    echo "Detected Attempts: $failed_logins"

    if [ "$failed_logins" -eq 0 ]; then

        echo "Risk: LOW"
        score=$((score + 20))

    elif [ "$failed_logins" -le 5 ]; then

        echo "Risk: MEDIUM"

    else

        echo "Risk: HIGH"

    fi

    # ==========================================
    # 4. Network Ports
    # ==========================================

    echo
    echo "[4] Network Ports"

    if command -v ss &>/dev/null; then

        listening_ports=$(ss -tuln 2>/dev/null | \
            grep -E "LISTEN|UNCONN" | \
            wc -l)

    else

        listening_ports=0

    fi

    echo "Open Endpoints: $listening_ports"

    if [ "$listening_ports" -le 10 ]; then

        echo "Risk: LOW"
        score=$((score + 20))

    elif [ "$listening_ports" -le 20 ]; then

        echo "Risk: MEDIUM"

    else

        echo "Risk: HIGH"

    fi

    # ==========================================
    # 5. Sensitive Files
    # ==========================================

    echo
    echo "[5] Sensitive File Permissions"

    if [ -f /etc/shadow ]; then

        shadow_permissions=$(stat -c "%a" /etc/shadow 2>/dev/null)

        echo "/etc/shadow: $shadow_permissions"

        if [ "$shadow_permissions" -le 640 ]; then

            echo "Risk: LOW"
            score=$((score + 20))

        else

            echo "Risk: HIGH"

        fi

    else

        echo "Status: UNABLE TO CHECK"
        echo "Risk: UNKNOWN"

    fi

    # ==========================================
    # Security Score
    # ==========================================

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

    echo
    echo "=========================================="
}

# ==========================================
# SECURITY MENU
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
