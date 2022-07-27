WITH DB AS 
(
	SELECT DBS.NAME, T.TABLESPACE_NAME, COUNT(*) 	QTD, row_number() over ( partition by TABLESPACE_NAME order by COUNT(*) desc ) as row_num 
	FROM DBA_SEGMENTS T
	JOIN 
	(
		SELECT USERNAME NAME 
		FROM ALL_USERS 
		WHERE 
		( 
				 SUBSTR(USERNAME, 1, 2) IN ( 'MV' ) 
			OR SUBSTR(USERNAME, 1, 3) IN ( 'DBA', 'BIB' )  
			OR SUBSTR(USERNAME, 1, 4) IN ( 'EXT_', 'USR_' )
		)	
		AND USER_ID BETWEEN 55 AND 1E+5
	) DBs ON ( DBS.NAME = T.OWNER )
	GROUP BY DBS.NAME, T.TABLESPACE_NAME
)
SELECT TABLESPACE_NAME, NAME
FROM DB
WHERE ROW_NUM = 1
ORDER BY TABLESPACE_NAME
/