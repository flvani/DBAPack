/*
  Referências:
  Bug 20877664 - SQL Plan Management Slow with High Shared Pool Allocations (Doc ID 20877664.8)
  High Wait Time for 'cursor: pin S wait on X' Event After Upgrade (Doc ID 1949691.1)
  How to Drop Plans from the SQL Plan Management (SPM) Repository (Doc ID 790039.1)
  How To Configure Automatic Purge(Drop) Of SQL Plan Baseline(SPM). (Doc ID 1438701.1)
*/

-- #################
-- ################# ALGUMAS CONTAGENS
-- #################

COL SQL_HANDLE FORMAT A40
COL PARSING_SCHEMA_NAME FORMAT A30
SELECT SQL_HANDLE, MAX(PARSING_SCHEMA_NAME) PARSING_SCHEMA_NAME, COUNT(DISTINCT PARSING_SCHEMA_NAME), COUNT(*) QTDE
FROM  DBA_SQL_PLAN_BASELINES 
GROUP BY SQL_HANDLE
HAVING COUNT(*) > 50
order by count(*) desc
/

SELECT COUNT(*) QTDE, COUNT(DISTINCT SQL_HANDLE) QTDE_D
FROM  DBA_SQL_PLAN_BASELINES
/

SELECT SUM(COUNT(*)) QTDE
FROM  DBA_SQL_PLAN_BASELINES 
GROUP BY SQL_HANDLE
HAVING COUNT(*) > 20
/

-- #################
-- ################# VER O SQL 
-- #################


SET LONG 5000
select PARSING_SCHEMA_NAME, substr(sql_text,1,5000)
FROM  DBA_SQL_PLAN_BASELINES 
WHERE SQL_handle = 'SQL_b165e1677de6d36f' fetch first 1 row only
/


-- #################
-- ################# RECUPERAR UM SQL ESPECIFICO (SQLTOOLS)
-- #################


SELECT SQL_HANDLE, plan_name, COUNT(*) 
FROM  DBA_SQL_PLAN_BASELINES 
WHERE SQL_TEXT LIKE 'SELECT%Nvl(to_char(OcupacaoAtualEfetivo.numPonto),%) numPonto,%' 
GROUP BY SQL_HANDLE, plan_name
/

SELECT SQL_HANDLE, COUNT(*) 
FROM  DBA_SQL_PLAN_BASELINES 
WHERE SQL_TEXT LIKE 'SELECT%Nvl(to_char(OcupacaoAtualEfetivo.numPonto),%) numPonto,%' 
GROUP BY SQL_HANDLE
/


SQL_HANDLE                 (*)
--------------------    ---------
SQL_4211cc1857f2a8e6        22


declare 
  p_gn number; 
  p_sqlhdl varchar2(100) := 'SQL_998021cea01bbfc0';
begin 
  --DBMS_SPM.DROP_SQL_PLAN_BASELINE (sql_handle IN VARCHAR2 := NULL, plan_name IN VARCHAR2 := NULL) RETURN PLS_INTEGER;
  p_gn := dbms_spm.drop_sql_plan_baseline(sql_handle=>p_sqlhdl); 
  commit; 
end; 
/ 

-- #################
-- ################# RECUPERAR UM SQL ESPECIFICO (SIACOP)
-- #################

SELECT SQL_HANDLE, COUNT(*) 
FROM  DBA_SQL_PLAN_BASELINES 
WHERE SQL_TEXT LIKE 'SELECT /*+ALL_ROWS ORDERED*/ DISTINCT  (UP.identidade) upid, (perfil.nomperfil) nomperfil,  perfil.codperfilsensivellotacao codigo%(SELECT SIGLOTACAO FROM USR_CAMARA.ViwLotacaoSigespOficialGeral where ideLotacao=UP.ideunidadecamaralotoficial)%(SELECT SIGLOTACAO FROM USR_CAMARA.ViwLotacaoSigespOficialGeral where ideLotacao= pessoal.ideunidadecamaralotoficial) pessoallotoficial%INNER JOIN usr_siacop.viw_dados_login pessoal ON usuario.idepessoal = pessoal.idepessoal%UP.ideassunto WHERE UP.codtipoacessoperfil <> 2%AND upper(pessoal.loginrede)  =upper(%and assunto.COD_AUXILIAR_PERFIL_ACESSO=%' 
GROUP BY SQL_HANDLE
/


SELECT SQL_HANDLE, COUNT(*) 
FROM  DBA_SQL_PLAN_BASELINES 
WHERE SQL_TEXT LIKE 'SELECT /*+ALL_ROWS ORDERED*/ DISTINCT  (UP.identidade) upid, (perfil.nomperfil) nomperfil,  perfil.codperfilsensivellotacao codigo%(SELECT SIGLOTACAO FROM USR_CAMARA.ViwLotacaoSigespOficialGeral where ideLotacao=UP.ideunidadecamaralotoficial)%(SELECT SIGLOTACAO FROM USR_CAMARA.ViwLotacaoSigespOficialGeral where ideLotacao= pessoal.ideunidadecamaralotoficial) pessoallotoficial%INNER JOIN usr_siacop.viw_dados_login pessoal ON usuario.idepessoal = pessoal.idepessoal%UP.ideassunto WHERE UP.codtipoacessoperfil <> 2%' 
GROUP BY SQL_HANDLE
/

SELECT SQL_HANDLE, COUNT(*) 
FROM  DBA_SQL_PLAN_BASELINES 
WHERE SQL_TEXT LIKE 'SELECT /*+ALL_ROWS ORDERED*/ DISTINCT  (UP.identidade) upid, (perfil.nomperfil) nomperfil,  perfil.codperfilsensivellotacao codigo%' 
GROUP BY SQL_HANDLE
/


