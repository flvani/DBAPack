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

EXPLAIN PLAN SET STATEMENT_ID='&1.' INTO sys.plan_table$ FOR
SELECT SN_ATIVA_PAINEL_DIGITAL   FROM DBAMV.CONFIG_PAEU  WHERE CD_MULTI_EMPRESA = 
DBAMV.PKG_MV2000.LE_EMPRESA
/

SELECT ROWID,CD_ATENDIMENTO,NM_PACIENTE,DH_ATENDIMENTO,QT_DIAS_INTERNACAO,NM_LEITO,
CD_CID,DS_CID,NM_PRESTADOR,CD_USUARIO,CD_CLASSIFICACAO,TP_ATENDIMENTO FROM SELECT 
usuarios.cd_usuario, atendime.cd_prestador, atendime.cd_atendimento, paciente.nm_paciente,
 TRUNC (atendime.dt_atendimento) + (atendime.hr_atendimento - TRUNC (atendime.hr_atendimento)) 
dh_atendimento, leito.ds_resumo nm_leito, DECODE (config_pagu.tp_procedimento_lov,
 'C', atendime.cd_cid, atendime.cd_pro_int ) cd_cid, DECODE (config_pagu.tp_procedimento_lov,
 'C', cid.ds_cid, pro_fat.ds_pro_fat ) ds_cid, prestador.nm_prestador, leito.cd_unid_int,
 unid_int.cd_setor, TRUNC (SYSDATE) - TRUNC (atendime.dt_atendimento) qt_dias_internacao 
FROM dbamv.prestador, dbamv.atendime, dbamv.paciente, dbamv.cid, dbamv.leito, dbamv.unid_int,
 dbasgu.usuarios, dbamv.usuario_unid_int, dbamv.pro_fat, dbamv.config_pagu WHERE 
atendime.tp_atendimento = 'I' AND NVL (atendime.dt_alta, TRUNC (SYSDATE + 1000)) 
= TRUNC (SYSDATE + 1000) /* LDAG - Performace - 410370 */ AND atendime.dt_alta IS 
NULL AND paciente.cd_paciente = atendime.cd_paciente AND prestador.cd_prestador = 
atendime.cd_prestador AND cid.cd_cid(+) = atendime.cd_cid AND pro_fat.cd_pro_fat(+) 
= atendime.cd_pro_int AND leito.cd_leito = atendime.cd_leito AND unid_int.cd_unid_int 
= leito.cd_unid_int AND usuarios.cd_prestador(+) = atendime.cd_prestador AND usuarios.cd_usuario(+) 
= USER AND usuario_unid_int.cd_id_usuario = USER AND usuario_unid_int.cd_unid_int 
= unid_int.cd_unid_int AND usuario_unid_int.cd_setor = unid_int.cd_setor AND Atendime.Cd_Multi_Empresa 
= dbamv.pkg_mv2000.le_empresa UNION ALL SELECT usuarios.cd_usuario, atendime.cd_atendimento,
 paciente.nm_paciente, TRUNC (atendime.dt_atendimento) + (atendime.hr_atendimento 
- TRUNC (atendime.hr_atendimento)) dh_atendimento, NULL nm_leito, DECODE (config_pagu.tp_procedimento_lov,
 'C', atendime.cd_cid, atendime.cd_pro_int ) cd_cid, DECODE (config_pagu.tp_procedimento_lov,
 'C', cid.ds_cid, pro_fat.ds_pro_fat ) ds_cid, prestador.nm_prestador, config_hoca.cd_unid_int 
cd_unid_int, unid_int.cd_setor cd_setor, TRUNC (SYSDATE) - TRUNC (atendime.dt_atendimento) 
qt_dias_internacao FROM dbamv.prestador, dbamv.atendime, dbamv.paciente, dbamv.cid,
 dbasgu.usuarios, dbamv.pro_fat, dbamv.config_pagu, dbamv.setor, dbamv.config_hoca,
 dbamv.unid_int WHERE atendime.tp_atendimento = 'H' AND NVL (atendime.dt_alta, TRUNC 
(SYSDATE + 1000)) = TRUNC (SYSDATE + 1000) /* LDAG - Performace - 410370 */ AND atendime.dt_alta 
IS NULL AND config_pagu.sn_carrega_lov = 'S' AND paciente.cd_paciente = atendime.cd_paciente 
AND prestador.cd_prestador = atendime.cd_prestador AND cid.cd_cid(+) = atendime.cd_cid 
AND pro_fat.cd_pro_fat(+) = atendime.cd_pro_int AND usuarios.cd_prestador(+) = atendime.cd_prestador 
AND usuarios.cd_usuario(+) = USER AND unid_int.cd_unid_int = config_hoca.cd_unid_int 
AND setor.cd_setor = unid_int.cd_setor AND Atendime.Cd_Multi_Empresa = dbamv.pkg_mv2000.le_empresa 
UNION ALL SELECT usuarios.cd_usuario, atendime.cd_atendimento, paciente.nm_paciente,
 TRUNC (atendime.dt_atendimento) + (atendime.hr_atendimento - TRUNC (atendime.hr_atendimento)) 
dh_atendimento, NULL nm_leito, DECODE (config_pagu.tp_procedimento_lov, 'C', atendime.cd_cid,
 atendime.cd_pro_int ) cd_cid, DECODE (config_pagu.tp_procedimento_lov, 'C', cid.ds_cid,
 pro_fat.ds_pro_fat ) ds_cid, prestador.nm_prestador, TO_NUMBER (NULL) cd_unid_int,
 ori_ate.cd_setor, TRUNC (SYSDATE) - TRUNC (atendime.dt_atendimento) qt_dias_internacao 
FROM dbamv.prestador, dbamv.atendime, dbamv.paciente, dbamv.cid, dbamv.ori_ate, dbasgu.usuarios,
 dbamv.usuario_unid_int, dbamv.pro_fat, dbamv.config_pagu WHERE atendime.tp_atendimento 
NOT IN ('I', 'H') AND ( TRUNC (atendime.dt_atendimento) + (atendime.hr_atendimento 
- TRUNC (atendime.hr_atendimento)) ) > (SYSDATE - 1) AND paciente.cd_paciente = atendime.cd_paciente 
AND prestador.cd_prestador = atendime.cd_prestador AND cid.cd_cid(+) = atendime.cd_cid 
AND pro_fat.cd_pro_fat(+) = atendime.cd_pro_int AND usuarios.cd_prestador(+) = atendime.cd_prestador 
AND usuarios.cd_usuario(+) = USER AND ori_ate.cd_ori_ate = atendime.cd_ori_ate AND 
usuario_unid_int.cd_setor = ori_ate.cd_setor AND usuario_unid_int.cd_id_usuario = 
USER AND usuario_unid_int.cd_unid_int IS NULL AND Atendime.Cd_Multi_Empresa = dbamv.pkg_mv2000.le_empresa 
WHERE CD_ATENDIMENTO=10 FOR UPDATE OF CD_ATENDIMENTO NOWAIT
.
