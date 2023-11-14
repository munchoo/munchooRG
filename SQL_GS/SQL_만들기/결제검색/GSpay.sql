SELECT    영업일자
     ,    부문명
     ,    팀명
     ,    OFC명
     ,    최초점포코드
     ,    점포코드
     ,    점포명
     ,    SUM(TOT_DEAL_COUNT) AS 전체결제건수
     ,    SUM(TOT_DEAL_AMT)  AS 전체결제금액
     ,    SUM(GSPAY_CARD_COUNT) AS GSPAY카드결제건수
     ,    SUM(GSPAY_ACCOUNT_COUNT) AS GSPAY계좌결제건수
     ,    SUM(GSPAY_CARD_AMT) AS GSPAY카드결제금액
     ,    SUM(GSPAY_ACCOUNT_AMT) AS GSPAY계좌결제금액
  FROM    (

SELECT    OPER_DT AS 영업일자
     ,    C.RGNNM AS 부문명
     ,    C.TEAM_LN  AS 팀명
     ,    C.PART_LN AS OFC명
     ,    A.ORIGIN_BIZPL_CD AS 최초점포코드
     ,    A.BIZPL_CD AS 점포코드 
     ,    B.BIZPL_NM AS 점포명
     ,    SUM(CASE WHEN TOT_AMT > 0 THEN 1 
                   WHEN TOT_AMT < 0 THEN -1  END) AS TOT_DEAL_COUNT
     ,    SUM(TOT_AMT) AS TOT_DEAL_AMT
     ,    0 AS GSPAY_CARD_COUNT
     ,    0 AS GSPAY_ACCOUNT_COUNT
     ,    0 AS GSPAY_CARD_AMT
     ,    0 AS GSPAY_ACCOUNT_AMT
  FROM    GSSCODS.TS_TR_HEADER A
  JOIN    LGMJVDP.TS_MS_BIZPL B
    ON    A.BIZPL_CD = B.BIZPL_CD
  JOIN    LGMJVDP.TB_STORE_DM C
    ON    SUBSTR(A.ORIGIN_BIZPL_CD,2,4) = C.STORECD
 WHERE 11=11
   AND  C.TEAMCD IN ('5405')   
  AND    A.OPER_DT BETWEEN REPLACE('2023-11-01','-','')   AND REPLACE('2023-11-02','-','')
  AND    DEAL_SP = '01'
   AND    TOT_AMT <> 0
 GROUP BY OPER_DT
     ,    C.RGNNM
     ,    C.TEAM_LN
     ,    C.PART_LN
     ,    A.ORIGIN_BIZPL_CD
     ,    A.BIZPL_CD
     ,    B.BIZPL_NM
 
 
 UNION ALL
 
SELECT    A.OPER_DT AS 영업일자
     ,    C.RGNNM AS 부문명
     ,    C.TEAM_LN  AS 팀명
     ,    C.PART_LN AS OFC명
     ,    A.ORIGIN_BIZPL_CD AS 최초점포코드
     ,    A.BIZPL_CD AS 점포코드 
     ,    B.BIZPL_NM AS 점포명
     ,    0 AS TOT_DEAL_COUNT
     ,    0 AS TOT_DEAL_AMT
     ,    SUM(CASE WHEN SMPL_PAY_SVC_CD = '08' AND NOR_CANCEL_SP = '0' THEN 1 
                   WHEN SMPL_PAY_SVC_CD = '08' AND NOR_CANCEL_SP = '9' THEN -1 
              END) AS GSPAY_CARD_COUNT
     ,    SUM(CASE WHEN SMPL_PAY_SVC_CD = '09' AND NOR_CANCEL_SP = '0' THEN 1 
                   WHEN SMPL_PAY_SVC_CD = '09' AND NOR_CANCEL_SP = '9' THEN -1 
              END) AS GSPAY_ACCOUNT_COUNT
     ,    SUM(CASE WHEN SMPL_PAY_SVC_CD = '08' THEN SMPL_PAY_DEAL_AMT END) AS GSPAY_CARD_AMT
     ,    SUM(CASE WHEN SMPL_PAY_SVC_CD = '09' THEN SMPL_PAY_DEAL_AMT END) AS GSPAY_ACCOUNT_AMT
  FROM    GSSCODS.TS_TR_SMPL_PAY_TENDER A
  JOIN    LGMJVDP.TS_MS_BIZPL B
    ON    A.BIZPL_CD = B.BIZPL_CD
  JOIN    LGMJVDP.TB_STORE_DM C
    ON    SUBSTR(A.ORIGIN_BIZPL_CD,2,4) = C.STORECD
 WHERE  11=11
   AND  C.TEAMCD IN ('5405')
    AND    A.OPER_DT  BETWEEN REPLACE('2023-11-01','-','')   AND REPLACE('2023-11-02','-','')
    AND    SMPL_PAY_SVC_CD IN ('08','09')
 GROUP BY A.OPER_DT
     ,    C.RGNNM 
     ,    C.TEAM_LN  
     ,    C.PART_LN 
     ,    A.ORIGIN_BIZPL_CD 
     ,    A.BIZPL_CD 
     ,    B.BIZPL_NM 
 )   
 GROUP BY 영업일자
     ,    부문명
     ,    팀명
     ,    OFC명
     ,    최초점포코드
     ,    점포코드
     ,    점포명