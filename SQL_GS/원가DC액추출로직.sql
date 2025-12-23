WITH DC_COST_PROFIT AS
(
  SELECT SUBSTR(O.STK_EVAL_DT,1,6) AS STK_EVAL_MM
        ,C.COST_DC_SP_CD
        ,O.BIZPL_CD
        ,C.GOODS_REGION_CD                                                  /* 지역 */
        ,C.GOODS_CD                                                        /* 상품코드 */
        ,O.PURCHASE_CD
        ,C.DC_COST_APP_START_DT || ' ~ ' || C.DC_COST_APP_END_DT AS DT_DUR /* 대상기간 */
        ,C.COST_OLD                                                        /* 원가 */
        ,C.DC_COST                                                         /* 할인원가 */
        ,TRIM(TO_CHAR(ROUND((C.COST_OLD - C.DC_COST) / C.COST_OLD * 100, 1), '990.9')) AS COST_DC_RATE /* 원가변동율 */
        ,C.PRC                                                             /* 매가 */
        ,SUM(C.COST_OLD - C.DC_COST) AS OVER_COST                          /* 개당초과이익 */
        ,SUM(O.COST_DC_PROFIT_AMT) AS BUY_QTY                              /* 매입수량 */
        ,SUM(O.COST_DC_PROFIT_AMT * (C.COST_OLD - C.DC_COST)) AS COST_DC_PROFIT_AMT /* 추가이익 */
   FROM (SELECT X.BIZPL_CD
               ,Y.GOODS_REGION_CD
               ,X.GOODS_CD
               ,X.STK_EVAL_DT
               ,X.PURCHASE_CD
               ,NVL(TRUNC(SUM(X.QTY)),0) AS COST_DC_PROFIT_AMT
           FROM ( /* 센터매입 기준 원가DC */
                 SELECT A.BIZPL_CD                                                        AS BIZPL_CD
                       ,A.GOODS_CD                                                        AS GOODS_CD
                       ,A.STK_EVAL_DT                                                     AS STK_EVAL_DT
                       ,A.PURCHASE_CD                                                     AS PURCHASE_CD
                       ,A.STR_DRBU_QTY                                                    AS QTY
                   FROM (
                        /* 편의점 센터매입 기준 원가DC TOBE LOGIC START */
                          SELECT A.STK_EVAL_DT
                                ,A.BIZPL_CD
                                ,A.PURCHASE_CD
                                ,DECODE(E.BVG_STK_EVAL_CD, NULL, E.GOODS_CD, A.GOODS_CD)  AS GOODS_CD
                                ,NVL(A.STKIN_QTY,0)                                       AS STR_DRBU_QTY
                                ,NVL(A.BUY_AMT,0)                                         AS STR_DRBU_AMT
                            FROM GSCSODS.TH_BY_BUY_BASICS    A
                                ,GSCSODS.TH_MS_GOODS         E
                           WHERE A.GOODS_CD             = E.GOODS_CD
                           /* 시작일 종료일 */
                             AND A.STK_EVAL_DT BETWEEN '#$Pre1Dt_YMD#' AND '#$CurDt_YMD#'
                             AND A.BUY_SP              <> 'B9'
                             AND A.CENTER_VNDR_SP  NOT IN ('1','2')
                             AND NVL(A.BUY_AMT,0) <> 0
                        ) A,
                        GSCSODS.TH_MS_BIZPL B
                  WHERE A.BIZPL_CD = B.BIZPL_CD
                    AND B.BIZPL_SP IN ('B','C')  
                UNION ALL 
                SELECT A.BIZPL_CD                                                       AS BIZPL_CD
                      ,A.GOODS_CD                                                       AS GOODS_CD
                      ,A.STKIN_DT                                                       AS STK_EVAL_DT
                      ,A.PURCHASE_CD                                                    AS PURCHASE_CD
                      ,(A.BUY_QTY - A.RTN_QTY)                                          AS QTY
                  FROM (
                         SELECT A.STKIN_DT                                              AS STKIN_DT
                               ,A.CENTER_BIZPL_CD                                       AS BIZPL_CD
                               ,B.GOODS_CD                                              AS GOODS_CD
                               ,A.PURCHASE_CD                                           AS PURCHASE_CD
                               ,NVL(DECODE(A.STKIN_SP, 'B1', B.CENTER_STKIN_AMT, 0),0)  AS NOMAL_BUY_AMT
                               ,NVL(DECODE(A.STKIN_SP, 'B4', B.CENTER_STKIN_AMT, 0),0)  AS COMPEN_BUY_AMT
                               ,NVL(DECODE(A.STKIN_SP, 'B3', B.CENTER_STKIN_AMT, 0),0)  AS NOCOMPEN_BUY_AMT
                               ,0                                                       AS SUPL_RTN_AMT
                               ,NVL(B.CENTER_STKIN_QTY,0)                               AS BUY_QTY
                               ,0                                                       AS RTN_QTY
                           FROM GSCSODS.TL_SI_STKIN        A
                               ,GSCSODS.TL_SI_STKIN_DETAIL B
                          WHERE A.CENTER_BIZPL_CD = B.CENTER_BIZPL_CD
                            AND A.LOGIS_SLIP_NO   = B.LOGIS_SLIP_NO
                            AND A.STKIN_DT BETWEEN '#$Pre1Dt_YMD#' AND '#$CurDt_YMD#'
                            AND A.STKIN_STAT_SP = '4'
                            AND A.STKIN_SP IN ('B1','B4','B3')                        
                         UNION ALL                        
                         SELECT A.RTN_DT                                                AS STKIN_DT
                               ,A.CENTER_BIZPL_CD                                       AS BIZPL_CD
                               ,B.GOODS_CD                                              AS GOODS_CD
                               ,A.PURCHASE_CD                                           AS PURCHASE_CD
                               ,0                                                       AS NOMAL_BUY_AMT
                               ,0                                                       AS COMPEN_BUY_AMT
                               ,0                                                       AS NOCOMPEN_BUY_AMT
                               ,B.CENTER_RTN_AMT                                        AS SUPL_RTN_AMT
                               ,0                                                       AS BUY_QTY
                               ,B.CENTER_RTN_QTY                                        AS RTN_QTY
                           FROM GSCSODS.TL_SR_SUPL_RTN        A
                               ,GSCSODS.TL_SR_SUPL_RTN_DETAIL B
                          WHERE A.CENTER_BIZPL_CD = B.CENTER_BIZPL_CD
                            AND A.LOGIS_SLIP_NO   = B.LOGIS_SLIP_NO
                            AND A.RTN_DT BETWEEN '#$Pre1Dt_YMD#' AND '#$CurDt_YMD#'
                            AND B.CENTER_RTN_QTY != 0
                       ) A
                       ,GSCSODS.TH_MS_GOODS G
                 WHERE A.GOODS_CD = G.GOODS_CD
                   AND (A.BUY_QTY - A.RTN_QTY) <> 0
              ) X
             ,GSCSODS.TH_MS_BIZPL Y
       WHERE X.BIZPL_CD = Y.BIZPL_CD
       GROUP BY X.BIZPL_CD
               ,Y.GOODS_REGION_CD
               ,X.GOODS_CD
               ,X.STK_EVAL_DT
               ,X.PURCHASE_CD
       ) O,
      ( /* 편의점 원가DC TOBE LOGIC START : 편의점 원가DC 신시스템 적용후 LOGIC */                        
       SELECT X.STAND_DT
             ,X.COST_DC_SP_CD
             ,X.GOODS_REGION_CD
             ,X.GOODS_CD
             ,X.DC_COST_APP_START_DT
             ,X.DC_COST_APP_END_DT
             ,X.PRC
             ,X.CMKT_PRC
             ,X.DC_COST
             ,X.COST_OLD
         FROM ( SELECT B.STAND_DT
                      ,A.COST_DC_SP_CD
                      ,A.GOODS_REGION_CD
                      ,A.GOODS_CD
                      ,A.DC_COST_APP_START_DT AS DC_COST_APP_START_DT
                      ,A.DC_COST_APP_END_DT AS DC_COST_APP_END_DT
                      ,A.PRC
                      ,A.CMKT_PRC
                      ,A.DC_COST AS DC_COST
                      ,A.COST_OLD
                      ,DENSE_RANK() OVER(PARTITION BY B.STAND_DT, A.GOODS_CD ORDER BY CASE WHEN A.COST_DC_SP_CD = 3 THEN 0 ELSE A.COST_DC_SP_CD END ASC) AS LANK_DT
                      ,MIN(A.COST_DC_SP_CD) OVER (PARTITION BY B.STAND_DT, A.GOODS_CD ) AS MAX_COST_DC_SP_CD
                  FROM ( SELECT CAST(A.COST_DC_SP_CD AS NUMERIC(1,0)) AS COST_DC_SP_CD
                               ,A.GOODS_REGION_CD
                               ,A.GOODS_CD
                               ,A.DC_COST_APP_START_DT AS DC_COST_APP_START_DT
                               ,A.DC_COST_APP_END_DT AS DC_COST_APP_END_DT
                               ,A.PRC
                               ,A.CMKT_PRC
                               ,A.COST_OLD -A.COST_DC_AMT AS DC_COST
                               ,A.COST_OLD
                           FROM ( SELECT '9' AS COST_DC_SP_CD
                                        ,X.GOODS_REGION_CD AS GOODS_REGION_CD
                                        ,X.GOODS_CD AS GOODS_CD
                                        ,X.DC_COST_APP_START_DT AS DC_COST_APP_START_DT
                                        ,X.DC_COST_APP_END_DT AS DC_COST_APP_END_DT
                                        ,X.PRC
                                        ,X.CMKT_PRC
                                        ,X.COST_OLD
                                        ,X.COST
                                        ,X.COST_OLD - X.COST AS COST_DC_AMT
                                        ,DENSE_RANK() OVER(PARTITION BY X.GOODS_REGION_CD, X.GOODS_CD ORDER BY X.DC_COST_APP_START_DT DESC, X.DC_COST_APP_END_DT DESC) AS LANK
                                   FROM ( 
                                        SELECT A.GOODS_CD
                                              ,A.GOODS_REGION_CD
                                              ,A.STR_SND_DT AS BIZPL_DSTRB_DT
                                              ,A.APP_START_DT AS DC_COST_APP_START_DT
                                              ,A.APP_END_DT AS DC_COST_APP_END_DT
                                              ,A.PRC
                                              ,B.CMKT_PRC
                                              ,A.DC_COST AS COST
                                              ,A.COST AS COST_OLD
                                              ,DENSE_RANK() OVER(PARTITION BY A.GOODS_REGION_CD, A.GOODS_CD, A.APP_START_DT, A.APP_END_DT ORDER BY A.STR_SND_DT DESC) AS LANK_DSTRB_NO
                                          FROM GSCSODS.TH_MS_XLS_UP_OBJ_GOODS A
                                                INNER JOIN ( SELECT GOODS_CD
                                                                   ,GOODS_REGION_CD 
                                                                   ,CASE WHEN TO_CHAR(SYSDATE,'YYYYMMDD') >= A.CMKT_PRC_APP_DT THEN A.CMKT_PRC ELSE A.CMKT_PRC_OLD END AS CMKT_PRC                 
                                                               FROM GSCSODS.TH_MS_GOODS_DETAIL A   ) B 
                                                        ON A.GOODS_CD = B.GOODS_CD 
                                                       AND A.GOODS_REGION_CD = B.GOODS_REGION_CD
                                         WHERE A.JOB_SP = 'C'    
                                           AND NOT EXISTS (SELECT '1'
                                                             FROM GSCSODS.TH_SS_ETC_CD_DETAIL
                                                            WHERE ETC_CLASS_CD = 'MS150'
                                                              AND ETC_CD       = SUBSTR(A.GOODS_CD,1,4)
                                                              AND USE_YN       = 'Y')
                                           AND A.APP_START_DT <= '#$CurDt_YMD#'
                                           AND A.APP_END_DT >= '#$Pre1Dt_YMD#'
                                         ) X
                                  WHERE X.LANK_DSTRB_NO = 1
                                  UNION ALL  
                                  SELECT Y.COST_DC_SP_CD
                                        ,Y.GOODS_REGION_CD
                                        ,Y.GOODS_CD
                                        ,Y.COST_DC_APP_START_DT AS DC_COST_APP_START_DT
                                        ,Y.COST_DC_APP_END_DT AS DC_COST_APP_END_DT
                                        ,Y.PRC
                                        ,Y.CMKT_PRC
                                        ,Y.COST_OLD AS COST_OLD
                                        ,Y.COST_OLD - COST_DC_AMT AS COST
                                        ,Y.COST_DC_AMT AS COST_DC_AMT
                                        ,1 AS LANK
                                    FROM ( SELECT A.COST_DC_SP_CD
                                                 ,A.GOODS_REGION_CD
                                                 ,A.GOODS_CD
                                                 ,A.COST_DC_APP_START_DT
                                                 ,A.COST_DC_APP_END_DT
                                                 ,A.STR_SND_DT
                                                 ,B.PRC
                                                 ,B.CMKT_PRC
                                                 ,NVL(A.COST,0) AS COST_OLD
                                                 ,A.STR_SND_DT
                                                 ,A.COST_DC_AMT
                                                 ,DENSE_RANK() OVER(PARTITION BY A.COST_DC_SP_CD, A.GOODS_REGION_CD, A.GOODS_CD, A.COST_DC_APP_START_DT,  A.COST_DC_APP_END_DT ORDER BY A.STR_SND_DT DESC) AS LANK_SND_NO
                                            FROM GSCSODS.TH_MS_GOODS_COST_DC_EVENT A  
                                                 INNER JOIN GSCSODS.TH_MS_GOODS_DETAIL B
                                                         ON A.GOODS_REGION_CD = B.GOODS_REGION_CD
                                                        AND A.GOODS_CD = B.GOODS_CD 
                                           WHERE A.COST_DC_SP_CD IN ('1', '3')   
                                             AND A.COST_DC_APP_START_DT <= '#$CurDt_YMD#'
                                             AND A.COST_DC_APP_END_DT >= '#$Pre1Dt_YMD#'
                                         ) Y        
                                   --WHERE Y.GOODS_CD = '8801043020473'
                                ) A
                          WHERE A.LANK = 1  
                       ) A
                       INNER JOIN GSHNBDW.TB_DM_STAND_DT B
                               ON B.STAND_DT BETWEEN A.DC_COST_APP_START_DT AND A.DC_COST_APP_END_DT 
              ) X
        WHERE X.LANK_DT <= '2'     
          AND X.MAX_COST_DC_SP_CD + X.COST_DC_SP_CD + X.LANK_DT <> 12
          AND X.STAND_DT BETWEEN '#$Pre1Dt_YMD#' AND '#$CurDt_YMD#'
     ) C
WHERE O.STK_EVAL_DT = C.STAND_DT
  AND O.GOODS_REGION_CD = C.GOODS_REGION_CD
  AND O.GOODS_CD = C.GOODS_CD
GROUP BY SUBSTR(O.STK_EVAL_DT,1,6)
        ,C.COST_DC_SP_CD
        ,O.BIZPL_CD
        ,C.GOODS_REGION_CD
        ,C.GOODS_CD
        ,O.PURCHASE_CD
        ,C.DC_COST_APP_START_DT
        ,C.DC_COST_APP_END_DT
        ,C.DC_COST
        ,C.COST_OLD
        ,C.PRC
)
SELECT A.STAND_YYMM                AS STAND_YYMM              /* 기준년월           */
     , A.ITEM_CD                   AS ITEM_CD                 /* 상품코드           */
     , A.UNI_WH_SITE_CD            AS UNI_WH_SITE_CD          /* 통합센터사업장코드 */
     , A.PURCH_COND_CD             AS PURCH_COND_CD           /* 구매조건코드       */
     , ROW_NUMBER() OVER (PARTITION BY A.STAND_YYMM, A.ITEM_CD, A.UNI_WH_SITE_CD, A.PURCH_COND_CD) AS WRK_SEQNO
     , 'C'                         AS BD_SP_CD                /* 사업부구분코드     */
     , A.BUY_QTY                   AS BUY_QTY                 /* 매입수량           */
     , A.ITEM_CST                  AS ITEM_CST                /* 상품원가           */
     , A.DC_CST                    AS DC_CST                  /* 할인원가           */
     , A.ITEM_SPRC                 AS ITEM_SPRC               /* 상품매가           */
     , A.CST_DC_AMT                AS CST_DC_AMT              /* 원가할인금액       */
     , SYSDATE                     AS REG_DTTM                /* 등록일시           */
  FROM (
        SELECT A.STK_EVAL_MM               AS STAND_YYMM              /* 기준년월           */
             , A.COST_DC_SP_CD             AS COST_DC_SP_CD
             , A.GOODS_CD                  AS ITEM_CD                 /* 상품코드           */
             , '~'                         AS UNI_WH_SITE_CD          /* 통합센터사업장코드 */
             , A.PURCHASE_CD               AS PURCH_COND_CD           /* 구매조건코드       */
             , SUM(A.BUY_QTY)              AS BUY_QTY                 /* 매입수량           */
             , A.COST_OLD                  AS ITEM_CST                /* 상품원가           */
             , A.DC_COST                   AS DC_CST                  /* 할인원가           */
             , A.PRC                       AS ITEM_SPRC               /* 상품매가           */
             , SUM(A.COST_DC_PROFIT_AMT)   AS CST_DC_AMT              /* 원가할인금액       */
          FROM DC_COST_PROFIT      A
         WHERE 1 = 1
           AND A.COST_DC_PROFIT_AMT <> 0
         GROUP BY A.STK_EVAL_MM
             , A.GOODS_CD
             , A.PURCHASE_CD
             , A.COST_DC_SP_CD
             , A.COST_OLD   
             , A.DC_COST 
             , A.PRC   
       ) A
;