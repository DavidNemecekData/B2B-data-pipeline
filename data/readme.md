# 📂 Data Directory: Sample & Synthetic Datasets

This directory contains CSV files exported from the test database. The dataset includes both basic dimensional data and fact data. 

For public presentation purposes and data protection, the sample fact data was synthetically generated using [Mockaroo](https://www.mockaroo.com/). Most dimensional data remains in its original state, with the exception of the `catalog_item` table, which was explicitly modified for demonstration purposes.

## ⚠️ Addressed Synthetic Data Inconsistencies

Because Mockaroo generates foreign keys and dates randomly, the raw generated datasets initially contained several logical and referential inconsistencies. These included:

* **Referential mismatches:** Invalid combinations of `issue_id` and `specialization_id`.
* **Status conflicts:** Discrepancies in contact status values between the `contact_history` table and their presence in the `issue_content` table.
* **Chronological errors:** Logical conflicts between the `deadline` date in the `issue` table and the `contact` date in the `contact_history` table.
* **Attribute logic:** Inconsistencies regarding the presence of `ed_author` for incorrect `catalog_items`.
* **Cardinality violations:** Multiple items listed in `issue_section` where strictly only one item is allowed.

## 🛠️ Data Correction & SQL Implementation

**Note: The CSV files provided in this folder represent the final, cleaned dataset.**

All of the anomalies mentioned above were successfully resolved directly within the PostgreSQL database using SQL prior to this export. 

* **Data Correction Scripts:** [View the SQL correction code](../sql_database/02_mockaroo_cleaning.sql)
* **Database Schema (DDL):** [View the initial DDL setup](../sql_database/01_ddl_create_schema.sql)