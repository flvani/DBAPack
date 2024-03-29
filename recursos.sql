SET LINES 200
COL RESOURCE_NAME         HEADING "Recurso" FORMAT A30
COL CURRENT_UTILIZATION   HEADING "Valor|Corrente"
COL MAX_UTILIZATION       HEADING "Valor|M�ximo"
COL INITIAL_ALLOCATION    HEADING "Valor|Inicial"  JUSTIFY R FORMAT A10
COL LIMIT_VALUE           HEADING "Valor|Limite"   JUSTIFY R FORMAT A10
COL "%Curr"               FORMAT  A7 JUSTIFY R

SELECT V.*
FROM
(
  SELECT L.*,
     TO_CHAR( NVL( L.CURRENT_UTILIZATION * 100 / DECODE( TRIM(L.LIMIT_VALUE), 'UNLIMITED', NULL, 0,NULL, L.LIMIT_VALUE ), 0 ), '990D00' ) "%Curr"
  FROM   GV$RESOURCE_LIMIT L
  WHERE  L.RESOURCE_NAME NOT LIKE 'lm%'
  AND    L.RESOURCE_NAME <> '_lm_procs'
  ORDER BY "%Curr" DESC
) V
WHERE V."%Curr" > 0
ORDER BY RESOURCE_NAME, INST_ID
/

select count(*) procs, count(background) bkg, count(*) - COUNT(BACKGROUND) usr from v$process
/

