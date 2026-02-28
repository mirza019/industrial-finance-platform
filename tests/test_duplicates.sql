USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE FINANCE_DB;

EXECUTE IMMEDIATE $$
BEGIN
  LET v_fail_count NUMBER DEFAULT 0;

  LET v_dup_orders NUMBER := (
    SELECT COUNT(*)
    FROM (
      SELECT ORDER_ID
      FROM FINANCE_DB.SILVER.SLV_ORDERS
      GROUP BY ORDER_ID
      HAVING COUNT(*) > 1
    )
  );

  LET v_dup_order_items NUMBER := (
    SELECT COUNT(*)
    FROM (
      SELECT ORDER_ID, ORDER_ITEM_ID
      FROM FINANCE_DB.SILVER.SLV_ORDER_ITEMS
      GROUP BY ORDER_ID, ORDER_ITEM_ID
      HAVING COUNT(*) > 1
    )
  );

  IF (v_dup_orders > 0) THEN
    v_fail_count := v_fail_count + 1;
  END IF;

  IF (v_dup_order_items > 0) THEN
    v_fail_count := v_fail_count + 1;
  END IF;

  IF (v_fail_count > 0) THEN
    LET v_force_fail NUMBER := 1/0;
  END IF;
END;
$$;
