DEFINE NTOPS=10
DEFINE SCHEMA='&1.'
DEFINE MINEXECS = 3
DEFINE MINEXECS = 10
DEFINE MINEXECS = 1
DEFINE MINEXECSBYSEC=0.00027 REM 1 VEZ A CADA 60 MIN
DEFINE MINEXECSBYSEC=0.00055 REM 1 VEZ A CADA 30 MIN
DEFINE MINEXECSBYSEC=0.001   REM 1 VEZ A CADA 100 SEGUNDOS
DEFINE MINEXECSBYSEC=0.0001  REM 1 VEZ A CADA 1000 SEGUNDOS
DEFINE MINEXECSBYSEC=0.00001 REM 1 VEZ A CADA 10000 SEGUNDOS
DEFINE MINEXECSBYSEC=0.001
DEFINE MINEXECSBYSEC=0.01
DEFINE MINEXECSBYSEC=0.1

DEFINE SORT="AVG_CPU_ELAPSED"
DEFINE SORT="CPU_ELAPSED"
DEFINE SORT="AVG_CPU_TIME"
DEFINE SORT="EXEC"
DEFINE SORT="LIO"
DEFINE SORT="CPU_TIME"
DEFINE SORT="AVG_LIO"
DEFINE SORT="AVG_EXEC"

SET VERIFY OFF LINES 400 FEED OFF PAGES 1000
COL INST_iD NOPRINT
COL HASH_VALUE FORMAT 999999999999
COL EXECUTIONS FORMAT A12 HEAD 'Execucoes' JUST R
COL GETS_BY_EXEC FORMAT A14 HEAD 'Leit.Logicas|Por Execucao' JUST R
COL CPU_TIME_BY_EXEC FORMAT A14 HEAD 'CPU Time (ms)|Por execucao' JUST R
COL ELA_TIME_BY_EXEC FORMAT A17 HEAD 'Elapsed Time (ms)|Por execucao' JUST R
COL EXECS_BY_SEC FORMAT 9G990D99999 HEAD 'Execucoes|Por segundo' JUST R
COL CACHE_TIME FORMAT A13 HEAD 'Cache time' JUST R
COL LINHAS FORMAT A12 HEAD 'Linhas|Processadas' JUST R
COL BUFFER_GETS FORMAT A14 HEAD 'Leituras|Logicas' JUST R
COL CPU_TIME FORMAT A12 HEAD 'Total|CPU Time (s)' JUST R
COL CPU_ELAP FORMAT A12 HEAD 'Total|CPU Elap (s)' JUST R
COL USER_NAME FORMAT A20 TRUNC
COL SQL_TEXT FORMAT A100 HEAD 'Inicio do Texto do SQL' TRUNC
COL COPIES FORMAT 999999 HEAD 'copies'
col HH new_value HH
COL RANK FORMAT 9999


SET TERMOUT OFF

select
  'Hora Atual: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS' ) HH
from dual;

SET TERMOUT ON

