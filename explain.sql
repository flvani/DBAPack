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

EXPLAIN PLAN SET STATEMENT_ID='&1.' INTO sys.plan_table$ FOR
SELECT ALL /*+ parallel */ 
	   CASE DECODE (:Mes_Referencia,NULL,TO_CHAR(:CF_MesRef),:Mes_Referencia)
	   		WHEN '1' THEN 'Jan/' || DECODE(:Ano_Referencia,NULL,:CF_AnoRef,:Ano_Referencia)
			WHEN '2' THEN 'Fev/' || DECODE(:Ano_Referencia,NULL,:CF_AnoRef,:Ano_Referencia)
			WHEN '3' THEN 'Mar/' || DECODE(:Ano_Referencia,NULL,:CF_AnoRef,:Ano_Referencia)
			WHEN '4' THEN 'Abr/' || DECODE(:Ano_Referencia,NULL,:CF_AnoRef,:Ano_Referencia)
			WHEN '5' THEN 'Mai/' || DECODE(:Ano_Referencia,NULL,:CF_AnoRef,:Ano_Referencia)
			WHEN '6' THEN 'Jun/' || DECODE(:Ano_Referencia,NULL,:CF_AnoRef,:Ano_Referencia)
			WHEN '7' THEN 'Jul/' || DECODE(:Ano_Referencia,NULL,:CF_AnoRef,:Ano_Referencia)
			WHEN '8' THEN 'Ago/' || DECODE(:Ano_Referencia,NULL,:CF_AnoRef,:Ano_Referencia)
			WHEN '9' THEN 'Set/' || DECODE(:Ano_Referencia,NULL,:CF_AnoRef,:Ano_Referencia)
			WHEN '10' THEN 'Out/' || DECODE(:Ano_Referencia,NULL,:CF_AnoRef,:Ano_Referencia)
			WHEN '11' THEN 'Nov/' || DECODE(:Ano_Referencia,NULL,:CF_AnoRef,:Ano_Referencia)
			WHEN '12' THEN 'Dez/' || DECODE(:Ano_Referencia,NULL,:CF_AnoRef,:Ano_Referencia)
	  	END MES_EXTENSO,  
		T1.ID_UF, 
		T1.NO_MUNICIPIO,
		'CODMUNIC:' || TO_CHAR(T1.ID_MUNICIPIO,'0000') 	 MUN_IDE_MUNICIPIO,
		CASE 
			 WHEN LENGTH(T1.ID_ENTIDADE) = 14 
			 	  THEN SUBSTR(T1.ID_ENTIDADE, 1, 9)     ||
	   			  	   '/'|| SUBSTR(T1.ID_ENTIDADE,10,4)||
	   				   '-'|| SUBSTR(T1.ID_ENTIDADE,14,2)  
			 WHEN LENGTH(T1.ID_ENTIDADE) = 11
			 	  THEN 
			 	  		SUBSTR(T1.ID_ENTIDADE, 1, 3)     ||
	   			  	   '.'|| SUBSTR(T1.ID_ENTIDADE,4,3)  ||
					   '.'|| SUBSTR(T1.ID_ENTIDADE,7,3)  ||
	   				   '-'|| SUBSTR(T1.ID_ENTIDADE,10,2)  
			 ELSE T1.ID_ENTIDADE
		END CNPJ_FAVORECIDO,
		T1.NO_ENTIDADE 					  				   NOME_FAVORECIDO,
    	trim (TO_CHAR(T1.CO_UO, '00G000') ) || ' - ' || T1.NO_UO 	DES_UO,
		T1.ID_ACAO_PT 	|| '.' || T1.ID_LOCALIZADOR_GASTO_PT   	  	COD_PT,
		T1.NO_ACAO_PT	DES_PT, 
		CASE 
			 WHEN      NVL(trim(T1.NR_ORIGINAL_TV), '') >= '000000' 
			 	   AND NVL(trim(T1.NR_ORIGINAL_TV), '') <= '999999' 
				   OR  NVL(trim(T1.NR_ORIGINAL_TV), '') = 'SEM INFORMACAO' 
			 THEN 'CONVÊNIO: ' 
		END || 
	    CASE WHEN NVL(trim(T1.NR_ORIGINAL_TV), '') = '/'
			 THEN  'CONVÊNIO: SEM INFORMACAO' 
			 ELSE NVL(trim(T1.NR_ORIGINAL_TV),'') 
		END 
     	|| ' - EMPENHO: ' || SUBSTR(T1.ID_DOCUMENTO,18, 6) ||
		' - ' || t1.tx_observacao					 		   	  	  		     CONVENIO,		
    	T1.VLR_EMP_MES,		
		T1.VLR_EMP_ATEOMES							
