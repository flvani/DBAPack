set veri off feed off
define uname=&1
COL uname FORMAT A30 HEAD "Nome"
COL TYPE FORMAT A15 HEAD "Tipo"
select 'USER' TYPE,  username uname from all_users where upper(username) like upper('&uname.')
union all
select 'ROLE', role from dba_roles where upper(role) like upper('&uname.')
order by 1 desc, 2 asc
/
prompt

set veri off feed 6
