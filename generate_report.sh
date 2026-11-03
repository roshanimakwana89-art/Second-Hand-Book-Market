#!/bin/bash

BOOKS_FILE="data/books.csv"
REPORT_FILE="reports/unsold_books_$(date +%Y%m%d).txt"

echo "====================================" > "$REPORT_FILE"
echo "       UNSOLD BOOKS REPORT" >> "$REPORT_FILE"
echo "====================================" >> "$REPORT_FILE"

awk -F, 'NR==1 || $6=="available"' "$BOOKS_FILE" >> "$REPORT_FILE"

echo "====================================" >> "$REPORT_FILE"
echo "Report generated on: $(date)" >> "$REPORT_FILE"

echo "Unsold books report generated successfully!"
echo "Report saved at: $REPORT_FILE"
