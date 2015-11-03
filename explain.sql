set autotrace off timing off
SET VERIFY OFF
--DEFINE SIFUS=USR_SIAFI_OLD

alter session set current_schema=usr_folhacd;

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

EXPLAIN PLAN SET STATEMENT_ID='&1.' INTO sys.plan_table$ FOR
select
e.IDEOBJETO as id,
'AFASTAMENTO' as tipo,
s.numponto as numPontoServidor,
i.TEXDESCRICAO as nomOcorrenciaExterna,
e.DATINICIOHISTORICO as datInicioOcorrencia,
a.horarioinicial as nmdInicioOcorrencia,
e.DATFIMHISTORICO as datFimOcorrencia,
a.horariofinal as nmdFimOcorrencia,
a.DATULTIMAALTERACAO
from AFASTAMENTO a
inner join SERVIDOREVENTOHISTORICO e on a.IDESERVEVENTOHIST = e.IDEOBJETO
inner join servidor s on e.IDESERVIDOR = s.IDEOBJETO
inner join TABELAITEM i on e.IDETABELAITEM = i.IDEOBJETO
inner join TIPOAFASTAMENTO t on i.IDEOBJETO = t.IDETABELAITEM
where (a.INDCANCELADOSISTEMA is null or a.INDCANCELADOSISTEMA = 'N')
and e.DATCANCELAMENTO is null
and a.indefeitonoeponto = 'Y'
and s.numponto = :1
and e.DATINICIOHISTORICO <= :2
and e.DATFIMHISTORICO >= :3
UNION ALL
select
f.IDEOBJETO as id,
'FERIADO' as tipo,
:4  as numPontoServidor,
f.TEXDESCRICAO as nomOcorrenciaExterna,
to_date (f.diaferiado || '/' || f.mesferiado || '/' || f.anoferiado, 'dd/MM/yyyy') as datInicioOcorrencia,
case
when f.numturno in (0, 7) then 0
when BITAND(f.numturno, 1) = 1 then  8*60
when BITAND(f.numturno, 2) = 2 then 14*60
when BITAND(f.numturno, 4) = 4 then 18*60
else null
end as nmdInicioOcorrencia,
to_date (f.diaferiado || '/' || f.mesferiado || '/' || f.anoferiado, 'dd/MM/yyyy') as datFimOcorrencia,
case
when f.numturno in (0, 7) then 24*60
when BITAND(f.numturno, 4) = 4 then 22*60
when BITAND(f.numturno, 2) = 2 then 18*60
when BITAND(f.numturno, 1) = 1 then 12*60
else null
end as nmdFimOcorrencia,
f.DATULTIMAALTERACAO
from FERIADO f
where f.anoferiado = :5  and f.mesferiado = :6
/

select
e.IDEOBJETO as id,
'AFASTAMENTO' as tipo,
s.numponto as numPontoServidor,
i.TEXDESCRICAO as nomOcorrenciaExterna,
e.DATINICIOHISTORICO as datInicioOcorrencia,
a.horarioinicial as nmdInicioOcorrencia,
e.DATFIMHISTORICO as datFimOcorrencia,
a.horariofinal as nmdFimOcorrencia,
a.DATULTIMAALTERACAO
from servidor s 
inner join SERVIDOREVENTOHISTORICO e on e.IDESERVIDOR = s.IDEOBJETO
inner join AFASTAMENTO a on a.IDESERVEVENTOHIST = e.IDEOBJETO
inner join TABELAITEM i on e.IDETABELAITEM = i.IDEOBJETO
inner join TIPOAFASTAMENTO t on i.IDEOBJETO = t.IDETABELAITEM
where (a.INDCANCELADOSISTEMA is null or a.INDCANCELADOSISTEMA = 'N')
and e.DATCANCELAMENTO is null
and a.indefeitonoeponto = 'Y'
and s.numponto = :1
and e.DATINICIOHISTORICO <= :2
and e.DATFIMHISTORICO >= :3
UNION ALL
select
f.IDEOBJETO as id,
'FERIADO' as tipo,
:4  as numPontoServidor,
f.TEXDESCRICAO as nomOcorrenciaExterna,
to_date (f.diaferiado || '/' || f.mesferiado || '/' || f.anoferiado, 'dd/MM/yyyy') as datInicioOcorrencia,
case
when f.numturno in (0, 7) then 0
when BITAND(f.numturno, 1) = 1 then  8*60
when BITAND(f.numturno, 2) = 2 then 14*60
when BITAND(f.numturno, 4) = 4 then 18*60
else null
end as nmdInicioOcorrencia,
to_date (f.diaferiado || '/' || f.mesferiado || '/' || f.anoferiado, 'dd/MM/yyyy') as datFimOcorrencia,
case
when f.numturno in (0, 7) then 24*60
when BITAND(f.numturno, 4) = 4 then 22*60
when BITAND(f.numturno, 2) = 2 then 18*60
when BITAND(f.numturno, 1) = 1 then 12*60
else null
end as nmdFimOcorrencia,
f.DATULTIMAALTERACAO
from FERIADO f
where f.anoferiado = :5  and f.mesferiado = :6
.