SET VERIFY OFF TERMOUT OFF LINES 320 DEFINE ON FEEDBACK OFF
/*
CREATE GLOBAL TEMPORARY TABLE SYSTEM.SEGMENT_MONIT_SPACE_TEMP
(    
  SEGMENT_OWNER VARCHAR2(30 CHAR),
  TABLE_NAME VARCHAR2(30 CHAR),
  GROUP_NAME VARCHAR2(30 CHAR),
  GROUP_TYPE VARCHAR2(30 CHAR),
  TABLESPACE_NAME VARCHAR2(30 CHAR),
  SEGMENT_NAME VARCHAR2(30 CHAR),
  PARTITION_NAME VARCHAR2(30 CHAR),
  SEGMENT_TYPE VARCHAR2(30 CHAR),
  SEGMENT_BYTES NUMBER,
  NEXT NUMBER,
  VAR_NEXT CHAR(1 CHAR),
  NFRAGS NUMBER,
  HEADER_FILE NUMBER,
  HEADER_BLOCK NUMBER,
  TOTAL_BLOCKS NUMBER,
  UNUSED_BLOCKS NUMBER
) 
ON COMMIT PRESERVE ROWS
.

CREATE OR REPLACE PROCEDURE SYSTEM.SEGMENT_UNUSED_SPACE 
(
 P_SEGMENT_OWNER             IN     VARCHAR2
,P_SEGMENT_NAME              IN     VARCHAR2
,P_SEGMENT_TYPE              IN     VARCHAR2
,P_TOTAL_BLOCKS              IN OUT NUMBER
,P_TOTAL_BYTES               IN OUT NUMBER
,P_UNUSED_BLOCKS             IN OUT NUMBER
,P_UNUSED_BYTES              IN OUT NUMBER
,P_LAST_USED_EXTENT_FILE_ID  IN OUT NUMBER
,P_LAST_USED_EXTENT_BLOCK_ID IN OUT NUMBER
,P_LAST_USED_BLOCK           IN OUT NUMBER
,P_PARTITION_NAME            IN     VARCHAR2 DEFAULT null
)
AS
begin
sys.dbms_space.unused_space (
  segment_owner             => p_segment_owner,
  segment_name              => p_segment_name,
  segment_type              => CASE UPPER(p_segment_type) WHEN 'LOBSEGMENT' THEN 'LOB' WHEN 'LOBINDEX' THEN 'INDEX' ELSE UPPER(p_segment_type) END,
  partition_name            => p_partition_name,
  total_blocks              => p_total_blocks,
  total_bytes               => p_total_bytes,
  unused_blocks             => p_unused_blocks,
  unused_bytes              => p_unused_bytes,
  last_used_extent_file_id  => p_last_used_extent_file_id,
  last_used_extent_block_id => p_last_used_extent_block_id,
  last_used_block           => p_last_used_block);
end;
.

*/

--@monit.segments.sql 'no' 'no' '' '%' 'usr_sipro' 'IDXT_CONTEUDODOC_BLODOC' '100' '0'

COLUMN cls_where new_value cls_where NOPRINT;

DEFINE v_agrupar="UPPER('&1.')"
DEFINE v_resumir="UPPER('&2.')"
DEFINE v_sort="UPPER('&3.')"
DEFINE v_tbs="UPPER('&4.')"
DEFINE v_owner="UPPER('&5.')"
DEFINE v_obj="UPPER('&6.')"
DEFINE v_pctocup_max='&7.'
DEFINE v_megas_min='&8.'

SELECT
  CASE WHEN INSTR( '&6.', ',' ) > 0
    THEN 'IN ('''||REPLACE(REPLACE(UPPER( '&6' ), ' ', ''), ',', ''',''')||''')'
    ELSE UPPER('LIKE ''&6.''')
    END cls_where
FROM DUAL
/

DELETE SYSTEM.SEGMENT_MONIT_SPACE_TEMP;

