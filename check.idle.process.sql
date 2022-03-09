select username, count(*) from v$session group by rollup(username) order by 2 ;

@histconn m %

@recursos
