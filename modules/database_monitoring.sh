#!/bin/bash

# ==========================================
# EIAMS - Database Monitoring Module
# ==========================================

show_database_services() {

    echo
    echo "=========================================="
    echo "        DATABASE SERVICES"
    echo "=========================================="
    echo

    echo "Checking common database services..."
    echo

    databases=("mysql" "mariadb" "postgresql" "mongod" "redis-server")

    found=0

    for db in "${databases[@]}"; do

        if systemctl list-unit-files 2>/dev/null | grep -q "^${db}.service"; then

            found=1

            if systemctl is-active --quiet "$db" 2>/dev/null; then
                echo "$db : RUNNING"
            else
                echo "$db : INSTALLED / NOT RUNNING"
            fi

        fi

    done

    if [ "$found" -eq 0 ]; then
        echo "No supported database services detected."
    fi

    echo
}

show_database_processes() {

    echo
    echo "=========================================="
    echo "        DATABASE PROCESSES"
    echo "=========================================="
    echo

    echo "Checking running database processes..."
    echo

    ps aux | grep -E \
        "[m]ysqld|[m]ariadbd|[p]ostgres|[m]ongod|[r]edis-server"

    if ! ps aux | grep -Eq \
        "[m]ysqld|[m]ariadbd|[p]ostgres|[m]ongod|[r]edis-server"; then

        echo "No database processes currently running."

    fi

    echo
}

show_database_ports() {

    echo
    echo "=========================================="
    echo "         DATABASE PORTS"
    echo "=========================================="
    echo

    echo "Common database listening ports:"
    echo

    ss -tuln 2>/dev/null | grep -E \
        ":3306|:5432|:27017|:6379"

    if ! ss -tuln 2>/dev/null | grep -Eq \
        ":3306|:5432|:27017|:6379"; then

        echo "No common database ports detected."

    fi

    echo
}

test_database_ports() {

    echo
    echo "=========================================="
    echo "       DATABASE PORT TEST"
    echo "=========================================="
    echo

    read -p "Enter database host [localhost]: " host

    if [ -z "$host" ]; then
        host="localhost"
    fi

    read -p "Enter database port: " port

    if [ -z "$port" ]; then
        echo
        echo "Port cannot be empty."
        return
    fi

    echo
    echo "Testing: $host:$port"
    echo "------------------------------------------"

    if timeout 3 bash -c \
        "</dev/tcp/$host/$port" 2>/dev/null; then

        echo "Status: DATABASE PORT OPEN"

    else

        echo "Status: DATABASE PORT CLOSED / UNREACHABLE"

    fi

    echo
}

database_summary() {

    echo
    echo "=========================================="
    echo "        DATABASE MONITORING SUMMARY"
    echo "=========================================="
    echo

    echo "Database Services:"
    echo "------------------------------------------"

    databases=("mysql" "mariadb" "postgresql" "mongod" "redis-server")

    database_found=0
    database_running=0

    for db in "${databases[@]}"; do

        if systemctl list-unit-files 2>/dev/null | grep -q "^${db}.service"; then

            database_found=$((database_found + 1))

            if systemctl is-active --quiet "$db" 2>/dev/null; then
                echo "$db : RUNNING"
                database_running=$((database_running + 1))
            else
                echo "$db : NOT RUNNING"
            fi

        fi

    done

    if [ "$database_found" -eq 0 ]; then
        echo "No supported database services detected."
    fi

    echo
    echo "Database Processes:"
    echo "------------------------------------------"

    process_count=$(ps aux | grep -E \
        "[m]ysqld|[m]ariadbd|[p]ostgres|[m]ongod|[r]edis-server" | wc -l)

    echo "Running database processes: $process_count"

    echo
    echo "Database Ports:"
    echo "------------------------------------------"

    port_count=$(ss -tuln 2>/dev/null | grep -E \
        ":3306|:5432|:27017|:6379" | wc -l)

    echo "Open database endpoints: $port_count"

    echo
    echo "Overall Database Status:"
    echo "------------------------------------------"

    if [ "$database_running" -gt 0 ] || [ "$process_count" -gt 0 ]; then
        echo "Status: DATABASE SERVICE ACTIVE"
    elif [ "$database_found" -gt 0 ]; then
        echo "Status: DATABASE INSTALLED BUT NOT RUNNING"
    else
        echo "Status: NO DATABASE SERVICE DETECTED"
    fi

    echo
    echo "=========================================="
}

while true; do

    clear

    echo "=========================================="
    echo "       EIAMS DATABASE MONITORING"
    echo "=========================================="
    echo
    echo "1. Database Services"
    echo "2. Database Processes"
    echo "3. Database Ports"
    echo "4. Test Database Port"
    echo "5. Database Summary"
    echo "6. Back to Main Menu"
    echo

    read -p "Enter your choice: " choice

    case "$choice" in

        1)
            show_database_services
            read -p "Press Enter to continue..."
            ;;

        2)
            show_database_processes
            read -p "Press Enter to continue..."
            ;;

        3)
            show_database_ports
            read -p "Press Enter to continue..."
            ;;

        4)
            test_database_ports
            read -p "Press Enter to continue..."
            ;;

        5)
            database_summary
            read -p "Press Enter to continue..."
            ;;

        6)
            break
            ;;

        *)
            echo
            echo "Invalid option."
            sleep 2
            ;;

    esac

done
