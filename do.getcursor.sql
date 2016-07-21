SET VERIFY OFF LINES 400 FEED OFF

COL HASH_VALUE FORMAT 999999999999
COL EXECUTIONS FORMAT A12 HEAD 'Execucoes' JUST R
COL CPU_TIME FORMAT A12 HEAD 'CPU Time|msecs' JUST R
COL CPU_TIME_BY_EXEC FORMAT 999G999G999 HEAD 'CPU Time|msecs/Exec' JUST R
COL ELAPSED_TIME FORMAT A12 HEAD 'Elapsed Time|msecs' JUST R
COL BUFFER_GETS FORMAT A12 HEAD 'Leituras|Logicas' JUST R
COL GETS_BY_EXEC FORMAT A12 HEAD 'Leit.Logicas|Por Execucao' JUST R
COL LINHAS FORMAT A12 HEAD 'Linhas|Processadas' JUST R
COL USER_NAME FORMAT A20 TRUNC
COL SQL_TEXT FORMAT A180 HEAD 'Inicio do Texto do SQL' TRUNC

set head off
COL HH FORMAT A50
SELECT 'Hora Atual: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS' ) HH
FROM DUAL
/
set head on


WITH /* GetCursor */ V AS 
(
  SELECT 
     c.sql_id
    ,c.inst_id
    ,c.hash_value
    ,c.user_name
    ,c.address
  FROM GV$OPEN_CURSOR C
  WHERE C.SID = &1. AND C.INST_ID = &2.
), CURSORES AS
(
SELECT /*+ ALL_ROWS NO_MERGE(V) */ 
   v.inst_id
  ,V.SQL_ID
  ,v.user_name
  ,S.ROWS_PROCESSED LINHAS, S.EXECUTIONS, S.BUFFER_GETS
  ,TRUNC(S.BUFFER_GETS/DECODE(S.EXECUTIONS,NULL,1,0,1,S.EXECUTIONS)) GETS_BY_EXEC
  ,TRUNC(S.CPU_TIME/1000) CPU_TIME
  ,TRUNC(S.CPU_TIME/1000/DECODE(S.EXECUTIONS,NULL,1,0,1,S.EXECUTIONS)) CPU_TIME_BY_EXEC
  ,TRUNC(S.ELAPSED_TIME/1000) ELAPSED_TIME
  ,S.SQL_TEXT 
  --,S.SQL_FULLTEXT
FROM V
LEFT JOIN GV$SQLAREA S ON ( V.sql_id = s.sql_id AND V.inst_id = s.inst_id )
)
SELECT 
   C.inst_id
  ,C.SQL_ID
  ,C.user_name
  ,LPAD(
   decode(sign(1e+12-C.LINHAS), -1, to_char(C.LINHAS/1e+09, 'fm999g999g999' ) || 'G',
   decode(sign(1e+09-C.LINHAS), -1, to_char(C.LINHAS/1e+06, 'fm999g999g999' ) || 'M',
   decode(sign(1e+06-C.LINHAS), -1, to_char(C.LINHAS/1e+03, 'fm999g999g999' ) || 'K',
   to_char(C.LINHAS, 'fm999g999g999' )  ) ) ), 12, ' ' ) LINHAS
  ,LPAD(
   decode(sign(1e+12-C.EXECUTIONS), -1, to_char(C.EXECUTIONS/1e+09, 'fm999g999g999' ) || 'G',
   decode(sign(1e+09-C.EXECUTIONS), -1, to_char(C.EXECUTIONS/1e+06, 'fm999g999g999' ) || 'M',
   decode(sign(1e+06-C.EXECUTIONS), -1, to_char(C.EXECUTIONS/1e+03, 'fm999g999g999' ) || 'K',
   to_char(C.EXECUTIONS, 'fm999g999g999' )  ) ) ), 12, ' ' ) EXECUTIONS
  ,LPAD(
   decode(sign(1e+12-C.BUFFER_GETS), -1, to_char(C.BUFFER_GETS/1e+09, 'fm999g999g999' ) || 'G',
   decode(sign(1e+09-C.BUFFER_GETS), -1, to_char(C.BUFFER_GETS/1e+06, 'fm999g999g999' ) || 'M',
   decode(sign(1e+06-C.BUFFER_GETS), -1, to_char(C.BUFFER_GETS/1e+03, 'fm999g999g999' ) || 'K',
   to_char(C.BUFFER_GETS, 'fm999g999g999' )  ) ) ), 12, ' ' ) BUFFER_GETS
  ,LPAD(
   decode(sign(1e+12-C.GETS_BY_EXEC), -1, to_char(C.GETS_BY_EXEC/1e+09, 'fm999g999g999' ) || 'G',
   decode(sign(1e+09-C.GETS_BY_EXEC), -1, to_char(C.GETS_BY_EXEC/1e+06, 'fm999g999g999' ) || 'M',
   decode(sign(1e+06-C.GETS_BY_EXEC), -1, to_char(C.GETS_BY_EXEC/1e+03, 'fm999g999g999' ) || 'K',
   to_char(C.GETS_BY_EXEC, 'fm999g999g999' )  ) ) ), 12, ' ' ) GETS_BY_EXEC
  ,LPAD(
   decode(sign(1e+12-C.CPU_TIME), -1, to_char(C.CPU_TIME/1e+09, 'fm999g999g999' ) || 'G',
   decode(sign(1e+09-C.CPU_TIME), -1, to_char(C.CPU_TIME/1e+06, 'fm999g999g999' ) || 'M',
   decode(sign(1e+06-C.CPU_TIME), -1, to_char(C.CPU_TIME/1e+03, 'fm999g999g999' ) || 'K',
   to_char(C.CPU_TIME, 'fm999g999g999' )  ) ) ), 12, ' ' ) CPU_TIME
  ,C.CPU_TIME_BY_EXEC
  ,LPAD(
   decode(sign(1e+12-C.ELAPSED_TIME), -1, to_char(C.ELAPSED_TIME/1e+09, 'fm999g999g999' ) || 'G',
   decode(sign(1e+09-C.ELAPSED_TIME), -1, to_char(C.ELAPSED_TIME/1e+06, 'fm999g999g999' ) || 'M',
   decode(sign(1e+06-C.ELAPSED_TIME), -1, to_char(C.ELAPSED_TIME/1e+03, 'fm999g999g999' ) || 'K',
   to_char(C.ELAPSED_TIME, 'fm999g999g999' )  ) ) ), 12, ' ' ) ELAPSED_TIME
  ,C.SQL_TEXT 
