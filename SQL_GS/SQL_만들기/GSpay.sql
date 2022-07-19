SELECT *
FROM LGMJVDP.TH_TR_SMPL_PAY_TENDER
WHERE OPER_DT ='20210912'
 AND  SMPL_PAY_SVC_CD IN ('08','09') -- GS PAY 08 : 신용카드, 09 : 계좌
LIMIT 10;

--------------------------------------------------
WITH ITEM AS (
SELECT    A.OPER_DT
     ,    A.ORIGIN_BIZPL_CD
     ,    A.POS_NO
     ,    A.SALE_SEQ
     ,    SUM(CASE WHEN SALE_SP <> '3' AND A.GOODS_CD <> ''  THEN (DC_PRC * SALE_QTY) - MBR_DC_AMT - PRMT_dC_AMT ELSE 0 END) AS SALE_AMT
  FROM    GSSCODS.TS_TR_ITEM A
 WHERE    (OPER_DT BETWEEN  '20220601' AND '20220630' OR OPER_DT BETWEEN  '20220711' AND '20220731')
   AND    SKU_CANCEL_YN ='N'
   --AND    A.ORIGIN_BIZPL_CD = 'V1008'  
   AND    SALE_SP IN ('1','2','3')
 GROUP BY A.OPER_DT
     ,    A.ORIGIN_BIZPL_CD
     ,    A.POS_NO
     ,    A.SALE_SEQ
),
SMPL AS(
SELECT    A.OPER_DT
     ,    A.ORIGIN_BIZPL_CD
     ,    A.POS_NO
     ,    A.SALE_SEQ
     ,    A.NOR_CANCEL_SP
     ,    A.SMPL_PAY_SVC_CD
     ,    B.RGNNM
     ,    B.TEAM_LN
     ,    B.PART_LN
     ,    C.OPEN_DT
     ,    C.CLOSE_DT
     ,    C.BIZPL_NM
     ,    C.BIZPL_cD
  FROM    GSSCODS.TS_TR_SMPL_PAY_TENDER A
  JOIN    LGMJVDP.TB_STORE_DM B
    ON    SUBSTR(A.ORIGIN_BIZPL_CD,2,4) = B.STORECD
  JOIN    LGMJVDP.TS_MS_BIZPL C
    ON    A.BIZPL_CD = C.BIZPL_CD
 WHERE    (OPER_DT BETWEEN  '20220601' AND '20220630' OR OPER_DT BETWEEN  '20220711' AND '20220731')
   --AND    A.ORIGIN_BIZPL_CD = 'V1008'
   AND    SMPL_PAY_SVC_CD IN ('08', '09')
   AND    B.RGNCD IN ('52','53','54')
 GROUP BY A.OPER_DT
     ,    A.ORIGIN_BIZPL_CD
     ,    A.POS_NO
     ,    A.SALE_SEQ
     ,    A.NOR_CANCEL_SP
     ,    A.SMPL_PAY_SVC_CD
     ,    B.RGNNM
     ,    C.OPEN_DT
     ,    C.CLOSE_DT
     ,    B.TEAM_LN
     ,    B.PART_LN
     ,    C.BIZPL_NM
     ,    C.BIZPL_cD
), Opedt as(
    select 'V'||a11.STORECD  STORECD, 
    sum(case when month(a11.datecd) = 6 then a11.SALDT_CNT END)   as mon6,
    sum(case when month(a11.datecd) = 7 then a11.SALDT_CNT END)   as mon7
    from  LGMJVDP.TB_SALDT_FT a11
    join LGMJVDP.TB_STORE_DM a12
      on  (a11.STORECD = a12.STORECD)
    where (a11.DATECD between ('2022-06-01') and ('2022-06-30') or a11.DATECD between ('2022-07-11') and ('2022-07-31'))
    group by 'V'||a11.STORECD
)
SELECT    A.RGNNM
     ,    A.TEAM_LN
     ,    A.PART_LN
     ,    A.ORIGIN_BIZPL_CD
     ,    A.BIZPL_CD
     ,    A.BIZPL_NM
     ,    A.OPEN_DT
     ,    A.CLOSE_DT
    -- ,    SUM(CASE WHEN A.SMPL_PAY_SVC_CD = '08' THEN B.SALE_AMT END) AS GSPAY신용카드매출
    -- ,    SUM(CASE WHEN A.SMPL_PAY_SVC_CD = '09' THEN B.SALE_AMT END) AS GSPAY계좌매출
     ,    SUM(CASE WHEN A.SMPL_PAY_SVC_CD = '08' AND A.NOR_CANCEL_SP ='0' AND A.OPER_DT < '20220701' THEN 1 
                   WHEN A.SMPL_PAY_SVC_CD = '08' AND A.NOR_CANCEL_SP ='9' AND A.OPER_DT < '20220701' THEN -1 END) AS GSPAY신용카드건수6
     ,    SUM(CASE WHEN A.SMPL_PAY_SVC_CD = '09' AND A.NOR_CANCEL_SP ='0' AND A.OPER_DT < '20220701' THEN 1 
                   WHEN A.SMPL_PAY_SVC_CD = '09' AND A.NOR_CANCEL_SP ='9' AND A.OPER_DT < '20220701' THEN -1 END) AS GSPAY계좌건수6
     ,    SUM(CASE WHEN A.SMPL_PAY_SVC_CD = '08' AND A.NOR_CANCEL_SP ='0' AND A.OPER_DT >= '20220701' THEN 1 
                   WHEN A.SMPL_PAY_SVC_CD = '08' AND A.NOR_CANCEL_SP ='9' AND A.OPER_DT >= '20220701' THEN -1 END) AS GSPAY신용카드건수7
     ,    SUM(CASE WHEN A.SMPL_PAY_SVC_CD = '09' AND A.NOR_CANCEL_SP ='0' AND A.OPER_DT >= '20220701' THEN 1 
                   WHEN A.SMPL_PAY_SVC_CD = '09' AND A.NOR_CANCEL_SP ='9' AND A.OPER_DT >= '20220701' THEN -1 END) AS GSPAY계좌건수7
     ,    C.mon6
     ,    c.mon7     
  FROM    ITEM B
  JOIN    SMPL A 
    ON    A.OPER_DT = B.OPER_DT
   AND    A.ORIGIN_BIZPL_CD = B.ORIGIN_BIZPL_CD
   AND    A.POS_NO = B.POS_NO
   AND    A.SALE_sEQ = B.SALE_SEQ
   AND    A.CLOSE_DT = ''
  JOIN    Opedt C
    ON    A.ORIGIN_BIZPL_CD = C.STORECD
 GROUP BY A.RGNNM
     ,    A.TEAM_LN
     ,    A.PART_LN
     ,    A.ORIGIN_BIZPL_CD
     ,    A.BIZPL_CD
     ,    A.BIZPL_NM
     ,    A.OPEN_DT
     ,    A.CLOSE_DT
     ,    mon6
     ,    mon7
 ORDER BY 1,2,3,4,5,6,7,8
