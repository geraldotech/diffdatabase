#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <REFERENCE_SQL> <OUTDATED_SQL> <OUTPUT_SQL_FILE>"
  exit 1
fi

# Input files
REFERENCE_SQL=$1
OUTDATED_SQL=$2
OUTPUT_SCRIPT=$3

# Temporary files
REFERENCE_TABLES="reference_tables.txt"
OUTDATED_TABLES="outdated_tables.txt"
DIFF_TABLES="diff_tables.txt"

# Step 1: Extract table names
grep -i "CREATE TABLE" "$REFERENCE_SQL" | awk '{print $3}' | tr -d '`' | sort | uniq > "$REFERENCE_TABLES"
grep -i "CREATE TABLE" "$OUTDATED_SQL" | awk '{print $3}' | tr -d '`' | sort | uniq > "$OUTDATED_TABLES"

# Step 2: Find missing tables
comm -23 "$REFERENCE_TABLES" "$OUTDATED_TABLES" > "$DIFF_TABLES"

# Output for missing tables
echo "-- Missing Tables (to be added):" > "$OUTPUT_SCRIPT"
if [ -s "$DIFF_TABLES" ]; then
  while read -r TABLE_NAME; do
    echo "Generating CREATE TABLE for missing table: $TABLE_NAME"
    awk "/CREATE TABLE.*\`$TABLE_NAME\`/,/;/ {print}" "$REFERENCE_SQL" >> "$OUTPUT_SCRIPT"
    echo "" >> "$OUTPUT_SCRIPT"
  done < "$DIFF_TABLES"
else
  echo "No tables are missing." >> "$OUTPUT_SCRIPT"
fi

# Step 3: Compare existing tables
echo "-- Alterations for existing tables:" >> "$OUTPUT_SCRIPT"

while read -r TABLE_NAME; do
  if grep -q "\`$TABLE_NAME\`" "$OUTDATED_SQL"; then
    echo "Checking table: $TABLE_NAME"

    # Extract column definitions for both reference and outdated tables
    REF_COLUMNS=$(awk "/CREATE TABLE.*\`$TABLE_NAME\`/,/;/ {if (\$0 ~ /\`/ && \$0 !~ /PRIMARY KEY/) print}" "$REFERENCE_SQL")
    OLD_COLUMNS=$(awk "/CREATE TABLE.*\`$TABLE_NAME\`/,/;/ {if (\$0 ~ /\`/ && \$0 !~ /PRIMARY KEY/) print}" "$OUTDATED_SQL")

    # Extract column names only
    REF_COL_NAMES=$(echo "$REF_COLUMNS" | grep -oP '\`\w+\`' | tr -d '`' | sort)
    OLD_COL_NAMES=$(echo "$OLD_COLUMNS" | grep -oP '\`\w+\`' | tr -d '`' | sort)

# Detect missing columns in outdated
MISSING_COLUMNS=$(comm -13 <(echo "$OLD_COL_NAMES") <(echo "$REF_COL_NAMES"))
#echo "Missing columns for $TABLE_NAME: $MISSING_COLUMNS" >> debug_log.txt
echo "Missing columns for $TABLE_NAME: $MISSING_COLUMNS"

if [ -n "$MISSING_COLUMNS" ]; then
  echo "-- Missing columns in table $TABLE_NAME" >> "$OUTPUT_SCRIPT"
  for COL_NAME in $MISSING_COLUMNS; do
    # Extract column definition and sanitize it: remove trailing commas and spaces
    COL_DEF=$(echo "$REF_COLUMNS" | grep "\`$COL_NAME\`" | sed 's/,$//g' | sed 's/[[:space:]]*$//') # Clean trailing commas and spaces

    # Ensure the column definition doesn't have a trailing comma before the semicolon
    COL_DEF=$(echo "$COL_DEF" | sed 's/,$//')

    if [ -n "$COL_DEF" ]; then
      # Add the column definition to the output script without the comma before the semicolon
      echo "ALTER TABLE \`$TABLE_NAME\` ADD COLUMN $COL_DEF;" >> "$OUTPUT_SCRIPT"
     # echo "ALTER TABLE \`$TABLE_NAME\` ADD COLUMN $COL_DEF;" >> debug2.txt
    else
    echo "Error: Failed to extract definition for column $COL_NAME in table $TABLE_NAME" 
     # echo "Error: Failed to extract definition for column $COL_NAME in table $TABLE_NAME" >> debug_log.txt
    fi
  done
fi



    # Detect renamed columns
    for REF_COL in $REF_COL_NAMES; do
      MATCHED_COL=$(echo "$OLD_COLUMNS" | grep "\`$REF_COL\`")
      if [ -z "$MATCHED_COL" ]; then
        # Check if it's a renamed column (same type but different name)
        REF_DEF=$(echo "$REF_COLUMNS" | grep "\`$REF_COL\`")
        OLD_SIMILAR=$(echo "$OLD_COLUMNS" | grep "$(echo "$REF_DEF" | cut -d' ' -f2-)")
        if [ -n "$OLD_SIMILAR" ]; then
          OLD_COL_NAME=$(echo "$OLD_SIMILAR" | awk '{print $1}' | tr -d '`')
          echo "ALTER TABLE \`$TABLE_NAME\` CHANGE COLUMN \`$OLD_COL_NAME\` \`$REF_COL\` $(echo "$REF_DEF" | cut -d' ' -f2-);" >> "$OUTPUT_SCRIPT"
        fi
      fi
    done
  fi
done < "$REFERENCE_TABLES"

# Cleanup
rm -f "$REFERENCE_TABLES" "$OUTDATED_TABLES" "$DIFF_TABLES"

# Final output
echo "SQL script created: $OUTPUT_SCRIPT"
