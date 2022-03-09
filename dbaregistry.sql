spool a:\mam.sql

set lines 1000
col comp_name  format a50
col other_schemas format a70 
col status format a10
col comp_id format a10
col control format a10
col schema format a10
col namespace format a10
col procedure format a40
col version format a15
col version_full format a15
col startup noprint
col parent_id noprint

select * from v$version;

select * from dba_registry;

select inst_id, instance_name from gv$instance;

--@backup.detail.sql 'DB INCR'
--@backup.detail.sql 'ARCHIVELOG'
--@backup.detail.sql 'RECVR AREA'

--@recursos

--@asm

--@dbafreespace %

--@topstmt %

--@topsa %

spool off