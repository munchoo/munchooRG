SELECT MAX(C.RGN_GRPNM) RGN_GRPNM,
       MAX(C.RGNNM) RGNNM,
       MAX(C.TEAM_LN) TEAM_LN,
       MAX(C.PART_LN) PART_LN,
       B.BIZPL_CD AS BIZPL_CD,                            
       MAX(C.STORECD) AS STORECD,                   
       MAX(C.STORENM) AS STORENM,                
       B.OPER_DT AS OPER_DT,                      
       /* CR191129059 총유형화상품수 */   
       CASE WHEN D.TARGET_BIZPL_YN IS NULL THEN NULL ELSE TO_CHAR((SELECT COUNT(1) FROM GSSCODS.TS_SL_AGRP_GOODS A WHERE A.ORIGIN_BIZPL_CD = B.ORIGIN_BIZPL_CD AND A.YYYYMM =  '202208' AND A.SP = 'A')) END AS TOTAL_A_GOODS_CNT,         
       /* CR191129059 총 결품대상상품 수  -- 그냥 MAX를 하면 OPER_DT가 없는 날짜가 NULL이 되어 서브쿼리로 변경 */
       (SELECT MAX(TARGET_GOODS_CNT) AS TARGET_GOODS_CNT  FROM GSSCODS.TS_OP_OUTSTK A WHERE A.ORIGIN_BIZPL_CD = B.ORIGIN_BIZPL_CD AND A.BIZPL_CD = B.BIZPL_CD  AND GOODS_SP ='A' AND SUBSTR(A.OPER_DT,1,6) =  '202208' ) AS TARGET_GOODS_CNT,
       /* CR191129059 총미취급상품수 */
       CASE WHEN D.TARGET_BIZPL_YN IS NULL  THEN NULL ELSE TO_CHAR((SELECT COUNT(1) FROM GSSCODS.TS_OP_MM_OUTSTK_SKU_NHDL A WHERE A.ORIGIN_BIZPL_CD = B.ORIGIN_BIZPL_CD AND A.BIZPL_CD = B.BIZPL_CD AND A.OPER_YYYYMM =  '202208' AND A.GOODS_SP = 'A')) END  AS TOTAL_NHDL_CNT,                 
       /* CR191129059 총취급상품수 */
       CASE WHEN D.TARGET_BIZPL_YN IS NULL THEN NULL ELSE TO_CHAR((SELECT COUNT(1) FROM GSSCODS.TS_OP_MM_OUTSTK_SKU_NHDL A WHERE A.ORIGIN_BIZPL_CD = B.ORIGIN_BIZPL_CD AND A.BIZPL_CD = B.BIZPL_CD AND A.OPER_YYYYMM =  '202208' AND A.GOODS_SP = 'A' AND  A.HDL_YN = 'Y')) END AS TOTAL_HDL_CNT, 
        /* CR191129059 결품상품수 -- 이것만 매트릭(일자별값) */
       CASE WHEN D.TARGET_BIZPL_YN IS NULL THEN NULL ELSE MAX(O.OUTSTK_GOODS_CNT) END AS OUTSTK_GOODS_CNT 

       /*  CR191129059 총 결품대상상품 수 -- 상생기획팀 요청으로 리포트에서 제외함. 
        (SELECT TO_CHAR(CAST(ROUND(AVG(A.OUTSTK_GOODS_CNT),1) AS DECIMAL(10,1))) AS AVG_OUTSTK_CNT
         FROM GSSCODS.TS_OP_OUTSTK A
        WHERE A.ORIGIN_BIZPL_CD = B.ORIGIN_BIZPL_CD
           AND A.BIZPL_CD = B.BIZPL_CD
           AND GOODS_SP ='A'
           AND SUBSTR(A.OPER_DT,1,6) = '202001' 
        ) AS AVG_OUTSTK_CNT
       */        
  FROM ( /*모든 점포의 일별 행을 생성*/
	      SELECT B.BIZPL_CD, B.ORIGIN_BIZPL_CD, D.OPER_DT
	          FROM
	               (SELECT TO_CHAR(DATECD,'YYYYMMDD') AS OPER_DT
	                 FROM LGMJVDP.TB_DATE_DM A
	                WHERE YMCD = '202208'
	                ) D,
	               (SELECT BIZPL_CD, ORIGIN_BIZPL_CD
	                  FROM LGMJVDP.TS_MS_BIZPL                                                                 -- MS_사업장
	                 WHERE 1=1 
	                   AND (CLOSE_DT IS NULL OR TRIM(CLOSE_DT) = '' OR CLOSE_DT > TO_CHAR(SYSDATE, 'YYYYMMDD'))
	                   AND OPEN_DT  <= TO_CHAR(SYSDATE,'YYYYMMDD')             
	               ) B
          ) B,
        GSSCODS.TS_OP_OUTSTK O,
       LGMJVDP.TB_STORE_DM C ,
       ( /* CR200107050 신규점은 오픈월 공란으로 표시 (양수도제외) */
      SELECT BIZPL_CD, BIZPL_NM, ORIGIN_BIZPL_CD, 'Y' AS TARGET_BIZPL_YN
          FROM LGMJVDP.TS_MS_BIZPL                                                                 -- MS_사업장
         WHERE 1=1
          AND  (CLOSE_DT IS NULL OR TRIM(CLOSE_DT) = '' OR CLOSE_DT > TO_CHAR(SYSDATE, 'YYYYMMDD'))
           AND OPEN_DT  <= TO_CHAR(SYSDATE,'YYYYMMDD')                                   
           AND (SUBSTR(OPEN_DT, 1 , 6) <> '202208' OR BIZPL_CD <> ORIGIN_BIZPL_CD )        
        ) D              
 WHERE B.BIZPL_CD = O.BIZPL_CD(+)
   AND B.ORIGIN_BIZPL_CD = O.ORIGIN_BIZPL_CD(+)
   AND B.OPER_DT = O.OPER_DT(+)
   AND O.OPER_DT(+) LIKE '202208' || '%'
   AND O.GOODS_SP(+) = 'A'
   AND substr(B.ORIGIN_BIZPL_CD,2,4) = C.STORECD
   AND c.teamcd in ( '4102' )
   AND B.BIZPL_CD = D.BIZPL_CD(+)
   AND B.ORIGIN_BIZPL_CD = D.ORIGIN_BIZPL_CD(+)
GROUP BY B.BIZPL_CD ,                                                                              
       B.ORIGIN_BIZPL_CD ,                                                                
       B.OPER_DT ,
       D.TARGET_BIZPL_YN      
--ORDER BY STORENM, OPER_DT  
;
