set autotrace off timing off
SET VERIFY OFF
--DEFINE SIFUS=USR_SIAFI_OLD

--alter session set current_schema=usr_folhacd;

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

DEFINE P_HASH='0'
DEFINE P_ADDR='0'
DEFINE P_SQL_ID='n/a'

EXPLAIN PLAN SET STATEMENT_ID='&1.' INTO sys.plan_table$ FOR
SELECT   this_.ideauditoria AS ideaudit1_0_,
                 this_.texatividade AS texativi2_5_0_,
                 this_.datoperacao AS datopera3_5_0_,
                 this_.texdescricao AS texdescr4_5_0_,
                 this_.idemestre AS idemestre5_0_,
                 this_.ideobjeto AS ideobjeto5_0_,
                 this_.texpontousuario AS texponto7_5_0_,
                 this_.texregistro AS texregis8_5_0_,
                 this_.textipomestre AS textipom9_5_0_,
                 this_.textipoobjeto AS textipo10_5_0_,
                 this_.codtipooperacao AS codtipo11_5_0_
            FROM usr_sigas.auditoria this_
           WHERE (   (this_.ideobjeto = 46432 AND this_.textipoobjeto ='br.gov.camara.procede.sigas.comum.model.Evento')
                  OR (this_.ideobjeto = 42486 AND this_.textipoobjeto ='br.gov.camara.procede.sigas.comum.model.Demanda')
                  OR (this_.idemestre = 46432 AND this_.textipomestre ='br.gov.camara.procede.sigas.comum.model.Evento' 
                  AND this_.textipoobjeto IN('br.gov.camara.procede.sigas.comum.model.Anexo'))
                 )
        ORDER BY this_.datoperacao DESC
/
