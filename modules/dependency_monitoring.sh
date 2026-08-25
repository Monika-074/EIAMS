#!/bin/bash

# ==========================================
# EIAMS - Service Dependency Monitoring
# ==========================================

check_service() {

    local service="$1"

    if systemctl is-active --quiet "$service"; then
        echo "RUNNING"
    else
        echo "NOT RUNNING"
    fi
}

check_dependency() {

    local service="$1"
    local dependency="$2"

    service_status=$(check_service "$service")
    dependency_status=$(check_service "$dependency")

    echo
    echo "Service:"
    echo "  $service"
    echo "  Status: $service_status"

    echo
    echo "Dependency:"
    echo "  $dependency"
    echo "  Status: $dependency_status"

    if [ "$service_status" = "RUNNING" ] &&
       [ "$dependency_status" = "RUNNING" ]; then

        echo
        echo "Result: HEALTHY"

        return 0

    elif [ "$service_status" = "RUNNING" ]; then

        echo
        echo "Result: WARNING"

        return 1

    else

        echo
        echo "Result: CRITICAL"

        return 2

    fi
}

show_dependency_monitoring() {

    clear

    echo "=========================================="
    echo "     SERVICE DEPENDENCY MONITORING"
    echo "=========================================="
    echo

    healthy=0
    warning=0
    critical=0

    # ==========================================
    # Docker -> containerd
    # ==========================================

    echo "------------------------------------------"
    echo "DOCKER DEPENDENCY"
    echo "------------------------------------------"

    check_dependency docker.service containerd.service

    result=$?

    case "$result" in
        0) ((healthy++)) ;;
        1) ((warning++)) ;;
        2) ((critical++)) ;;
    esac

    # ==========================================
    # Network -> systemd-resolved
    # ==========================================

    echo
    echo "------------------------------------------"
    echo "NETWORK DEPENDENCY"
    echo "------------------------------------------"

    check_dependency systemd-resolved.service systemd-timesyncd.service

    result=$?

    case "$result" in
        0) ((healthy++)) ;;
        1) ((warning++)) ;;
        2) ((critical++)) ;;
    esac

    # ==========================================
    # Logging -> rsyslog
    # ==========================================

    echo
    echo "------------------------------------------"
    echo "LOGGING DEPENDENCY"
    echo "------------------------------------------"

    check_dependency rsyslog.service systemd-journald.service

    result=$?

    case "$result" in
        0) ((healthy++)) ;;
        1) ((warning++)) ;;
        2) ((critical++)) ;;
    esac

    # ==========================================
    # Dependency Summary
    # ==========================================

    echo
    echo "=========================================="
    echo "      DEPENDENCY HEALTH SUMMARY"
    echo "=========================================="
    echo

    echo "Healthy:     $healthy"
    echo "Warning:     $warning"
    echo "Critical:    $critical"

    echo

    if [ "$critical" -gt 0 ]; then

        echo "Overall Status: CRITICAL"

    elif [ "$warning" -gt 0 ]; then

        echo "Overall Status: WARNING"

    else

        echo "Overall Status: HEALTHY"

    fi

    echo
    echo "=========================================="
    echo "    DEPENDENCY MONITORING COMPLETE"
    echo "=========================================="
}

show_dependency_monitoring

read -p "Press Enter to return to the main menu..."
