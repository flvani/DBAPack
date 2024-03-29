SET VERIFY OFF FEED OFF DEFINE ON PAGES 5000 UNDERLINE '~' LINES 145 LONG 8000

COL PRIVILEGIOS FORMAT A145
COL SINONIMO    FORMAT A145
COL DETALHES    FORMAT A145
COL OBJETO      FORMAT A145
COL DDL         FORMAT A145
COL TIPO        NEW_VALUE TIPO NOPRINT

DEFINE P1=UPPER('&1.')

PROMPT
PROMPT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT PRIVIL�GIOS DE SISTEMA=SIM
PROMPT PRIVIL�GIOS DE OBJETO=&OBJGRANT.

-- INFORMACOES PREVIAS DO USUARIO/ROLE
SELECT OBJETO
FROM
(
  SELECT '###### USUARIO ' || USERNAME || CHR(10) || CHR(10)
         || '-- Id '|| user_id || CHR(10)
         || '-- Created ' || to_char(created, 'dd/mm/yyyy hh24:mi' ) || CHR(10)
         || '-- AcState ' || account_status || decode( lock_date, null, '', ' since ' ) || to_char(lock_date, 'dd/mm/yyyy hh24:mi' ) || CHR(10)
         || '-- Profile ' || profile  || CHR(10)
         || '-- Passwd Versions ' || password_versions  || CHR(10)
         || '-- Last login ' || to_char(last_login, 'dd/mm/rr' ) OBJETO
  FROM   DBA_USERS
  WHERE  USERNAME = &P1.
  UNION ALL
  SELECT '###### ROLE ' || ROLE || CHR(10) || CHR(10)
         || '-- PasswordRequired '|| PASSWORD_REQUIRED OBJETO
  FROM   DBA_ROLES
  WHERE  ROLE = &P1.
  UNION ALL
  (
    SELECT DECODE( SUM( X ), 0, '###### OBJETO ' || CHR(10) || CHR(10) || '-- Objeto n�o encontrado.', '' ) OBJETO
    FROM
    (
      SELECT COUNT(*) x FROM DBA_ROLES WHERE ROLE = &P1.
      UNION ALL
      SELECT COUNT(*) x FROM DBA_USERS WHERE USERNAME = &P1.
    )
  )
)
WHERE OBJETO IS NOT NULL
/

SPOOL &p_temp_path.privuser.&1..txt APPEND
-- OBTEM O DDL DO USUARIO/ROLE
WITH OBJ AS
(
  SELECT 'USER' TIPO, USERNAME OBJETO
  FROM   DBA_USERS
  WHERE  USERNAME = &P1.
  UNION ALL
  SELECT 'ROLE' TIPO, ROLE OBJETO
  FROM   DBA_ROLES
  WHERE  ROLE = &P1.
)
SELECT 
   TRIM( DBMS_METADATA.GET_DDL( TIPO, OBJETO ) )||
   CASE TIPO
     WHEN 'ROLE' THEN  CHR(10) || '/' || CHR(10) || CHR(10) || 'REVOKE ' || OBJETO || ' FROM ' || USER || CHR(10) || '/'
     WHEN 'USER' THEN 
       CHR(10) || (SELECT '      '|| REPLACE(STRAGG('QUOTA ' || DECODE( MAX_BYTES, -1, 'UNLIMITED', MAX_BYTES ) || ' ON '||TABLESPACE_NAME), ',', CHR(10)||'      ') 
                   FROM DBA_TS_QUOTAS WHERE USERNAME = &P1.) || CHR(10) || ';'
   END DDL
  ,TIPO
FROM OBJ
/

-- N�O EST� EM USO (VER SELECT ACIMA)
SELECT 
  'ALTER USER ' || USERNAME || ' QUOTA ' || DECODE( MAX_BYTES, -1, 'UNLIMITED', MAX_BYTES ) || ' ON '||TABLESPACE_NAME||';' DETALHES
FROM DBA_TS_QUOTAS
WHERE USERNAME = &P1.
AND '&TIPO.' = 'USER'
.

-- LISTA GRANTEES DE UMA ROLE
SELECT 
  'GRANT ' || GRANTED_ROLE || ' TO ' || GRANTEE || CASE ADMIN_OPTION WHEN 'YES' THEN ' WITH ADMIN OPTION;' ELSE ';' END DETALHES
FROM DBA_ROLE_PRIVS 
WHERE GRANTED_ROLE LIKE &P1.
AND '&TIPO.' = 'ROLE'
/

-- LISTA PRIVIL�GIOS DE SISTEMA/OBJETO CONCEDIDOS AO USU�RIO/ROLE
SELECT 'GRANT ' || DECODE( DEFAULT_ROLE, 'YES', '/* ROLE DEFAULT */ ', '/* ROLE */ ' ) || GRANTED_ROLE || ' TO ' || GRANTEE || ';' PRIVILEGIOS
FROM DBA_ROLE_PRIVS WHERE GRANTEE=&P1.
UNION ALL
SELECT 'GRANT /* SYSPRIV */ ' || PRIVILEGE    || ' TO ' || GRANTEE || ';'
FROM DBA_SYS_PRIVS WHERE GRANTEE=&P1.
UNION ALL
SELECT 'GRANT /* OBJPRIV */ ' || STRAGG(PRIVILEGE)    || ' ON ' || OWNER || '.' || TABLE_NAME || ' TO ' || GRANTEE || DECODE( GRANTABLE, 'YES', ' WITH GRANT OPTION' ) || ';'
FROM DBA_TAB_PRIVS  
WHERE GRANTEE=&P1. 
AND 'SIM' = '&OBJGRANT.'
AND TABLE_NAME NOT LIKE 'BIN$%'
GROUP BY OWNER, TABLE_NAME, GRANTEE, GRANTABLE
ORDER BY 1
/

-- LISTA SINONIMOS PRIVADOS DO USUARIO
SELECT
  'CREATE SYNONYM ' || OWNER || '.' || SYNONYM_NAME || ' FOR ' ||
  TABLE_OWNER || '.' || TABLE_NAME || DECODE( DB_LINK, NULL, NULL, '@' ) || DB_LINK || ';' SINONIMO
FROM
  DBA_SYNONYMS
WHERE OWNER=&P1. AND 'SIM' = '&SINONIMOS.'
/
SPOOL OFF

PROMPT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PROMPT
PROMPT RELACAO DOS PRIVILEGIOS GERADA EM: &p_temp_path.privuser.&1..txt
PROMPT

SET FEED 6 PAGES 66 UNDERLINE '-'

COL PRIVILEGIOS CLEAR
COL DDL         CLEAR
COL DETALHES    CLEAR
COL OBJETO      CLEAR
COL SINONIMO    CLEAR
COL TIPO 		CLEAR

UNDEFINE P1
