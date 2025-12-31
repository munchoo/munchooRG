/* 정기 CSR 쿼리 가져오기
20251231 김영남 -점포경영시스템 CSR 부진재고 top 500 추출 쿼리 */


SELECT  
  '기준년월'||','||
  '상품코드'||','||
  '상품명'||','||
  '재고수량'||','||
  '취급점포수' AS RN
 FROM DUAL
UNION ALL
  SELECT
   A.AGG_YYYYMM||','||
   A.GOODS_CD||',"'||
   C.GOODS_NM||'",'||
   B.STK_QTY ||','||
   A.BIZ_CNT AS RN
  FROM (
	  SELECT *
	  FROM (
	   SELECT G.AGG_YYYYMM, G.GOODS_CD, G.BIZ_CNT
	   , RANK() OVER(ORDER BY G.BIZ_CNT DESC) AS RNK
	   FROM (
	    SELECT A.AGG_YYYYMM , A.GOODS_CD, COUNT(A.GOODS_CD) AS BIZ_CNT    
	      FROM TS_ST_MM_SLMP_STK A    
	     WHERE 1=1    
	       AND A.AGG_YYYYMM = '${aggyyyymm}'  
	    GROUP BY A.AGG_YYYYMM , A.GOODS_CD    
	    ) G
	  ) Z 
	  WHERE Z.RNK <= 500
  )  A
 ,(      	
      SELECT A.AGG_YYYYMM , A.GOODS_CD, SUM(B.BOOK_STK_QTY) AS STK_QTY  	
        FROM TS_ST_MM_SLMP_STK A  	
        , TS_ST_SKU_PER_STK B  	
       WHERE 1=1  	
         AND A.ORIGIN_BIZPL_CD = B.ORIGIN_BIZPL_CD  	
         AND A.GOODS_CD = B.GOODS_CD  	
         AND B.STK_EVAL_DT = TO_CHAR(TO_DATE('${aggyyyymm}'||'01','YYYYMMDD') -1,'YYYYMMDD')
         AND A.AGG_YYYYMM = '${aggyyyymm}'
      GROUP BY A.AGG_YYYYMM , A.GOODS_CD  	
  ) B, TS_MS_GOODS C    	
  WHERE A.GOODS_CD = B.GOODS_CD
  AND A.GOODS_CD = C.GOODS_CD	