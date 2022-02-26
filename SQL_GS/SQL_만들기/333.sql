select
     OPER_DT
     ,RGN_GRPNM
     ,RGNNM
     ,TEAM_LN
     ,PART_LN
     ,ORIGIN_BIZPL_CD
     ,STORECD
     ,STORENM
     ,REGI_DTTM
     ,POS_NO
     ,SALE_SEQ
     ,sum(DC_PRC) as 매가
     ,sum(SALE_QTY) as 판매수량
from( SELECT    A.OPER_DT
     ,    C.RGN_GRPNM
     ,    C.RGNNM
     ,    C.TEAM_LN
     ,    C.PART_LN
     ,    A.REGI_DTTM
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

 WHERE    A.OPER_DT BETWEEN REPLACE('2021-11-10','-','') AND REPLACE('2021-11-21','-','')
   AND    A.SALE_SP IN ('1', '2')  --장상판매 , 고객반품
   AND    A.SKU_CANCEL_YN   =  'N'
   AND    A.GOODS_CD IN ('88002798     ', '8801104221467')

 GROUP BY A.OPER_DT
     ,    C.RGN_GRPNM
     ,    C.RGNNM
     ,    C.TEAM_LN
     ,    C.PART_LN
     ,    A.ORIGIN_BIZPL_CD
     ,    C.STORECD
     ,    C.STORENM
     ,    A.REGI_DTTM
     ,    A.POS_NO
     ,    A.SALE_SEQ
     ,    B.GOOD_CLS1NM
     ,    B.GOOD_CLS2NM
     ,    A.GOODS_CD
     ,    B.GOODNM
  -- having    (a.GOODS_CD in ('88002798     ') and sum(a.SALE_QTY) = 1)
  --       or (a.GOODS_CD in ('8801062623471') and sum(a.SALE_QTY) = 2)
  --       or (a.GOODS_CD in ('8801104221467') and sum(a.SALE_QTY) = 1)
        -- or (a.GOODS_CD in ('8801121771402') and sum(a.SALE_QTY) = 3)
  order by sum(a.SALE_QTY) DESC
)

group by OPER_DT
     ,RGN_GRPNM
     ,RGNNM
     ,TEAM_LN
     ,PART_LN
     ,ORIGIN_BIZPL_CD
     ,STORECD
     ,STORENM
     ,REGI_DTTM
     ,POS_NO
     ,SALE_SEQ

having SUM(SALE_QTY) = 7 and
sum(DC_PRC) >10000