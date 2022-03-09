--DROP materialized view usr_dw_tesourogerencial.viw_covid19_execucao_raw;

CREATE MATERIALIZED VIEW USR_DW_TESOUROGERENCIAL.VIW_COVID19_EXECUCAO_RAW
  SEGMENT CREATION IMMEDIATE
  ORGANIZATION HEAP PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
  NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TBSD_DW_TESOUROGERENCIAL"
  BUILD deferred
  USING INDEX
  REFRESH FORCE ON DEMAND
  USING DEFAULT LOCAL ROLLBACK SEGMENT
  USING ENFORCED CONSTRAINTS DISABLE QUERY REWRITE
AS 
SELECT
  id_orgao_maxi
, co_orgao_maxi
, no_orgao_maxi
, t1.id_uo
, id_funcao_pt
, id_subfuncao_pt
, id_programa_pt
, t1.id_acao_pt
, t1.id_po
, no_po
, no_acao_pt
, id_uo_exercicio
, co_uo
, no_uo
, id_ano_lanc
, id_mes_lanc
, sg_mes_completo
, CASE WHEN t1.id_po IN ('CV19')
            THEN NULL
       WHEN (t1.id_acao_pt, t1.id_po) IN ( ('20TP', 'CV80'), ('212B', 'CV80'), ('212H', 'CV50') )
            THEN (SELECT max(ds_tema) FROM usr_dw_tesourogerencial.tab_covid19_acao_tema WHERE id_acao_pt = '21C0')
            ELSE t2.ds_tema
       END AS ds_tema
, CASE WHEN t1.id_po IN ('CV19')
            THEN NULL
       WHEN (t1.id_acao_pt, t1.id_po) IN ( ('20TP', 'CV80'), ('212B', 'CV80'), ('212H', 'CV50') )
            THEN (SELECT max(ds_subtema) FROM usr_dw_tesourogerencial.tab_covid19_acao_tema WHERE id_acao_pt = '21C0')
            ELSE t2.ds_subtema
       END AS ds_subtema
, dt_movimento
, co_mp
, Max(tx_url_mp) AS tx_url_mp
, Sum(CASE WHEN ID_ITEM_INFORMACAO = 83 THEN va_saldo_item_informacao
           WHEN ID_ITEM_INFORMACAO = 481 THEN -va_saldo_item_informacao ELSE 0 END) AS vlr_autorizado