INSERT INTO SYSTEM.SEGMENT_MONIT_SPACE_TEMP
WITH SEGMENTOS AS -- PRIMEIRA PASSADA: VARIAS TRANSFORMACOES PARA FORMAR GRUPOS RAZOAVEIS
(
  SELECT /*+materialize*/
    s.owner AS segment_owner
   ,TRIM( CASE
      WHEN s.segment_name LIKE 'DR$%' OR s.segment_name LIKE 'DRC$%'
        THEN (SELECT i.table_name
              FROM dba_indexes i
              WHERE SUBSTR( s.segment_name, INSTR(s.segment_name,'$',1,1)+1, INSTR(s.segment_name||'$', '$',1,2 )-INSTR(s.segment_name,'$',1,1)-1 ) = i.index_name
              AND s.owner = i.owner)
      WHEN s.segment_type IN ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION')
        THEN s.segment_name
      WHEN s.segment_type IN ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION')
        THEN (SELECT i.table_name
              FROM dba_indexes i
              WHERE s.segment_name = i.index_name AND s.owner = i.owner)
      WHEN s.segment_type IN ('LOBSEGMENT', 'LOB PARTITION')
        THEN (SELECT l.table_name
              FROM dba_lobs l
              WHERE s.segment_name = l.segment_name AND s.owner = l.owner)
      WHEN s.segment_type IN ('LOBINDEX')
        THEN (SELECT l.table_name
              FROM dba_lobs l
              WHERE s.segment_name = l.index_name AND s.owner = l.owner)
      ELSE 'Desconhecido'
    END ) AS table_name
   ,CASE
      WHEN s.segment_name LIKE 'DR$%' OR s.segment_name LIKE 'DRC$%'
        THEN SUBSTR( s.segment_name, INSTR(s.segment_name,'$',1,1)+1, INSTR(s.segment_name||'$', '$',1,2 )-INSTR(s.segment_name,'$',1,1)-1 )
      WHEN s.segment_type IN ( 'TABLE PARTITION', 'TABLE SUBPARTITION')
        THEN s.segment_name
      WHEN s.segment_type IN ( 'INDEX PARTITION', 'INDEX SUBPARTITION')
        THEN (SELECT i.table_name
              FROM dba_indexes i
              WHERE s.segment_name = i.index_name AND s.owner = i.owner)
        ELSE NULL
    END AS group_name
   ,CASE
      WHEN s.segment_name LIKE 'DR$%' OR s.segment_name LIKE 'DRC$%'
        THEN 'TEXTINDEX'
      WHEN s.segment_type IN ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION')
        THEN 'INDEX'
      WHEN s.segment_type IN ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION')
        THEN 'TABLE'
      WHEN s.segment_type IN ('LOBSEGMENT', 'LOB PARTITION')
        THEN 'LOBSEGMNT'
        ELSE s.segment_type
    END AS group_type
   ,s.tablespace_name
   ,s.segment_name   AS segment_name
   ,s.partition_name AS partition_name
   ,s.segment_type   AS segment_type
   ,s.bytes          AS segment_bytes
   ,s.next_extent    AS next
   ,DECODE(NVL(s.pct_increase,0), 0, '', '*' ) AS var_next
   ,s.extents AS nfrags
   ,s.header_file
   ,s.header_block
  FROM DBA_SEGMENTS s
  WHERE s.tablespace_name LIKE &v_tbs.
  AND s.owner LIKE &v_owner.
  AND s.segment_name NOT LIKE 'BIN$%'
  AND s.segment_type NOT IN ( 'TEMPORARY' )
),
SEGMENTOS2 AS -- SEGUNDA PASSADA: PARA LIMPAR NOME DA TABELA E AJUSTAR GRUPO
(
  SELECT
     SS.segment_owner
    ,CASE WHEN SS.table_name LIKE 'DR$%' OR SS.table_name LIKE 'DRC$%'
        THEN (SELECT i.table_name
              FROM dba_indexes i
              WHERE SUBSTR( SS.table_name, INSTR(SS.table_name,'$',1,1)+1, INSTR(SS.table_name||'$', '$',1,2 )-INSTR(SS.table_name,'$',1,1)-1 ) = i.index_name
              AND SS.segment_owner = i.owner)
        ELSE SS.table_name
     END AS table_name
    ,CASE WHEN SS.table_name LIKE 'DR$%' OR SS.table_name LIKE 'DRC$%'
        THEN SUBSTR( SS.table_name, INSTR(SS.table_name,'$',1,1)+1, INSTR(SS.table_name||'$', '$',1,2 )-INSTR(SS.table_name,'$',1,1)-1 )
        ELSE SS.group_name
     END  AS group_name
    ,SS.group_type
    ,SS.tablespace_name
    ,SS.segment_name
    ,SS.partition_name
    ,SS.segment_type
    ,SS.segment_bytes
    ,SS.next
    ,SS.var_next
    ,SS.nfrags
    ,SS.header_file
    ,SS.header_block
    ,TO_NUMBER(NULL) n1
    ,TO_NUMBER(NULL) n2
  FROM SEGMENTOS SS
)
SELECT * FROM SEGMENTOS2
WHERE ( SEGMENTOS2.table_name &cls_where. OR SEGMENTOS2.group_name &cls_where. OR SEGMENTOS2.segment_name &cls_where. );

