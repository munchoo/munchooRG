
select           
   A.OPER_DT
  ,C.RGN_GRPNM
  ,C.RGNNM
  ,C.TEAM_LN
  ,C.PART_LN
  ,A.ORIGIN_BIZPL_CD
  ,C.STORECD
  ,C.STORENM
  ,A.REGI_DTTM
  ,A.POS_NO
  ,A.SALE_SEQ
  ,B.GOODNM
  ,sum(A.DC_PRC) as 매가
  ,sum(A.SALE_QTY) as 판매수량

from GSSCODS.TS_TR_ITEM A
INNER JOIN( select
            A.OPER_DT
          ,C.RGN_GRPNM
          ,C.RGNNM
          ,C.TEAM_LN
          ,C.PART_LN
          ,A.ORIGIN_BIZPL_CD
          ,C.STORECD
          ,C.STORENM
          ,A.REGI_DTTM
          ,A.POS_NO
          ,A.SALE_SEQ
          --  ,B.GOODNM
          ,sum(A.DC_PRC) as 매가
          ,sum(A.SALE_QTY) as 판매수량
      FROM    GSSCODS.TS_TR_ITEM A
        INNER JOIN ( SELECT    A.OPER_DT
                    ,    A.REGI_DTTM
                    ,    A.ORIGIN_BIZPL_CD
                    ,    A.POS_NO
                    ,    A.SALE_SEQ
                  FROM    GSSCODS.TS_TR_ITEM A


                WHERE    A.OPER_DT BETWEEN REPLACE('2021-11-10','-','') AND REPLACE('2021-11-21','-','')
                  AND    A.SALE_SP IN ('1', '2')  --장상판매 , 고객반품
                  AND    A.SKU_CANCEL_YN   =  'N'
                  AND    A.GOODS_CD IN ('88002798', '8801104221467', '8801062623471', '8801062623594' )

                GROUP BY A.OPER_DT
                    ,    A.ORIGIN_BIZPL_CD
                    ,    A.REGI_DTTM
                    ,    A.POS_NO
                    ,    A.SALE_SEQ
                having COUNT(DISTINCT A.GOODS_CD) = 3

                ) AC
                ON A.OPER_DT = AC.OPER_DT 
                AND A.ORIGIN_BIZPL_CD = AC.ORIGIN_BIZPL_CD
                AND A.SALE_SEQ = AC.SALE_SEQ 
        LEFT  JOIN    LGMJVDP.TB_GOOD_DM B
          ON    A.GOODS_CD = B.GOODCD
        JOIN    LGMJVDP.TB_STORE_DM  C
          ON    SUBSTR(A.ORIGIN_BIZPL_CD,2,4) = C.STORECD
      group by       A.OPER_DT
          ,C.RGN_GRPNM
          ,C.RGNNM
          ,C.TEAM_LN
          ,C.PART_LN
          ,A.ORIGIN_BIZPL_CD
          ,C.STORECD
          ,C.STORENM
          ,A.REGI_DTTM
          ,A.POS_NO
          ,A.SALE_SEQ
          --  ,B.GOODNM
      -- having sum(A.SALE_QTY) = 7
      -- and sum(A.DC_PRC) = 11600
      order by sum(A.DC_PRC) DESC
      ) AB
      
      ON A.OPER_DT = AB.OPER_DT 
      AND A.ORIGIN_BIZPL_CD = AB.ORIGIN_BIZPL_CD
      AND A.SALE_SEQ = AB.SALE_SEQ 
      LEFT  JOIN    LGMJVDP.TB_GOOD_DM B
      ON    A.GOODS_CD = B.GOODCD
      JOIN    LGMJVDP.TB_STORE_DM  C
      ON    SUBSTR(A.ORIGIN_BIZPL_CD,2,4) = C.STORECD
  group by A.OPER_DT
  ,C.RGN_GRPNM
  ,C.RGNNM
  ,C.TEAM_LN
  ,C.PART_LN
  ,A.ORIGIN_BIZPL_CD
  ,C.STORECD
  ,C.STORENM
  ,A.REGI_DTTM
  ,A.POS_NO
  ,A.SALE_SEQ
  ,B.GOODNM
