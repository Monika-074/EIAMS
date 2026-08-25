#!/bin/bash

# ==========================================
# Enterprise Infrastructure Automation
# & Monitoring System (EIAMS)
# ==========================================

while true; do

    clear

    echo "=========================================="
    echo " Enterprise Infrastructure Automation"
    echo "        & Monitoring System"
    echo "=========================================="
    echo
    echo "1. User Management"
    echo "2. Service Management"
    echo "3. System Monitoring"
    echo "4. Security Check"
    echo "5. Infrastructure Health Report"
    echo "6. Log Management"
    echo "7. Exit"
    echo

    read -p "Enter your choice: " choice

    case $choice in

        1)
            ./modules/user_management.sh
            ;;

        2)
            ./modules/service_management.sh
            ;;

        3)
            ./modules/system_monitoring.sh
            read -p "Press Enter to return to the main menu..."
            ;;

        4)
            ./modules/security_check.sh
            ;;

        5)
            ./modules/health_report.sh
            read -p "Press Enter to return to the main menu..."
            ;;

        6)
            ./modules/log_management.sh
            ;;

        7)
            echo
            echo "Exiting EIAMS..."
            exit 0
            ;;

        *)
            echo
            echo "Invalid option. Please try again."
            sleep 2
            ;;

    esac

done