, Sum(CASE WHEN ID_ITEM_INFORMACAO = 421 THEN va_saldo_item_informacao ELSE 0 END) AS vlr_empenhado
, Sum(CASE WHEN ID_ITEM_INFORMACAO = 423 THEN va_saldo_item_informacao ELSE 0 END) AS vlr_pago
, Sum(CASE WHEN ID_ITEM_INFORMACAO = 911 THEN va_saldo_item_informacao ELSE 0 END) AS vlr_rp_inscr_proc_nproc
, Sum(CASE WHEN ID_ITEM_INFORMACAO = 912 THEN va_saldo_item_informacao ELSE 0 END) AS vlr_rp_cancel_proc_nproc
, Sum(CASE WHEN ID_ITEM_INFORMACAO = 604 THEN va_saldo_item_informacao ELSE 0 END) AS vlr_rp_pago
FROM
(
select /*+ FULL( a11 ) */
    a18.ID_ORGAO_MAXI  ID_ORGAO_MAXI,
    max(a112.CO_ORGAO_MAXI)  CO_ORGAO_MAXI,
    max(a112.NO_ORGAO_MAXI)  NO_ORGAO_MAXI,
    a11.ID_UO  ID_UO,
    a11.ID_FUNCAO_PT  ID_FUNCAO_PT,
    a11.ID_SUBFUNCAO_PT  ID_SUBFUNCAO_PT,
    a11.ID_PROGRAMA_PT  ID_PROGRAMA_PT,
    a11.ID_ACAO_PT  ID_ACAO_PT,
    a11.ID_PO  ID_PO,
    max(a111.NO_PO)  NO_PO,
    max(a114.NO_ACAO_PT)  NO_ACAO_PT,
    a16.ID_UO  ID_UO_EXERCICIO,
    max(a113.CO_UO)  CO_UO,
    max(a113.NO_UO)  NO_UO,
    a15.ID_ANO  ID_ANO_LANC,
    a15.ID_MES  ID_MES_LANC,
    max(a19.SG_MES_COMPLETO)  SG_MES_COMPLETO,
    a14.ID_ITEM_INFORMACAO  ID_ITEM_INFORMACAO,
    max(a110.NO_ITEM_INFORMACAO)  NO_ITEM_INFORMACAO,
    max(a110.CO_ITEM_INFORMACAO)  CO_ITEM_INFORMACAO,
    To_Date((SELECT max(id_ano_siafi * 10000 + id_mes_siafi * 100 + id_dia_siafi) as dat_movimento
             FROM usr_dw_tesouroGerencial.WD_CALENDARIO_SIAFI), 'yyyyMMDD') AS dt_movimento,
    sum(((a11.VA_MOVIMENTO_LIQUIDO * a14.IN_OPERACAO_EXPRESSAO) * a13.PE_TAXA)) va_saldo_item_informacao
from    usr_dw_tesouroGerencial.WF_LANCAMENTO_COMPLETA    a11
    join    usr_dw_tesouroGerencial.WD_MOEDA    a12
      on     (a11.ID_MOEDA_UG_EXEC_H = a12.ID_MOEDA)
    join    usr_dw_tesouroGerencial.WD_TAXA_CAMBIO_MENSAL    a13
      on     (a12.ID_MOEDA = a13.ID_MOEDA_ORIGEM)
    join    usr_dw_tesouroGerencial.WD_ITEM_DECODIFICADO_CCON    a14
      on     (a11.ID_ANO_LANC = a14.ID_ANO_ITEM_CONTA and
    a11.ID_CONTA_CONTABIL_LANC = a14.ID_CONTA_CONTABIL)
    join    usr_dw_tesouroGerencial.WA_MES_ACUM    a15
      on     (a11.ID_ANO_LANC = a15.ID_ANO_ACUM_ANO_SALDO and
    a11.ID_MES_LANC = a15.ID_MES_ACUM_ANO_SALDO)
    JOIN    usr_dw_tesouroGerencial.WD_CONTA_CONTABIL_EXERCICIO    a151
      on     (a11.ID_ANO_LANC = a151.ID_ANO and
           a11.ID_CONTA_CONTABIL_LANC = a151.ID_CONTA_CONTABIL)
    join    usr_dw_tesouroGerencial.WD_UO_EXERCICIO    a16
      on     (a11.ID_ANO_LANC = a16.ID_ANO and
    a11.ID_UO = a16.ID_UO)
    join    usr_dw_tesouroGerencial.WD_ORGAO_EXERCICIO    a17
      on     (a16.ID_ANO = a17.ID_ANO and
    a16.ID_ORGAO_UO = a17.ID_ORGAO)
    join    usr_dw_tesouroGerencial.WD_ORGAO_SUPE_EXERCICIO    a18
      on     (a17.ID_ANO = a18.ID_ANO and
    a17.ID_ORGAO_SUPE = a18.ID_ORGAO_SUPE)
    join    usr_dw_tesouroGerencial.WD_MES    a19
      on     (a15.ID_ANO = a19.ID_ANO and
    a15.ID_MES = a19.ID_MES)
    join    usr_dw_tesouroGerencial.WD_ITEM_INFORMACAO    a110
      on     (a14.ID_ITEM_INFORMACAO = a110.ID_ITEM_INFORMACAO)
    join    usr_dw_tesouroGerencial.WD_PO    a111
      on     (a11.ID_ACAO_PT = a111.ID_ACAO_PT and
    a11.ID_FUNCAO_PT = a111.ID_FUNCAO_PT and
    a11.ID_PO = a111.ID_PO and
    a11.ID_PROGRAMA_PT = a111.ID_PROGRAMA_PT and
    a11.ID_SUBFUNCAO_PT = a111.ID_SUBFUNCAO_PT and
    a11.ID_UO = a111.ID_UO)
    join    usr_dw_tesouroGerencial.WD_ORGAO_MAXI    a112
      on     (a18.ID_ORGAO_MAXI = a112.ID_ORGAO_MAXI)
    join    usr_dw_tesouroGerencial.WD_UO    a113
      on     (a16.ID_UO = a113.ID_UO)
    join    usr_dw_tesouroGerencial.WD_ACAO_PT    a114
      on     (a11.ID_ACAO_PT = a114.ID_ACAO_PT)
    JOIN usr_dw_tesouroGerencial.viw_covid19_execucao_crit crit
      ON  a11.id_uo = crit.id_uo
      AND a11.id_funcao_pt = crit.id_funcao_pt
      AND a11.id_subfuncao_pt = crit.id_subfuncao_pt
      AND a11.id_programa_pt = crit.id_programa_pt
      AND a11.id_acao_pt = crit.id_acao_pt
      AND a11.id_localizador_gasto_pt = crit.id_localizador_gasto_pt
      AND a11.id_po = crit.id_po
where    ((a15.ID_ANO >= 2020)
 and (a14.ID_ITEM_INFORMACAO in (83, 421, 423, 481, 604, 911, 912) or a151.ID_CONTA_CONTABIL_DESTINO in (622120105))
 and a13.ID_ANO = a19.ID_ANO
 and a13.ID_MES = a19.ID_MES)
group by    a18.ID_ORGAO_MAXI,
    a11.ID_UO,
    a11.ID_FUNCAO_PT,
    a11.ID_SUBFUNCAO_PT,
    a11.ID_PROGRAMA_PT,
    a11.ID_ACAO_PT,
    a11.ID_PO,
    a11.ID_ACAO_PT,
    a16.ID_UO,
    a15.ID_ANO,
    a15.ID_MES,
    a14.ID_ITEM_INFORMACAO
) t1
left JOIN usr_dw_tesouroGerencial.tab_covid19_acao_tema t2
ON t1.id_acao_pt = t2.id_acao_pt
left JOIN usr_dw_tesouroGerencial.TAB_COVID19_MP_MAPPING t3
ON t1.id_acao_pt = t3.id_acao_pt
AND t1.id_orgao_maxi = t3.id_orgao_maximo_uo
AND t1.id_uo = t3.id_uo
AND t1.id_po = t3.id_po
GROUP BY
  id_orgao_maxi
, co_orgao_maxi
, no_orgao_maxi
, t1.id_uo
, id_funcao_pt
, id_subfuncao_pt
, id_programa_pt
, t1.id_acao_pt
, t1.id_po
, no_po
, no_acao_pt
, id_uo_exercicio
, co_uo
, no_uo
, id_ano_lanc
, id_mes_lanc
, sg_mes_completo
, co_mp
, ds_tema
, ds_subtema
, dt_movimento
/

GRANT SELECT ON USR_DW_TESOUROGERENCIAL.VIW_COVID19_EXECUCAO_RAW TO ROLDWORCAMENTOCONSULTA;
GRANT SELECT ON USR_DW_TESOUROGERENCIAL.VIW_COVID19_EXECUCAO_RAW TO ROLDWTESOUROGERENCIAL;


exec dbms_mview.refresh( 'USR_DW_TESOUROGERENCIAL.VIW_COVID19_EXECUCAO_RAW' );

col table_name format a30

select distinct i.table_name , i.owner, i.index_name, trunc(o.created)
  from dba_indexes i
  join dba_objects o on (i.owner = o.owner and i.index_name = o.object_name)
  where i.owner='USR_DW_TESOUROGERENCIAL'
 order by trunc(o.created)
/
 
 
19:40:10 p_7236@dgdwhpro7.vpropus7> @topsa %

     Hora Atual: 10/06/2021 19:40:17

     TOP SESSIONS (300 primeiros ativos)
     Cluster - Background: NO

