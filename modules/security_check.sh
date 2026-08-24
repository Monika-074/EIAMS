#!/bin/bash

# ==========================================
# EIAMS - Security Check Module
# ==========================================

check_firewall() {
    echo
    echo "========== FIREWALL STATUS =========="

    if command -v ufw &>/dev/null; then
        sudo ufw status verbose
    else
        echo "UFW is not installed."
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

    else
        echo "SSH server configuration not found."
    fi

    echo
}

check_failed_logins() {
    echo
    echo "========== FAILED LOGIN ATTEMPTS =========="

    if command -v journalctl &>/dev/null; then
        journalctl --no-pager | grep -Ei "failed password|authentication failure" | tail -10

        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            echo "No recent failed login records found."
        fi
    else
        echo "journalctl is not available."
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
    ls -l /etc/shadow 2>/dev/null || echo "Cannot access /etc/shadow"

    echo
}

security_summary() {
    echo
    echo "=========================================="
    echo "          SECURITY SUMMARY"
    echo "=========================================="

    echo
    echo "[1] Firewall:"
    if command -v ufw &>/dev/null; then
        sudo ufw status | head -1
    else
        echo "UFW not installed"
    fi

    echo
    echo "[2] Listening Ports:"
    ss -tuln | grep LISTEN | wc -l

    echo
    echo "[3] Sudo Group:"
    getent group sudo

    echo
    echo "[4] Shadow File Permissions:"
    ls -l /etc/shadow 2>/dev/null || echo "Access denied"

    echo
    echo "=========================================="
}

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

    case $choice in

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
