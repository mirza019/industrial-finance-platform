USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE FINANCE_DB;

EXECUTE IMMEDIATE $$
BEGIN
  LET v_fail_count NUMBER DEFAULT 0;

  LET v_bad_daily NUMBER := (
    SELECT COUNT(*)
    FROM FINANCE_DB.GOLD.KPI_DAILY_REVENUE
    WHERE ORDER_DATE IS NULL OR REVENUE < 0 OR ORDERS < 0 OR UNIQUE_CUSTOMERS < 0
  );

  LET v_bad_monthly NUMBER := (
    SELECT COUNT(*)
    FROM FINANCE_DB.GOLD.KPI_MONTHLY_REVENUE
    WHERE YEAR_MONTH IS NULL OR MONTH_START_DATE IS NULL OR REVENUE < 0 OR ORDERS < 0 OR UNIQUE_CUSTOMERS < 0
  );

  LET v_monthly_recon_diff NUMBER := (
    WITH d AS (
      SELECT TO_CHAR(ORDER_DATE, 'YYYY-MM') AS YEAR_MONTH, SUM(REVENUE) AS daily_revenue
      FROM FINANCE_DB.GOLD.KPI_DAILY_REVENUE
      GROUP BY 1
    ), m AS (
      SELECT YEAR_MONTH, SUM(REVENUE) AS monthly_revenue
      FROM FINANCE_DB.GOLD.KPI_MONTHLY_REVENUE
      GROUP BY 1
    )
    SELECT COUNT(*)
    FROM (
      SELECT ABS(COALESCE(d.daily_revenue,0) - COALESCE(m.monthly_revenue,0)) AS diff
      FROM d
      FULL OUTER JOIN m ON d.YEAR_MONTH = m.YEAR_MONTH
    ) q
    WHERE diff > 0.01
  );

  IF (v_bad_daily > 0 OR v_bad_monthly > 0 OR v_monthly_recon_diff > 0) THEN
    v_fail_count := v_fail_count + 1;
  END IF;

  IF (v_fail_count > 0) THEN
    LET v_force_fail NUMBER := 1/0;
  END IF;
END;
$$;
