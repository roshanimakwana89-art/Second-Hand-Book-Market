
#!/bin/bash

BOOKS_FILE="data/books.csv"
LOG_FILE="logs/activity.log"

# Activity Log
log_activity() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Display All Books
view_books() {
    echo ""
    echo "=============================================================="
    echo "                         ALL BOOKS"
    echo "=============================================================="

    printf "%-5s %-25s %-15s %-10s %-12s %-12s\n" \
    "ID" "TITLE" "SUBJECT" "PRICE" "SELLER" "STATUS"

    echo "--------------------------------------------------------------"

    awk -F, 'NR>1 {
        printf "%-5s %-25s %-15s Rs.%-7s %-12s %-12s\n",
        $1,$2,$3,$4,$5,$6
    }' "$BOOKS_FILE"

    echo "=============================================================="
    log_activity "All books viewed"
}

# List a New Book
list_book() {
    echo ""
    echo "---------- ADD NEW BOOK ----------"

    read -p "Enter book title: " title
    read -p "Enter subject: " subject
    read -p "Enter price: " price
    read -p "Enter seller name: " seller

    if [[ -z "$title" || -z "$subject" || ! "$price" =~ ^[0-9]+$ || -z "$seller" ]]; then
        echo "Invalid input! Please enter all details correctly."
        return
    fi

    if [[ "$title" == *","* || "$subject" == *","* || "$seller" == *","* ]]; then
        echo "Comma is not allowed in book details."
        return
    fi

    id=$(awk -F, 'NR>1 && $1>max {max=$1} END {print max+1}' "$BOOKS_FILE")

    echo "$id,$title,$subject,$price,$seller,available" >> "$BOOKS_FILE"

    echo "----------------------------------"
    echo "Book added successfully!"
    echo "New Book ID: $id"
    echo "----------------------------------"

    log_activity "New book added: $title"
}

# Search Books by ID or Book Name
search_books() {
    echo ""
    echo "=========================================="
    echo "              SEARCH BOOKS"
    echo "=========================================="
    echo "1. Search by Book ID"
    echo "2. Search by Book Name"
    echo "=========================================="

    read -p "Enter your choice: " choice

    case $choice in
        1)
            read -p "Enter Book ID: " keyword

            if [[ ! "$keyword" =~ ^[0-9]+$ ]]; then
                echo "Please enter a valid numeric ID."
                return
            fi

            result=$(awk -F, -v id="$keyword" '
            NR>1 && $1==id {print}
            ' "$BOOKS_FILE")
            ;;

        2)
            read -p "Enter Book Name: " keyword

            if [[ -z "$keyword" ]]; then
                echo "Book name cannot be empty."
                return
            fi

            result=$(awk -F, -v key="$keyword" '
            NR>1 && index(tolower($2),tolower(key))>0 {print}
            ' "$BOOKS_FILE")
            ;;

        *)
            echo "Invalid choice!"
            return
            ;;
    esac

    echo ""
    echo "================ SEARCH RESULT ================"

    if [[ -n "$result" ]]; then
        printf "%-5s %-25s %-15s %-10s %-12s %-12s\n" \
        "ID" "BOOK NAME" "SUBJECT" "PRICE" "SELLER" "STATUS"

        echo "--------------------------------------------------------------"

        while IFS=, read -r id title subject price seller status
        do
            printf "%-5s %-25s %-15s Rs.%-7s %-12s %-12s\n" \
            "$id" "$title" "$subject" "$price" "$seller" "$status"
        done <<< "$result"
    else
        echo "No matching book found!"
    fi

    echo "=============================================================="
    log_activity "Book search performed: $keyword"
}

# Mark a Book as Sold
mark_sold() {
    echo ""
    echo "---------- MARK BOOK AS SOLD ----------"

    read -p "Enter book ID: " id

    if [[ ! "$id" =~ ^[0-9]+$ ]]; then
        echo "Please enter a valid numeric ID."
        return
    fi

    if grep -q "^$id,.*available$" "$BOOKS_FILE"; then
        sed -i "/^$id,/s/,available$/,sold/" "$BOOKS_FILE"

        echo "Book marked as sold successfully!"
        log_activity "Book ID $id marked as sold"
    else
        echo "Book not found or already sold."
    fi
}

# Show Earnings Per Seller
seller_earnings() {
    echo ""
    echo "================================================"
    echo "                 SELLER EARNINGS"
    echo "================================================"

    printf "%-20s %s\n" "SELLER" "TOTAL EARNINGS"
    echo "------------------------------------------------"

    awk -F, 'NR>1 && $6=="sold" {
        earnings[$5]+=$4
    }
    END {
        for (seller in earnings)
            printf "%-20s Rs. %d\n",seller,earnings[seller]
    }' "$BOOKS_FILE"

    log_activity "Seller earnings viewed"
}

# Show Five Cheapest Available Books
cheapest_books() {
    echo ""
    echo "=============================================================="
    echo "                 TOP 5 CHEAPEST BOOKS"
    echo "=============================================================="

    printf "%-5s %-25s %-15s %-10s %-12s\n" \
    "ID" "BOOK TITLE" "SUBJECT" "PRICE" "SELLER"

    echo "--------------------------------------------------------------"

    awk -F, 'NR>1 && $6=="available" {
        print $1 "," $2 "," $3 "," $4 "," $5
    }' "$BOOKS_FILE" |
    sort -t, -k4,4n |
    head -n 5 |
    while IFS=, read -r id title subject price seller
    do
        printf "%-5s %-25s %-15s Rs.%-7s %-12s\n" \
        "$id" "$title" "$subject" "$price" "$seller"
    done

    echo "=============================================================="
    log_activity "Cheapest books viewed"
}

# Create Backup
backup_books() {
    backup_file="backups/books_backup_$(date +%Y%m%d_%H%M%S).tar.gz"

    if tar -czf "$backup_file" "$BOOKS_FILE"; then
        echo ""
        echo "Backup created successfully!"
        echo "Backup file: $backup_file"
        log_activity "Books backup created"
    else
        echo "Backup creation failed!"
    fi
}
