# 🏭 Enterprise Industrial Financial Data Platform on Snowflake

## 📌 Project Vision
Design and implement a full-stack, industrial-grade Data Engineering platform using Snowflake that simulates a regulated German industrial enterprise. The system must cover end-to-end data ingestion, Medallion architecture, financial domain modeling, audit and reconciliation controls, Change Data Capture (CDC), automation using Streams and Tasks, governance with RBAC, CI/CD using GitHub Actions, and Git-based modular deployment. This is not a tutorial project. This is a production-style financial data platform simulation intended for full-time Data Engineering job preparation.

---

## 🎯 Primary Objectives
1. Build a complete Snowflake-based data platform from raw ingestion to executive-level KPIs.  
2. Implement financial controls and reconciliation logic.  
3. Design audit-ready transformation traceability.  
4. Automate incremental processing using Streams and Tasks.  
5. Structure the entire project using Git with CI/CD deployment.  
6. Simulate enterprise-grade data engineering practices used in regulated environments.  

---

## 🏢 Business Context (Industrial Financial Re-Modeling)
The Brazilian E-Commerce Public Dataset (Olist) will be reinterpreted as an industrial financial system for a German enterprise.

| Olist Concept | Industrial Financial Meaning |
|--------------|-----------------------------|
| Orders | Industrial sales contracts |
| Order Items | Equipment line items |
| Payments | Treasury transactions |
| Customers | Corporate clients |
| Sellers | Suppliers |
| Reviews | SLA / Service performance |
| Geolocation | Regional sales distribution |

This simulates a German industrial distribution company tracking revenue, VAT (19%), payment behavior, delivery delays, supplier performance, and customer credit exposure.

---

## 🏗 Architecture Overview

Raw Files  
→ STAGE (File Storage)  
→ LANDING (Raw Capture + Metadata)  
→ BRONZE (Typed & Structural Cleanup)  
→ ERROR (Invalid Data Isolation)  
→ SILVER (Standardized Financial Model)  
→ GOLD (Financial KPIs)  
→ CONTROL (Reconciliation & Validation)  
→ AUDIT (Execution Logging)  
→ STREAMS (CDC)  
→ TASKS (Automation)

---

## 🗂 Database Structure

DEV_INDUSTRIAL_DB  
├── STAGE  
├── LANDING  
├── BRONZE  
├── SILVER  
├── GOLD  
├── ERROR  
├── METADATA  
├── AUDIT  
└── CONTROL  

---

## 🔹 Layer Responsibilities

### STAGE
Stores file formats and named stages. Responsible for raw CSV storage only. No transformation logic exists here.

### LANDING
Contains raw ingestion tables with metadata capture. Each row includes file name, load timestamp, and file row number. No data transformation occurs in this layer. It ensures full traceability of source files.

### BRONZE
Performs type casting, timestamp normalization, structural cleanup, and basic validation. This layer converts raw strings into proper data types using defensive SQL (TRY_TO_DATE, TRY_TO_NUMBER). No business joins occur here.

### ERROR
Stores invalid or rejected records. Ensures no silent data deletion. Maintains compliance traceability by preserving corrupted rows.

### SILVER
Implements standardized financial data modeling including fact and dimension tables. Includes SCD Type 2 for Customer dimension, VAT calculation (19%), currency normalization (if applicable), deduplication, and referential integrity validation.

### GOLD
Produces executive-level financial KPIs including monthly revenue, payment aging buckets (0–30 / 30–60 / 60+), customer credit exposure, supplier performance scoring, delivery performance metrics, cumulative revenue using window functions, and ranking logic.

### METADATA
Tracks file load logs, row counts, batch processing timestamps, and ingestion statistics.

### AUDIT
Logs pipeline execution start/end times, task execution history, records processed, records failed, and execution status.

### CONTROL
Implements reconciliation and financial validation checks including row count validation (Landing vs Bronze), Bronze minus Error equals Silver validation, duplicate detection, VAT validation, payment vs order consistency checks, and negative revenue detection.

