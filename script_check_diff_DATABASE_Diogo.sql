WITH estrutura_atual AS (
    SELECT 
        table_name,
        GROUP_CONCAT(CONCAT(column_name, ':', data_type, ':', is_nullable, ':', column_key) 
                     ORDER BY ordinal_position SEPARATOR '|') AS estrutura
    FROM information_schema.columns
    WHERE table_schema = 'maringa'
    GROUP BY table_name
),
estrutura_novo AS (
    SELECT 
        table_name,
        GROUP_CONCAT(CONCAT(column_name, ':', data_type, ':', is_nullable, ':', column_key) 
                     ORDER BY ordinal_position SEPARATOR '|') AS estrutura
    FROM information_schema.columns
    WHERE table_schema = 'sga_dev2'
    GROUP BY table_name
),
tabelas_renomeadas AS (
    SELECT 
        ea.table_name AS tabela_antiga,
        en.table_name AS tabela_nova,
        ea.estrutura
    FROM estrutura_atual ea
    JOIN estrutura_novo en ON ea.estrutura = en.estrutura AND ea.table_name != en.table_name
),
colunas_apenas_em_um_lado AS (
    SELECT 
        'APENAS EM SGA_ATUAL' AS TIPO_DIFERENCA,
        A.TABLE_NAME, A.COLUMN_NAME, A.DATA_TYPE, A.IS_NULLABLE, A.COLUMN_KEY
    FROM information_schema.columns A
    LEFT JOIN information_schema.columns B 
        ON A.TABLE_NAME = B.TABLE_NAME 
       AND A.COLUMN_NAME = B.COLUMN_NAME
       AND B.table_schema = 'sga_dev2'
    WHERE A.table_schema = 'maringa' 
      AND B.COLUMN_NAME IS NULL
      AND A.TABLE_NAME NOT IN (SELECT tabela_antiga FROM tabelas_renomeadas)
    UNION
    SELECT 
        'APENAS EM SGA_NOVO' AS TIPO_DIFERENCA,
        B.TABLE_NAME, B.COLUMN_NAME, B.DATA_TYPE, B.IS_NULLABLE, B.COLUMN_KEY
    FROM information_schema.columns B
    LEFT JOIN information_schema.columns A 
        ON B.TABLE_NAME = A.TABLE_NAME 
       AND B.COLUMN_NAME = A.COLUMN_NAME
       AND A.table_schema = 'maringa'
    WHERE B.table_schema = 'sga_dev2' 
      AND A.COLUMN_NAME IS NULL
      AND B.TABLE_NAME NOT IN (SELECT tabela_nova FROM tabelas_renomeadas)
),
colunas_diferentes AS (
    SELECT 
        'ATRIBUTOS DIFERENTES' AS TIPO_DIFERENCA,
        A.TABLE_NAME, A.COLUMN_NAME,
        CONCAT(A.DATA_TYPE, ' / ', B.DATA_TYPE) AS DATA_TYPE,
        CONCAT(A.IS_NULLABLE, ' / ', B.IS_NULLABLE) AS IS_NULLABLE,
        CONCAT(A.COLUMN_KEY, ' / ', B.COLUMN_KEY) AS COLUMN_KEY
    FROM information_schema.columns A
    JOIN information_schema.columns B 
        ON A.TABLE_NAME = B.TABLE_NAME 
       AND A.COLUMN_NAME = B.COLUMN_NAME
    WHERE A.table_schema = 'maringa'
      AND B.table_schema = 'sga_dev2'
      AND A.TABLE_NAME NOT IN (
          SELECT tabela_antiga FROM tabelas_renomeadas
      )
      AND (
            A.DATA_TYPE != B.DATA_TYPE
         OR A.IS_NULLABLE != B.IS_NULLABLE
         OR A.COLUMN_KEY != B.COLUMN_KEY
      )
)
SELECT * FROM (
    SELECT 'TABELA RENOMEADA' AS TIPO_DIFERENCA, tabela_antiga AS TABLE_NAME, tabela_nova AS COLUMN_NAME, estrutura AS DATA_TYPE,
           NULL AS IS_NULLABLE, NULL AS COLUMN_KEY
    FROM tabelas_renomeadas
    UNION ALL
    SELECT * FROM colunas_apenas_em_um_lado
    UNION ALL
    SELECT * FROM colunas_diferentes
) AS resultado
WHERE 
TIPO_DIFERENCA IN ('APENAS EM SGA_NOVO','TABELA RENOMEADA')
ORDER BY TIPO_DIFERENCA, TABLE_NAME, COLUMN_NAME;