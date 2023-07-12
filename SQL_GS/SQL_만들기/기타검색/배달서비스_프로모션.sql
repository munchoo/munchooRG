SELECT    SUBSTR(A.OPER_DT,1,6)  AS 기준년월
     ,    C.RGNNM    AS 지역
     ,    C.TEAM_LN  AS 영업팀
     ,    C.PART_LN  AS 파트
     ,    A.ORIGIN_BIZPL_CD AS 최초점포코드
     ,    A.BIZPL_CD AS 점포코드
     ,    B.BIZPL_NM AS 점포명
     ,    H.COOR_NOTE AS 배달주문업체
     ,    A.DLIV_COOR_NM  AS 배달대행업체
     ,    G.ETC_CD_NM     AS 매출구분
     ,    E.GOOD_CLS0CD   AS 대분류코드
     ,    E.GOOD_CLS0NM   AS 대분류명
     ,    E.GOOD_CLS1CD   AS 중분류코드
     ,    E.GOOD_CLS1NM   AS 중분류명
     ,    D.GOODS_CD      AS 상품코드
     ,    E.GOODNM        AS 상품명
     ,    SUM(D.SALE_QTY) AS 판매수량
     ,    SUM(D.DC_PRC * D.SALE_QTY)   AS 판매금액
     ,    MAX(D.SALE_VAT ) AS 부가세
     ,    SUM(D.DC_PRC * D.SALE_QTY) - MAX(D.SALE_VAT ) AS 매출액     
  FROM    GSSCODS.TS_TR_DLIV_RQUST    A    /* TR_배달주문     */
  JOIN    LGMJVDP.TS_MS_BIZPL  B           /* MS_전사사업장   */
    ON    A.BIZPL_CD = B.BIZPL_CD
  JOIN    LGMJVDP.TB_STORE_DM C
    ON    SUBSTR(B.ORIGIN_BIZPL_CD,2,4) = C.STORECD
   AND    C.RGNCD IN ('41')
   AND    C.TEAMCD IN ('4105')
      
  JOIN    GSSCODS.TS_TR_ITEM D    /* TR_상품        */
    ON    A.ORIGIN_BIZPL_CD    = D.ORIGIN_BIZPL_CD
   AND    A.OPER_DT            = D.OPER_DT
   AND    A.POS_NO             = D.POS_NO
   AND    A.SALE_SEQ           = D.SALE_SEQ
--   AND    D.SALE_SP IN ('1','2')  --정상 , 반품
  LEFT    OUTER JOIN    LGMJVDP.TB_GOOD_DM E
    ON    D.GOODS_CD = E.GOODCD
--   AND    E.GOOD_CLS0CD IN ('05','06','07','08')  --채소 , 과일 , 축산 , 수산    
  JOIN    GSSCODS.TS_TR_HEADER F           /*TR_해더*/
    ON    A.ORIGIN_BIZPL_CD    = F.ORIGIN_BIZPL_CD
   AND    A.OPER_DT            = F.OPER_DT
   AND    A.POS_NO             = F.POS_NO
   AND    A.SALE_SEQ           = F.SALE_SEQ
  JOIN    GSSCODS.TS_MS_ETC_CD_DETAIL G
    ON    D.SALE_SP = G.ETC_CD
   AND    G.ETC_CLASS_CD ='TR10'  
  JOIN    GSSCODS.TS_MS_COOR H
    ON    A.DLIV_RQUST_COOR_CD = H.TRADE_CD
 WHERE    SUBSTR(A.OPER_DT,1,6) IN ('202206')

 GROUP BY SUBSTR(A.OPER_DT,1,6)
     ,    C.RGNNM
     ,    C.TEAM_LN
     ,    C.PART_LN
     ,    A.ORIGIN_BIZPL_CD
     ,    A.BIZPL_CD
     ,    B.BIZPL_NM
     ,    H.COOR_NOTE
     ,    A.DLIV_COOR_NM
     ,    G.ETC_CD_NM
     ,    E.GOOD_CLS0CD
     ,    E.GOOD_CLS0NM
     ,    E.GOOD_CLS1CD
     ,    E.GOOD_CLS1NM 
     ,    D.GOODS_CD
     ,    E.GOODNM

[분석엔진 계산 단계:
	1.  cross-tabbing 수행
]
