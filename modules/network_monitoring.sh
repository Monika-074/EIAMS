#!/bin/bash

# ==========================================
# EIAMS - Network Monitoring Module
# ==========================================

show_interfaces() {

    echo
    echo "=========================================="
    echo "          NETWORK INTERFACES"
    echo "=========================================="
    echo

    ip -br addr

    echo
}

show_gateway() {

    echo
    echo "=========================================="
    echo "           DEFAULT GATEWAY"
    echo "=========================================="
    echo

    ip route | grep "^default" || echo "Default gateway not found."

    echo
}

show_routes() {

    echo
    echo "=========================================="
    echo "             ROUTING TABLE"
    echo "=========================================="
    echo

    ip route

    echo
}

show_dns() {

    echo
    echo "=========================================="
    echo "           DNS CONFIGURATION"
    echo "=========================================="
    echo

    if [ -f /etc/resolv.conf ]; then
        grep -E "^[[:space:]]*(nameserver|search|domain)" /etc/resolv.conf \
            || echo "No DNS configuration found."
    else
        echo "/etc/resolv.conf not found."
    fi

    echo
}

show_listening_ports() {

    echo
    echo "=========================================="
    echo "           LISTENING PORTS"
    echo "=========================================="
    echo

    if command -v ss &>/dev/null; then
        ss -tuln
    else
        echo "ss command is not available."
    fi

    echo
}

show_connections() {

    echo
    echo "=========================================="
    echo "          ACTIVE CONNECTIONS"
    echo "=========================================="
    echo

    if command -v ss &>/dev/null; then
        ss -tun
    else
        echo "ss command is not available."
    fi

    echo
}

test_connectivity() {

    echo
    echo "=========================================="
    echo "        NETWORK CONNECTIVITY TEST"
    echo "=========================================="
    echo

    read -p "Enter host to test [8.8.8.8]: " host

    if [ -z "$host" ]; then
        host="8.8.8.8"
    fi

    echo
    echo "Testing connectivity to: $host"
    echo "------------------------------------------"

    if ping -c 3 -W 2 "$host" &>/dev/null; then
        echo "Status: CONNECTIVITY OK"
    else
        echo "Status: CONNECTIVITY FAILED"
    fi

    echo
}

show_network_statistics() {

    echo
    echo "=========================================="
    echo "          NETWORK STATISTICS"
    echo "=========================================="
    echo

    if command -v ip &>/dev/null; then

        echo "Interface Statistics:"
        echo

        ip -s link

    else
        echo "ip command is not available."
    fi

    echo
}

network_summary() {

    echo
    echo "=========================================="
    echo "          NETWORK SUMMARY"
    echo "=========================================="
    echo

    echo "Hostname:"
    hostname

    echo
    echo "Interfaces:"
    ip -br addr

    echo
    echo "Default Gateway:"
    ip route | grep "^default" || echo "Not found"

    echo
    echo "DNS Servers:"
    grep -E "^[[:space:]]*nameserver" /etc/resolv.conf \
        2>/dev/null || echo "Not found"

    echo
    echo "Listening TCP/UDP Endpoints:"
    ss -tuln 2>/dev/null | tail -n +2 | wc -l

    echo
    echo "Network Connectivity:"

    if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        echo "ONLINE"
    else
        echo "OFFLINE"
    fi

    echo
    echo "=========================================="
}

# ==========================================
# Network Monitoring Menu
# ==========================================

while true; do

    clear

    echo "=========================================="
    echo "       EIAMS NETWORK MONITORING"
    echo "=========================================="
    echo
    echo "1. Show Network Interfaces"
    echo "2. Show Default Gateway"
    echo "3. Show Routing Table"
    echo "4. Show DNS Configuration"
    echo "5. Show Listening Ports"
    echo "6. Show Active Connections"
    echo "7. Test Network Connectivity"
    echo "8. Show Network Statistics"
    echo "9. Network Summary"
    echo "10. Back to Main Menu"
    echo

    read -p "Enter your choice: " choice

    case "$choice" in

        1)
            show_interfaces
            read -p "Press Enter to continue..."
            ;;

        2)
            show_gateway
            read -p "Press Enter to continue..."
            ;;

        3)
            show_routes
            read -p "Press Enter to continue..."
            ;;

        4)
            show_dns
            read -p "Press Enter to continue..."
            ;;

        5)
            show_listening_ports
            read -p "Press Enter to continue..."
            ;;

        6)
            show_connections
            read -p "Press Enter to continue..."
            ;;

        7)
            test_connectivity
            read -p "Press Enter to continue..."
            ;;

        8)
            show_network_statistics
            read -p "Press Enter to continue..."
            ;;

        9)
            network_summary
            read -p "Press Enter to continue..."
            ;;

        10)
            break
            ;;

        *)
            echo
            echo "Invalid option."
            sleep 2
            ;;

    esac

done
