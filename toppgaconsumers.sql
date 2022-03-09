col username format a30
SELECT nvl(s.username,case p.background when '1' then 'system' when null then 'foreground' else 'others' end ) username
  ,count(*) qtde
  ,round(sum(p.pga_used_mem)/1024/1024,0) mb_used
  ,round(sum(p.pga_alloc_mem)/1024/1024,0) mb_aloc
  ,round(sum(p.pga_freeable_mem)/1024/1024,0) mb_freab
  ,round(max(p.pga_max_mem)/1024/1024,0) mb_max
  ,round(avg(p.pga_max_mem)/1024/1024,0) mb_avg
FROM V$PROCESS p 
left join v$session s on s.paddr = p.addr
group by rollup ( nvl(s.username,case p.background when '1' then 'system' when null then 'foreground' else 'others' end ) )
order by grouping( nvl(s.username,case p.background when '1' then 'system' when null then 'foreground' else 'others' end ) ), mb_aloc 
/


select value/power(1024,2) "MB" from v$pgastat where name = 'maximum PGA allocated';

SELECT nvl(s.username,s.program ) username
  ,count(*) qtde
  ,round(sum(p.pga_used_mem)/1024/1024,0) mb_used
  ,round(sum(p.pga_alloc_mem)/1024/1024,0) mb_aloc
  ,round(sum(p.pga_freeable_mem)/1024/1024,0) mb_freab
  ,round(max(p.pga_max_mem)/1024/1024,0) mb_max
  ,round(avg(p.pga_max_mem)/1024/1024,0) mb_avg
FROM V$PROCESS p 
left join v$session s on s.paddr = p.addr
where p.background  = '1'
group by rollup ( nvl(s.username,s.program ) )
order by grouping( nvl(s.username,s.program ) ), mb_aloc 
.
