# Database Sync and Validation Scripts

Scripts para sincronização e validação de esquemas de bancos de dados MySQL.

---

## Pré-requisitos

- Bash (Linux, macOS ou WSL no Windows)
- MySQL (para aplicar os scripts gerados)
- Arquivos `.sql` de referência e bancos desatualizados

## Estrutura
├── diff4.sh          # Gera update.sql para sincronizar bancos
├── report.sh         # Gera relatório de tabelas e colunas faltantes
├── README.md         # Documentação (este arquivo)

---

## Scripts disponíveis

### 1. **Gerar Atualizações (`diff4.sh`)**

Script para gerar um arquivo de atualização (`update.sql`) que adiciona tabelas e colunas faltantes.

#### **📚 Uso:**

```bash
./diff3.sh UPDATED.sql OUTDATED.sql updatefile.sql
```

### 2. **Gerar Relatório de Diferenças (report.sh)**
```bash
./report.sh referencia.sql desatualizado.sql relatorio.txt
```

## Features

- CREATE TABLE
- ALTER TABLE: (ADD COLUMN)
- ALTER TABLE: (CHANGE COLUMN para AUTO_INCREMENT, only change table name) (v 5.2+)
- DROP TABLE (v 5.2+)

## version 5.2 (30/08/2025)

```shell
# - BUGFIX SE FOR UMA COLUNA DE AUTOINCREMENT APENAS ATUALIZA O NOME 
# - logs, tempo decorrido, hostname
```


#### https://github.com/geraldotech/diffdatabase

