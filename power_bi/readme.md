# 📊 Power BI Reporting & Data Visualization

This directory contains the final presentation layer of the B2B Data Pipeline. The interactive dashboard translates the transformed data (Star Schema) from the `dbt` layer into actionable business insights tailored for advertising sales performance.

*Note: The underlying data powering this report is based on the cleaned and transformed synthetic dataset (Mockaroo).*

### 🌐 Interactive Dashboard
You can explore the fully interactive version of the dashboard online:

👉 **[View the Interactive Report](https://mavenshowcase.com/project/56446)**

---

### 💡 Key Features & Analytical Capabilities
The dashboard is designed to provide a comprehensive overview of advertising revenue, sales efficiency, and product performance within the agricultural publishing domain. 

* **Executive KPI Banner:** Tracks core metrics including Total Gross/Net Sales, Average Discount percentages, and Overall Win Rate, complete with dynamic Year-over-Year (vs. PY) performance indicators.
* **Trend & Channel Analysis:** A stacked column chart breaks down monthly net sales by origin channel (Inbound vs. Outbound), allowing for quick seasonal trend spotting.
* **Domain-Specific Segmentation:** Analyzes net sales distributed across specific agri-business specializations to identify the most profitable market segments.
* **Discount Strategy Evaluation:** Features an scatter plot comparing Average Discount vs. Total Net Sales by individual companies, utilizing dynamic quadrant lines to quickly identify outliers and evaluate pricing discipline.
* **Catalog Performance Matrix:** A detailed breakdown of performance by content type (Advertisement, PR Article, Editorial Article) showing the exact ratio of paid vs. bonus placements.

### 🧮 DAX Implementation Highlights
The report heavily relies on DAX measures to drive the analytical logic:
* **Time Intelligence:** Implementation of `CALCULATE` and `SAMEPERIODLASTYEAR` to compute dynamic vs. PY variances for all core KPIs.
* **Advanced Ratios & Averages:** DAX logic handling weighted averages for discounts and divide-by-zero protection for Win Rate calculations.
* **Dynamic Formatting:** Custom logic for dynamic positive/negative variance indicators (green arrows up, red arrows down).

### 📸 Dashboard Preview
*(A static snapshot of the main overview page)*

![Advertising Report Dashboard](../docs/dashboard_preview.png)