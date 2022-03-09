set autotrace off timing off
SET VERIFY OFF
--DEFINE SIFUS=USR_SIAFI_OLD

14:52:56 p_7236@dgotppro6.vpropus6> show parameter adap

NAME                                 TYPE        VALUE
------------------------------------ ----------- --------------------------------------------------
fileio_network_adapters              string
optimizer_adaptive_features          boolean     TRUE
optimizer_adaptive_reporting_only    boolean     FALSE
parallel_adaptive_multi_user         boolean     TRUE
14:53:05 p_7236@dgotppro6.vpropus6> show parameter base

NAME                                 TYPE        VALUE
------------------------------------ ----------- --------------------------------------------------
cluster_database                     boolean     FALSE
cluster_database_instances           integer     1
enable_pluggable_database            boolean     FALSE
optimizer_capture_sql_plan_baselines boolean     FALSE
optimizer_use_sql_plan_baselines     boolean     TRUE

alter session set optimizer_use_sql_plan_baselines=false;
alter session set optimizer_adaptive_features=false;
alter session set current_schema=usr_folhacd;
set autotrace traceonly explain


/*
ALTER SESSION SET NLS_SORT='BINARY'
/
ALTER SESSION SET NLS_COMP='BINARY'
/

ALTER SESSION SET NLS_SORT='WEST_EUROPEAN'
/
ALTER SESSION SET NLS_COMP='ANSI'
/
*/

--CREATE INDEX USR_FOLHACD.IX_FFI_BENE_FF_RUBR
--ON  USR_FOLHACD.fichafinanceiraitem(idebeneficiario, idefichafinanceira,iderubrica)
--TABLESPACE TBSI_FOLHACD
--/

--ALTER SESSION SET OPTIMIZER_FEATURES_ENABLE='12.1.0.2';
--ALTER SESSION SET OPTIMIZER_FEATURES_ENABLE='11.2.0.2';
--alter session enable parallel dml;

EXPLAIN PLAN SET STATEMENT_ID='&1.' INTO sys.plan_table$ FOR
SELECT * FROM DUAL;