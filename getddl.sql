-- 1- tipo (table, index...)
-- 2 - schema
-- 3 - nome do objeto
COL DDL FORMAT A500 
SET LONG 100000 VERIFY OFF pages 0 LINES 500
PROMPT
PROMPT --DROP &1. &2..&3.;;
SELECT 
 CASE WHEN '&3.' = '*'
 THEN DBMS_METADATA.GET_DDL( upper('&1.'), upper('&2.') ) 
 ELSE DBMS_METADATA.GET_DDL( upper('&1.'), upper('&3.'), upper('&2.') ) 
 END DDL
 FROM DUAL
/
PROMPT /
COL DDL CLEAR
