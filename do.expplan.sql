COL NAME   FORMAT A20 HEAD "Par�metro"
COL VALUE  FORMAT A30 HEAD "Valor"
COL PLAN_TABLE_OUTPUT FORMAT A169 HEAD "Plano de Execu��o"

SELECT PLAN_TABLE_OUTPUT
FROM TABLE(DBMS_XPLAN.DISPLAY('SYS.PLAN_TABLE$', '&1.', 'TYPICAL'  )) 
--FROM TABLE(DBMS_XPLAN.DISPLAY('SYS.PLAN_TABLE$', '&1.', 'ALL'  )) -- ALL -PROJECTION -ALIAS 
/

SELECT NAME, UPPER(VALUE) VALUE
FROM V$PARAMETER
WHERE NAME IN ( 'cursor_sharing', 'optimizer_mode', 'hash_join_enabled' )
UNION ALL
SELECT 'sql_id', '&P_SQL_ID.' FROM DUAL
UNION ALL
SELECT 'address', case when '&P_SQL_ID.' = 'n/a' then 'n/a' else to_char('&p_addr.') end FROM DUAL
UNION ALL
SELECT DISTINCT 'plan_hash_value', case when '&P_SQL_ID.' = 'n/a' then 'n/a' else to_char(PLAN_ID) end
FROM sys.PLAN_TABLE$
WHERE STATEMENT_ID = '&1.'
--UNION ALL
--SELECT 'arquivo', upper('explain.&1..sql') FROM DUAL 
/

WITH PLANS AS
(
  SELECT /*+materialize*/ DISTINCT
    P.SQL_ID, P.CHILD_NUMBER VERSION#, P.HASH_VALUE, P.ADDRESS, P.PLAN_HASH_VALUE, CHILD_ADDRESS
  FROM GV$SQL_PLAN P
  WHERE P.SQL_ID = '&P_SQL_ID.'
) 
SELECT S.INST_ID SID, P.VERSION#, P.ADDRESS, S.CHILD_ADDRESS, P.PLAN_HASH_VALUE, S.LOADED_VERSIONS, OPEN_VERSIONS
FROM PLANS P
JOIN GV$SQL S ON (S.CHILD_ADDRESS = P.CHILD_ADDRESS)
ORDER BY  S.INST_ID, P.VERSION#
/

COL NAME   clear
COL VALUE  clear
COL PLAN_TABLE_OUTPUT clear


