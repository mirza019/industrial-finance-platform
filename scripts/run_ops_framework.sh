#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="${1:-${SNOWFLAKE_PROFILE:-retail-dev}}"

run_file() {
  local f="$1"
  echo "Running: $f"
  snow sql -c "$PROFILE" -f "$f"
}

echo "Using Snowflake profile: $PROFILE"

run_file "$ROOT_DIR/sql/08_audit/00_create_audit_framework.sql"
run_file "$ROOT_DIR/sql/07_control/00_create_control_framework.sql"
run_file "$ROOT_DIR/sql/09_streams/00_create_streams.sql"
run_file "$ROOT_DIR/sql/05_silver/11_proc_apply_silver_incremental.sql"
run_file "$ROOT_DIR/sql/06_gold/11_proc_apply_gold_incremental.sql"
run_file "$ROOT_DIR/sql/10_tasks/00_create_tasks_orchestration.sql"

echo "Calling procedure once..."
snow sql -c "$PROFILE" -q "CALL FINANCE_DB.OPS.SP_PIPELINE_RUN();"

echo "Executing manual task once..."
snow sql -c "$PROFILE" -q "EXECUTE TASK FINANCE_DB.OPS.TASK_PIPELINE_RUN_MANUAL;"

sleep 12

echo "Latest audit rows:"
snow sql -c "$PROFILE" -q "SELECT RUN_ID, PIPELINE_NAME, STARTED_AT, ENDED_AT, STATUS, NOTE FROM FINANCE_DB.AUDIT.PIPELINE_RUN_LOG ORDER BY INSERTED_AT DESC LIMIT 10;"

echo "Latest DQ rows:"
snow sql -c "$PROFILE" -q "SELECT RUN_ID, CHECK_TS, CHECK_GROUP, CHECK_NAME, STATUS, METRIC_VALUE, EXPECTED_VALUE FROM FINANCE_DB.CONTROL.DQ_CHECK_RESULTS ORDER BY CHECK_TS DESC LIMIT 20;"

echo "Task status:"
snow sql -c "$PROFILE" -q "SHOW TASKS IN SCHEMA FINANCE_DB.OPS;"

echo "Task history (account_usage):"
snow sql -c "$PROFILE" -q "SELECT NAME, STATE, QUERY_ID, SCHEDULED_TIME, COMPLETED_TIME, ERROR_MESSAGE FROM SNOWFLAKE.ACCOUNT_USAGE.TASK_HISTORY WHERE DATABASE_NAME='FINANCE_DB' AND SCHEMA_NAME='OPS' AND NAME IN ('TASK_PIPELINE_RUN_AUTO','TASK_PIPELINE_RUN_MANUAL') ORDER BY SCHEDULED_TIME DESC LIMIT 20;"

echo "Done."
