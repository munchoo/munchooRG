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


---------------------------------------- 시간별이 아닌 일자별로 그룹화
--********************************************************************************


SELECT    TO_CHAR(A.REGI_DTTM,'YYYYMMDD') AS 영업일자
     ,    F.RGNNM AS 부문명
     ,    A.ORIGIN_BIZPL_CD AS 최초코드
     ,    F.TEAM_LN AS 팀명
     ,    C.BIZPL_NM AS 점포명
     ,    D.COOR_NOTE AS 배달업체명
     --,    A.DLIV_RQUST_NO AS 배달주문번호
     ,    A.SALE_AMT AS 판매금액
     ,    TRIM(A.DLIV_ORDPS_REQ_CNTS) AS 배달거절사유
     ,    CASE WHEN A.DLIV_RQUST_SP_CD in ('A') THEN '정상'
          WHEN A.DLIV_RQUST_SP_CD in ('C') THEN '업체취소'
          WHEN A.DLIV_RQUST_SP_CD in ('D') THEN '점포취소'
          ELSE '기타' END AS 주문구분코드
     ,    A.DLIV_RQUST_STAT_CD AS 주문상태코드
     ,    COUNT(A.DLIV_RQUST_NO) AS 건수
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
     ,    F.RGNNM
     ,    F.TEAM_LN
     ,    A.ORIGIN_BIZPL_CD
     ,    C.BIZPL_NM
     ,    D.COOR_NOTE
--     ,    A.DLIV_RQUST_NO
     ,    A.SALE_AMT
     ,    TRIM(A.DLIV_ORDPS_REQ_CNTS)
     ,    CASE WHEN A.DLIV_RQUST_SP_CD in ('A') THEN '정상'
          WHEN A.DLIV_RQUST_SP_CD in ('C') THEN '업체취소'
          WHEN A.DLIV_RQUST_SP_CD in ('D') THEN '점포취소'
          ELSE '기타' END
     ,    A.DLIV_RQUST_STAT_CD


------------ 시간별 #####################################

SELECT    TO_CHAR(A.DLIV_RQUST_ACQ_DTTM,'HH24') AS 배달주문요청일시
     ,    F.RGNNM AS 부문명
     ,    A.ORIGIN_BIZPL_CD AS 최초코드
     ,    F.TEAM_LN AS 팀명
     ,    C.BIZPL_NM AS 점포명
     ,    D.COOR_NOTE AS 배달업체명
     --,    A.DLIV_RQUST_NO AS 배달주문번호
     ,    A.SALE_AMT AS 판매금액
     ,    TRIM(A.DLIV_ORDPS_REQ_CNTS) AS 배달거절사유
     ,    CASE WHEN A.DLIV_RQUST_SP_CD in ('A') THEN '정상'
          WHEN A.DLIV_RQUST_SP_CD in ('C') THEN '업체취소'
          WHEN A.DLIV_RQUST_SP_CD in ('D') THEN '점포취소'
          ELSE '기타' END AS 주문구분코드
     ,    A.DLIV_RQUST_STAT_CD AS 주문상태코드
     ,    COUNT(A.DLIV_RQUST_NO) AS 건수
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

GROUP by  TO_CHAR(A.DLIV_RQUST_ACQ_DTTM,'HH24')
     ,    F.RGNNM
     ,    F.TEAM_LN
     ,    A.ORIGIN_BIZPL_CD
     ,    C.BIZPL_NM
     ,    D.COOR_NOTE
--     ,    A.DLIV_RQUST_NO
     ,    A.SALE_AMT
     ,    TRIM(A.DLIV_ORDPS_REQ_CNTS)
     ,    CASE WHEN A.DLIV_RQUST_SP_CD in ('A') THEN '정상'
          WHEN A.DLIV_RQUST_SP_CD in ('C') THEN '업체취소'
          WHEN A.DLIV_RQUST_SP_CD in ('D') THEN '점포취소'
          ELSE '기타' END
     ,    A.DLIV_RQUST_STAT_CD





