#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Uso: $0 referencia.sql desatualizado.sql relatorio.txt"
  exit 1
fi

REFERENCE_SQL=$1
OUTDATED_SQL=$2
REPORT_FILE=$3

REF_TB="ref_tables.txt"
OLD_TB="old_tables.txt"
MISS_TB="missing_tables.txt"

echo "==== Database Comparison Report ====" > "$REPORT_FILE"
echo "Reference SQL: $REFERENCE_SQL" >> "$REPORT_FILE"
echo "Outdated SQL: $OUTDATED_SQL" >> "$REPORT_FILE"
echo -n "Generated on: " >> "$REPORT_FILE"
date >> "$REPORT_FILE"
echo "====================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 1. Tabelas
grep -iE "^CREATE TABLE\s+\`" "$REFERENCE_SQL" | awk '{print tolower($3)}' | tr -d '`' | sort > "$REF_TB"
grep -iE "^CREATE TABLE\s+\`" "$OUTDATED_SQL" | awk '{print tolower($3)}' | tr -d '`' | sort > "$OLD_TB"

comm -23 "$REF_TB" "$OLD_TB" > "$MISS_TB"

echo "=== Missing Tables ===" >> "$REPORT_FILE"
if [ -s "$MISS_TB" ]; then
  while read -r TABLE; do
    echo "- $TABLE" >> "$REPORT_FILE"
  done < "$MISS_TB"
else
  echo "No missing tables." >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# 2. Colunas
echo "=== Missing Columns in Existing Tables ===" >> "$REPORT_FILE"
while read -r TABLE; do
  if grep -iq "\`$TABLE\`" "$OUTDATED_SQL"; then
    REF_COLS=$(awk "/CREATE TABLE.*\`$TABLE\`/,/;/ {if (\$0 ~ /\`/ && \$0 !~ /KEY /) print}" "$REFERENCE_SQL")
    OLD_COLS=$(awk "/CREATE TABLE.*\`$TABLE\`/,/;/ {if (\$0 ~ /\`/ && \$0 !~ /KEY /) print}" "$OUTDATED_SQL")

    REF_NAMES=$(echo "$REF_COLS" | grep -oP '\`\w+\`' | tr -d '`' | sort)
    OLD_NAMES=$(echo "$OLD_COLS" | grep -oP '\`\w+\`' | tr -d '`' | sort)

    MISSING=$(comm -13 <(echo "$OLD_NAMES") <(echo "$REF_NAMES"))

    if [ -n "$MISSING" ]; then
      echo "[$TABLE]" >> "$REPORT_FILE"
      echo "$MISSING" | sed 's/^/- /' >> "$REPORT_FILE"
      echo "" >> "$REPORT_FILE"
    fi
  fi
done < "$REF_TB"

# Cleanup
rm -f "$REF_TB" "$OLD_TB" "$MISS_TB"

echo "Relatório gerado: $REPORT_FILE"
