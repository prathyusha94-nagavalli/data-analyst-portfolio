# 🏷️ Case Study: Product Lifecycle Cost Optimization

## 🧩 Background
Product teams rely heavily on cost visibility throughout the product lifecycle to make informed decisions. Each product receives multiple factory quotes that break down costs 
into material and labor components. However, fragmented and inconsistent quote data made it difficult for stakeholders to track cost performance against benchmarks.

## 🛠️ Problem
- Quotes from factories came from multiple sources with inconsistent data structures.
- Key metrics such as material usage, waste (in grams), and associated costs were scattered across systems.
- There was no single source of truth to compare actual quoted costs vs. target benchmark costs throughout the product lifecycle.
- Stakeholders lacked visibility into how their products were trending over time from a cost optimization standpoint.

## 🎯 Objective
To build a robust data pipeline and analytical layer that:
- Integrates product, BOM (Bill of Materials), and labor quote data.
- Standardizes cost elements including material type, weight, waste, and labor time.
- Supports a self-service dashboard for stakeholders to monitor quote trends and benchmark comparisons.

## 🔍 Data Sources
- **Product Data**: Product ID, season, style, color, factory
- **Bill of Materials (BOM)**: Material type, sub-type, usage (gms), waste (gms), cost per unit
- **Bill of Labor (BOL)**: Operation type, time taken, labor cost
- **Factory Quote Tables**: Quote version, product ID, quote date, total cost breakdown
- **Benchmark Tables**: Target costs for materials and labor per product category

## 🧪 Process

### 1. Data Extraction & Wrangling
- Queried product master and BOM data from Snowflake and Teradata.
- Cleaned material names and standardized units across suppliers.
- Joined factory quote tables with product IDs and BOM to align quote-level detail with material components.

### 2. Data Transformation & Modeling
- Used SQL CTEs and window functions to extract:
  - Latest vs. historical quotes for each product
  - Cost per gram used vs. wasted
  - Cumulative quote trends over time
- Calculated key KPIs:
  - % deviation from target cost
  - Material usage efficiency: `(Material Used - Waste) / Material Used`
  - Labor efficiency: `Actual Labor Cost vs. Target`

### 3. Data Validation
- Applied integrity checks to flag products with missing or duplicate quote entries.
- Profiled data for abnormal usage-to-waste ratios and alerted sourcing teams.

## 📊 Outcome
- Delivered a scalable Snowflake model feeding into the **Footwear Quotes** dashboard.
- Empowered product managers to:
  - Compare quote performance across factories
  - Track deviations from target cost benchmarks
  - Spot materials or factories consistently underperforming
- Enabled $93M in potential cost optimization through proactive decision-making (data redacted for confidentiality).

## 📈 Tools & Tech Used
- SQL (Snowflake, Teradata)
- Python (for data validation)
- Tableau & Metabase (for dashboard development)

## ✅ Impact
- Reduced manual tracking efforts by 60%
- Improved stakeholder visibility across the product lifecycle
- Supported more accurate product cost forecasting and vendor negotiations

---

> 🔗 Stay tuned: In the next section, I’ll add visualizations and KPI panels from the Footwear Quotes dashboard!