------------------------
-- AQUI COMEÇA O PL/SQL PARA IMPRIMIR OS DADOS
------------------------

SET TERMOUT ON SERVEROUT ON VERIFY Off LINES 250 FEED OFF

PROMPT
PROMPT   Tablespaces=&v_tbs. | Owner=&v_owner. | Objetos=&v_obj. | Agrupar por tabelas=&v_agrupar. | Resumir=&v_resumir. | Ocupacao <= &v_pctocup_max.% e Tamanho >= &v_megas_min.M
PROMPT
DECLARE

  v_resumir2          BOOLEAN := &v_agrupar. = 'YES' or &v_resumir. = 'YES';

  segment_size_blocks NUMBER;
  segment_size_bytes  NUMBER;
  used_blocks         NUMBER;
  used_bytes          NUMBER;
  expired_blocks      NUMBER;
  expired_bytes       NUMBER;
  unexpired_blocks    NUMBER;
  unexpired_bytes     NUMBER;

  v_total_blocks      NUMBER;
  v_total_bytes       NUMBER;
  v_unused_blocks     NUMBER;
  v_unused_bytes      NUMBER;

  last_ext_file_id    NUMBER;
  last_ext_blk_id     NUMBER;
  last_used_blk       NUMBER;

  result_table        NVARCHAR2(128);
  result_segment_type NVARCHAR2(128);
  result_segment_name NVARCHAR2(128);
  result_used_mb      NUMBER;
  result_unused_mb    NUMBER;
  result_total_mb     NUMBER;

  block_size          NUMBER;

  V_AUX INTEGER;

  TOT_MEGAS NUMBER;
  EMPTY_MEGAS NUMBER;
  NEXT_MEGAS NUMBER;

  G_TOT_MEGAS NUMBER;
  G_EMPTY_MEGAS NUMBER;

  CPART VARCHAR2(200);

  VPCTFREE  NUMBER(3) := NULL;
  VPCTUSED  NUMBER(3) := NULL;
  VINITRANS NUMBER(3) := NULL;
  VMAXTRANS NUMBER(3) := NULL;
  VHIBOUNDVAL  varchar2(3000) := NULL;
  VPNAME       varchar2(3000) := NULL;
  VPHIBOUNDVAL varchar2(3000) := NULL;

  LAST_SEGMENT VARCHAR2(32) := 'X';
  LAST_TABLE   VARCHAR2(32) ;

  FIRST          BOOLEAN := TRUE;

  LAST_WAS_PART  BOOLEAN := FALSE;

  AC_TOT_MEGAS    NUMBER;
  AC_EMPTY_MEGAS  NUMBER;
  AC_CNFRAGS      NUMBER;
  AC_CVAR_NEXT    VARCHAR2(1);
  AC_CNEXT        NUMBER;

  AC_VPCTFREE     NUMBER;
  AC_VPCTUSED     NUMBER;
  AC_VINITRANS    NUMBER;
  AC_VMAXTRANS    NUMBER;

  CURSOR C1 IS
    SELECT * FROM SYSTEM.SEGMENT_MONIT_SPACE_TEMP FOR UPDATE;

  CURSOR C2 IS
    WITH GRUPO AS
    (
      SELECT
         SEGMENT_OWNER SEGMENT_OWNER
        ,TABLE_NAME TABLE_NAME
        ,DECODE(&v_agrupar., 'YES', 'TABLE', DECODE( &v_resumir., 'YES', GROUP_TYPE, SEGMENT_TYPE)) SEGMENT_TYPE
        ,DECODE(&v_agrupar., 'YES', ' ', TABLESPACE_NAME) TABLESPACE_NAME
        ,DECODE(&v_agrupar., 'YES', ' ', DECODE( &v_resumir., 'YES', 
           CASE WHEN SEGMENT_TYPE LIKE '%INDEX' OR group_TYPE in( 'LOBSEGMNT','TEXTINDEX') THEN NVL(GROUP_NAME,SEGMENT_NAME) ELSE SEGMENT_NAME END, SEGMENT_NAME) ) SEGMENT_NAME
        ,DECODE(&v_agrupar., 'YES', ' ', DECODE( &v_resumir., 'YES', ' ', PARTITION_NAME)) PARTITION_NAME
        ,MAX(NEXT) NEXT
        ,MAX(VAR_NEXT) VAR_NEXT
        ,SUM(NFRAGS) NFRAGS
        ,SUM(SEGMENT_BYTES) SEGMENT_BYTES
        ,SUM(TOTAL_BLOCKS)  TOTAL_BLOCKS
        ,SUM(UNUSED_BLOCKS) UNUSED_BLOCKS
      FROM SYSTEM.SEGMENT_MONIT_SPACE_TEMP
      WHERE (table_name &cls_where. OR group_name &cls_where. OR SEGMENT_NAME &cls_where. )
      GROUP BY
         SEGMENT_OWNER
        ,TABLE_NAME
        ,DECODE(&v_agrupar., 'YES', 'TABLE', DECODE( &v_resumir., 'YES', GROUP_TYPE, SEGMENT_TYPE))
        ,DECODE(&v_agrupar., 'YES', ' ', TABLESPACE_NAME)
        ,DECODE(&v_agrupar., 'YES', ' ', DECODE( &v_resumir., 'YES', 
           CASE WHEN SEGMENT_TYPE LIKE '%INDEX' OR group_TYPE in( 'LOBSEGMNT','TEXTINDEX') THEN NVL(GROUP_NAME,SEGMENT_NAME) ELSE SEGMENT_NAME END, SEGMENT_NAME) ) 
        ,DECODE(&v_agrupar., 'YES', ' ', DECODE( &v_resumir., 'YES', ' ', PARTITION_NAME))
    )
    SELECT *
    FROM GRUPO
    ORDER BY
      DECODE(&v_sort., 'SIZE', segment_bytes, 0 ) DESC
     ,SEGMENT_OWNER
     ,TABLE_NAME
     ,SEGMENT_NAME
     ,DECODE( SUBSTR(SEGMENT_TYPE, 1, 5), 'TABLE', 1, 'TEXTI', 2, 'INDEX', 3, 'LOBSE', 4, 5 )
     ,SEGMENT_BYTES DESC
   ;

  PROCEDURE IMPRIME_DETALHE
    (CPART VARCHAR2, TOT_MEGAS NUMBER, EMPTY_MEGAS NUMBER, NFRAGS NUMBER, VAR_NEXT VARCHAR2,
     PNEXT NUMBER, PPCTFREE NUMBER, PPCTUSED NUMBER, PINITRANS NUMBER, PMAXTRANS NUMBER,
     PG_TOT_MEGAS IN OUT NUMBER, PG_EMPTY_MEGAS IN OUT NUMBER,
     FIRST IN OUT BOOLEAN, ULTIMA_PART BOOLEAN := FALSE )
  IS
    PCT_OCUP NUMBER;
    CPCT_OCUP VARCHAR2(10);
  BEGIN

    IF EMPTY_MEGAS IS NOT NULL THEN

      IF TOT_MEGAS > 0 THEN
        PCT_OCUP := 100-ROUND( EMPTY_MEGAS * 100 / TOT_MEGAS, 2 );
      ELSE
        PCT_OCUP := 0;
      END IF;
      CPCT_OCUP := TO_CHAR( PCT_OCUP, 'fm990D00' )||'%';
    ElSE
      CPCT_OCUP := 'N/A';
    END IF;

    IF NVL(PCT_OCUP,0) <= &v_pctocup_max. and TOT_MEGAS >= &v_megas_min. THEN

      IF FIRST THEN
        DBMS_OUTPUT.PUT_LINE( '+----------------------------------------------------------+----------------------------------------------------------------+----------------------------+--------------+' ); -- -------------------------+' );
        DBMS_OUTPUT.PUT_LINE( '|                                                          |                                    (*NEXT_MB = PCTINCREASE > 0)| ==== ESPACO UTILIZADO ==== | == EXTENTS = |' ); --   PARAMETROS DE BLOCO    |' );
        DBMS_OUTPUT.PUT_LINE( '|OWNER.OBJETO                                              |TYPE      TABLESPACE:SEGMENTO                                   |  TOTAL_MB  VAZIO_MB OCUPADO| FRAGS NEXT_MB|' ); -- %FREE %USED ITRANS MTRANS|' );
        DBMS_OUTPUT.PUT_LINE( '|----------------------------------------------------------|--------- ------------------------------------------------------|---------- --------- -------|------ -------|' ); -- ----- ----- ------ ------|' );
        FIRST := FALSE;
      END IF;

      DBMS_OUTPUT.PUT     ( CPART || '|' );
      DBMS_OUTPUT.PUT     ( LPAD( TO_CHAR(TOT_MEGAS             , 'fm999g990D00')     ,  10, ' ' ) );
      DBMS_OUTPUT.PUT     ( LPAD( TO_CHAR(NVL(EMPTY_MEGAS,0)    , 'fm999g990D00')     ,  10, ' ' ) );
      DBMS_OUTPUT.PUT     ( LPAD( CPCT_OCUP,                                             8, ' ' ) || '|' );
      DBMS_OUTPUT.PUT     ( LPAD( TO_CHAR(NFRAGS                , 'fm99990'     )     ,  6, ' ' ) );
      DBMS_OUTPUT.PUT_LINE( LPAD( VAR_NEXT||TO_CHAR(NVL(PNEXT,0), 'fm9990D00'   )     ,  8, ' ' ) || '|' );

      IF ULTIMA_PART THEN
        DBMS_OUTPUT.PUT_LINE( '|----------------------------------------------------------|----------------------------------------------------------------|---------- --------- -------|------ -------' ); -- |----- ----- ------ ------|' );
      ELSE
        PG_TOT_MEGAS   := PG_TOT_MEGAS + TOT_MEGAS;
        PG_EMPTY_MEGAS := PG_EMPTY_MEGAS + NVL(EMPTY_MEGAS,0);
      END IF;

    END IF;

  END;

