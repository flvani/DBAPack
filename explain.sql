set autotrace off timing off
SET VERIFY OFF
--DEFINE SIFUS=USR_SIAFI_OLD

--alter session set current_schema=usr_sipro;

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

EXPLAIN PLAN SET STATEMENT_ID='&1.' INTO sys.plan_table$ FOR
select count(*)
FROM usr_folhacd.servidor s
JOIN (
SELECT uc.idecadastro
from usr_folhacd.unidadecamara uc
start with uc.idecadastro in (
SELECT uc1.idecadastro
FROM usr_folhacd.historicoservidorcargocom hscc
JOIN usr_folhacd.servidoreventohistorico sehcc ON sehcc.ideobjeto = hscc.ideserveventohist
JOIN usr_folhacd.servidor chefe ON chefe.ideobjeto = sehcc.ideservidor
JOIN usr_folhacd.cargocomissionado cc ON hscc.idecargocomissionado = cc.ideobjeto
JOIN usr_folhacd.unidadecamara uc1 ON uc1.idecargocomissionadotitular = cc.ideobjeto
WHERE chefe.numponto = :1     -- Ponto do chefe
AND sehcc.datcancelamento IS NULL
AND sehcc.datiniciohistorico <= Trunc(SYSDATE)
AND Nvl(sehcc.datfimhistorico, Trunc(SYSDATE)) >= Trunc(SYSDATE)
)
connect by prior idecadastro = ideUnidadeSuperior
) lot ON s.ideunidadefolhaponto = lot.idecadastro
WHERE s.numponto = :2   -- Ponto do subordinado
/
