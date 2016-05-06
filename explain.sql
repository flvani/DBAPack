set autotrace off timing off
SET VERIFY OFF
--DEFINE SIFUS=USR_SIAFI_OLD

alter session set current_schema=ext_smartecm;

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

--ALTER SESSION SET OPTIMIZER_FEATURES_ENABLE='11.2.0.2';
--ALTER SESSION SET OPTIMIZER_FEATURES_ENABLE='11.2.0.2';
--alter session enable parallel dml;

EXPLAIN PLAN SET STATEMENT_ID='&1.' INTO sys.plan_table$ FOR
SELECT "_C1" 
FROM 
(
  SELECT "HIERARCHY"."ID" AS "_C1" 
  FROM "HIERARCHY" 
  JOIN hierarchy_read_acl "_RACL" ON "HIERARCHY"."ID" = "_RACL".id 
  JOIN aclr_user_map "_ACLRUSERMAP" ON "_RACL".acl_id ="_ACLRUSERMAP".acl_id 
  LEFT JOIN "MISC" "_F1" ON "HIERARCHY"."ID" ="_F1"."ID" 
  WHERE 
  (
      ("HIERARCHY"."PRIMARYTYPE" IN (:1 , :2 )) 
    AND 
      ("HIERARCHY"."ID" in 
        (
          SELECT id 
          FROM hierarchy 
          WHERE LEVEL>1 AND isproperty = 0 
          START WITH id=:3  
          CONNECT BY PRIOR id = parentid
        )
      ) AND ("_F1"."LIFECYCLESTATE" <> :4 ) 
    AND ("HIERARCHY"."ID" <> :5 )
  ) 
  AND "_ACLRUSERMAP".user_id = nx_hash_users(null)
  UNION ALL 
  SELECT "_H"."ID" AS "_C1" 
  FROM "HIERARCHY" "_H" 
  JOIN "PROXIES" ON "_H"."ID" = "PROXIES"."ID" 
  JOIN "HIERARCHY" ON "PROXIES"."TARGETID" = "HIERARCHY"."ID" 
  JOIN hierarchy_read_acl "_RACL" ON "_H"."ID" ="_RACL".id 
  JOIN aclr_user_map "_ACLRUSERMAP" ON "_RACL".acl_id = "_ACLRUSERMAP".acl_id 
  LEFT JOIN "MISC" "_F1" ON "HIERARCHY"."ID" = "_F1"."ID" 
  WHERE 
  (
      ("HIERARCHY"."PRIMARYTYPE" IN (:7 , :8 ))
    AND 
      ("_H"."ID" in 
        (
           SELECT id 
           FROM hierarchy 
           WHERE LEVEL>1 AND isproperty = 0 
           START WITH id=:9  
           CONNECT BY PRIOR id = parentid
        )
     ) AND ("_F1"."LIFECYCLESTATE" <> :10 )
    AND ("_H"."ID" <> :11 )
  ) AND "_ACLRUSERMAP".user_id = nx_hash_users(null)
)
/