PROMPT
PROMPT Top &NTOPS. Statements
PROMPT Execucoes (minimo): &MINEXECS. === Execucoes/Segundo (minimo): &MINEXECSBYSEC.
PROMPT Schema: &SCHEMA. === ORDER BY: &SORT.
PROMPT &HH.
WITH /* Top Statements v5 */ CURSORES AS
(
  SELECT /*+ ALL_ROWS */ 
     MAX(S.SQL_ID) SQL_ID
    ,MAX(S.PARSING_SCHEMA_NAME) USER_NAME
    ,SUM(S.ROWS_PROCESSED) LINHAS
    ,SUM(S.EXECUTIONS) EXECUTIONS
    ,SUM(S.BUFFER_GETS) BUFFER_GETS
    ,TRUNC(SUM(S.CPU_TIME/1000/1000)) CPU_TIME
    ,TRUNC(SUM(S.ELAPSED_TIME)/1000/1000) CPU_ELAP
    ,((SYSDATE-TO_DATE( MIN(S.FIRST_LOAD_TIME), 'YYYY-MM-DD/HH24:MI:SS' )) DAY(3) TO SECOND(0)) CACHE_TIME
    ,TRUNC(DECODE(MAX(SYSDATE-TO_DATE( S.FIRST_LOAD_TIME, 'YYYY-MM-DD/HH24:MI:SS' )), NULL, 0, 0, 0, 
                        SUM(S.EXECUTIONS)/(MAX(SYSDATE-TO_DATE( S.FIRST_LOAD_TIME, 'YYYY-MM-DD/HH24:MI:SS' ))*24*60*60)),5) EXECS_BY_SEC
    ,TRUNC(DECODE(SUM(S.EXECUTIONS),NULL,0,0,0,SUM(S.BUFFER_GETS)/SUM(S.EXECUTIONS))) GETS_BY_EXEC
    ,TRUNC(DECODE(SUM(S.EXECUTIONS),NULL,0,0,0,SUM(S.CPU_TIME)/1000/SUM(S.EXECUTIONS))) CPU_TIME_BY_EXEC
    ,TRUNC(DECODE(SUM(S.EXECUTIONS),NULL,0,0,0,SUM(S.ELAPSED_TIME)/1000/SUM(S.EXECUTIONS))) ELA_TIME_BY_EXEC
    ,MAX(TRIM(REPLACE( REPLACE( S.SQL_TEXT, chr(10), ' ' ), chr(13), '' ))) SQL_TEXT 
    ,COUNT(*) COPIES
    --,S.force_matching_signature
  FROM GV$SQLAREA S
  WHERE S.force_matching_signature > 0
  GROUP BY S.force_matching_signature
  HAVING DECODE(MAX(SYSDATE-TO_DATE( S.FIRST_LOAD_TIME, 'YYYY-MM-DD/HH24:MI:SS' )), NULL, 0, 0, 0, 
                        SUM(S.EXECUTIONS)/(MAX(SYSDATE-TO_DATE( S.FIRST_LOAD_TIME, 'YYYY-MM-DD/HH24:MI:SS' ))*24*60*60)) >= &MINEXECSBYSEC.
  AND   SUM(S.EXECUTIONS) >= &MINEXECS.
  AND   MAX(S.PARSING_SCHEMA_NAME) LIKE UPPER(NVL('&SCHEMA.', '%'))
  AND   MAX(S.SQL_TEXT) NOT LIKE 'SELECT /* DS_SVC */%'
  AND   MAX(S.SQL_TEXT) NOT LIKE 'WITH /* Top Statements v5 */ CURSORES AS%'
  ORDER BY
	CASE '&SORT.'
		WHEN 'AVG_CPU_ELAPSED' THEN DECODE(SUM(S.EXECUTIONS),NULL,0,0,0,SUM(S.ELAPSED_TIME)/1000/SUM(S.EXECUTIONS))
		WHEN 'CPU_ELAPSED' THEN SUM(S.ELAPSED_TIME) 
		WHEN 'AVG_CPU_TIME' THEN DECODE(SUM(S.EXECUTIONS),NULL,0,0,0,SUM(S.CPU_TIME)/1000/SUM(S.EXECUTIONS))
		WHEN 'CPU_TIME' THEN SUM(S.CPU_TIME) 
		WHEN 'AVG_EXEC' THEN DECODE(MAX(SYSDATE-TO_DATE( S.FIRST_LOAD_TIME, 'YYYY-MM-DD/HH24:MI:SS' )), NULL, 0, 0, 0, 
                           SUM(S.EXECUTIONS)/(MAX(SYSDATE-TO_DATE( S.FIRST_LOAD_TIME, 'YYYY-MM-DD/HH24:MI:SS' ))*24*60*60))
    WHEN 'COPIES' THEN COUNT(*)
		WHEN 'EXEC' THEN SUM(S.EXECUTIONS)
		WHEN 'LIO' THEN SUM(S.BUFFER_GETS)
		ELSE /*AVG_LIO*/ DECODE(SUM(S.EXECUTIONS),NULL,0,0,0,SUM(S.BUFFER_GETS)/SUM(S.EXECUTIONS))
	END
  DESC
  FETCH FIRST &NTOPS. ROWS ONLY
)
SELECT
   ROWNUM "Rank"
  ,C.user_name
  ,LPAD(
   decode(sign(1e+12-C.GETS_BY_EXEC), -1, to_char(C.GETS_BY_EXEC/1e+09, 'fm999g999g999' ) || 'G',
   decode(sign(1e+09-C.GETS_BY_EXEC), -1, to_char(C.GETS_BY_EXEC/1e+06, 'fm999g999g999' ) || 'M',
   decode(sign(1e+06-C.GETS_BY_EXEC), -1, to_char(C.GETS_BY_EXEC/1e+03, 'fm999g999g999' ) || 'K',
   to_char(C.GETS_BY_EXEC, 'fm999g999g999' )  ) ) ), 14, ' ' ) GETS_BY_EXEC
  ,LPAD(
     decode(sign(1e+12-C.CPU_TIME_BY_EXEC), -1, to_char(C.CPU_TIME_BY_EXEC/1e+09, 'fm999g999g999' ) || 'G',
     decode(sign(1e+09-C.CPU_TIME_BY_EXEC), -1, to_char(C.CPU_TIME_BY_EXEC/1e+06, 'fm999g999g999' ) || 'M',
     decode(sign(1e+06-C.CPU_TIME_BY_EXEC), -1, to_char(C.CPU_TIME_BY_EXEC/1e+03, 'fm999g999g999' ) || 'K',
     to_char(C.CPU_TIME_BY_EXEC, 'fm999g999g999g999' )  ) ) ), 13, ' ' ) CPU_TIME_BY_EXEC
  ,LPAD(
     decode(sign(1e+12-C.ELA_TIME_BY_EXEC), -1, to_char(C.ELA_TIME_BY_EXEC/1e+09, 'fm999g999g999' ) || 'G',
     decode(sign(1e+09-C.ELA_TIME_BY_EXEC), -1, to_char(C.ELA_TIME_BY_EXEC/1e+06, 'fm999g999g999' ) || 'M',
     decode(sign(1e+06-C.ELA_TIME_BY_EXEC), -1, to_char(C.ELA_TIME_BY_EXEC/1e+03, 'fm999g999g999' ) || 'K',
     to_char(C.ELA_TIME_BY_EXEC, 'fm999g999g999' )  ) ) ), 13, ' ' ) ELA_TIME_BY_EXEC
  ,C.EXECS_BY_SEC
  ,LPAD(
   decode(sign(1e+12-C.EXECUTIONS), -1, to_char(C.EXECUTIONS/1e+09, 'fm999g999g999' ) || 'G',
   decode(sign(1e+09-C.EXECUTIONS), -1, to_char(C.EXECUTIONS/1e+06, 'fm999g999g999' ) || 'M',
   decode(sign(1e+06-C.EXECUTIONS), -1, to_char(C.EXECUTIONS/1e+03, 'fm999g999g999' ) || 'K',
   to_char(C.EXECUTIONS, 'fm999g999g999' )  ) ) ), 12, ' ' ) EXECUTIONS
  ,LPAD(
   decode(sign(1e+12-C.BUFFER_GETS), -1, to_char(C.BUFFER_GETS/1e+09, 'fm999g999g999' ) || 'G',
   decode(sign(1e+09-C.BUFFER_GETS), -1, to_char(C.BUFFER_GETS/1e+06, 'fm999g999g999' ) || 'M',
   decode(sign(1e+06-C.BUFFER_GETS), -1, to_char(C.BUFFER_GETS/1e+03, 'fm999g999g999' ) || 'K',
   to_char(C.BUFFER_GETS, 'fm999g999g999' )  ) ) ), 14, ' ' ) BUFFER_GETS
  ,LPAD(to_char(C.CPU_TIME, 'fm999g999g999' ), 12, ' ' ) CPU_TIME
  ,LPAD(to_char(C.CPU_ELAP, 'fm999g999g999' ), 12, ' ' ) CPU_ELAP
  ,C.COPIES
  ,C.CACHE_TIME
  ,C.SQL_ID
  ,C.SQL_TEXT
  --,force_matching_signature
 /* ,LPAD(
   decode(sign(1e+12-C.LINHAS), -1, to_char(C.LINHAS/1e+09, 'fm999g999g999' ) || 'G',
   decode(sign(1e+09-C.LINHAS), -1, to_char(C.LINHAS/1e+06, 'fm999g999g999' ) || 'M',
   decode(sign(1e+06-C.LINHAS), -1, to_char(C.LINHAS/1e+03, 'fm999g999g999' ) || 'K',
   to_char(C.LINHAS, 'fm999g999g999' )  ) ) ), 12, ' ' ) LINHAS
  ,LPAD(
   decode(sign(1e+12-C.CPU_TIME), -1, to_char(C.CPU_TIME/1e+09, 'fm999g999g999' ) || 'G',
   decode(sign(1e+09-C.CPU_TIME), -1, to_char(C.CPU_TIME/1e+06, 'fm999g999g999' ) || 'M',
   decode(sign(1e+06-C.CPU_TIME), -1, to_char(C.CPU_TIME/1e+03, 'fm999g999g999' ) || 'K',
   to_char(C.CPU_TIME, 'fm999g999g999' )  ) ) ), 12, ' ' ) CPU_TIME
  ,LPAD(
   decode(sign(1e+12-C.ELAPSED_TIME), -1, to_char(C.ELAPSED_TIME/1e+09, 'fm999g999g999' ) || 'G',
   decode(sign(1e+09-C.ELAPSED_TIME), -1, to_char(C.ELAPSED_TIME/1e+06, 'fm999g999g999' ) || 'M',
   decode(sign(1e+06-C.ELAPSED_TIME), -1, to_char(C.ELAPSED_TIME/1e+03, 'fm999g999g999' ) || 'K',
   to_char(C.ELAPSED_TIME, 'fm999g999g999' )  ) ) ), 12, ' ' ) ELAPSED_TIME */
