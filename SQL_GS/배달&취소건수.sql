SELECT    TO_CHAR(A.REGI_DTTM,'YYYYMMDD') AS 영업일자
     ,    TO_CHAR(A.DLIV_RQUST_ACQ_DTTM,'YYYY-MM-DD HH24:MI:SS') AS 배달주문요청일시
     ,    TO_CHAR(A.REGI_DTTM, 'YYYY-MM-DD HH24:MI:SS') AS 처리시간
     ,    F.RGNNM AS 부문명
     ,    A.ORIGIN_BIZPL_CD AS 최초코드
     ,    F.TEAM_LN AS 팀명
     ,    C.BIZPL_NM AS 점포명
     ,    D.COOR_NOTE AS 배달업체명
     ,    A.DLIV_RQUST_NO AS 배달주문번호
     ,    A.SALE_AMT AS 판매금액
     ,    TRIM(A.DLIV_ORDPS_REQ_CNTS) AS 배달거절사유
     ,    CASE WHEN A.DLIV_RQUST_SP_CD in ('A') THEN '정상'
          WHEN A.DLIV_RQUST_SP_CD in ('C') THEN '업체취소'
          WHEN A.DLIV_RQUST_SP_CD in ('D') THEN '점포취소'
          ELSE '기타' END AS 주문구분코드
     ,    A.DLIV_RQUST_STAT_CD AS 주문상태코드
  FROM    GSSCODS.TS_TS_DLIV_RQUST A
  JOIN    GSSCODS.TS_TS_DLIV_RQUST_ITEM B
    ON    A.DLIV_RQUST_NO = B.DLIV_RQUST_NO
  JOIN    LGMJVDP.TS_MS_BIZPL C
    ON    A.BIZPL_CD = C.BIZPL_CD
  JOIN    GSSCODS.TS_MS_COOR D
    ON    A.DLIV_RQUST_COOR_CD = D.TRADE_CD
  JOIN    LGMJVDP.TB_GOOD_DM E
    ON    B.GOODS_CD = E.GOODCD
  JOIN    LGMJVDP.TB_STORE_DM F
    ON    SUBSTR(C.ORIGIN_BIZPL_CD,2,4) = F.STORECD
   AND    F.RGNCD BETWEEN ('41') AND ('60')

-------영업일수를 일자별로 구해서 INNER JOIN으로 영업일수가 0인 점포 제외하기 ----------
  INNER JOIN (select	a11.STORECD  STORECD,
                a11.DATECD  DATECD,
                sum(a11.SALDT_CNT)  영업일수
              from	LGMJVDP.TB_SALDT_FT	a11
              join	LGMJVDP.TB_STORE_DM	a13
                  on 	(a11.STORECD = a13.STORECD)
              where	a11.DATECD BETWEEN ('2022-02-01') AND to_char(sysdate,'YYYY-MM-DD')
              group by	a11.STORECD,
                a11.DATECD
              Having sum(a11.SALDT_CNT) > 0
              ) Z
    ON F.STORECD = Z.STORECD AND TO_CHAR(A.REGI_DTTM,'YYYY-MM-DD') = Z.DATECD

   WHERE    TO_CHAR(A.REGI_DTTM,'YYYYMMDD') BETWEEN REPLACE('2022-02-01','-','')AND to_char(sysdate,'YYYYMMDD')
--   AND    A.DLIV_RQUST_SP_CD ='D'

GROUP by TO_CHAR(A.REGI_DTTM,'YYYYMMDD')
     ,    TO_CHAR(A.DLIV_RQUST_ACQ_DTTM,'YYYY-MM-DD HH24:MI:SS')
     ,    TO_CHAR(A.REGI_DTTM, 'YYYY-MM-DD HH24:MI:SS')
     ,    F.RGNNM
     ,    F.TEAM_LN
     ,    A.ORIGIN_BIZPL_CD
     ,    C.BIZPL_NM
     ,    D.COOR_NOTE
     ,    A.DLIV_RQUST_NO
     ,    A.SALE_AMT
     ,    TRIM(A.DLIV_ORDPS_REQ_CNTS)
     ,    CASE WHEN A.DLIV_RQUST_SP_CD in ('A') THEN '정상'
          WHEN A.DLIV_RQUST_SP_CD in ('C') THEN '업체취소'
          WHEN A.DLIV_RQUST_SP_CD in ('D') THEN '점포취소'
          ELSE '기타' END
     ,    A.DLIV_RQUST_STAT_CD


-----------------------------------------------------영업일수 뽑아내기

select	a11.STORECD  STORECD,
      	a11.DATECD  DATECD,
	      sum(a11.SALDT_CNT)  영업일수
from	LGMJVDP.TB_SALDT_FT	a11
join	LGMJVDP.TB_STORE_DM	a13
	  on 	(a11.STORECD = a13.STORECD)
where	a11.DATECD BETWEEN ('2022-02-01') AND to_char(sysdate,'YYYY-MM-DD')
group by	a11.STORECD,
	a11.DATECD


--------------판매

