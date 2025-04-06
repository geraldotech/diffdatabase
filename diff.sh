#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <REFERENCE_SQL> <OUTDATED_SQL> <OUTPUT_SQL_FILE>"
  exit 1
fi

# Input files
REFERENCE_SQL=$1
OUTDATED_SQL=$2
OUTPUT_SCRIPT=$3  # Custom output file for CREATE TABLE statements

# Temporary files for table names
REFERENCE_TABLES="reference_tables.txt"
OUTDATED_TABLES="outdated_tables.txt"
DIFF_TABLES="diff_tables.txt"

# Step 1: Extract table names from CREATE TABLE statements in the reference and outdated SQL files
grep -i "CREATE TABLE" "$REFERENCE_SQL" | awk '{print $3}' | tr -d '`' | sort | uniq > "$REFERENCE_TABLES"
grep -i "CREATE TABLE" "$OUTDATED_SQL" | awk '{print $3}' | tr -d '`' | sort | uniq > "$OUTDATED_TABLES"

# Step 2: Find tables missing in the outdated database (only in the reference database)
comm -23 "$REFERENCE_TABLES" "$OUTDATED_TABLES" > "$DIFF_TABLES" # Tables in reference but not in outdated

# Step 3: Generate the output script for the missing tables
echo "-- Missing Tables from Outdated Database (to be added):" > "$OUTPUT_SCRIPT"
if [ -s "$DIFF_TABLES" ]; then
  cat "$DIFF_TABLES" >> "$OUTPUT_SCRIPT"
else
  echo "No tables are missing in the outdated database." >> "$OUTPUT_SCRIPT"
fi
echo "" >> "$OUTPUT_SCRIPT"

# Step 4: Generate CREATE TABLE statements for missing tables from the reference database
while read -r TABLE_NAME; do
  echo "Generating CREATE TABLE for: $TABLE_NAME"
  awk "/CREATE TABLE.*\`$TABLE_NAME\`/,/;/ {print}" "$REFERENCE_SQL" >> "$OUTPUT_SCRIPT"
  echo "" >> "$OUTPUT_SCRIPT"
done < "$DIFF_TABLES"

# Cleanup temporary files
rm -f "$REFERENCE_TABLES" "$OUTDATED_TABLES" "$DIFF_TABLES"

# Final output message
echo "SQL script for missing tables created: $OUTPUT_SCRIPT"
