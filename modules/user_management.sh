#!/bin/bash

# ==========================================
# EIAMS - User Management Module
# ==========================================

show_users() {
    echo
    echo "========== SYSTEM USERS =========="
    cut -d: -f1 /etc/passwd
    echo
}

show_logged_users() {
    echo
    echo "========== LOGGED-IN USERS =========="
    who
    echo
}

show_user_details() {
    read -p "Enter username: " username

    if id "$username" &>/dev/null; then
        echo
        echo "========== USER DETAILS =========="
        id "$username"
        echo
        echo "Home Directory:"
        eval echo "~$username"
        echo
        echo "Login Shell:"
        getent passwd "$username" | cut -d: -f7
        echo
    else
        echo "User '$username' does not exist."
    fi
}

create_user() {
    read -p "Enter username to create: " username

    if id "$username" &>/dev/null; then
        echo "User '$username' already exists."
    else
        sudo useradd -m "$username"

        if [ $? -eq 0 ]; then
            echo "User '$username' created successfully."
            sudo passwd "$username"
        else
            echo "Failed to create user."
        fi
    fi
}

delete_user() {
    read -p "Enter username to delete: " username

    if id "$username" &>/dev/null; then
        sudo userdel -r "$username"

        if [ $? -eq 0 ]; then
            echo "User '$username' deleted successfully."
        else
            echo "Failed to delete user."
        fi
    else
        echo "User '$username' does not exist."
    fi
}

while true; do

    clear

    echo "=========================================="
    echo "           USER MANAGEMENT"
    echo "=========================================="
    echo
    echo "1. List System Users"
    echo "2. Show Logged-in Users"
    echo "3. Show User Details"
    echo "4. Create User"
    echo "5. Delete User"
    echo "6. Back to Main Menu"
    echo

    read -p "Enter your choice: " choice

    case $choice in

        1)
            show_users
            read -p "Press Enter to continue..."
            ;;

        2)
            show_logged_users
            read -p "Press Enter to continue..."
            ;;

        3)
            show_user_details
            read -p "Press Enter to continue..."
            ;;

        4)
            create_user
            read -p "Press Enter to continue..."
            ;;

        5)
            delete_user
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