---

## 🔁 Automation Layer

### Streams
Streams capture changes in Silver tables to enable incremental processing and avoid full reloads.

### Tasks
Tasks schedule automated KPI refresh, reconciliation checks, and audit logging. Tasks must demonstrate idempotent behavior and incremental update logic.

---

## 🧪 Data Quality & Financial Controls

The system must enforce:
- Landing row count equals Bronze row count.
- Bronze minus Error equals Silver row count.
- No duplicate business keys.
- Payment amount must not exceed order amount.
- No negative revenue without valid credit logic.
- VAT must be calculated correctly.
- Missing foreign keys must be isolated in ERROR schema.

All validation outputs must be logged in CONTROL schema.

---

## 🔐 Governance & Security

Implement Role-Based Access Control (RBAC):

| Role | Access Scope |
|------|-------------|
| DATA_ENGINEER | Full pipeline access |
| FINANCE_ANALYST | GOLD schema only |
| AUDITOR | CONTROL + AUDIT schemas |
| ADMIN | Full account control |

Apply least privilege principle. Configure warehouse auto-suspend. Maintain cost-aware architecture.

---

## 🔄 Change Data Capture (CDC)

Create Streams on Silver fact tables. Use Tasks to incrementally update Gold KPIs. Avoid full reload logic. Ensure pipeline is idempotent and incremental.

---

## 🌳 Git Architecture

### Repository Structure

industrial-finance-platform/  
├── sql/  
│   ├── 00_roles/  
│   ├── 01_database/  
│   ├── 02_stage/  
│   ├── 03_landing/  
│   ├── 04_bronze/  
│   ├── 05_validation/  
│   ├── 06_silver/  
│   ├── 07_gold/  
│   ├── 08_control/  
│   ├── 09_audit/  
│   ├── 10_streams/  
│   └── 11_tasks/  
├── tests/  
├── deploy/  
└── .github/workflows/  

### Branching Strategy

main → Production  
develop → Integration  
feature/* → Development  

---

## ⚙️ CI/CD (GitHub Actions)

CI/CD must:
1. Install SnowSQL.
2. Connect to Snowflake using GitHub Secrets.
3. Deploy SQL scripts in correct dependency order.
4. Execute validation tests.
5. Fail the pipeline if data quality checks fail.

Deployment flow:
- Push to develop → Deploy to DEV.
- Push to main → Deploy to PROD.

---

## 📊 Performance Optimization

Include query profiling, warehouse sizing logic, optional clustering key usage, micro-partition understanding, and cost-aware design principles.

---

## 🧠 Skills Covered

This project demonstrates:
- End-to-end data ingestion
- Medallion architecture
- Financial modeling
- SCD Type 2 implementation
- Change Data Capture (CDC)
- Automation with Streams & Tasks
- Reconciliation framework
- Audit logging
- Governance design
- CI/CD integration
- Git-based deployment
- Performance optimization

---

## 🎯 Final Outcome

After completion, the project enables confident discussion of:
- Snowflake architecture design
- Enterprise financial data pipelines
- Audit & compliance frameworks
- Incremental data processing
- Automation strategies
- DevOps for data platforms

This project prepares for full-time Data Engineering and Data Platform Engineering roles in regulated enterprise environments.

---

## 🚀 Future Enhancements (Optional Advanced Layer)

- Multi-source ingestion (ERP + Payments + FX).
- Snowpark transformations.
- API-based ingestion simulation.
- Automated Data Quality alerting.
- Dashboard integration (Power BI / Tableau).
- Multi-environment promotion (DEV → TEST → PROD).

---

## 📌 Final Statement

This project simulates a real-world industrial financial data engineering platform with automation, governance, audit controls, and CI/CD integration. It is designed to demonstrate production-level data engineering capability suitable for full-time roles in enterprise environments.