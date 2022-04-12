SELECT    A.BIZPL_CD          AS 점포코드
     ,    B.BIZPL_NM          AS 점포명
     ,    A.GOODS_CD          AS 상품코드
     ,    SUM(A.STKIN_QTY)    AS 입고수량
     ,    SUM(A.BUY_AMT)      AS 매입금액
  FROM    GSCSODS.TH_BY_BUY_BASICS A
  JOIN    LGMJVDP.TS_MS_BIZPL B
    ON    A.BIZPL_CD = B.BIZPL_CD 
   --AND    B.CLOSE_DT = ''
 WHERE    A.STK_EVAL_DT BETWEEN REPLACE('2022-03-05','-','') AND REPLACE('2022-04-05','-','')
   AND    A.GOODS_CD = '2800100149580'
   AND    A.BUY_SP = 'B1'
 GROUP BY A.STK_EVAL_DT
     ,    A.BIZPL_CD
     ,    B.BIZPL_NM
     ,    A.GOODS_CD
     ,    A.BUY _SP
 ORDER BY 1,3,5

