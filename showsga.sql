SET TERMOUT OFF FEED OFF VERIFY OFF

col Pool format a22 Heading "SGA Pool"
col Megas justify right heading "Size(MB)" format a11
col v_cache_size new_value p_cache_size

SELECT DECODE(SUBSTR( VERSION, 1, INSTR(VERSION, '.')-1), '8',
         '((SELECT VALUE FROM V$PARAMETER WHERE NAME = ''db_block_size'')*BUFFERS/1048576)',
         'CURRENT_SIZE' ) v_cache_size FROM V$INSTANCE
/

SET TERMOUT ON

COL PARAMETRO FORMAT A22 HEAD "Parâmetro"
select upper(name) PARAMETRO, To_char( value/1048576, '99g999g999') megas, ISADJUSTED, ISDEPRECATED 
from v$parameter2 where name in ( 'sga_max_size', 'sga_target', 'memory_max_target', 'memory_target' )
order by
   case name 
     when 'memory_max_target' then 1
     when 'memory_target' then 2
     when 'sga_max_size' then 3
     when 'sga_target' then 4
     else 99
   end  
/

select decode( pool, null, decode(name, 'buffer_cache', 'buffer cache total', 'db_block_buffers', 'buffer cache total',
                                          'fixed_sga', 'fixed sga', 'log_buffer', 'log buffer' ), pool ||
       decode( substr( name, 1, 4 ), 'free', ' free', ' alloc' ) ) Pool ,
       to_char( round(sum(bytes)/1048576,1), '999g990d00' ) Megas
from v$sgastat
group by decode( pool, null, decode(name, 'buffer_cache', 'buffer cache total', 'db_block_buffers', 'buffer cache total',
                                          'fixed_sga', 'fixed sga', 'log_buffer', 'log buffer' ), pool ||
         decode( substr( name, 1, 4 ), 'free', ' free', ' alloc' ) )
UNION
select pool || ' total', to_char( round(sum(bytes)/1048576,1), '999g990d00' )
from v$sgastat
where pool is not null
group by pool
UNION
select 'total SGA', to_char( round(sum(bytes)/1048576,1), '999g990d00' )
from v$sgastat
union
SELECT 'buffer cache ' || lower( name ), to_char( round(&p_cache_size.,1), '999g990d00' ) Megas
FROM V$BUFFER_POOL
WHERE &p_cache_size. > 0
/

col Pool format a22 Heading "PGA Pool"
SELECT POOL, MEGAS
FROM
(
 SELECT
   TO_CHAR( ROUND(VALUE/1048576,1), '999g990d00') MEGAS,
   DECODE( NAME, 'aggregate PGA target parameter', 'PGA Aggregate Target',
                 'aggregate PGA auto target', 'PGA Internal Target',
                 'total PGA inuse', 'Total PGA In Use',
                 'total PGA allocated', 'Total PGA Allocated', 'X' ) POOL
 FROM V$PGASTAT
)
WHERE POOL <> 'X'
/

col Pool  CLEAR
col Megas CLEAR
col Parametro CLEAR
SET FEED 6 VERIFY ON
PROMPT

