#!/bin/bash

## Gera script de atualização da estrutura (não dados) entre dois arquivos SQL.
## Versão completa com suporte a CREATE, ALTER
## diff 5- ADICIONADO DROP TABLES

# Uso: ./diff3.sh UPDATED.sql OUTDATED.sql updatefile.sql

# Inputs
REFERENCE_SQL=$1
OUTDATED_SQL=$2
OUTPUT_SCRIPT=$3

# Temp files
REFERENCE_TABLES="reference_tables.txt"
OUTDATED_TABLES="outdated_tables.txt"
MISSING_TABLES="missing_tables.txt"

# Start fresh
rm -f "$OUTPUT_SCRIPT"
echo "START TRANSACTION;" > "$OUTPUT_SCRIPT"
echo "" >> "$OUTPUT_SCRIPT"

# Step 1: Extract table names
grep -i "CREATE TABLE" "$REFERENCE_SQL" | awk '{print $3}' | tr -d '`' | sort | uniq > "$REFERENCE_TABLES"
grep -i "CREATE TABLE" "$OUTDATED_SQL" | awk '{print $3}' | tr -d '`' | sort | uniq > "$OUTDATED_TABLES"

# Step 2: Find missing tables (reference - outdated)
comm -23 "$REFERENCE_TABLES" "$OUTDATED_TABLES" > "$MISSING_TABLES"

# Step 3: Generate CREATE TABLE IF NOT EXISTS for missing tables
if [ -s "$MISSING_TABLES" ]; then
    echo "-- Creating missing tables" >> "$OUTPUT_SCRIPT"
    while read -r TABLE_NAME; do
        echo "Generating CREATE TABLE for: $TABLE_NAME"
        awk "/CREATE TABLE.*\`$TABLE_NAME\`/,/;[[:space:]]*$/" "$REFERENCE_SQL" \
            | sed '1s/CREATE TABLE/CREATE TABLE IF NOT EXISTS/' >> "$OUTPUT_SCRIPT"
        echo "" >> "$OUTPUT_SCRIPT"
    done < "$MISSING_TABLES"
else
    echo "-- No missing tables" >> "$OUTPUT_SCRIPT"
fi

# Step 4: For existing tables, compare columns
echo "-- Altering existing tables to add missing columns" >> "$OUTPUT_SCRIPT"
while read -r TABLE_NAME; do
    if grep -q "\`$TABLE_NAME\`" "$OUTDATED_SQL"; then
        if grep -q "^$TABLE_NAME\$" "$MISSING_TABLES"; then
            continue
        fi

        echo "Checking columns for: $TABLE_NAME"

        REF_COLUMNS=$(awk "/CREATE TABLE.*\`$TABLE_NAME\`/,/;/ {if (\$0 ~ /\`/ && \$0 !~ /PRIMARY KEY/ && \$0 !~ /KEY /) print}" "$REFERENCE_SQL")
        OLD_COLUMNS=$(awk "/CREATE TABLE.*\`$TABLE_NAME\`/,/;/ {if (\$0 ~ /\`/ && \$0 !~ /PRIMARY KEY/ && \$0 !~ /KEY /) print}" "$OUTDATED_SQL")

        REF_COL_NAMES=$(echo "$REF_COLUMNS" | grep -oP '\`\w+\`' | tr -d '`' | sort)
        OLD_COL_NAMES=$(echo "$OLD_COLUMNS" | grep -oP '\`\w+\`' | tr -d '`' | sort)

        MISSING_COLUMNS=$(comm -13 <(echo "$OLD_COL_NAMES") <(echo "$REF_COL_NAMES"))

        if [ -n "$MISSING_COLUMNS" ]; then
            echo "-- Missing columns in table $TABLE_NAME" >> "$OUTPUT_SCRIPT"
            for COL_NAME in $MISSING_COLUMNS; do
                COL_DEF=$(echo "$REF_COLUMNS" | grep "\`$COL_NAME\`" | sed 's/[,[:space:]]*$//')
                if [ -n "$COL_DEF" ]; then
                    echo "ALTER TABLE \`$TABLE_NAME\` ADD COLUMN $COL_DEF;" >> "$OUTPUT_SCRIPT"
                fi
            done
        fi
    fi
done < "$REFERENCE_TABLES"

# Step 5: Drop tables not found in reference
echo "-- Dropping tables not found in reference" >> "$OUTPUT_SCRIPT"
TABLES_TO_DROP=$(comm -13 "$REFERENCE_TABLES" "$OUTDATED_TABLES")
if [ -n "$TABLES_TO_DROP" ]; then
    while read -r TABLE_NAME; do
        echo "DROP TABLE IF EXISTS \`$TABLE_NAME\`;" >> "$OUTPUT_SCRIPT"
    done <<< "$TABLES_TO_DROP"
else
    echo "-- No tables to drop" >> "$OUTPUT_SCRIPT"
fi

# End transaction
echo "" >> "$OUTPUT_SCRIPT"
echo "COMMIT;" >> "$OUTPUT_SCRIPT"

# Cleanup
rm -f "$REFERENCE_TABLES" "$OUTDATED_TABLES" "$MISSING_TABLES"

echo "SQL script created: $OUTPUT_SCRIPT"
