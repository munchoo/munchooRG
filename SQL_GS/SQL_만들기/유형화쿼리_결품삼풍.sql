/*==========================
점포경영>OFC>점포지도>유형화결품. 결품상품 상세조회 팝업
-- 2020.01.10 CR200106043
-- 점포경영 쿼리 공유받아 DW로 변환함
==========================*/

SELECT  MAX(C.RGN_GRPNM) RGN_GRPNM,
       MAX(C.RGNNM) RGNNM,
       MAX(C.TEAM_LN) TEAM_LN,
       MAX(C.PART_LN) PART_LN,
       A.BIZPL_CD AS BIZPL_CD,              /* 조직코드 */
--       A.BIZPL_NM AS OPER_NM,          /* 조직명   */
       MAX(C.STORECD) AS STORECD,       /* CR191129059 최초사업장코드 */
       MAX(C.STORENM) AS STORENM,
       A.OPER_DT,
       A.OUTSTK_DAY_CNT,                    --점포별일자별 상품수(DW용) 
       A.GOODS_CD, 
       MAX(B.GOODS_NM) AS GOODS_NM, 
       A.OPER_DT_CNT AS outstk_day_sum  -- 상품별 월결품일수 
FROM (
         SELECT A.BIZPL_CD, 
                   A.ORIGIN_BIZPL_CD, 
                   A.GOODS_CD, 
                   A.OPER_DT, 
                   COUNT(A.OPER_DT) OVER (PARTITION BY A.BIZPL_CD, A.ORIGIN_BIZPL_CD, A.GOODS_CD) AS OPER_DT_CNT,  -- 상품별 결품일수
                   COUNT(A.OPER_DT) OVER (PARTITION BY A.BIZPL_CD, A.ORIGIN_BIZPL_CD, A.OPER_DT) AS OUTSTK_DAY_CNT
          FROM LGMJVDP.TS_OP_OUTSTK_SKU A,              -- OP_단품별결품상태, MS_상품
          		  /* CR200107050 신규점은 오픈월 공란으로 표시 (양수도제외) */
	              (SELECT BIZPL_CD, ORIGIN_BIZPL_CD
                    FROM LGMJVDP.TS_MS_BIZPL                                                                 -- MS_사업장
                   WHERE 1=1
                      AND  (CLOSE_DT IS NULL OR TRIM(CLOSE_DT) = '' OR CLOSE_DT > TO_CHAR(SYSDATE, 'YYYYMMDD'))
                      AND OPEN_DT  <= TO_CHAR(SYSDATE,'YYYYMMDD')                                   
                      AND (SUBSTR(OPEN_DT, 1 , 6) <> '202001' OR BIZPL_CD <> ORIGIN_BIZPL_CD )
                  ) B
         WHERE 1=1
           AND A.BIZPL_CD = B.BIZPL_CD                   
           AND A.ORIGIN_BIZPL_CD = B.ORIGIN_BIZPL_CD
           AND A.OUTSTK_YN = 'Y'          
           AND A.GOODS_SP = 'A'
           AND substr(a.oper_dt,1,6) = '202001'
           AND A.GOODS_CD IS NOT NULL -- DW는 총대상상품을 UNION ALL로 추가로 가져와서 해당 행 제거를 위해 추가함 
         ) A,
       LGMJVDP.TS_MS_GOODS B,
       LGMJVDP.TB_STORE_DM C
 WHERE substr(A.ORIGIN_BIZPL_CD,2,4) = C.STORECD
   AND A.GOODS_CD = B.GOODS_CD
   AND c.teamcd is not   NULL
GROUP BY A.BIZPL_CD ,                                                                                   
       A.ORIGIN_BIZPL_CD ,                                                                  
       C.STORENM ,
       A.OPER_DT, 
       A.GOODS_CD, 
       A.OUTSTK_DAY_CNT, 
       A.OPER_DT_CNT
 --ORDER BY BIZPL_CD, OPER_DT      
;   
