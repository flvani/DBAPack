NAnotações
•	Automatizar a produção das métricas para painel de indicadores da Cainf
  o	Confirmar com Jairo
  o	Prometheus ou Nagios
  o	Visualização via Graphana 
•	Levar o número atual dos indicadores propostos na próxima reunião (a marcar) para Olival consolidar e apresentar à Coges/Consultoria

•	Indicadores propostos
  o	Atendimento ao usuário (fonte: OTRS)
    -	Tempo médio de atendimento dos chamados
    -	% de chamados atendidos no prazo

  o	Disponibilidade de bancos críticos
    -	% de disponibilidade (uptime)
    -	Combinado utilizar um script para tentar escrever algo em alguma tabela para certificar que banco está OK.

  o	Processamento
    -	Média de CPU
    -	Tamanho da fila

  o	Outras métricas
    -	Total de bancos/esquemas
    -	Tamanho das bases
    -	Nº de transações p/ seg.

  o	Guardium
    -	Taxa de pacotes perdidos
 

select 
   trunc(begin_time) day
  ,avg(case metric_name when 'User Transaction Per Sec' then average end) User_Transactions_Per_Sec
  --,sum(case metric_name when 'User Transaction Per Sec' then average end) User_Transactions_Per_Sec
from dba_hist_sysmetric_summary
where trunc(begin_time) > sysdate-7
and metric_name = 'User Transaction Per Sec'
group by trunc(begin_time)
--group by snap_id
order by trunc(begin_time);


select min(begin_time), max(end_time),
sum(case metric_name when 'User Commits Per Sec' then average end) User_Commits_Per_Sec,
sum(case metric_name when 'User Rollbacks Per Sec' then average end) User_Rollbacks_Per_Sec,
sum(case metric_name when 'User Transaction Per Sec' then average end) User_Transactions_Per_Sec,
snap_id
from dba_hist_sysmetric_summary
where trunc(begin_time) > sysdate-7
group by snap_id
order by snap_id
.

select trunc(begin_time) day, sum(case metric_name when 'User Transaction Per Sec' then average end) User_Transactions_Per_Sec
from dba_hist_sysmetric_summary
where trunc(begin_time) > sysdate-7
group by trunc(begin_time)
order by trunc(begin_time) 
.




SELECT USERNAME, USER_ID FROM ALL_USERS 
WHERE SUBSTR(USERNAME, 1, 4) NOT IN ('EXT_', 'USR_' )
AND SUBSTR(USERNAME, 1, 2) NOT IN ( 'MV' ) 
AND SUBSTR(USERNAME, 1, 3) NOT IN ( 'DBA' )  
AND SUBSTR(USERNAME, 1, 5) NOT IN ('USER_' )
AND SUBSTR(USERNAME, 1, 2) NOT IN ('P_', 'D_',  'T_')
AND USER_ID BETWEEN 55 AND 1E+5
ORDER BY USER_ID
/

SELECT USERNAME FROM ALL_USERS 
WHERE ( SUBSTR(USERNAME, 1, 4) IN ('EXT_', 'USR_' ) OR SUBSTR(USERNAME, 1, 2) IN ('MV' ) OR SUBSTR(USERNAME, 1, 3) IN ( 'DBA' )) 
AND EXISTS (SELECT 1 FROM DBA_TABLES WHERE OWNER=USERNAME)
/

SELECT ((res0.ok/100) * (res1.ok/100) * (res2.ok/100) * (res3.ok/100) * (res4.ok/100) * (res5.ok/100)) * 100 AS ok
FROM
 (SELECT DISTINCT 'GLPI' AS host, ok, warn, crit, down, downtime FROM public.disponibilidade WHERE service = 'Summary' AND hostname = 'MERIVA' AND EXTRACT(YEAR FROM dt_to) = '2199') res1,  
 (SELECT DISTINCT 'GLPI' AS host, ok, warn, crit, down, downtime FROM public.disponibilidade WHERE service = 'Summary' AND hostname = 'VIPER' AND EXTRACT(YEAR FROM dt_to) = '2199') res0,  
 (SELECT DISTINCT 'GLPI' AS host, ok, warn, crit, down, downtime FROM public.disponibilidade WHERE service = 'Summary' AND hostname = 'MONZA' AND EXTRACT(YEAR FROM dt_to) = '2199') res2,  
 (SELECT DISTINCT 'GLPI' AS host, ok, warn, crit, down, downtime FROM public.disponibilidade WHERE service = 'Summary' AND hostname = 'CORSA' AND EXTRACT(YEAR FROM dt_to) = '2199') res3,  
 (SELECT DISTINCT 'GLPI' AS host, ok, warn, crit, down, downtime FROM public.disponibilidade WHERE service = 'Summary' AND hostname = 'AVANT' AND EXTRACT(YEAR FROM dt_to) = '2199') res4,  
 (SELECT DISTINCT 'GLPI' AS host, ok, warn, crit, down, downtime FROM public.disponibilidade WHERE service = 'Summary' AND hostname = 'EDGE' AND EXTRACT(YEAR FROM dt_to) = '2199') res5
WHERE res0.host = res1.host 
AND res1.host = res2.host 
AND res2.host = res3.host 
AND res3.host = res4.host 
AND res4.host = res5.host


SELECT DISTINCT ok FROM public.disponibilidade WHERE service = 'Oracle Check Health - Write Test' AND hostname = 'DWHPRO' AND EXTRACT(YEAR FROM dt_to) = '2199'


SELECT DISTINCT ok FROM public.disponibilidade WHERE service = 'Summary' AND hostname = 'OLTPPRO' AND EXTRACT(YEAR FROM dt_to) = '2199'

SELECT DISTINCT ok FROM public.disponibilidade WHERE service = 'Summary' AND hostname = 'DWHPRO' AND EXTRACT(YEAR FROM dt_to) = '2199'


Oracle Check Health - Write Test
