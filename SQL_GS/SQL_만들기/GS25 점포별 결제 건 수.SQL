WITH HEADER AS(
SELECT    OPER_DT
     ,    ORIGIN_BIZPL_CD
     ,    POS_NO
     ,    SALE_SEQ
  FROM    GSSCODS.TS_TR_HEADER A
 WHERE    A.OPER_DT BETWEEN TO_CHAR(SYSDATE-3,'YYYYMMDD') AND TO_CHAR(SYSDATE-1,'YYYYMMDD')
   AND    DEAL_SP IN ('01', '33', '61')
 GROUP BY OPER_DT
     ,    ORIGIN_BIZPL_CD
     ,    POS_NO
     ,    SALE_SEQ
)
SELECT    영업일자
     ,    부문명
     ,    팀명
     ,    OFC명
     ,    최초점포코드
     ,    점포코드
     ,    점포명
     ,    SUM(총매출액) AS 총매출액
     ,    SUM(총결제건수) AS 총결제건수
     ,    SUM(신용카드매출액) AS 신용카드매출액
     ,    SUM(현금매출액) AS 현금매출액
     ,    SUM(네이버) AS 네이버매출액
     ,    SUM(카카오) AS 카카오매출액
     ,    SUM(GS페이계좌) AS GS페이계좌매출액
     ,    SUM(GS페이카드) AS GS페이카드매출액
     ,    SUM(다날페이코인) AS 다날페이코인매출액
     ,    SUM(스마일페이) AS 스마일페이매출액
     ,    SUM(페이코) AS 페이코매출액
     ,    SUM(신용카드건수) AS 신용카드건수
     ,    SUM(현금건수) AS 현금건수
     ,    SUM(네이버건수) AS 네이버건수
     ,    SUM(카카오건수) AS 카카오건수
     ,    SUM(GS페이계좌건수) AS GS페이계좌건수
     ,    SUM(GS페이카드건수) AS GS페이카드건수
     ,    SUM(다날페이코인건수) AS 다날페이코인건수
     ,    SUM(스마일페이건수) AS 스마일페이건수
     ,    SUM(페이코건수) AS 페이코건수
 FROM    
