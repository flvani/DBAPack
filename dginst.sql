SET VERIFY OFF SERVEROUT ON FEEDBACK OFF UNDERLINE '~' LINES 221

col db_name format a9
col inst_name format a9
col host_name format a12
col db_unique_name format a14
col status format a20
col st1 format a14 heading "Startup Time"
col st3 format a12 heading "Running Time"
col st2 format a14 heading "System Date" noprint
col st4 format a12 heading "Running Secs" noprint
col scn format a20 just r

COL RECOVERY_MODE FORMAT A30
COL SWITCHOVER_STATUS FORMAT A30
COL PROTECTION_MODE FORMAT A30
 

PROMPT
PROMPT ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~

select
   i.inst_id
  ,d.name db_name
  ,d.db_unique_name
  ,i.instance_name inst_name
  ,case when instr(i.host_name, '.') > 0 then substr( i.host_name, 1, instr(i.host_name, '.') -1 ) else i.host_name end host_name
  ,to_char( i.startup_time, 'dd/mm/yy hh24"h"mi' ) st1
  ,to_char( sysdate, 'dd/mm/yy hh24"h"mi' ) st2
  ,lpad( to_char( trunc(sysdate,'YEAR') + (sysdate-i.startup_time-1),
        decode( trunc( sysdate-i.startup_time, 0 ), 0, '"0d "hh24"h"mi', 'fmddd"d "fmhh24"h"mi' ) ), 12, ' ' ) st3
  ,to_char( (sysdate-i.startup_time)*24*60*60, '999g999g990' ) st4
  ,to_char(d.current_scn, '999g999g999g999g999') SCN
from gv$instance i 
join gv$database d on (i.inst_id = d.inst_id)
ORDER BY i.INST_ID        
/

select 
   i.inst_id
  ,i.status || ' ' || d.open_mode status
  ,i.logins
  ,i.archiver
  ,d.database_role db_role
  ,d.protection_mode
  ,d.switchover_status 
from gv$instance i 
join gv$database d on (i.inst_id = d.inst_id)
ORDER BY i.INST_ID        
/


COL INST_ID FORMAT 9999 TRUNC
COL DEST_ID FORMAT 9999 TRUNC
COL STATUS FORMAT A10 TRUNC
COL TYPE FORMAT A15 TRUNC
COL DESTINATION FORMAT A30 TRUNC
COL RECOVERY_MODE FORMAT A24 TRUNC
COL ARCHIVED_THREAD# HEAD "ARCHIVED|THREAD#"
COL ARCHIVED_SEQ# HEAD "ARCHIVED|SEQUENCE#"
COL APPLIED_THREAD# HEAD "APPLIED|THREAD#"
COL APPLIED_SEQ# HEAD "APPLIED|SEQUENCE#"
COL ERROR FORMAT A71 TRUNC

SELECT 
   DS.INST_ID, DS.DEST_ID, DS.TYPE, DS.DESTINATION, DS.STATUS, DS.RECOVERY_MODE
  ,DS.ARCHIVED_THREAD#, DS.ARCHIVED_SEQ#, DS.APPLIED_THREAD#, DS.APPLIED_SEQ#, DS.ERROR
FROM GV$ARCHIVE_DEST_STATUS DS
WHERE DS.STATUS NOT IN ( 'INACTIVE' )
AND   DS.TYPE NOT IN ( 'UNKNOWN' );

SELECT INST_ID, PROCESS, STATUS, THREAD#, SEQUENCE#
FROM GV$MANAGED_STANDBY
ORDER BY INST_ID;

COL VALUE FORMAT A18
COL NAME FORMAT A30 HEAD STATISTIC
COL SOURCE_DBID FORMAT 9999999999999999
COL SOURCE_DB_UNIQUE_NAME HEAD SOURCE_NAME FORMAT A14

select source_dbid, source_db_unique_name, name, value, unit from v$dataguard_stats;

COL MESSAGE FORMAT A115 HEAD "LAST MESSAGES (15 minutes)" TRUNC
 
select TO_CHAR( timestamp, 'DD/MM HH24:MI:SS' ) TIMESTAMP, facility, severity, error_code, message 
from V$DATAGUARD_STATUS 
WHERE timestamp > (SYSDATE - 15/1440)
order by 1;

PROMPT
SET FEEDBACK 6 UNDERLINE '-'

PROMPT ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
PROMPT 
col st1 clear
col st2 clear
col st3 clear
col st4 clear
COL MESSAGE CLEAR