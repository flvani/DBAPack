rem # use a partir do script @obj - que lista nome de subpartitions

col tabela format a45 head TABELA
col partition_name format a20 head PARTICAO
col p_key format a6
col s_key format a6

select 
  s.table_owner ||'.'|| s.table_name tabela, s.partition_name
 ,p.high_value p_key
 ,s.high_value s_key
 ,to_char( p.last_analyzed, 'dd/mm/yy hh24:mi' ) p_last_stat
 ,to_char( s.last_analyzed, 'dd/mm/yy hh24:mi' ) subp_last_stat
from dba_tab_subpartitions s 
join dba_tab_partitions p on p.partition_name = s.partition_name
where s.SUBPARTITION_NAME = 'SYS_SUBP66277'
.


rem # use a partir do script @obj - que lista nome de subpartitions

col tabela format a50 head TABELA
col partition_name format a20 head PARTICAO
col subpartition_name format a20 head PARTICAO
col p_key format a10
col s_key format a10
set pages 100

select 
  s.table_owner ||'.'|| s.table_name tabela, s.partition_name , s.subpartition_name
 ,to_char( p.last_analyzed, 'dd/mm/yy hh24:mi' ) p_last_stat
 ,to_char( s.last_analyzed, 'dd/mm/yy hh24:mi' ) subp_last_stat
 ,p.high_value p_key
 ,s.high_value s_key
 ,s.num_rows
 ,s.blocks
from dba_tab_subpartitions s 
join dba_tab_partitions p on p.partition_name = s.partition_name
where s.table_name = 'WF_LANCAMENTO_COMPLETA'
-- where s.SUBPARTITION_NAME = 'SYS_SUBP66277'
/