FROM 
(
SELECT /*+ parallel   */  ALL
            a19.ID_ENTIDADE_FAVO_DOC  ID_ENTIDADE,      
            MAX(a114.NO_ENTIDADE)  NO_ENTIDADE,
			MAX(a19.ID_UF_BENE_NE)  ID_UF,
            MAX(a19.ID_MUNICIPIO_BENE_NE)  ID_MUNICIPIO,
            MAX(a115.NO_MUNICIPIO)  NO_MUNICIPIO,
            MAX(a110.CO_UO)  CO_UO,
            MAX(a110.NO_UO)  NO_UO,
            a11.ID_PROGRAMA_PT  ID_PROGRAMA_PT,                    
            MAX(a113.NO_PROGRAMA_PT)  NO_PROGRAMA_PT,
            a11.ID_ACAO_PT  ID_ACAO_PT,                            
			a11.ID_LOCALIZADOR_GASTO_PT ID_LOCALIZADOR_GASTO_PT,   
            MAX(a111.NO_ACAO_PT)  NO_ACAO_PT,
            MAX(a11.ID_DOCUMENTO_ccor)  ID_DOCUMENTO,
			MAX(a19.NR_ORIGINAL_TV)  NR_ORIGINAL_TV, 
			MAX(a17.tx_observacao)  tx_observacao,
 			SUM(CASE 
			    WHEN a11.ID_MES_LANC  = DECODE(:Mes_Referencia,NULL,TO_CHAR(:CF_MesRef,'99'),:Mes_Referencia) 
					  THEN (
					  	   	a11.VA_MOVIMENTO_LIQUIDO * 
							(CASE 
								 WHEN a11.va_credito < a11.va_debito AND va_movimento_liquido > 0 
								 	 THEN -1  
									 ELSE 1  
							END) *
							CASE    
								WHEN a11.ID_MOEDA_UG_EXEC_H = 790 
								THEN 1
								ELSE 
					 				(SELECT a14.PE_TAXA FROM  usr_dw_tesourogerencial.WD_TAXA_CAMBIO_MENSAL a14
					 				 WHERE 
				 	 	   			  	   a14.id_ano = a11.id_ano_lanc
				 	 	   				   AND id_mes = a11.id_mes_lanc
			  	 	   	   				   AND a14.ID_MOEDA_ORIGEM = a11.ID_MOEDA_UG_EXEC_H
					 	   				   AND a14.id_moeda_destino = 790)
							 END 
							 )
			   		  ELSE 0 
			   END) VLR_EMP_MES, 	
			SUM(CASE 
			    WHEN a11.ID_MES_LANC  <= DECODE(:Mes_Referencia,NULL,TO_CHAR(:CF_MesRef,'99'),:Mes_Referencia) 
					  THEN (
					  	    a11.VA_MOVIMENTO_LIQUIDO * 
							(CASE 
								WHEN a11.va_credito < a11.va_debito AND va_movimento_liquido > 0 
	 							THEN -1  
	 							ELSE 1  
						    END) * 
							(CASE    
								WHEN a11.ID_MOEDA_UG_EXEC_H = 790 
								THEN 1
								ELSE 
					 				(SELECT MAX(a14.PE_TAXA) FROM  usr_dw_tesourogerencial.WD_TAXA_CAMBIO_MENSAL a14
					 				 WHERE 
				 	 	   			  	   a14.id_ano = a11.id_ano_lanc
				 	 	   				   AND id_mes = a11.id_mes_lanc
			  	 	   	   				   AND a14.ID_MOEDA_ORIGEM = a11.ID_MOEDA_UG_EXEC_H
					 	   				   AND a14.id_moeda_destino = 790)
							END) 
							)
			   		  ELSE 0 
			   END) VLR_EMP_ATEOMES    
-- Explain plan for			   
-- SELECT /*+ parallel */ *  			   
FROM  
	  (SELECT e1.*
	   FROM  usr_dw_tesourogerencial.WD_ENTIDADE e1 
	   WHERE e1.id_tp_entidade  = 'PJ' 
	   )a114 
	   JOIN  (SELECT fav_ide_favorecido FROM usr_dw_orcamento.dim_favorecido   
	   		 WHERE fav_tip_favorecido = '1'
			 AND FAV_COD_NATUREZA_JURIDICA IN (124,103,106, 112, 115, 118,120,121, 201, 203, 309)
			 ORDER BY 1
	         ) f1   
			 ON  LPAD(f1.fav_ide_favorecido, 14, '0') = a114.id_entidade  
	  JOIN usr_dw_tesourogerencial.WD_MUNICIPIO a115
		   ON a114.ID_MUNICIPIO_ENTI = a115.ID_MUNICIPIO  
      JOIN usr_dw_tesourogerencial.WD_DOC_NE a19
		   ON (a114.ID_TP_ENTIDADE = a19.ID_TP_ENTIDADE_FAVO_DOC AND 
			   a114.ID_ENTIDADE = a19.ID_ENTIDADE_FAVO_DOC)
	  JOIN  usr_dw_tesourogerencial.WF_LANCAMENTO_EP01 a11   
   		    ON (a19.ID_DOCUMENTO = a11.ID_DOCUMENTO_CCOR)	
      JOIN usr_dw_tesourogerencial.WD_DOCUMENTO a17
            ON (a17.ID_DOCUMENTO = a11.ID_DOCUMENTO_CCOR)
      JOIN usr_dw_tesourogerencial.WD_UO a110
		    ON (a110.ID_UO = a11.ID_UO)
      JOIN usr_dw_tesourogerencial.WD_PROGRAMA_PT a113
	    	ON (a113.ID_PROGRAMA_PT = a11.ID_PROGRAMA_PT)	
	   JOIN usr_dw_tesourogerencial.WD_ACAO_PT a111
			ON (a111.ID_ACAO_PT = a11.ID_ACAO_PT)	
WHERE 
	  A115.ID_UF = NVL(UPPER(:INFORME_UF), A115.ID_UF)
	  AND A115.ID_MUNICIPIO = NVL(:INFORME_COD_MUNICIPIO, A115.ID_MUNICIPIO)
  	  AND a11.ID_ANO_LANC = DECODE(:Ano_Referencia,NULL,:CF_AnoRef,:Ano_Referencia)
      AND a11.ID_MES_LANC <= DECODE(:Mes_Referencia,NULL,TO_CHAR(:CF_MesRef,'99'),:Mes_Referencia)
 	  AND A11.ID_MOAP_NADE IN (30, 31, 32, 35, 36, 40, 41, 42, 45, 46, 50)
	  AND (a11.ID_CONTA_CONTABIL_LANC 	 IN       
	      (SELECT c22.ID_CONTA_CONTABIL
           FROM   usr_dw_tesourogerencial.WD_CONTA_CONTABIL c22
                  JOIN usr_dw_tesourogerencial.WD_ITEM_DECODIFICADO_CCON    c23
                       ON     (c23.id_ano_item_conta =  2015   
				      AND c23.ID_ITEM_INFORMACAO = 421
					  AND c22.ID_CONTA_CONTABIL = c23.ID_CONTA_CONTABIL)
						))
GROUP BY    
            a115.ID_UF,
            a114.ID_MUNICIPIO_ENTI,
	        a19.ID_TP_ENTIDADE_FAVO_DOC,
            a19.ID_ENTIDADE_FAVO_DOC,
            a11.ID_UO,
            a11.ID_PROGRAMA_PT,
			a11.ID_ACAO_PT,
			a11.ID_LOCALIZADOR_GASTO_PT,
            a11.ID_DOCUMENTO_ccor,
			a19.NR_ORIGINAL_TV,  
			a17.tx_observacao
) T1
ORDER BY   1,2, 3, 4, 5,7  
/
