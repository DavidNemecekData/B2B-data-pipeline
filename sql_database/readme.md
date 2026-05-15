# 💾 SQL Database & Data Engineering

This directory contains the core SQL scripts used for defining the database architecture, cleaning synthetic data anomalies, and performing exploratory data analysis.

### 🏗️ 1. Data Definition & Initialization
* **[`01_ddl_create_schema.sql`](./01_ddl_create_schema.sql):** The complete Data Definition Language (DDL) script. It includes the creation of custom `ENUM` types, primary/foreign key relationships, and `GENERATED ALWAYS AS` columns for automated business logic.

### 🧹 2. Data Cleaning & Transformation
* **[`02_mockaroo_cleaning.sql`](./02_mockaroo_cleaning.sql):** SQL scripts used to resolve referential and logical inconsistencies introduced by the random generation of synthetic data via [Mockaroo](https://www.mockaroo.com/). 
  * *Note: For a detailed list of the addressed anomalies, please refer to the [data directory documentation](../data/).*

### 📊 3. Sample Queries
* **[`03_sample_queries.sql`](./03_sample_queries.sql):** A collection of practical SQL queries demonstrating day-to-day database interactions, data extraction for reporting, and analytical checks.

---

### 💡 Code Snippet Highlight

Here is an example of  data cleaning from the `02_mockaroo_cleaning.sql` file. 

```sql
WITH deduplication_cte AS (
    SELECT
        ic.content_id,
        ROW_NUMBER() OVER (
            PARTITION BY ic.issue_id, ic.section_id 
            ORDER BY random()
        ) AS numbered_rows
    FROM issue_content ic
    WHERE ic.section_id IN (1, 2, 3, 4, 16, 17, 18)
)
UPDATE issue_content ic
SET section_id = 21
FROM deduplication_cte cte
WHERE cte.content_id = ic.content_id 
  AND cte.numbered_rows > 1;
```

Here is an example from `03_sample_queries.sql` demonstrating a complex business reporting query. 

```sql
SELECT 
    i.issue_year AS year,
    i.issue_month AS month,
    ic.final_net_price AS final_price,
    c.company_name,
    (
        SELECT string_agg(s2.spec_name, ', ')
        FROM company_specialization cs2
        JOIN specialization s2 USING (specialization_id)
        WHERE cs2.company_id = c.company_id
    ) AS company_specializations,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM issue_content ic2 
            WHERE ic2.issue_id = 90 AND ic2.company_id = c.company_id
        ) THEN 'Yes'
        ELSE 'No'
    END AS already_advertising_in_target_issue
FROM issue_content ic
JOIN company c USING (company_id)
JOIN issue i USING (issue_id)
WHERE i.issue_id IN (
    SELECT ispec.issue_id 
    FROM issue_specialization ispec
    JOIN specialization s USING (specialization_id)
    WHERE s.spec_name IN ('Feed production', 'Storage', 'Cereals')
)
ORDER BY year DESC, month DESC;

