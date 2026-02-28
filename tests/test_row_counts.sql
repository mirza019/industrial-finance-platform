USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE FINANCE_DB;

EXECUTE IMMEDIATE $$
BEGIN
  LET v_fail_count NUMBER DEFAULT 0;

  LET v_brz_orders NUMBER := (SELECT COUNT(*) FROM FINANCE_DB.BRONZE.BRZ_ORDERS);
  LET v_slv_orders NUMBER := (SELECT COUNT(*) FROM FINANCE_DB.SILVER.SLV_ORDERS);
  LET v_gold_daily NUMBER := (SELECT COUNT(*) FROM FINANCE_DB.GOLD.KPI_DAILY_REVENUE);
  LET v_gold_monthly NUMBER := (SELECT COUNT(*) FROM FINANCE_DB.GOLD.KPI_MONTHLY_REVENUE);

  IF (v_brz_orders = 0) THEN
    v_fail_count := v_fail_count + 1;
  END IF;

  IF (v_slv_orders = 0) THEN
    v_fail_count := v_fail_count + 1;
  END IF;

  IF (v_gold_daily = 0 OR v_gold_monthly = 0) THEN
    v_fail_count := v_fail_count + 1;
  END IF;


  IF (v_fail_count > 0) THEN
    LET v_force_fail NUMBER := 1/0;
  END IF;
END;
$$;
