/*
PARA MATAR TABELAS ORFAS DO ADVANCED QUEUE.
alter session set events '10851 trace name context forever, level 2';
drop table xxxx;
*/
UNDEFINE P_OWNER
SET DEFINE ON SERVEROUT ON VERIFY OFF
ACCEPT P_OWNER PROMPT "Informe o Nome do Usuário: "

DECLARE
  CURSOR C1 IS
    SELECT
      OBJECT_TYPE, OWNER, '"'||OBJECT_NAME||'"' OBJECT_NAME,
      'DROP ' || OBJECT_TYPE || ' ' || OWNER || '.' || '"'||OBJECT_NAME||'"'  ||
      DECODE( OBJECT_TYPE, 'TABLE', ' CASCADE CONSTRAINTS PURGE' ) DROP_STMT
    FROM DBA_OBJECTS
    WHERE OBJECT_TYPE IN
         (
           'TABLE',
           'DIMENSION',
           'MATERIALIZED VIEW',
           'VIEW',
           'SEQUENCE',
           'SYNONYM',
           'PROCEDURE',
           'FUNCTION',
           'PACKAGE',
           'TYPE',
           'QUEUE',
           'JAVA SOURCE',
           'JAVA RESOURCE',
           'JAVA CLASS'
         )
    AND OWNER IN UPPER( '&P_OWNER.' )
    AND OBJECT_NAME NOT LIKE 'BIN$%'
    AND OBJECT_NAME NOT LIKE 'DR$%'
    ORDER BY DECODE (OBJECT_TYPE, 'INDEX', 1, 'MATERIALIZED VIEW', 2, 'QUEUE', 2, 'TYPE', 4, 3 );

    v_existe NUMBER(1);


BEGIN
  SELECT COUNT(*)
  INTO v_existe
  FROM DBA_USERS
  WHERE USERNAME = UPPER('&P_OWNER.');

  IF v_existe = 0 THEN
     RAISE_APPLICATION_ERROR(-20000,'Esquema '||'&P_OWNER.'||' não existe!');
  ELSE
     --EXECUTE IMMEDIATE 'PURGE DBA_RECYCLEBIN';

     FOR R1 IN C1 LOOP
--       dbms_output.put_line( r1.DROP_STMT );

       BEGIN
         IF R1.OBJECT_TYPE='QUEUE' THEN
           DBMS_AQADM.DROP_QUEUE(R1.OWNER||'.'||R1.OBJECT_NAME);
         ELSE
           BEGIN
             EXECUTE IMMEDIATE R1.DROP_STMT;
           EXCEPTION
             WHEN OTHERS THEN
               IF SQLCODE=-24005 THEN
                 DBMS_AQADM.DROP_QUEUE_TABLE( R1.OWNER||'.'||R1.OBJECT_NAME, TRUE);
               END IF;
           END;           
         END IF;  
       EXCEPTION
         WHEN OTHERS THEN
           DBMS_OUTPUT.PUT_LINE(R1.DROP_STMT||CHR(10)||SQLERRM);
       END;

--       raise_application_error( -20000, 'teste' );

     END LOOP;

     --EXECUTE IMMEDIATE 'PURGE DBA_RECYCLEBIN';

   END IF;
END;
/

PROMPT
PROMPT OBJETOS DE &&P_OWNER.
SELECT OBJECT_TYPE, COUNT(*) QTDE FROM DBA_OBJECTS WHERE OWNER=UPPER( '&&P_OWNER.' )
GROUP BY OBJECT_TYPE
/

UNDEFINE P_OWNER
