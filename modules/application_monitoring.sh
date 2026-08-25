#!/bin/bash

# ==========================================
# EIAMS - Application Monitoring Module
# ==========================================

# ==========================================
# Check Service Status
# ==========================================

check_service() {

    local service="$1"

    echo
    echo "------------------------------------------"
    echo "Service: $service"
    echo "------------------------------------------"

    if command -v systemctl &>/dev/null; then

        if systemctl is-active --quiet "$service" 2>/dev/null; then
            echo "Status: RUNNING"
        elif systemctl is-enabled --quiet "$service" 2>/dev/null; then
            echo "Status: STOPPED"
        else
            echo "Status: NOT INSTALLED / NOT ENABLED"
        fi

    else
        echo "systemctl is not available."
    fi
}

# ==========================================
# Application Service Monitoring
# ==========================================

monitor_services() {

    clear

    echo "=========================================="
    echo "       APPLICATION SERVICE MONITORING"
    echo "=========================================="

    check_service "nginx"
    check_service "docker"
    check_service "ssh"
    check_service "cron"

    echo
}

# ==========================================
# Check Docker
# ==========================================

check_docker() {

    clear

    echo "=========================================="
    echo "             DOCKER MONITORING"
    echo "=========================================="
    echo

    if command -v docker &>/dev/null; then

        echo "Docker Version:"
        docker --version

        echo
        echo "Docker Service:"

        if systemctl is-active --quiet docker 2>/dev/null; then
            echo "Status: RUNNING"
        else
            echo "Status: NOT RUNNING"
        fi

        echo
        echo "Running Containers:"
        docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}" 2>/dev/null

    else

        echo "Docker is not installed."

    fi

    echo
}

# ==========================================
# Check Nginx
# ==========================================

check_nginx() {

    clear

    echo "=========================================="
    echo "             NGINX MONITORING"
    echo "=========================================="
    echo

    if command -v nginx &>/dev/null; then

        echo "Nginx Version:"
        nginx -v 2>&1

        echo
        echo "Nginx Service:"

        if systemctl is-active --quiet nginx 2>/dev/null; then
            echo "Status: RUNNING"
        else
            echo "Status: NOT RUNNING"
        fi

        echo
        echo "Configuration Test:"

        if sudo nginx -t 2>&1; then
            echo "Configuration: VALID"
        else
            echo "Configuration: INVALID"
        fi

    else

        echo "Nginx is not installed."

    fi

    echo
}

# ==========================================
# Check Application Ports
# ==========================================

check_application_ports() {

    clear

    echo "=========================================="
    echo "          APPLICATION PORTS"
    echo "=========================================="
    echo

    if command -v ss &>/dev/null; then

        echo "Listening TCP/UDP endpoints:"
        echo

        ss -tuln

    else

        echo "ss command is not available."

    fi

    echo
}

# ==========================================
# Check Application Processes
# ==========================================

check_application_processes() {

    clear

    echo "=========================================="
    echo "        APPLICATION PROCESSES"
    echo "=========================================="
    echo

    echo "Docker:"
    pgrep -af "dockerd" 2>/dev/null || echo "Docker daemon not running."

    echo
    echo "Nginx:"
    pgrep -af "nginx" 2>/dev/null || echo "Nginx process not running."

    echo
    echo "SSH:"
    pgrep -af "sshd" 2>/dev/null || echo "SSH daemon not running."

    echo
}

# ==========================================
# HTTP Connectivity Test
# ==========================================

http_test() {

    clear

    echo "=========================================="
    echo "          APPLICATION HTTP TEST"
    echo "=========================================="
    echo

    read -p "Enter URL [http://localhost]: " url

    if [ -z "$url" ]; then
        url="http://localhost"
    fi

    echo
    echo "Testing:"
    echo "$url"
    echo "------------------------------------------"

    if command -v curl &>/dev/null; then

        http_status=$(curl -L -o /dev/null -s -w "%{http_code}" --max-time 5 "$url")

        if [[ "$http_status" =~ ^[0-9]+$ ]] && [ "$http_status" -ge 200 ] && [ "$http_status" -lt 500 ]; then
            echo "HTTP Status: $http_status"
            echo "Status: APPLICATION REACHABLE"
        else
            echo "HTTP Status: $http_status"
            echo "Status: APPLICATION UNREACHABLE"
        fi

    else

        echo "curl is not installed."

    fi

    echo
}

# ==========================================
# Application Summary
# ==========================================

application_summary() {

    clear

    echo "=========================================="
    echo "       APPLICATION MONITORING SUMMARY"
    echo "=========================================="
    echo

    running_services=0
    total_services=4

    for service in nginx docker ssh cron; do

        if systemctl is-active --quiet "$service" 2>/dev/null; then
            echo "$service: RUNNING"
            running_services=$((running_services + 1))
        else
            echo "$service: NOT RUNNING"
        fi

    done

    echo
    echo "------------------------------------------"
    echo "Services Running: $running_services/$total_services"
    echo "------------------------------------------"

    if [ "$running_services" -ge 2 ]; then
        echo "Application Environment: HEALTHY"
    elif [ "$running_services" -eq 1 ]; then
        echo "Application Environment: WARNING"
    else
        echo "Application Environment: CRITICAL"
    fi

    echo
    echo "Running Docker Containers:"

    if command -v docker &>/dev/null; then
        docker ps -q 2>/dev/null | wc -l
    else
        echo "Docker not installed."
    fi

    echo
    echo "Listening Endpoints:"

    ss -tuln 2>/dev/null | grep -E "LISTEN|UNCONN" | wc -l

    echo
    echo "=========================================="
}

# ==========================================
# Main Menu
# ==========================================

while true; do

    clear

    echo "=========================================="
    echo "       EIAMS APPLICATION MONITORING"
    echo "=========================================="
    echo
    echo "1. Monitor Application Services"
    echo "2. Docker Monitoring"
    echo "3. Nginx Monitoring"
    echo "4. Application Ports"
    echo "5. Application Processes"
    echo "6. HTTP Connectivity Test"
    echo "7. Application Summary"
    echo "8. Back to Main Menu"
    echo

    read -p "Enter your choice: " choice

    case "$choice" in

        1)
            monitor_services
            read -p "Press Enter to continue..."
            ;;

        2)
            check_docker
            read -p "Press Enter to continue..."
            ;;

        3)
            check_nginx
            read -p "Press Enter to continue..."
            ;;

        4)
            check_application_ports
            read -p "Press Enter to continue..."
            ;;

        5)
            check_application_processes
            read -p "Press Enter to continue..."
            ;;

        6)
            http_test
            read -p "Press Enter to continue..."
            ;;

        7)
            application_summary
            read -p "Press Enter to continue..."
            ;;

        8)
            break
            ;;

        *)
            echo
            echo "Invalid option."
            sleep 2
            ;;

    esac

done
