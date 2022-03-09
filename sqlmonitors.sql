   
col username format a30
col sql_exec_start format a20
col sql_id format a20
col plan_hash format a20
col sql_text format a50 
col start_date new_value start_date.

set termout off
--select to_char(trunc(sysdate)+(11/24+15/1440), 'DD/MM/YYYY HH24:MI:SS') start_date from dual;
select to_char(trunc(sysdate)+(7/24), 'DD/MM/YYYY HH24:MI:SS') start_date from dual;
define nlimite='30'
set termout on 

set verify off pages 200

prompt
prompt ############################################################################################
prompt Sentenças que demoraram mais de &nlimite. segundos, a partir de &START_DATE.
prompt ##################################################

col plan_hashes format a55
col emin format 9G999D00 HEAD "Elaped|Min" JUST R
col eavg format 9G999D00 HEAD "Elaped|Avg" JUST R
col emax format 9G999D00 HEAD "Elaped|Max" JUST R

SELECT v2.username, v2.sql_id, sum(qtd) qtd, sum(qtd_plan) qtd_plan, stragg(v2.plan_hash) plan_hashes, min(v2.emin) emin, avg(v2.eavg) eavg, max(v2.emax) emax, min(v2.sql_text) sql_text
from (
  SELECT v.username, v.sql_id, v.plan_hash, count(*) qtd, count(distinct v.plan_hash) qtd_plan, min(elap_sec) emin, avg(elap_sec) eavg, max(elap_sec) emax, min(sql_text) sql_text
  FROM ( 
    SELECT /*+ NO_XML_QUERY_REWRITE MATERIALIZE */ x1.username, 
    to_char(to_date(x1.sql_exec_start, 'mm/dd/yyyy hh24:mi:ss'),'yyyy/mm/dd hh24:mi:ss') dt_start, x1.sql_id, x1.plan_hash,
    trunc(x1.elapsed_time/1000000,2) elap_sec, 
    replace(replace(substr(x1.sql_text, 1, 50), chr(13), ' ' ), chr(10), ' ' ) sql_text
    FROM dba_hist_reports t 
    , xmltable('/report_repository_summary/sql' 
    PASSING xmlparse(document t.report_summary) 
    COLUMNS 
    sql_id path '@sql_id' 
    , sql_exec_start path '@sql_exec_start' 
    , sql_exec_id path '@sql_exec_id' 
    , sql_text path 'sql_text'
    , username path 'user'
    , plan_hash path 'plan_hash'
    , duration path 'stats/stat[@name="duration"]' 
    , elapsed_time path 'stats/stat[@name="elapsed_time"]' 
    , cpu_time path 'stats/stat[@name="cpu_time"]' 
    ) x1 
    where t.COMPONENT_NAME = 'sqlmonitor'
    and  x1.username LIKE UPPER('&1.')
    and  x1.elapsed_time/1000000 > &nlimite.
    --and  x1.sql_id = 'a9yr4qy05y1yc'
    --and to_date(x1.sql_exec_start, 'MM/DD/YYYY HH24:MI:SS') between trunc(sysdate) and sysdate
    and to_date(x1.sql_exec_start, 'MM/DD/YYYY HH24:MI:SS') >= to_date( '&START_DATE.', 'DD/MM/YYYY HH24:MI:SS' )
    --order by 5 desc 
    --fetch first 10 rows only
  ) V  
  WHERE v.username IS NOT NULL AND v.username <> 'SYS'
  group by v.username, v.sql_id, v.plan_hash
) v2
group by v2.username, v2.sql_id
order by 3 desc, 8 desc
/
set verify on pages 66
