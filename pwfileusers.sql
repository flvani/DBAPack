set lines 300
col account_status format a20
col password_profile format a20
col external_name format a20
col last_login format a20
select * from v$pwfile_users;
