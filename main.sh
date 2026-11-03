
#!/bin/bash

# Load functions
source lib/functions.sh

# Main menu loop
while true
do
    echo ""
    echo "========================================"
    echo "       SECOND-HAND BOOK MARKET"
    echo "========================================"
    echo "1. List a Book for Sale"
    echo "2. Search Books by Title or Subject"
    echo "3. Mark a Book as Sold"
    echo "4. Show Earnings per Seller"
    echo "5. Show 5 Cheapest Available Books"
    echo "6. View All Books"
    echo "7. Create Backup"
    echo "8. View Activity Log"
    echo "0. Exit"
    echo "========================================"

    read -p "Enter your choice: " choice

    case $choice in

        1)
            list_book
            ;;

        2)
            search_books
            ;;

        3)
            mark_sold
            ;;

        4)
            seller_earnings
            ;;

        5)
            cheapest_books
            ;;

        6)
            view_books
            ;;

        7)
            backup_books
            ;;

        8)
            echo "------ ACTIVITY LOG ------"
            if [ -f "$LOG_FILE" ]; then
                cat "$LOG_FILE"
            else
                echo "No activity found."
            fi
            ;;

        0)
            echo "Thank you for using Second-Hand Book Market!"
            echo "Program ended."
            break
            ;;

        *)
            echo "Invalid choice! Please enter a number from 0 to 8."
            ;;

    esac

done
