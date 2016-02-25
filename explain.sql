set autotrace off timing off
SET VERIFY OFF
--DEFINE SIFUS=USR_SIAFI_OLD

alter session set current_schema=usr_sipro;

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
Select 
P.anoProtocolo ,
 P.numProtocolo , 
 to_char(P.datCriacao,'dd/mm/yyyy hh24:mi') datCriacao ,
 vw.tx_lot , 
 NVL(E.texEspecie,'Espécie não especificada') , 
 NVL(F.texFuncao, 'Função não especificada') ,
 P.texComplementoTitulo , P.texAutorIniciativa , P.indTipoProtocolo ,
NVL(C1.texDescricao,'Primeiro nível de classificação não definido') , 
NVL(C2.texDescricao, 'Segundo nível de classificação não definido') ,
NVL(C3.texDescricao,'Terceiro nível de classificação não definido') , 
P.indStatus , P.indStatusComplementar , 
P.anoDocumentoOriginador ,
P.numDocumentoOriginador 
, P."ROWID" , Pe."ROWID" , E."ROWID" , F."ROWID" , C1."ROWID" , C2."ROWID" , C3."ROWID"
-- ,vw."ROWID" 
From Protocolo P , 
Perfil Pe , 
Especie E , 
Funcao F , 
Classificacao C1 , 
Classificacao C2 , 
Classificacao C3 ,
usr_sipro.vwconsultaintranetlotacoes vw 
Where P.idePerfilCriador = Pe.idePerfil and 
Pe.ideUnidade = vw.ideUnidade and P.ideEspecie =
E.ideEspecie(+) and P.ideFuncao = F.ideFuncao(+) and 
P.ideClassificacao = C1.ideClassificacao(+) and 
C1.ideClassificacaoSuperior =C2.ideClassificacao(+) 
and C2.ideClassificacaoSuperior = C3.ideClassificacao(+) 
and P.ideProtocolo = 1034694
/
