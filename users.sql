define name=&1
select 'USER' TYPE,  username NAME from all_users where upper(username) like upper('&name.')
union all
select 'ROLE', role from dba_roles where upper(role) like upper('&name.')
order by 1 desc, 2 asc
/
