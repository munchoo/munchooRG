WITH HEADER AS (
SELECT    A.OPER_DT
     ,    A.ORIGIN_BIZPL_CD
     ,    A.POS_NO
     ,    A.SALE_SEQ
     ,    A.POS_NO || A.RECEIPT_NO  AS RECEIPT_NO
     ,    A.DEAL_SP
     ,    A.TOT_AMT
     ,    A.TOT_QTY
     ,    TO_CHAR(A.SALE_END_DTTM, 'HH24') AS TIME_CD
     ,    A.SALE_END_DTTM
  FROM    GSSCODS.TS_TR_HEADER A
 WHERE    A.OPER_DT BETWEEN REPLACE('2022-08-01','-','') AND REPLACE('2022-08-08','-','')
   AND    A.DEAL_SP IN ('01','33')  --정상판매 , 기프트콘
  
)
,
ITEM AS  (
SELECT    A.OPER_DT
     ,    C.RGN_GRPNM
     ,    C.RGNNM
     ,    C.TEAM_LN
     ,    C.PART_LN
     ,    A.ORIGIN_BIZPL_CD
     ,    C.STORECD
     ,    C.STORENM
     ,    A.POS_NO
     ,    A.SALE_SEQ
     ,    B.GOOD_CLS1NM  --중분류명
     ,    B.GOOD_CLS2NM  --소분류명
     ,    A.GOODS_CD
     ,    B.GOODNM
     ,    SUM(A.DC_PRC)      AS DC_PRC       --매가
     ,    SUM(A.MBR_DC_AMT)  AS MBR_DC_AMT   --멤버십할인금액
     ,    SUM(A.PRMT_DC_AMT) AS PRMT_DC_AMT  --판촉할인금액
     ,    SUM(A.SALE_QTY)    AS SALE_QTY     --판매수량
     ,    SUM(( A.DC_PRC * A.SALE_QTY ) - A.MBR_DC_AMT - A.PRMT_DC_AMT)  AS SALE_AMT
  FROM    GSSCODS.TS_TR_ITEM A
  LEFT    OUTER JOIN    LGMJVDP.TB_GOOD_DM B
    ON    A.GOODS_CD = B.GOODCD
  JOIN    LGMJVDP.TB_STORE_DM  C
    ON    SUBSTR(A.ORIGIN_BIZPL_CD,2,4) = C.STORECD

 WHERE    A.OPER_DT BETWEEN REPLACE('2022-08-01','-','') AND REPLACE('2022-08-08','-','')
   AND    A.SALE_SP IN ('1', '2')  --장상판매 , 고객반품
   AND    A.SKU_CANCEL_YN   =  'N'
   AND    A.GOODS_CD IN ('2800100160431')   
  
 GROUP BY A.OPER_DT
     ,    C.RGN_GRPNM
     ,    C.RGNNM
     ,    C.TEAM_LN
     ,    C.PART_LN
     ,    A.ORIGIN_BIZPL_CD
     ,    C.STORECD
     ,    C.STORENM
     ,    A.POS_NO
     ,    A.SALE_SEQ
     ,    B.GOOD_CLS1NM
     ,    B.GOOD_CLS2NM
     ,    A.GOODS_CD
     ,    B.GOODNM
)

SELECT    A.RGN_GRPNM  AS 부문명
     ,    A.RGNNM      AS 지역명
     ,    A.TEAM_LN    AS 팀명
     ,    A.PART_LN    AS OFC명
     ,    A.ORIGIN_BIZPL_CD AS 최초점포코드
     ,    A.STORECD    AS 점포코드
     ,    A.STORENM    AS 점포명
     ,    A.GOOD_CLS1NM  AS 중분류명
     ,    A.GOOD_CLS2NM  AS 소분류명
     ,    A.GOODS_CD     AS 상품코드
     ,    A.GOODNM       AS 상품명
     ,    MAX(A.DC_PRC)      AS 매가
     ,    SUM(A.MBR_DC_AMT)  AS 멤버십할인금액
     ,    SUM(A.PRMT_DC_AMT) AS 판촉할인금액
     ,    SUM(A.SALE_QTY)    AS 판매수량
     ,    SUM(A.SALE_AMT)    AS 매출액
  FROM    ITEM  A
  JOIN    HEADER B
    ON    A.OPER_DT = B.OPER_DT
   AND    A.ORIGIN_BIZPL_CD   = B.ORIGIN_BIZPL_CD
   AND    A.POS_NO = B.POS_NO
   AND    A.SALE_SEQ = B.SALE_SEQ

 GROUP BY A.RGN_GRPNM
     ,    A.RGNNM
     ,    A.TEAM_LN
     ,    A.PART_LN
     ,    A.ORIGIN_BIZPL_CD
     ,    A.STORECD
     ,    A.STORENM
     ,    A.GOOD_CLS1NM
     ,    A.GOOD_CLS2NM
     ,    A.GOODS_CD
     ,    A.GOODNM
