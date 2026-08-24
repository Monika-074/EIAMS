#!/bin/bash

# ==========================================
# EIAMS - Service Management Module
# ==========================================

list_services() {
    echo
    echo "========== RUNNING SERVICES =========="
    systemctl list-units --type=service --state=running --no-pager
    echo
}

check_service() {
    read -p "Enter service name: " service

    echo
    echo "========== SERVICE STATUS =========="

    if systemctl list-unit-files | grep -q "^${service}.service"; then
        systemctl status "$service" --no-pager
    else
        echo "Service '$service' was not found."
    fi

    echo
}

start_service() {
    read -p "Enter service name to start: " service

    if systemctl list-unit-files | grep -q "^${service}.service"; then
        sudo systemctl start "$service"

        if [ $? -eq 0 ]; then
            echo "Service '$service' started successfully."
        else
            echo "Failed to start '$service'."
        fi
    else
        echo "Service '$service' was not found."
    fi
}

stop_service() {
    read -p "Enter service name to stop: " service

    if systemctl list-unit-files | grep -q "^${service}.service"; then
        sudo systemctl stop "$service"

        if [ $? -eq 0 ]; then
            echo "Service '$service' stopped successfully."
        else
            echo "Failed to stop '$service'."
        fi
    else
        echo "Service '$service' was not found."
    fi
}

restart_service() {
    read -p "Enter service name to restart: " service

    if systemctl list-unit-files | grep -q "^${service}.service"; then
        sudo systemctl restart "$service"

        if [ $? -eq 0 ]; then
            echo "Service '$service' restarted successfully."
        else
            echo "Failed to restart '$service'."
        fi
    else
        echo "Service '$service' was not found."
    fi
}

while true; do

    clear

    echo "=========================================="
    echo "          SERVICE MANAGEMENT"
    echo "=========================================="
    echo
    echo "1. List Running Services"
    echo "2. Check Service Status"
    echo "3. Start Service"
    echo "4. Stop Service"
    echo "5. Restart Service"
    echo "6. Back to Main Menu"
    echo

    read -p "Enter your choice: " choice

    case $choice in

        1)
            list_services
            read -p "Press Enter to continue..."
            ;;

        2)
            check_service
            read -p "Press Enter to continue..."
            ;;

        3)
            start_service
            read -p "Press Enter to continue..."
            ;;

        4)
            stop_service
            read -p "Press Enter to continue..."
            ;;

        5)
            restart_service
            read -p "Press Enter to continue..."
            ;;

        6)
            break
            ;;

        *)
            echo "Invalid option."
            sleep 2
            ;;

    esac

done