SELECT    A.OPER_DT    AS 영업일자
     ,    B.RGNNM      AS 부문명
     ,    B.TEAM_LN    AS 팀명
     ,    B.PART_LN    AS OFC명
     ,    C.BIZPL_CD   AS 점포코드
     ,    C.BIZPL_NM   AS 점포명ㄴ
     ,     D.COOR_NOTE AS 배달주문업체
     ,    A.DLIV_COOR_NM AS 배달대행업체     
     ,    SUM(CASE WHEN A.TENDER_AMT >= 0 THEN 1 ELSE 0 END) AS 정상건수
     ,    SUM(CASE WHEN A.TENDER_AMT < 0 THEN -1 ELSE 0 END) AS 반품건수
     ,    SUM(CASE WHEN A.TENDER_AMT >= 0 THEN A.SALE_AMT ELSE 0 END) AS 정상매출액
     ,    SUM(CASE WHEN A.TENDER_AMT < 0 THEN A.SALE_AMT ELSE 0 END) AS 반품매출액
     ,    SUM(CASE WHEN A.TENDER_AMT >= 0 THEN 1 ELSE -1 END) AS 전체건수
     ,    SUM(A.SALE_AMT) AS 전체매출액
  FROM    GSSCODS.TS_TR_DLIV_RQUST    A    /* TR_배달주문     */
  JOIN    LGMJVDP.TB_STORE_DM B
    ON    SUBSTR(A.ORIGIN_BIZPL_CD,2,4) = B.STORECD



  JOIN    LGMJVDP.TS_MS_BIZPL  C           /* MS_전사사업장   */
    ON    A.BIZPL_CD = C.BIZPL_CD
 JOIN    GSSCODS.TS_MS_COOR D
    ON    A.DLIV_RQUST_COOR_CD = D.TRADE_CD
 WHERE    A.OPER_DT BETWEEN REPLACE('2022-03-09','-','') AND REPLACE('2022-03-09','-','')
 GROUP BY A.OPER_DT
     ,    B.RGNNM
     ,    B.TEAM_LN
     ,    B.PART_LN
     ,    C.BIZPL_CD
     ,    C.BIZPL_NM
    ,     D.COOR_NOTE
     ,    A.DLIV_COOR_NM

---------------------------------판매금액

SELECT    A.OPER_DT   AS 영업일자
     ,    F.POS_NO || F.RECEIPT_NO  AS 영수증번호
     ,    F.SALE_END_DTTM      AS 주문일시
     ,    C.RGNNM    AS 지역
     ,    C.TEAM_LN  AS 영업팀
     ,    C.PART_LN  AS 파트
     ,    A.BIZPL_CD AS 점포코드
     ,    B.BIZPL_NM AS 점포명
     ,    H.COOR_NOTE AS 배달주문업체
     ,    A.DLIV_COOR_NM  AS 배달대행업체
     ,    G.ETC_CD_NM     AS 매출구분
    ,    E.GOOD_CLS0NM
     ,    E.GOOD_CLS1NM   AS 중분류명
     ,    D.GOODS_CD      AS 상품코드
     ,    E.GOODNM        AS 상품명
     ,    SUM(D.SALE_QTY) AS 판매수량
      ,    SUM(CASE WHEN D.SALE_SP NOT IN ('5','6','9','A') THEN (D.DC_PRC * D.SALE_QTY) ELSE 0 END)   AS 판매금액
  ,    COST AS 원가
     ,    SUM(CASE WHEN D.SALE_SP NOT IN ('5','6','9','A') THEN (D.DC_PRC* D.SALE_QTY)  - D.SALE_VAT  ELSE 0 END )  AS 매출액
     --,    SUM(CASE WHEN D.SALE_QTY > 0 THEN 1 ELSE 0 END) AS 주문건수
  FROM    GSSCODS.TS_TR_DLIV_RQUST    A    /* TR_배달주문     */
  JOIN    LGMJVDP.TS_MS_BIZPL  B           /* MS_전사사업장   */
    ON    A.BIZPL_CD = B.BIZPL_CD
  JOIN    LGMJVDP.TB_STORE_DM C
    ON    SUBSTR(B.ORIGIN_BIZPL_CD,2,4) = C.STORECD
 
  
  
  JOIN    GSSCODS.TS_TR_ITEM D    /* TR_상품        */
    ON    A.ORIGIN_BIZPL_CD    = D.ORIGIN_BIZPL_CD
   AND    A.OPER_DT            = D.OPER_DT
   AND    A.POS_NO             = D.POS_NO
   AND    A.SALE_SEQ           = D.SALE_SEQ
  LEFT    OUTER JOIN LGMJVDP.TB_GOOD_DM E
    ON    D.GOODS_CD = E.GOODCD
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
 WHERE    A.OPER_DT BETWEEN REPLACE('2022-03-09','-','') AND REPLACE('2022-03-09','-','')
 GROUP BY A.OPER_DT
     ,    F.POS_NO || F.RECEIPT_NO
     ,    F.SALE_END_DTTM
     ,    C.RGNNM
     ,    C.TEAM_LN
     ,    C.PART_LN
     ,    A.BIZPL_CD
     ,    B.BIZPL_NM
     ,    H.COOR_NOTE    
     ,    COST
     ,    A.DLIV_COOR_NM
     ,    E.GOOD_CLS0NM
     ,    G.ETC_CD_NM
     ,    E.GOOD_CLS1NM 
     ,    D.GOODS_CD
     ,    E.GOODNM