(SELECT   OPER_DT AS 영업일자
     ,    Z.RGNNM AS 부문명
     ,    Z.TEAM_LN AS 팀명
     ,    Z.PART_LN AS OFC명
     ,    Y.ORIGIN_BIZPL_CD AS 최초점포코드
     ,    Y.BIZPL_CD AS 점포코드
     ,    Y.BIZPL_NM AS 점포명
     ,    0 AS 총매출액
     ,    0 AS 총결제건수
     ,    0 AS 신용카드매출액
     ,    0 AS 현금매출액
     ,    0 AS 네이버
     ,    SUM(CASE WHEN SMPL_PAY_SVC_CD IN ('01','03') THEN SMPL_PAY_DEAL_AMT END) AS 카카오
     ,    SUM(CASE WHEN SMPL_PAY_SVC_CD = '09' THEN SMPL_PAY_DEAL_AMT END) AS GS페이계좌
     ,    SUM(CASE WHEN SMPL_PAY_SVC_CD = '08' THEN SMPL_PAY_DEAL_AMT END) AS GS페이카드
     ,    SUM(CASE WHEN SMPL_PAY_SVC_CD = '10' THEN SMPL_PAY_DEAL_AMT END) AS 다날페이코인
     ,    SUM(CASE WHEN SMPL_PAY_BIZOP_CD = 'SP' THEN SMPL_PAY_DEAL_AMT END) AS 스마일페이
     ,    0 AS 페이코
     ,    0 AS 신용카드건수
     ,    0 AS 현금건수
     ,    0 AS 네이버건수
     ,    SUM(CASE WHEN  SMPL_PAY_SVC_CD IN ('01','03') AND NOR_CANCEL_SP  = '0' THEN 1
                   WHEN  SMPL_PAY_SVC_CD = '01' AND NOR_CANCEL_SP  = '9' THEN -1 END) AS 카카오건수
     ,    SUM(CASE WHEN  SMPL_PAY_SVC_CD = '09' AND NOR_CANCEL_SP  = '0' THEN 1
                   WHEN  SMPL_PAY_SVC_CD = '09' AND NOR_CANCEL_SP  = '9' THEN -1 END) AS GS페이계좌건수
     ,    SUM(CASE WHEN  SMPL_PAY_SVC_CD = '08' AND NOR_CANCEL_SP  = '0' THEN 1
                   WHEN  SMPL_PAY_SVC_CD = '08' AND NOR_CANCEL_SP  = '9' THEN -1 END) AS GS페이카드건수
     ,    SUM(CASE WHEN  SMPL_PAY_SVC_CD = '10' AND NOR_CANCEL_SP  = '0' THEN 1
                   WHEN  SMPL_PAY_SVC_CD = '10' AND NOR_CANCEL_SP  = '9' THEN -1 END) AS 다날페이코인건수
     ,    SUM(CASE WHEN  SMPL_PAY_BIZOP_CD = 'SP' AND NOR_CANCEL_SP  = '0' THEN 1
                   WHEN  SMPL_PAY_BIZOP_CD = 'SP' AND NOR_CANCEL_SP  = '9' THEN -1 END) AS 스마일페이건수
     ,    0 AS 페이코건수
  FROM    GSSCODS.TS_TR_SMPL_PAY_TENDER A
  JOIN    LGMJVDP.TS_MS_BIZPL Y
    ON    A.BIZPL_CD = Y.BIZPL_CD
  JOIN    LGMJVDP.TB_STORE_DM Z
    ON    SUBSTR(A.ORIGIN_BIZPL_CD,2,4) = Z.STORECD
 WHERE    A.OPER_DT BETWEEN TO_CHAR(SYSDATE-3,'YYYYMMDD') AND TO_CHAR(SYSDATE-1,'YYYYMMDD')
 GROUP BY OPER_DT
     ,    0
     ,    Z.RGNNM
     ,    Z.TEAM_LN
     ,    Z.PART_LN
     ,    Y.ORIGIN_BIZPL_CD
     ,    Y.BIZPL_CD
     ,    Y.BIZPL_NM
UNION ALL

SELECT    A.OPER_DT AS 영업일자
     ,    Z.RGNNM AS 부문명
     ,    Z.TEAM_LN AS 팀명
     ,    Z.PART_LN AS OFC명
     ,    Y.ORIGIN_BIZPL_CD AS 최초점포코드
     ,    Y.BIZPL_CD AS 점포코드
     ,    Y.BIZPL_NM AS 점포명
     ,    SUM(TENDER_AMT-CHANGE) AS 총매출액
     ,    SUM(CASE WHEN A.NOR_CANCEL_SP = '0' THEN 1 ELSE -1 END) AS 총결제건수
     ,    SUM(CASE WHEN TENDER_CD = '06' THEN TENDER_AMT END ) AS 신용카드매출액
     ,    SUM(CASE WHEN TENDER_CD = '01' THEN TENDER_AMT - CHANGE END ) AS 현금매출액
     ,    SUM(CASE WHEN TENDER_CD = '06' AND SUBSTR(CARD_NO,1,6) = '920077' THEN TENDER_AMT END) AS 네이버
     ,    0 AS 카카오
     ,    0 AS GS페이계좌
     ,    0 AS GS페이카드
     ,    0 AS 다날페이코인
     ,    0 AS 스마일페이
     ,    0 AS 페이코
     ,    SUM(CASE WHEN TENDER_CD = '06' AND NOR_CANCEL_SP = '0' THEN 1
                   WHEN TENDER_CD = '06' AND NOR_CANCEL_SP = '9' THEN -1 END ) AS 신용카드건수
     ,    SUM(CASE WHEN TENDER_CD = '01' AND NOR_CANCEL_SP = '0' THEN 1
                   WHEN TENDER_CD = '01' AND NOR_CANCEL_SP = '9' THEN -1 END ) AS 현금건수
     ,    SUM(CASE WHEN TENDER_CD = '06' AND SUBSTR(CARD_NO,1,6) = '920077' AND NOR_CANCEL_SP = '0' THEN 1
                   WHEN TENDER_CD = '06' AND SUBSTR(CARD_NO,1,6) = '920077' AND NOR_CANCEL_SP = '9' THEN -1 END ) AS 네이버건수
     ,    0 AS 카카오건수
     ,    0 AS GS페이계좌건수
     ,    0 AS GS페이카드건수
     ,    0 AS 다날페이코인건수
     ,    0 AS 스마일페이건수
     ,    0 AS 페이코건수
  FROM    GSSCODS.TS_TR_TENDER A
  JOIN    HEADER B
    ON    A.OPER_DT = B.OPER_DT
   AND    A.ORIGIN_BIZPL_CD = B.ORIGIN_BIZPL_CD
   AND    A.POS_NO = B.POS_NO
   AND    A.SALE_SEQ = B.SALE_SEQ
  JOIN    LGMJVDP.TS_MS_BIZPL Y
    ON    A.BIZPL_CD = Y.BIZPL_CD
  JOIN    LGMJVDP.TB_STORE_DM Z
    ON    SUBSTR(A.ORIGIN_BIZPL_CD,2,4) = Z.STORECD
 WHERE    A.OPER_DT BETWEEN TO_CHAR(SYSDATE-3,'YYYYMMDD') AND TO_CHAR(SYSDATE-1,'YYYYMMDD')
 GROUP BY A.OPER_DT
     ,    0
     ,    Z.RGNNM
     ,    Z.TEAM_LN
     ,    Z.PART_LN
     ,    Y.ORIGIN_BIZPL_CD
     ,    Y.BIZPL_CD
     ,    Y.BIZPL_NM
 
 UNION ALL
 
 SELECT   OPER_DT AS 영업일자
     ,    Z.RGNNM AS 부문명
     ,    Z.TEAM_LN AS 팀명
     ,    Z.PART_LN AS OFC명
     ,    Y.ORIGIN_BIZPL_CD AS 최초점포코드
     ,    Y.BIZPL_CD AS 점포코드
     ,    Y.BIZPL_NM AS 점포명
     ,    0 AS 총매출액
     ,    0 AS 총결제건수
     ,    0 AS 신용카드매출액
     ,    0 AS 현금매출액
     ,    0 AS 네이버
     ,    0 AS 카카오
     ,    0 AS GS페이계좌
     ,    0 AS GS페이카드
     ,    0 AS 다날페이코인
     ,    0 AS 스마일페이
     ,    SUM(PAYCO_TENDER_AMT) AS 페이코
     ,    0 AS 신용카드건수
     ,    0 AS 현금건수
     ,    0 AS 네이버건수
     ,    0 AS 카카오건수
     ,    0 AS GS페이계좌건수
     ,    0 AS GS페이카드건수
     ,    0 AS 다날페이코인건수
     ,    0 AS 스마일페이건수
     ,    SUM(CASE WHEN NOR_CANCEL_SP ='0' THEN 1 
                   WHEN NOR_CANCEL_SP ='9' THEN -1 END) AS 페이코건수 
  FROM    GSSCODS.TS_TR_PAYCO_TENDER A
  JOIN    LGMJVDP.TS_MS_BIZPL Y
    ON    A.BIZPL_CD = Y.BIZPL_CD
  JOIN    LGMJVDP.TB_STORE_DM Z
    ON    SUBSTR(A.ORIGIN_BIZPL_CD,2,4) = Z.STORECD
 WHERE    OPER_DT BETWEEN TO_CHAR(SYSDATE-3,'YYYYMMDD') AND TO_CHAR(SYSDATE-1,'YYYYMMDD')
 GROUP BY OPER_DT
     ,    0
     ,    Z.RGNNM
     ,    Z.TEAM_LN
     ,    Z.PART_LN
     ,    Y.ORIGIN_BIZPL_CD
     ,    Y.BIZPL_CD
     ,    Y.BIZPL_NM
)
 GROUP BY 영업일자
     ,    부문명
     ,    팀명
     ,    OFC명
     ,    최초점포코드
     ,    점포코드
     ,    점포명
 ORDER BY 1,2,3,4,5,6,7,8