Rank  Sid,Serial#,@I  SPId Svr OraUser                   Cliente              Login       Chamada     Sql ID        AVG Reads(s)    Logical Reads  CPU Time(s) Wait                       Machine                 Programa        Sql Statement
---- --------------------------------------------------- -------------------- ----------- ----------- ------------- ------------ ---------------- ------------ -------------------------- ----------------------- --------------- ------------------------------------------------------------------------------------------
  1:    '49,9598,@1' 17875 DED P_7236                    p_7236               10/06 19:38 10/06 19:38 3s9m4tavw76h2      220.452       18.738.392            0 ASM IO for non-blocking po redecamara\dc-351266    oracle@vpropus7 /* MV_REFRESH (INS) */INSERT /*+ BYPASS_RECURSIVE_CHECK */ INTO "USR_DW_TESOUROGERENCIAL".
  2:  '1238,8041,@1' 17879 DED P_7236                    p_7236               10/06 19:38 10/06 19:38 3s9m4tavw76h2      172.714       14.680.692            0 direct path read           redecamara\dc-351266    oracle@vpropus7 /* MV_REFRESH (INS) */INSERT /*+ BYPASS_RECURSIVE_CHECK */ INTO "USR_DW_TESOUROGERENCIAL".
  3: '1011,34227,@1' 11712 DED P_7236                    p_7236               10/06 19:16 10/06 19:38 3s9m4tavw76h2          213          309.231           34 PX Deq: Execute Reply      redecamara\dc-351266    sqlplus.exe     /* MV_REFRESH (INS) */INSERT /*+ BYPASS_RECURSIVE_CHECK */ INTO "USR_DW_TESOUROGERENCIAL".
  4: '1023,57386,@1'  6809 DED P_7236                    p_7236               10/06 19:40 10/06 19:40 13ucpf0qcvw88          101              706            0 PGA memory operation       redecamara\dc-351266    sqlplus.exe     WITH TOP_SESSIONS AS (   SELECT      s.inst_id INST, S.SID, S.SERIAL# SERIAL, S.STATUS, S.
  5:   '46,19773,@1' 18233 DED P_7236                    p_7236               10/06 19:38 10/06 19:38 3s9m4tavw76h2            1               52            0 PX Deq: Execution Msg      redecamara\dc-351266    oracle@vpropus7 /* MV_REFRESH (INS) */INSERT /*+ BYPASS_RECURSIVE_CHECK */ INTO "USR_DW_TESOUROGERENCIAL".
  6:  '447,29507,@1' 18235 DED P_7236                    p_7236               10/06 19:38 10/06 19:38 3s9m4tavw76h2            1              100            0 PX Deq: Execution Msg      redecamara\dc-351266    oracle@vpropus7 /* MV_REFRESH (INS) */INSERT /*+ BYPASS_RECURSIVE_CHECK */ INTO "USR_DW_TESOUROGERENCIAL".
  7: '1224,58123,@1'  9832 DED P_7236                    p_7236               10/06 19:38 10/06 19:38 3s9m4tavw76h2            1               43            0 PX Deq: Execution Msg      redecamara\dc-351266    oracle@vpropus7 /* MV_REFRESH (INS) */INSERT /*+ BYPASS_RECURSIVE_CHECK */ INTO "USR_DW_TESOUROGERENCIAL".
  8:  '625,51287,@1' 18237 DED P_7236                    p_7236               10/06 19:38 10/06 19:38 3s9m4tavw76h2            1               55            0 PX Deq: Execution Msg      redecamara\dc-351266    oracle@vpropus7 /* MV_REFRESH (INS) */INSERT /*+ BYPASS_RECURSIVE_CHECK */ INTO "USR_DW_TESOUROGERENCIAL".
  9:  '439,26367,@1' 17881 DED P_7236                    p_7236               10/06 19:38 10/06 19:38 3s9m4tavw76h2            0               15            0 PX Deq: Execution Msg      redecamara\dc-351266    oracle@vpropus7 /* MV_REFRESH (INS) */INSERT /*+ BYPASS_RECURSIVE_CHECK */ INTO "USR_DW_TESOUROGERENCIAL".
 10:  '814,41803,@1' 18444 DED SYS                       oracle               02/06 15:51 10/06 19:39 g0bggfqrddc4w            0               27            5 PL/SQL lock timer          vpropus7.redecamara.cam JDBC Thin Clien BEGIN dbms_lock.sleep(60); END;
 11:   '614,3894,@1' 17883 DED P_7236                    p_7236               10/06 19:38 10/06 19:38 3s9m4tavw76h2            0               12            0 PX Deq: Execution Msg      redecamara\dc-351266    oracle@vpropus7 /* MV_REFRESH (INS) */INSERT /*+ BYPASS_RECURSIVE_CHECK */ INTO "USR_DW_TESOUROGERENCIAL".

19:40:17 p_7236@dgdwhpro7.vpropus7> @longs %

USER                                     OPERACAO                                 INICIO      RESTANTE    PASSADO     PERCENT OBJETO
---------------------------------------- ---------------------------------------- ----------- ----------- ----------- ------- --------------------------------------------------
USR_DW_TESOUROGERENCIAL '1238,8041,@1'   TABLE SCAN                               10/06 19:39 00:19:29    00:01:04       5,19 USR_DW_TESOUROGERENCIAL.WF_LANCAMENTO_CO
USR_DW_TESOUROGERENCIAL '49,9598,@1'     TABLE SCAN                               10/06 19:38 01:42:41    00:01:28       1,41 USR_DW_TESOUROGERENCIAL.WF_LANCAMENTO_CO

19:40:20 p_7236@dgdwhpro7.vpropus7> @getsql 3s9m4tavw76h2

                                                               Execs   CPU Time Elapsed Time  Leituras  Leituras       Linhas  Leituras  Leituras  CPU Time Elapsed Time  Versions     Users
Sid Parsing User         Child Address         Plan Hash       Total msecs/Exec   msecs/Exec Log./Exec Fis./Exec  Processadas   Logicas   Fisicas     msecs        msecs  Tot/Open Open/Exec LAST_EXEC
~~~ ~~~~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~ ~~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~~~~~ ~~~~~~~~~ ~~~~~~~~~ ~~~~~~~~~~~~ ~~~~~~~~~ ~~~~~~~~~ ~~~~~~~~~ ~~~~~~~~~~~~ ~~~~~~~~~ ~~~~~~~~~ ~~~~~~~~~~~~~~~~~~~
  1 USR_DW_TESOUROGERENC * 000000009E1EA650   1921358576           0    392.189      520.161   98.921K   11.363K            0   98.921K   11.363K   392.189      520.161       1/1       9/9 10/06/2021 19:43:11

Comando de SQL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/* MV_REFRESH (INS) */INSERT /*+ BYPASS_RECURSIVE_CHECK */ INTO "USR_DW_TESOUROGERENCIAL"."VIW_COVID19_EXECUCAO_RAW" SELECT
id_orgao_maxi
, co_orgao_maxi
, no_orgao_maxi
, t1.id_uo
, id_funcao_pt
, id_subfuncao_pt
, id_programa_pt
, t1.id_acao_pt
, t1.id_po
, no_po
, no_acao_pt
, id_uo_exercicio
, co_uo
, no_uo
, id_ano_lanc
, id_mes_lanc
, sg_mes_completo
, CASE WHEN t1.id_po IN ('CV19')
THEN NULL
WHEN (t1.id_acao_pt, t1.id_po) IN ( ('20TP', 'CV80'), ('212B', 'CV80'), ('212H', 'CV50') )
THEN (SELECT max(ds_tema) FROM usr_dw_tesourogerencial.tab_covid19_acao_tema WHERE id_acao_pt = '21C0')
ELSE t2.ds_tema
END AS ds_tema
, CASE WHEN t1.id_po IN ('CV19')
THEN NULL
WHEN (t1.id_acao_pt, t1.id_po) IN ( ('20TP', 'CV80'), ('212B', 'CV80'), ('212H', 'CV50') )
THEN (SELECT max(ds_subtema) FROM usr_dw_tesourogerencial.tab_covid19_acao_tema WHERE id_acao_pt = '21C0')
ELSE t2.ds_subtema
END AS ds_subtema
, dt_movimento
, co_mp
, Max(tx_url_mp) AS tx_url_mp
, Sum(CASE WHEN ID_ITEM_INFORMACAO = 83 THEN va_saldo_item_informacao
WHEN ID_ITEM_INFORMACAO = 481 THEN -va_saldo_item_informacao ELSE 0 END) AS vlr_autorizado
, Sum(CASE WHEN ID_ITEM_INFORMACAO = 421 THEN va_saldo_item_informacao ELSE 0 END) AS vlr_empenhado
, Sum(CASE WHEN ID_ITEM_INFORMACAO = 423 THEN va_saldo_item_informacao ELSE 0 END) AS vlr_pago
, Sum(CASE WHEN ID_ITEM_INFORMACAO = 911 THEN va_saldo_item_informacao ELSE 0 END) AS vlr_rp_inscr_proc_nproc
, Sum(CASE WHEN ID_ITEM_INFORMACAO = 912 THEN va_saldo_item_informacao ELSE 0 END) AS vlr_rp_cancel_proc_nproc
, Sum(CASE WHEN ID_ITEM_INFORMACAO = 604 THEN va_saldo_item_informacao ELSE 0 END) AS vlr_rp_pago
FROM
(
select /*+ FULL( a11 ) */
a18.ID_ORGAO_MAXI  ID_ORGAO_MAXI,
max(a112.CO_ORGAO_MAXI)  CO_ORGAO_MAXI,
max(a112.NO_ORGAO_MAXI)  NO_ORGAO_MAXI,
a11.ID_UO  ID_UO,
a11.ID_FUNCAO_PT  ID_FUNCAO_PT,
a11.ID_SUBFUNCAO_PT  ID_SUBFUNCAO_PT,
a11.ID_PROGRAMA_PT  ID_PROGRAMA_PT,
a11.ID_ACAO_PT  ID_ACAO_PT,
a11.ID_PO  ID_PO,
max(a111.NO_PO)  NO_PO,
max(a114.NO_ACAO_PT)  NO_ACAO_PT,
a16.ID_UO  ID_UO_EXERCICIO,
max(a113.CO_UO)  CO_UO,
max(a113.NO_UO)  NO_UO,
a15.ID_ANO  ID_ANO_LANC,
a15.ID_MES  ID_MES_LANC,
max(a19.SG_MES_COMPLETO)  SG_MES_COMPLETO,
a14.ID_ITEM_INFORMACAO  ID_ITEM_INFORMACAO,
max(a110.NO_ITEM_INFORMACAO)  NO_ITEM_INFORMACAO,
max(a110.CO_ITEM_INFORMACAO)  CO_ITEM_INFORMACAO,
To_Date((SELECT max(id_ano_siafi * 10000 + id_mes_siafi * 100 + id_dia_siafi) as dat_movimento
FROM usr_dw_tesouroGerencial.WD_CALENDARIO_SIAFI), 'yyyyMMDD') AS dt_movimento,
sum(((a11.VA_MOVIMENTO_LIQUIDO * a14.IN_OPERACAO_EXPRESSAO) * a13.PE_TAXA)) va_saldo_item_informacao
from    usr_dw_tesouroGerencial.WF_LANCAMENTO_COMPLETA    a11
join    usr_dw_tesouroGerencial.WD_MOEDA    a12
on     (a11.ID_MOEDA_UG_EXEC_H = a12.ID_MOEDA)
join    usr_dw_tesouroGerencial.WD_TAXA_CAMBIO_MENSAL    a13
on     (a12.ID_MOEDA = a13.ID_MOEDA_ORIGEM)
join    usr_dw_tesouroGerencial.WD_ITEM_DECODIFICADO_CCON    a14
on     (a11.ID_ANO_LANC = a14.ID_ANO_ITEM_CONTA and
a11.ID_CONTA_CONTABIL_LANC = a14.ID_CONTA_CONTABIL)
join    usr_dw_tesouroGerencial.WA_MES_ACUM    a15
on     (a11.ID_ANO_LANC = a15.ID_ANO_ACUM_ANO_SALDO and
a11.ID_MES_LANC = a15.ID_MES_ACUM_ANO_SALDO)
JOIN    usr_dw_tesouroGerencial.WD_CONTA_CONTABIL_EXERCICIO    a151
on     (a11.ID_ANO_LANC = a151.ID_ANO and
a11.ID_CONTA_CONTABIL_LANC = a151.ID_CONTA_CONTABIL)
join    usr_dw_tesouroGerencial.WD_UO_EXERCICIO    a16
on     (a11.ID_ANO_LANC = a16.ID_ANO and
a11.ID_UO = a16.ID_UO)
join    usr_dw_tesouroGerencial.WD_ORGAO_EXERCICIO    a17
on     (a16.ID_ANO = a17.ID_ANO and
a16.ID_ORGAO_UO = a17.ID_ORGAO)
join    usr_dw_tesouroGerencial.WD_ORGAO_SUPE_EXERCICIO    a18
on     (a17.ID_ANO = a18.ID_ANO and
a17.ID_ORGAO_SUPE = a18.ID_ORGAO_SUPE)
join    usr_dw_tesouroGerencial.WD_MES    a19
on     (a15.ID_ANO = a19.ID_ANO and
a15.ID_MES = a19.ID_MES)
join    usr_dw_tesouroGerencial.WD_ITEM_INFORMACAO    a110
on     (a14.ID_ITEM_INFORMACAO = a110.ID_ITEM_INFORMACAO)
join    usr_dw_tesouroGerencial.WD_PO    a111
on     (a11.ID_ACAO_PT = a111.ID_ACAO_PT and
a11.ID_FUNCAO_PT = a111.ID_FUNCAO_PT and
a11.ID_PO = a111.ID_PO and
a11.ID_PROGRAMA_PT = a111.ID_PROGRAMA_PT and
a11.ID_SUBFUNCAO_PT = a111.ID_SUBFUNCAO_PT and
a11.ID_UO = a111.ID_UO)
join    usr_dw_tesouroGerencial.WD_ORGAO_MAXI    a112
on     (a18.ID_ORGAO_MAXI = a112.ID_ORGAO_MAXI)
join    usr_dw_tesouroGerencial.WD_UO    a113
on     (a16.ID_UO = a113.ID_UO)
join    usr_dw_tesouroGerencial.WD_ACAO_PT    a114
on     (a11.ID_ACAO_PT = a114.ID_ACAO_PT)
JOIN usr_dw_tesouroGerencial.viw_covid19_execucao_crit crit
ON  a11.id_uo = crit.id_uo
AND a11.id_funcao_pt = crit.id_funcao_pt
AND a11.id_subfuncao_pt = crit.id_subfuncao_pt
AND a11.id_programa_pt = crit.id_programa_pt
AND a11.id_acao_pt = crit.id_acao_pt
AND a11.id_localizador_gasto_pt = crit.id_localizador_gasto_pt
AND a11.id_po = crit.id_po
where    ((a15.ID_ANO >= 2020)
and (a14.ID_ITEM_INFORMACAO in (83, 421, 423, 481, 604, 911, 912) or a151.ID_CONTA_CONTABIL_DESTINO in (622120105))
and a13.ID_ANO = a19.ID_ANO
and a13.ID_MES = a19.ID_MES)
group by    a18.ID_ORGAO_MAXI,
a11.ID_UO,
a11.ID_FUNCAO_PT,
a11.ID_SUBFUNCAO_PT,
a11.ID_PROGRAMA_PT,
a11.ID_ACAO_PT,
a11.ID_PO,
a11.ID_ACAO_PT,
a16.ID_UO,
a15.ID_ANO,
a15.ID_MES,
a14.ID_ITEM_INFORMACAO
) t1
left JOIN usr_dw_tesouroGerencial.tab_covid19_acao_tema t2
ON t1.id_acao_pt = t2.id_acao_pt
left JOIN usr_dw_tesouroGerencial.TAB_COVID19_MP_MAPPING t3
ON t1.id_acao_pt = t3.id_acao_pt
AND t1.id_orgao_maxi = t3.id_orgao_maximo_uo
AND t1.id_uo = t3.id_uo
AND t1.id_po = t3.id_po
GROUP BY
id_orgao_maxi
, co_orgao_maxi
, no_orgao_maxi
, t1.id_uo
, id_funcao_pt
, id_subfuncao_pt
, id_programa_pt
, t1.id_acao_pt
, t1.id_po
, no_po
, no_acao_pt
, id_uo_exercicio
, co_uo
, no_uo
, id_ano_lanc
, id_mes_lanc
, sg_mes_completo
, co_mp
, ds_tema
, ds_subtema
, dt_movimento
/

--- Bind Info

--- <End> Bind Info

Plano de Execucao
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                                  | Name                          | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |    TQ  |IN-OUT| PQ Distrib |
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT                                           |                               |       |       |  3450K(100)|          |       |       |        |      |            |
|   1 |  LOAD TABLE CONVENTIONAL                                   | VIW_COVID19_EXECUCAO_RAW      |       |       |            |          |       |       |        |      |            |
|   2 |   SORT AGGREGATE                                           |                               |     1 |    49 |            |          |       |       |        |      |            |
|   3 |    PX COORDINATOR                                          |                               |       |       |            |          |       |       |        |      |            |
|   4 |     PX SEND QC (RANDOM)                                    | :TQ20001                      |     1 |    49 |            |          |       |       |  Q2,01 | P->S | QC (RAND)  |
|   5 |      SORT AGGREGATE                                        |                               |     1 |    49 |            |          |       |       |  Q2,01 | PCWP |            |
|   6 |       TABLE ACCESS BY INDEX ROWID                          | TAB_COVID19_ACAO_TEMA         |     1 |    49 |     1   (0)| 00:00:01 |       |       |  Q2,01 | PCWP |            |
|   7 |        PX RECEIVE                                          |                               |     1 |       |     0   (0)|          |       |       |  Q2,01 | PCWP |            |
|   8 |         PX SEND HASH (BLOCK ADDRESS)                       | :TQ20000                      |     1 |       |     0   (0)|          |       |       |        | S->P | HASH (BLOCK|
|*  9 |          INDEX UNIQUE SCAN                                 | SYS_C001478448                |     1 |       |     0   (0)|          |       |       |        |      |            |
|  10 |   SORT AGGREGATE                                           |                               |     1 |    58 |            |          |       |       |        |      |            |
|  11 |    PX COORDINATOR                                          |                               |       |       |            |          |       |       |        |      |            |
|  12 |     PX SEND QC (RANDOM)                                    | :TQ30001                      |     1 |    58 |            |          |       |       |  Q3,01 | P->S | QC (RAND)  |
|  13 |      SORT AGGREGATE                                        |                               |     1 |    58 |            |          |       |       |  Q3,01 | PCWP |            |
|  14 |       TABLE ACCESS BY INDEX ROWID                          | TAB_COVID19_ACAO_TEMA         |     1 |    58 |     1   (0)| 00:00:01 |       |       |  Q3,01 | PCWP |            |
|  15 |        PX RECEIVE                                          |                               |     1 |       |     0   (0)|          |       |       |  Q3,01 | PCWP |            |
|  16 |         PX SEND HASH (BLOCK ADDRESS)                       | :TQ30000                      |     1 |       |     0   (0)|          |       |       |        | S->P | HASH (BLOCK|
|* 17 |          INDEX UNIQUE SCAN                                 | SYS_C001478448                |     1 |       |     0   (0)|          |       |       |        |      |            |
|  18 |   SORT AGGREGATE                                           |                               |     1 |    10 |            |          |       |       |        |      |            |
|  19 |    PX COORDINATOR                                          |                               |       |       |            |          |       |       |        |      |            |
|  20 |     PX SEND QC (RANDOM)                                    | :TQ10000                      |     1 |    10 |            |          |       |       |  Q1,00 | P->S | QC (RAND)  |
|  21 |      SORT AGGREGATE                                        |                               |     1 |    10 |            |          |       |       |  Q1,00 | PCWP |            |
|  22 |       PX BLOCK ITERATOR                                    |                               | 18786 |   183K|     5   (0)| 00:00:01 |       |       |  Q1,00 | PCWC |            |
|* 23 |        INDEX FAST FULL SCAN                                | PKWD_CALENDARIO_SIAFI         | 18786 |   183K|     5   (0)| 00:00:01 |       |       |  Q1,00 | PCWP |            |
|  24 |   PX COORDINATOR                                           |                               |       |       |            |          |       |       |        |      |            |
|  25 |    PX SEND QC (RANDOM)                                     | :TQ40006                      |     1 |   561 |  3450K  (1)| 00:00:55 |       |       |  Q4,06 | P->S | QC (RAND)  |
|  26 |     HASH GROUP BY                                          |                               |     1 |   561 |  3450K  (1)| 00:00:55 |       |       |  Q4,06 | PCWP |            |
|  27 |      PX RECEIVE                                            |                               |     1 |   561 |  3450K  (1)| 00:00:55 |       |       |  Q4,06 | PCWP |            |
|  28 |       PX SEND HASH                                         | :TQ40005                      |     1 |   561 |  3450K  (1)| 00:00:55 |       |       |  Q4,05 | P->P | HASH       |
|  29 |        HASH GROUP BY                                       |                               |     1 |   561 |  3450K  (1)| 00:00:55 |       |       |  Q4,05 | PCWP |            |
|  30 |         NESTED LOOPS OUTER                                 |                               |     1 |   561 |  3450K  (1)| 00:00:55 |       |       |  Q4,05 | PCWP |            |
|  31 |          NESTED LOOPS OUTER                                |                               |     1 |   464 |  3450K  (1)| 00:00:55 |       |       |  Q4,05 | PCWP |            |
|  32 |           VIEW                                             |                               |     1 |   362 |  3450K  (1)| 00:00:55 |       |       |  Q4,05 | PCWP |            |
|  33 |            SORT GROUP BY                                   |                               |     1 |   483 |  3450K  (1)| 00:00:55 |       |       |  Q4,05 | PCWP |            |
|  34 |             PX RECEIVE                                     |                               |     1 |   483 |  3450K  (1)| 00:00:55 |       |       |  Q4,05 | PCWP |            |
|  35 |              PX SEND HASH                                  | :TQ40004                      |     1 |   483 |  3450K  (1)| 00:00:55 |       |       |  Q4,04 | P->P | HASH       |
|  36 |               SORT GROUP BY                                |                               |     1 |   483 |  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|  37 |                NESTED LOOPS                                |                               |     1 |   483 |  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|  38 |                 NESTED LOOPS                               |                               |   178 |   483 |  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|  39 |                  NESTED LOOPS                              |                               |     1 |   408 |  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|  40 |                   NESTED LOOPS                             |                               |     1 |   346 |  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|  41 |                    NESTED LOOPS                            |                               |     1 |   304 |  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|  42 |                     NESTED LOOPS                           |                               |     2 |   574 |  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|  43 |                      NESTED LOOPS                          |                               |     2 |   536 |  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|  44 |                       NESTED LOOPS                         |                               |     2 |   452 |  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|  45 |                        NESTED LOOPS                        |                               |     2 |   426 |  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|  46 |                         NESTED LOOPS                       |                               |     2 |   398 |  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|  47 |                          NESTED LOOPS                      |                               |     2 |   296 |  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|* 48 |                           HASH JOIN                        |                               |     2 |   268 |  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|  49 |                            JOIN FILTER CREATE              | :BF0000                       |   344 | 11008 |     2   (0)| 00:00:01 |       |       |  Q4,04 | PCWP |            |
|  50 |                             MAT_VIEW ACCESS FULL           | VIW_COVID19_EXECUCAO_CRIT     |   344 | 11008 |     2   (0)| 00:00:01 |       |       |  Q4,04 | PCWP |            |
|* 51 |                            HASH JOIN                       |                               |  3555K|   345M|  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|  52 |                             PX RECEIVE                     |                               |   230 | 11730 |     8   (0)| 00:00:01 |       |       |  Q4,04 | PCWP |            |
|  53 |                              PX SEND PARTITION (KEY)       | :TQ40003                      |   230 | 11730 |     8   (0)| 00:00:01 |       |       |  Q4,03 | P->P | PART (KEY) |
|  54 |                               NESTED LOOPS                 |                               |   230 | 11730 |     8   (0)| 00:00:01 |       |       |  Q4,03 | PCWP |            |
|* 55 |                                HASH JOIN                   |                               |   230 | 10810 |     8   (0)| 00:00:01 |       |       |  Q4,03 | PCWP |            |
|  56 |                                 JOIN FILTER CREATE         | :BF0001                       |   144 |  4320 |     4   (0)| 00:00:01 |       |       |  Q4,03 | PCWP |            |
|  57 |                                  PX RECEIVE                |                               |   144 |  4320 |     4   (0)| 00:00:01 |       |       |  Q4,03 | PCWP |            |
|  58 |                                   PX SEND BROADCAST        | :TQ40002                      |   144 |  4320 |     4   (0)| 00:00:01 |       |       |  Q4,02 | P->P | BROADCAST  |
|* 59 |                                    HASH JOIN BUFFERED      |                               |   144 |  4320 |     4   (0)| 00:00:01 |       |       |  Q4,02 | PCWP |            |
|  60 |                                     PX RECEIVE             |                               |    90 |  1440 |     2   (0)| 00:00:01 |       |       |  Q4,02 | PCWP |            |
|  61 |                                      PX SEND HYBRID HASH   | :TQ40000                      |    90 |  1440 |     2   (0)| 00:00:01 |       |       |  Q4,00 | P->P | HYBRID HASH|
|  62 |                                       STATISTICS COLLECTOR |                               |       |       |            |          |       |       |  Q4,00 | PCWC |            |
|  63 |                                        PX BLOCK ITERATOR   |                               |    90 |  1440 |     2   (0)| 00:00:01 |       |       |  Q4,00 | PCWC |            |
|* 64 |                                         TABLE ACCESS FULL  | WD_MES                        |    90 |  1440 |     2   (0)| 00:00:01 |       |       |  Q4,00 | PCWP |            |
|  65 |                                     PX RECEIVE             |                               |   240 |  3360 |     2   (0)| 00:00:01 |       |       |  Q4,02 | PCWP |            |
|  66 |                                      PX SEND HYBRID HASH   | :TQ40001                      |   240 |  3360 |     2   (0)| 00:00:01 |       |       |  Q4,01 | P->P | HYBRID HASH|
|  67 |                                       PX BLOCK ITERATOR    |                               |   240 |  3360 |     2   (0)| 00:00:01 |       |       |  Q4,01 | PCWC |            |
|* 68 |                                        TABLE ACCESS FULL   | WA_MES_ACUM                   |   240 |  3360 |     2   (0)| 00:00:01 |       |       |  Q4,01 | PCWP |            |
|  69 |                                 JOIN FILTER USE            | :BF0001                       |   681 | 11577 |     4   (0)| 00:00:01 |       |       |  Q4,03 | PCWP |            |
|  70 |                                  PX BLOCK ITERATOR         |                               |   681 | 11577 |     4   (0)| 00:00:01 |       |       |  Q4,03 | PCWC |            |
|* 71 |                                   TABLE ACCESS FULL        | WD_TAXA_CAMBIO_MENSAL         |   681 | 11577 |     4   (0)| 00:00:01 |       |       |  Q4,03 | PCWP |            |
|* 72 |                                INDEX UNIQUE SCAN           | PKWD_MOEDA                    |     1 |     4 |     0   (0)|          |       |       |  Q4,03 | PCWP |            |
|  73 |                             JOIN FILTER USE                | :BF0000                       |   733M|    34G|  3450K  (1)| 00:00:55 |       |       |  Q4,04 | PCWP |            |
|  74 |                              PX PARTITION RANGE ALL        |                               |   733M|    34G|  3450K  (1)| 00:00:55 |     1 |1048575|  Q4,04 | PCWC |            |
|  75 |                               PX PARTITION LIST ALL        |                               |   733M|    34G|  3450K  (1)| 00:00:55 |     1 |    16 |  Q4,04 | PCWC |            |
|* 76 |                                TABLE ACCESS FULL           | WF_LANCAMENTO_COMPLETA        |   733M|    34G|  3450K  (1)| 00:00:55 |     1 |1048575|  Q4,04 | PCWP |            |
|  77 |                           TABLE ACCESS BY INDEX ROWID      | WD_UO_EXERCICIO               |     1 |    14 |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|* 78 |                            INDEX UNIQUE SCAN               | PKWD_UO_EXERCICIO             |     1 |       |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|  79 |                          TABLE ACCESS BY INDEX ROWID       | WD_UO                         |     1 |    51 |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|* 80 |                           INDEX UNIQUE SCAN                | PKWD_UO                       |     1 |       |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|  81 |                         TABLE ACCESS BY INDEX ROWID        | WD_ORGAO_EXERCICIO            |     1 |    14 |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|* 82 |                          INDEX UNIQUE SCAN                 | PKWD_ORGAO_EXERCICIO          |     1 |       |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|  83 |                        TABLE ACCESS BY INDEX ROWID         | WD_ORGAO_SUPE_EXERCICIO       |     1 |    13 |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|* 84 |                         INDEX UNIQUE SCAN                  | PKWD_ORGAO_SUPE_EXERC         |     1 |       |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|  85 |                       TABLE ACCESS BY INDEX ROWID          | WD_ORGAO_MAXI                 |     1 |    42 |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|* 86 |                        INDEX UNIQUE SCAN                   | PKWD_ORGAO_MAXI               |     1 |       |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|* 87 |                      INDEX RANGE SCAN                      | PKWD_ITEM_DECODIFICADO_CCON   |     1 |    19 |     2   (0)| 00:00:01 |       |       |  Q4,04 | PCWP |            |
|* 88 |                     TABLE ACCESS BY INDEX ROWID            | WD_CONTA_CONTABIL_EXERCICIO   |     1 |    17 |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|* 89 |                      INDEX UNIQUE SCAN                     | PKWD_CONTA_CONTABIL_EXERCICIO |     1 |       |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|  90 |                    TABLE ACCESS BY INDEX ROWID             | WD_ITEM_INFORMACAO            |     1 |    42 |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|* 91 |                     INDEX UNIQUE SCAN                      | PKWD_ITEM_INFORMACAO          |     1 |       |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|  92 |                   TABLE ACCESS BY INDEX ROWID              | WD_ACAO_PT                    |     1 |    62 |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|* 93 |                    INDEX UNIQUE SCAN                       | PKWD_ACAO_PT                  |     1 |       |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|* 94 |                  INDEX RANGE SCAN                          | IX_PO_ID_PO                   |   178 |       |     0   (0)|          |       |       |  Q4,04 | PCWP |            |
|* 95 |                 TABLE ACCESS BY INDEX ROWID                | WD_PO                         |     1 |    75 |    10   (0)| 00:00:01 |       |       |  Q4,04 | PCWP |            |
|  96 |           TABLE ACCESS BY INDEX ROWID                      | TAB_COVID19_ACAO_TEMA         |     1 |   102 |     0   (0)|          |       |       |  Q4,05 | PCWP |            |
|* 97 |            INDEX UNIQUE SCAN                               | SYS_C001478448                |     1 |       |     0   (0)|          |       |       |  Q4,05 | PCWP |            |
|  98 |          TABLE ACCESS BY INDEX ROWID BATCHED               | TAB_COVID19_MP_MAPPING        |     1 |    97 |     1   (0)| 00:00:01 |       |       |  Q4,05 | PCWP |            |
|* 99 |           INDEX RANGE SCAN                                 | SYS_C001485403                |     1 |       |     0   (0)|          |       |       |  Q4,05 | PCWP |            |
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   9 - access("ID_ACAO_PT"='21C0')
  17 - access("ID_ACAO_PT"='21C0')
  23 - access(:Z>=:Z AND :Z<=:Z)
  48 - access("A11"."ID_UO"="CRIT"."ID_UO" AND "A11"."ID_FUNCAO_PT"="CRIT"."ID_FUNCAO_PT" AND "A11"."ID_SUBFUNCAO_PT"="CRIT"."ID_SUBFUNCAO_PT" AND
              "A11"."ID_PROGRAMA_PT"="CRIT"."ID_PROGRAMA_PT" AND "A11"."ID_ACAO_PT"="CRIT"."ID_ACAO_PT" AND "A11"."ID_LOCALIZADOR_GASTO_PT"="CRIT"."ID_LOCALIZADOR_GASTO_PT" AND
              "A11"."ID_PO"="CRIT"."ID_PO")
  51 - access("A11"."ID_ANO_LANC"="A15"."ID_ANO_ACUM_ANO_SALDO" AND "A11"."ID_MES_LANC"="A15"."ID_MES_ACUM_ANO_SALDO" AND "A11"."ID_MOEDA_UG_EXEC_H"="A12"."ID_MOEDA")
  55 - access("A13"."ID_ANO"="A19"."ID_ANO" AND "A13"."ID_MES"="A19"."ID_MES")
  59 - access("A15"."ID_ANO"="A19"."ID_ANO" AND "A15"."ID_MES"="A19"."ID_MES")
  64 - access(:Z>=:Z AND :Z<=:Z)
       filter("A19"."ID_ANO">=2020)
  68 - access(:Z>=:Z AND :Z<=:Z)
       filter("A15"."ID_ANO">=2020)
  71 - access(:Z>=:Z AND :Z<=:Z)
       filter(("A13"."ID_ANO">=2020 AND SYS_OP_BLOOM_FILTER(:BF0001,"A13"."ID_ANO","A13"."ID_MES")))
  72 - access("A12"."ID_MOEDA"="A13"."ID_MOEDA_ORIGEM")
  76 - filter(SYS_OP_BLOOM_FILTER(:BF0000,"A11"."ID_UO","A11"."ID_FUNCAO_PT","A11"."ID_SUBFUNCAO_PT","A11"."ID_PROGRAMA_PT","A11"."ID_ACAO_PT","A11"."ID_LOCALIZADOR_GASTO_PT","A
              11"."ID_PO"))
  78 - access("A11"."ID_ANO_LANC"="A16"."ID_ANO" AND "A11"."ID_UO"="A16"."ID_UO")
  80 - access("A16"."ID_UO"="A113"."ID_UO")
  82 - access("A16"."ID_ANO"="A17"."ID_ANO" AND "A16"."ID_ORGAO_UO"="A17"."ID_ORGAO")
  84 - access("A17"."ID_ANO"="A18"."ID_ANO" AND "A17"."ID_ORGAO_SUPE"="A18"."ID_ORGAO_SUPE")
  86 - access("A18"."ID_ORGAO_MAXI"="A112"."ID_ORGAO_MAXI")
  87 - access("A11"."ID_ANO_LANC"="A14"."ID_ANO_ITEM_CONTA" AND "A11"."ID_CONTA_CONTABIL_LANC"="A14"."ID_CONTA_CONTABIL")
       filter("A11"."ID_CONTA_CONTABIL_LANC"="A14"."ID_CONTA_CONTABIL")
  88 - filter((INTERNAL_FUNCTION("A14"."ID_ITEM_INFORMACAO") OR "A151"."ID_CONTA_CONTABIL_DESTINO"=622120105))
  89 - access("A11"."ID_CONTA_CONTABIL_LANC"="A151"."ID_CONTA_CONTABIL" AND "A11"."ID_ANO_LANC"="A151"."ID_ANO")
  91 - access("A14"."ID_ITEM_INFORMACAO"="A110"."ID_ITEM_INFORMACAO")
  93 - access("A11"."ID_ACAO_PT"="A114"."ID_ACAO_PT")
  94 - access("A11"."ID_PO"="A111"."ID_PO")
  95 - filter(("A11"."ID_UO"="A111"."ID_UO" AND "A11"."ID_ACAO_PT"="A111"."ID_ACAO_PT" AND "A11"."ID_PROGRAMA_PT"="A111"."ID_PROGRAMA_PT" AND
              "A11"."ID_SUBFUNCAO_PT"="A111"."ID_SUBFUNCAO_PT" AND "A11"."ID_FUNCAO_PT"="A111"."ID_FUNCAO_PT"))
  97 - access("T1"."ID_ACAO_PT"="T2"."ID_ACAO_PT")
  99 - access("T1"."ID_ACAO_PT"="T3"."ID_ACAO_PT" AND "T1"."ID_PO"="T3"."ID_PO")
       filter(("T1"."ID_PO"="T3"."ID_PO" AND "T1"."ID_UO"=TO_NUMBER("T3"."ID_UO") AND "T1"."ID_ORGAO_MAXI"=TO_NUMBER("T3"."ID_ORGAO_MAXIMO_UO")))

Parametro            Valor
-------------------- ------------------------------
cursor_sharing       EXACT
optimizer_mode       ALL_ROWS
sql_id               3s9m4tavw76h2
child_address        000000009E1EA650
plan_hash_value      1921358576

19:43:14 p_7236@dgdwhpro7.vpropus7>