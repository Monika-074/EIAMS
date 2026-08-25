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
    echo "7. Backup Management"
    echo "8. System Information"
    echo "9. Automation Management"
    echo "10. Configuration Management"
    echo "11. Process Management"
    echo "12. Exit"
    echo

    read -p "Enter your choice: " choice

    case "$choice" in

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
            ./modules/backup_management.sh
            ;;

        8)
            ./modules/system_info.sh
            ;;

        9)
            ./modules/automation_management.sh
            ;;

        10)
            ./modules/config_management.sh
            ;;

        11)
            ./modules/process_management.sh
            ;;

        12)
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
