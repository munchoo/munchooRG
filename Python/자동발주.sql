WITH SEARCH_DATA AS(
    SELECT A.START_DT
         , A.END_DT
         , TO_DATE(A.END_DT,'YYYYMMDDHH24MISS') - TO_DATE(A.START_DT,'YYYYMMDDHH24MISS') +1 AS DIFF
     FROM (SELECT '${start_dt}' AS START_DT
                , '${end_dt}' AS END_DT
             FROM DUAL) A
), AUTO_ORD AS (
    SELECT /*+ LEADING(J) */ 
             J.TEAM_MNG_CD
            , J.TEAM_MNG_NM
            , I.PART_MNG_CD
            , I.PART_MNG_NM
            , G.ORIGIN_BIZPL_CD
            , H.BIZPL_CD
            , H.BIZPL_NM
            , CNT_AUTO_ORD
      FROM (SELECT /*+ FULL(G) */ 
                  ORIGIN_BIZPL_CD
                , COUNT(DISTINCT G.ORD_DT) AS CNT_AUTO_ORD
             FROM TS_OR_STR_JOB G
            WHERE JOB_TYPE = 'SYS'
              AND ORD_DT BETWEEN '${start_dt}' AND '${end_dt}'
              AND ORD_QTY > 0
              AND LINE_CD  = '13'
            GROUP BY ORIGIN_BIZPL_CD) G
         , (SELECT /*+ FULL(A) */ 
                   ORIGIN_BIZPL_CD
                 , BIZPL_CD
                 , BIZPL_NM
                 , PART_MNG_CD
                 , TEAM_MNG_CD
              FROM TS_MS_BIZPL A
             WHERE OPEN_DT  <= TO_CHAR(SYSDATE,'YYYYMMDD')
               AND (close_dt IS NULL OR close_dt >= TO_CHAR (SYSDATE, 'yyyymmdd'))
               AND bizpl_sp = 'C') H
         , TS_MS_OPER_PART_MNG I
         , TS_MS_OPER_TEAM_MNG J
     WHERE G.ORIGIN_BIZPL_CD = H.ORIGIN_BIZPL_CD 
       AND H.PART_MNG_CD = I.PART_MNG_CD
       AND H.TEAM_MNG_CD = I.TEAM_MNG_CD
       AND H.TEAM_MNG_CD = J.TEAM_MNG_CD
       AND J.TEAM_MNG_NM LIKE DECODE('${team_nm}', 'NULL', '%', '%${team_nm}%'))
SELECT  
  '팀명'||','||
  'OFC명'||','||
  '점포코드'||','||
  '점포명'||','||
  '사용률'||','||
  '사용일수' AS RN
 FROM DUAL
UNION ALL
SELECT /*+ USE_HASH(B) */
      A.TEAM_MNG_NM||','||
      A.PART_MNG_NM||','||
      A.BIZPL_CD||','||
      A.BIZPL_NM||','||
      (CASE WHEN NVL(A.CNT_AUTO_ORD,0) = '0' THEN '0'
                WHEN NVL(A.CNT_AUTO_ORD,0) - NVL(B.PD_REAL_CNT,0) > 0 
                THEN ROUND(NVL(B.PD_REAL_CNT,0) / C.DIFF *100,2)  || '%'
                ELSE ROUND(NVL(A.CNT_AUTO_ORD,0) / C.DIFF *100,2) || '%' END) ||','||
      (CASE WHEN NVL(A.CNT_AUTO_ORD,0) = 0 THEN 0
            WHEN NVL(A.CNT_AUTO_ORD,0) - NVL(B.PD_REAL_CNT,0) > 0 
                 THEN NVL(B.PD_REAL_CNT,0)
                 ELSE NVL(A.CNT_AUTO_ORD,0) END)  AS RN
  FROM AUTO_ORD A
     , (SELECT T1.BIZPL_CD, COUNT(DISTINCT ORD_DT) AS PD_REAL_CNT
          FROM TH_OR_STR@DL_PCSOR T1
         WHERE T1.ORD_DT BETWEEN '${start_dt}' AND '${end_dt}'
           AND T1.ORD_QTY > 0
           AND T1.ORD_SP = '4'
           AND T1.LINE_CD = '13'
        GROUP BY T1.BIZPL_CD) B
     , SEARCH_DATA C 
WHERE A.BIZPL_CD = B.BIZPL_CD(+)