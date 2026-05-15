# ⚙️ Data Transformation Layer (dbt)

This component specifies the dbt (Data Build Tool) layer used for transforming raw database records into a clean, dimensional data model optimized for reporting in Power BI.

### 🌐 Interactive dbt Documentation & Lineage Graph
The complete interactive documentation, including the Directed Acyclic Graph (DAG) of data lineage, table relationships, and column-level definitions, has been compiled using `dbt docs` and is hosted online. 

👉 **[Explore the Interactive dbt Documentation Here](https://davidnemecekdata.github.io/B2B-data-pipeline/#!/overview)**

---

The architecture strictly follows dbt best practices, separating code into modular layers and applying software engineering principles (version control, automated testing, D.R.Y.) to data transformations.

## 🏗️ 1. Staging Layer (Data Ingestion & Normalization)
**Objective:** The entry point of the data warehouse. Raw data is cleaned, data types are cast, nomenclature is unified, and `NULL` values are handled. A strict 1:1 relationship with the source tables is maintained. No business logic aggregations or complex `JOIN`s are performed here.

*   **`stg_company`:** Concatenates first and last names into a `contact_person_full_name` column. Unifies email fields to `primary_email` and `secondary_email`.
*   **`stg_issue`:** Structural data repair. Generates a true `DATE` type column `issue_date` using the `MAKE_DATE` function and standardizes boolean flags.
*   **`stg_contact_history`:** Applies the **Dual Column Pattern**—retaining the original status values for back-end computations while generating a `contact_status_renamed` column for BI visualizations.
*   **`stg_catalog_item` & `stg_category_field`:** Translates internal ENUM statuses (e.g., `ADVERTISEMENT`, `PR_ARTICLE`) into user-friendly labels for reporting.
*   **`stg_issue_content`:** Renames selected columns.
*   **`stg_specialization`, `stg_issue_section`, `stg_ed_author`:** Basic string trimming and primary key standardization.
*   **`stg_company_specialization`:** Isolated staging of the bridging table to prevent direct reads from source tables in the Marts layer.

## 🚀 2. Marts Layer (Business & Presentation)
**Objective:** Wide, denormalized tables optimized for the VertiPaq engine in Power BI. This layer defines business logic and splits the data into Dimensions and Facts. 

### Dimensions (Filtering Context)
*   **`dim_calendar`:** A centralized date dimension essential for Time Intelligence DAX functions in Power BI.
*   **`dim_company_enriched`:** Appends an aggregated list of specializations using `STRING_AGG()` to prevent **Fan-out effects** during downstream joins.
*   **`dim_specialization`:** Joins specific specializations with their parent categories.
*   **`dim_catalog_item`:** Transforms system values into business dimensions (e.g., mapping the `is_bonus` boolean to a text column `bonus_status` returning 'Bonus' / 'Paid').
*   **`dim_issue`:** A dedicated dimension optimized for issue reporting.

### Facts (Measurable Transactions)
*   **`fct_sales_performance`:** The core business fact table integrating sales, catalogs, and issues. Computes absolute discount values and inherits quantitative ratios directly from the catalog. Transforms origin logic into readable BI dimensions: `contact_direction` ('Inbound'/'Outbound') and `sales_channel` ('Direct'/'Agency').
*   **`fct_crm_funnel`:** Aggregates CRM history to compute conversion metrics (Win Rate), complete with divide-by-zero protection.
*   **`fct_contact_history`:** A transactional log of sales activities. Introduces performance metrics such as `lead_time_days` and `days_before_deadline`. Includes a binary `is_win_flag` for rapid downstream aggregations.

## 🛡️ 3. Automated Testing (Data Quality)
**Objective:** To guarantee data reliability, prevent silent failures, and continuously monitor referential integrity.

### Generic Tests (Defined in `schema.yml`)
*   **Referential Integrity:** Enforced using `relationships` to ensure all IDs in fact tables exist in their corresponding dimensions.
*   **Primary Keys:** `unique` and `not_null` assertions on all `_id` columns across both Staging and Marts to prevent accidental Fan-out.
*   **Categorical Purity:** `accepted_values` applied to contact statuses, categories, fields, `is_win_flag`, and derived business text columns.
*   **Financial Safeguards:** Asserts that `final_net_price` is never `NULL`.

### Singular Business Tests (Custom SQL in `tests/`)
*   `assert_deadline_before_distribution`: Logical anomaly check. The submission deadline must chronologically precede the distribution date.
*   `assert_no_negative_revenue`: Financial anomaly check. Combined discounts cannot drive the net price below zero.
*   `assert_pr_no_author`: Editorial rule protection. PR articles cannot be assigned to internal editorial authors.
*   `assert_bonus_has_zero_price`: Items sold under a 'Bonus' catalog item must not have a billed price > 0.
*   `assert_positive_lead_time`: The re-contact date must not precede the initial contact date.
*   `assert_contact_before_deadline`: Sales logic check (`days_before_deadline < 0`) ensuring ads aren't sold for issues already past their deadline.

### Source Freshness (`sources.yml`)
*   Monitors if the source system is regularly feeding fresh data based on the `contact_date::timestamp` column, configured with a tolerance window that accounts for weekends and public holidays.

## 🧩 4. Macros (D.R.Y. Principle)
*   **`calculate_vat(column_name, vat_rate)`:** A Jinja macro dynamically calculating VAT directly within fact tables (e.g., `{{ calculate_vat('ic.final_net_price', 0.21) }}`). Minimizes hardcoding and enhances reusability.

## 📸 5. Snapshots (SCD Type 2)
*   **Tracking Price Lists (`catalog_item`):** Instead of overwriting old prices when a catalog update occurs, dbt creates a new row with temporal validity columns (`valid_from`, `valid_to`). This guarantees that historical revenue reports are not retroactively skewed by new pricing updates.