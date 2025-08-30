#!/bin/bash

## Gera script de atualização da estrutura (não dados) entre dois arquivos SQL.
## https://github.com/geraldotech/diffdatabase
## Author: GeraldoDev
## Since: 29, April, 2025

# Captura o timestamp inicial
start=$(date +%s)

#variaveis de apoio
ADD_LOG=1
VERSION=1

# Inputs
REFERENCE_SQL=$1
OUTDATED_SQL=$2
OUTPUT_SCRIPT=$3

# Temp files
REFERENCE_TABLES="reference_tables.txt"
OUTDATED_TABLES="outdated_tables.txt"
MISSING_TABLES="missing_tables.txt"

# check os 3 argumentos foram passados, exige mensagem de uso:
if [ $# -ne 3 ]; then
  echo "Uso: $0 <arquivo_sql_atualizado> <arquivo_sql_desatualizado> <script_de_saida.sql>"
  exit 1
fi

# Start fresh
rm -f "$OUTPUT_SCRIPT"


# textos opcionais
if [ $ADD_LOG -eq 1 ]; then
    echo "-- criado gerado em $(date '+%Y-%m-%d %H:%M:%S')"  >> "$OUTPUT_SCRIPT"    
    echo "-- hostname: `hostname`"  >> "$OUTPUT_SCRIPT"
fi

#echo "incluir versao no final? (s para sim)"
#read version
if ([ $VERSION -eq 1 ]); then
    echo "-- versao do script 5.2 - GeraldoDev"  >> "$OUTPUT_SCRIPT"
    echo >> "$OUTPUT_SCRIPT" # linha branco
fi
# textos opcionais

echo "START TRANSACTION;" >> "$OUTPUT_SCRIPT"

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
                    if echo "$COL_DEF" | grep -qi "AUTO_INCREMENT"; then
                        # Já existe coluna AUTO_INCREMENT na tabela desatualizada?
                        AUTO_EXISTENTE=$(echo "$OLD_COLUMNS" | grep -i "AUTO_INCREMENT")
                        
                        if [ -n "$AUTO_EXISTENTE" ]; then
                        # Extrair o nome da coluna existente com AUTO_INCREMENT
                        OLD_AUTO_COL=$(echo "$AUTO_EXISTENTE" | grep -oP '\`\K[^`]+' | head -n 1)
                        echo "-- Substituindo coluna AUTO_INCREMENT $OLD_AUTO_COL por $COL_NAME em $TABLE_NAME" >> "$OUTPUT_SCRIPT"
                        
                        # Pega o tipo do novo campo (sem o nome, mas com o tipo e atributos)
                        NOVO_TIPO=$(echo "$COL_DEF" | sed "s/\`$COL_NAME\`//" | sed 's/^ *//')
                        
                        echo "ALTER TABLE \`$TABLE_NAME\` CHANGE COLUMN \`$OLD_AUTO_COL\` \`$COL_NAME\` $NOVO_TIPO;" >> "$OUTPUT_SCRIPT"
                        else
                        echo "ALTER TABLE \`$TABLE_NAME\` ADD COLUMN $COL_DEF;" >> "$OUTPUT_SCRIPT"
                        fi
                    else
                        echo "ALTER TABLE \`$TABLE_NAME\` ADD COLUMN $COL_DEF;" >> "$OUTPUT_SCRIPT"
                    fi
                    fi
            done
        fi
    fi
done < "$REFERENCE_TABLES"

# Step 5: Drop tables nao encontradas na referencia
echo >> "$OUTPUT_SCRIPT" # linha branco
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

# Cleanup remove os arquivos temporarios
rm -f "$REFERENCE_TABLES" "$OUTDATED_TABLES" "$MISSING_TABLES"

echo $(date '+%Y-%m-%d %H:%M:%S') "SQL script created: $OUTPUT_SCRIPT"

# Captura o timestamp final
end=$(date +%s)
# Calcula diferença
elapsed=$((end - start)) 
echo "tempo gasto $elapsed segundos"