FROM CURSORES C
WHERE ( C.BUFFER_GETS >= &L_BUF_GET. OR C.GETS_BY_EXEC >= &L_BUF_GET_BY_EXEC. )
ORDER BY case when c.user_name = 'SYS' then 'x' else c.user_name end, C.BUFFER_GETS DESC
/

PROMPT
PROMPT Resumo de cursores abertos
PROMPT

SELECT O.INST_ID, O.SID, O.SQL_ID, SUM(S.OPEN_VERSIONS) open, COUNT(*) qtde
FROM GV$OPEN_CURSOR O
JOIN GV$SQLAREA S ON (O.SQL_ID = S.SQL_ID AND O.inst_id = S.inst_id)
WHERE O.SID=&1.
AND O.INST_ID = &2.
GROUP BY O.INST_ID, O.SID, O.SQL_ID
.

PROMPT

COL HASH_VALUE CLEAR
COL GETS_BY_EXEC CLEAR
COL LINHAS CLEAR
COL SQL_TEXT CLEAR
COL BUFFER_GETS CLEAR
COL EXECUTIONS CLEAR
COL CPU_TIME CLEAR
COL CPU_TIME_BY_EXEC CLEAR
COL ELAPSED_TIME CLEAR
COL USER_NAME CLEAR

SET VERIFY ON FEED 6 LINES 200