FROM CURSORES C
ORDER BY
	CASE '&SORT.'
		WHEN 'AVG_CPU_ELAPSED' THEN C.ELA_TIME_BY_EXEC
		WHEN 'CPU_ELAPSED' THEN C.CPU_ELAP 
		WHEN 'AVG_CPU_TIME' THEN C.CPU_TIME_BY_EXEC
		WHEN 'CPU_TIME' THEN C.CPU_TIME 
		WHEN 'AVG_EXEC' THEN C.EXECS_BY_SEC
		WHEN 'EXEC' THEN C.EXECUTIONS
		WHEN 'LIO' THEN C.BUFFER_GETS
		ELSE /*AVG_LIO*/ C.GETS_BY_EXEC
	END
DESC
/

PROMPT

COL HASH_VALUE CLEAR
COL GETS_BY_EXEC CLEAR
COL LINHAS CLEAR
COL SQL_TEXT CLEAR
COL BUFFER_GETS CLEAR
COL EXECUTIONS CLEAR
COL CPU_TIME CLEAR
COL CPU_TIME_BY_EXEC CLEAR
COL CPU_ELAP CLEAR
COL USER_NAME CLEAR

SET VERIFY ON FEED 6 LINES 200 PAGES 100
col HH CLEAR 
col RANK CLEAR 
UNDEFINE 1 SCHEMA
