# Industrial Finance Platform

Snowflake-first, production-style finance data platform.

## What Is Implemented

- Layered pipeline: `landing -> bronze -> silver -> gold`
- Incremental CDC with Streams
- Event-driven orchestration with Tasks
- Data quality framework (`CONTROL.DQ_CHECK_RESULTS`)
- Audit/run logging (`AUDIT.PIPELINE_RUN_LOG`)
- Failure email alert procedure (`AUDIT.SP_SEND_FAILURE_EMAIL`)
- GitHub Actions deploy workflow with ordered SQL deployment + SQL tests

## Current Runtime Architecture

1. Data is inserted/updated in `FINANCE_DB.BRONZE.*`
2. Bronze streams (`STR_BRZ_*`) capture deltas
3. `OPS.TASK_PIPELINE_RUN_AUTO` fires when stream data exists
4. `OPS.SP_PIPELINE_RUN` executes:
   - `AUDIT.SP_LOG_RUN_START`
   - `SILVER.SP_APPLY_SILVER_INCREMENTAL`
   - `GOLD.SP_APPLY_GOLD_INCREMENTAL`
   - `CONTROL.SP_RUN_DQ`
   - `AUDIT.SP_LOG_RUN_END`
5. On failure, email procedure is called in exception path

## Repository Structure

```text
industrial-finance-platform/
├── sql/
│   ├── 01_database/
│   ├── 02_stage/
│   ├── 03_landing/
│   ├── 04_bronze/
│   ├── 05_silver/
│   ├── 06_gold/
│   ├── 07_control/
│   ├── 08_audit/
│   ├── 09_streams/
│   └── 10_tasks/
├── tests/
│   ├── test_row_counts.sql
│   ├── test_duplicates.sql
│   └── test_incremental_recon.sql
├── scripts/
│   └── run_ops_framework.sh
└── .github/workflows/deploy.yml
```

## SQL Execution Order (bootstrap)

1. `sql/01_database/01_create_db_schema.sql`
2. `sql/02_stage/01_create_file_format_and_stage.sql`
3. `sql/03_landing/01_create_landing_and_copy_core_files.sql`
4. `sql/04_bronze/00_create_tables.sql`
5. `sql/05_silver/00_create_tables.sql`
6. `sql/06_gold/00_create_gold_tables.sql`
7. `sql/07_control/00_create_control_framework.sql`
8. `sql/08_audit/00_create_audit_framework.sql`
9. `sql/08_audit/01_create_email_alerting.sql`
10. `sql/09_streams/00_create_streams.sql`
11. `sql/05_silver/11_proc_apply_silver_incremental.sql`
12. `sql/06_gold/11_proc_apply_gold_incremental.sql`
13. `sql/10_tasks/00_create_tasks_orchestration.sql`

## Operational Checks

```sql
-- latest runs
SELECT RUN_ID, PIPELINE_NAME, STATUS, NOTE, STARTED_AT, ENDED_AT
FROM FINANCE_DB.AUDIT.PIPELINE_RUN_LOG
ORDER BY INSERTED_AT DESC
LIMIT 20;

-- latest DQ rows
SELECT RUN_ID, CHECK_GROUP, CHECK_NAME, STATUS, CHECK_TS
FROM FINANCE_DB.CONTROL.DQ_CHECK_RESULTS
ORDER BY CHECK_TS DESC
LIMIT 50;

-- task state
SHOW TASKS IN SCHEMA FINANCE_DB.OPS;
```

## Task Modes

- Auto mode: `OPS.TASK_PIPELINE_RUN_AUTO` (resumed, stream-triggered)
- Manual mode: `OPS.TASK_PIPELINE_RUN_MANUAL` (suspended by default)

Manual trigger:

```sql
EXECUTE TASK FINANCE_DB.OPS.TASK_PIPELINE_RUN_MANUAL;
```

## Email Alerting Setup

`AUDIT.SP_SEND_FAILURE_EMAIL` sends only when pipeline fails.

Required:

1. Create notification integration (EMAIL type)
2. Update `AUDIT.ALERT_CONFIG` with:
   - valid `EMAIL_INTEGRATION`
   - valid `RECIPIENT_EMAIL`
   - `IS_ACTIVE = TRUE`

## CI/CD

Workflow: `.github/workflows/deploy.yml`

- Trigger: push to `dev`, `test`, `main`
- Branch to environment mapping:
  - `dev -> dev`
  - `test -> test`
  - `main -> prod`
- Deploy SQL in dependency order
- Run SQL validation tests

## Branching

- `dev`: active development
- `test`: QA / pre-prod
- `main`: production-ready