BEGIN

  SELECT VALUE INTO block_size
  FROM V$PARAMETER WHERE name='db_block_size';

  FOR ro IN C1 LOOP

    BEGIN

      system.segment_unused_space(
        p_segment_owner             => ro.segment_owner,
        p_segment_name              => ro.segment_name,
        p_segment_type              => ro.segment_type,
        p_partition_name            => ro.partition_name,
        p_total_blocks              => v_total_blocks,
        p_total_bytes               => v_total_bytes,
        p_unused_blocks             => v_unused_blocks,
        p_unused_bytes              => v_unused_bytes,
        p_last_used_extent_file_id  => last_ext_file_id,
        p_last_used_extent_block_id => last_ext_blk_id,
        p_last_used_block           => last_used_blk );

    EXCEPTION
      WHEN OTHERS THEN
        v_total_blocks := NULL;
        v_unused_blocks := null;
        --dbms_output.put_line( ro.segment_name || ' + ' || ro.segment_type ||  ' + ' || TOT_MEGAS );
        --raise;
    END;

    UPDATE SYSTEM.SEGMENT_MONIT_SPACE_TEMP
      SET
         TOTAL_BLOCKS=v_total_blocks
        ,UNUSED_BLOCKS=v_unused_blocks
      WHERE CURRENT OF C1;

  END LOOP;

  G_TOT_MEGAS   := 0.0;
  G_EMPTY_MEGAS := 0.0;

  DBMS_OUTPUT.ENABLE( 1E+6 );

  FOR ro IN C2 LOOP
    DECLARE
      TIPO VARCHAR2(100);
      TBS_SEG VARCHAR2(100);
      ULTIMA_PARTICAO boolean := false;
    BEGIN

      ULTIMA_PARTICAO := false;
      IF LAST_SEGMENT <> ro.segment_name THEN

        IF LAST_WAS_PART THEN
          ULTIMA_PARTICAO := (NOT v_resumir2);
          IMPRIME_DETALHE
            (
              CPART, AC_TOT_MEGAS, AC_EMPTY_MEGAS, AC_CNFRAGS, AC_CVAR_NEXT,
              AC_CNEXT, AC_VPCTFREE, AC_VPCTUSED, AC_VINITRANS, AC_VMAXTRANS,
              G_TOT_MEGAS, G_EMPTY_MEGAS, FIRST, ULTIMA_PARTICAO
            );
        END IF;

        AC_TOT_MEGAS    := 0;
        AC_EMPTY_MEGAS  := 0;
        AC_CNFRAGS      := 0;
        AC_CVAR_NEXT    := NULL;
        AC_CNEXT        := NULL;

        LAST_SEGMENT   := ro.SEGMENT_NAME;
        LAST_WAS_PART  := ro.PARTITION_NAME IS NOT NULL AND NOT v_resumir2 AND &v_sort. <> 'SIZE';

      END IF;

      IF LAST_TABLE IS NOT NULL THEN
         IF LAST_TABLE <> ro.table_name AND (NOT v_resumir2) THEN
          LAST_TABLE := ro.table_name;
          IF not ULTIMA_PARTICAO AND &v_sort. <> 'SIZE' THEN
            DBMS_OUTPUT.PUT_LINE( '|----------------------------------------------------------|----------------------------------------------------------------|---------- --------- -------|------ -------|' ); -- ----- ----- ------ ------|' );
          END IF;
         END IF;
      ELSE
         LAST_TABLE := ro.table_name;
      END IF;

      IF ro.TOTAL_BLOCKS IS NULL THEN
        TOT_MEGAS := ro.SEGMENT_BYTES / 1024 / 1024;
        EMPTY_MEGAS := NULL;
      ELSE
        TOT_MEGAS := ro.TOTAL_BLOCKS * block_size / 1024 / 1024;
        EMPTY_MEGAS := ro.UNUSED_BLOCKS * block_size / 1024 / 1024;
      END IF;

      NEXT_MEGAS := ro.NEXT / 1024 / 1024;

      AC_TOT_MEGAS    := AC_TOT_MEGAS   + TOT_MEGAS   ;
      AC_EMPTY_MEGAS  := AC_EMPTY_MEGAS + NVL(EMPTY_MEGAS, 0) ;
      AC_CNFRAGS      := AC_CNFRAGS     + ro.NFRAGS    ;

      AC_CNEXT        := NVL( AC_CNEXT    , NEXT_MEGAS  );
      AC_CVAR_NEXT    := NVL( AC_CVAR_NEXT, ro.VAR_NEXT );

      TIPO := SUBSTR(ro.SEGMENT_TYPE,1,10);
      IF ro.SEGMENT_TYPE IN ('TABLE PARTITION', 'INDEX PARTITION' ) THEN
        TIPO := 'PARTITION';
      ELSIF ro.SEGMENT_TYPE IN ('TABLE SUBPARTITION', 'INDEX SUBPARTITION' ) THEN
        TIPO := 'SUBPART';
      ELSIF ro.SEGMENT_TYPE IN ('LOBSEGMENT' ) THEN
        TIPO := 'LOBSEGMNT';
      END IF;

      IF (ro.tablespace_name || ro.segment_name) IS NULL OR '*'||TRIM(ro.tablespace_name || ro.segment_name)||'*'  = '**' THEN
        TBS_SEG := 'Agrupando todos os segmentos';
      ELSE
        IF TIPO IN ('PARTITION', 'SUBPART') /*AND &v_sort. = 'SIZE' */ THEN
          TBS_SEG := ro.tablespace_name || ':' || ro.PARTITION_NAME;
        ELSIF TIPO IN ('INDEX') /*AND &v_sort. = 'SIZE' */ THEN
          TBS_SEG := ro.tablespace_name || ':' || ro.segment_name;
        ELSE
          TBS_SEG := ro.tablespace_name || ':' || ro.segment_name;
        END IF;
      END IF;

      -- IMPRESSAO PADRAO
      CPART := '|' || RPAD( ro.segment_owner || '.' ||ro.table_name, 58, ' ' ) || '|' || RPAD ( RPAD( TIPO, 9, ' ' ) || ' ' || TBS_SEG, 64, ' ' ) ;

      -- IMPRESSAO DETALHE PARTICAO
      IF LAST_WAS_PART AND NOT v_resumir2 THEN
         CPART := '|' || RPAD( ' ', 58, ' ' ) ||  '|' || RPAD ( RPAD( TIPO, 9, ' ' ) || ' ' || ro.tablespace_name || ':' || ro.PARTITION_NAME, 64, ' ' ) ;
      END IF;

      IF NOT ( v_resumir2 AND LAST_WAS_PART ) THEN
        IMPRIME_DETALHE
          ( CPART, TOT_MEGAS, EMPTY_MEGAS, ro.NFRAGS, ro.VAR_NEXT,
            NEXT_MEGAS, VPCTFREE, VPCTUSED, VINITRANS, VMAXTRANS,
            G_TOT_MEGAS, G_EMPTY_MEGAS, FIRST
          );
      END IF;

      -- IMPRESSAO TOTAL OBJETO PARTICIONADO
      IF LAST_WAS_PART AND NOT v_resumir2 THEN -- flavio
         CPART :=  '|' || RPAD( SUBSTR(ro.SEGMENT_TYPE,1,5) || ' ' || ro.segment_owner || '.' ||ro.segment_name,  58, ' ' ) || '|' || RPAD( ' ', 64, ' ' ) ;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;


  END LOOP;


  -- NECESSARIO IMPRIMIR APOS O FIM DO LOOP CASO O ULTIMO OBJETO SEJA PARTICIONACO
  IF LAST_WAS_PART THEN
    IMPRIME_DETALHE
      ( CPART, AC_TOT_MEGAS, AC_EMPTY_MEGAS, AC_CNFRAGS, AC_CVAR_NEXT,
        AC_CNEXT, AC_VPCTFREE, AC_VPCTUSED, AC_VINITRANS, AC_VMAXTRANS,
        G_TOT_MEGAS, G_EMPTY_MEGAS, FIRST, (NOT v_resumir2)
      );
  END IF;

  IF NOT FIRST THEN
    DECLARE
      PCT NUMBER;
    BEGIN

      IF G_TOT_MEGAS > 0 THEN
        PCT := 100-ROUND( G_EMPTY_MEGAS * 100 / G_TOT_MEGAS, 2 ) ;
      ELSE
        PCT := 0;
      END IF;

      IF v_resumir2 OR (NOT LAST_WAS_PART) THEN
        DBMS_OUTPUT.PUT_LINE( '|----------------------------------------------------------+----------------------------------------------------------------|---------- --------- -------|------ -------|' ); -- ----- ----- ------ ------|' );
      END IF;

      DBMS_OUTPUT.PUT_LINE(   '| TOTAIS GERAIS ----------------------------------------------------------------------------------------------------------- |'||
                            LPAD( TO_CHAR(G_TOT_MEGAS, 'fm9g999g990'),  10, ' ' ) ||
                            LPAD( TO_CHAR(G_EMPTY_MEGAS, 'fm9g999g990'),  10, ' ' ) ||
                            LPAD( TO_CHAR(PCT, 'fm990D00')||'%',  8, ' ' ) || '| -----  ------|' ); --  ---   ---   ----   ---- |' );
      DBMS_OUTPUT.PUT_LINE(   '+---------------------------------------------------------------------------------------------------------------------------+----------------------------+--------------+' ); -- -------------------------+' );
    END;

  END IF;

END;
/

--SELECT * FROM SYSTEM.SEGMENT_MONIT_SPACE_TEMP;
