# Database Sync and Validation Scripts

Scripts para sincronização e validação de esquemas de bancos de dados MySQL.

---

## Pré-requisitos

- Shell Script (Linux, macOS ou WSL no Windows)
- MySQL (para aplicar os scripts gerados)
- Arquivos `.sql` de referência e bancos desatualizados

## Estrutura

├── diff4.sh          # Gera update.sql para sincronizar bancos  
├── report.sh         # Gera relatório de tabelas e colunas faltantes  
├── README.md         # Documentação (este arquivo)  

---

## Scripts disponíveis

### 1. **Gerar Atualizações (`diff4.sh`)**

## diff5 
foi adicionado suporte a drop tables (tem no desatualizado mais não tem no atualizado)



Script para gerar um arquivo de atualização (`update.sql`) que adiciona tabelas e colunas faltantes.

#### **📚 Uso:**

```bash
./diff4.sh referencia.sql desatualizado.sql update.sql
```

### 2. **Gerar Relatório de Diferenças (report.sh)**
```bash
./report.sh referencia.sql desatualizado.sql relatorio.txt
```

