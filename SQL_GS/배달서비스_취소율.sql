SELECT    A.OPER_DT    AS 영업일자
     ,    B.RGNNM      AS 부문명
     ,    B.TEAM_LN    AS 팀명
     ,    B.PART_LN    AS OFC명
     ,    C.BIZPL_CD   AS 점포코드
     ,    C.BIZPL_NM   AS 점포명
     ,     D.COOR_NOTE AS 배달주문업체
     ,    A.DLIV_COOR_NM AS 배달대행업체     
     ,    SUM(CASE WHEN A.TENDER_AMT >= 0 THEN 1 ELSE 0 END) AS 정상건수
  FROM    GSSCODS.TS_TR_DLIV_RQUST    A    /* TR_배달주문     */
  JOIN    LGMJVDP.TB_STORE_DM B
    ON    SUBSTR(A.ORIGIN_BIZPL_CD,2,4) = B.STORECD
     AND B.RGNCD IN ('56')  


  JOIN    LGMJVDP.TS_MS_BIZPL  C           /* MS_전사사업장   */
    ON    A.BIZPL_CD = C.BIZPL_CD
 JOIN    GSSCODS.TS_MS_COOR D
    ON    A.DLIV_RQUST_COOR_CD = D.TRADE_CD
 WHERE    A.OPER_DT BETWEEN REPLACE('2024-03-01','-','') AND REPLACE('2024-03-17','-','')
 GROUP BY A.OPER_DT
     ,    B.RGNNM
     ,    B.TEAM_LN
     ,    B.PART_LN
     ,    C.BIZPL_CD
     ,    C.BIZPL_NM
    ,     D.COOR_NOTE
     ,    A.DLIV_COOR_NM





SELECT    TO_CHAR(A.REGI_DTTM,'YYYYMMDD') AS 영업일자
     ,    TO_CHAR(A.DLIV_RQUST_ACQ_DTTM,'YYYY-MM-DD HH24:MI:SS') AS 배달주문요청일시
     ,    TO_CHAR(A.REGI_DTTM, 'YYYY-MM-DD HH24:MI:SS') AS 배달거절시간
     ,    F.PART_LN AS 파트명 
     ,    C.BIZPL_NM AS 점포명
     ,    D.COOR_NOTE AS 배달업체명
     ,    A.DLIV_RQUST_NO AS 배달주문번호
     ,    A.SALE_AMT AS 판매금액
          ,    CASE 
               WHEN A.DLIV_RQUST_SP_CD = 'C' THEN '취소'
               WHEN A.DLIV_RQUST_SP_CD = 'R' THEN '반품'
               WHEN A.DLIV_RQUST_SP_CD = 'D' THEN '거절'
          END
     ,    TRIM(A.DLIV_ORDPS_REQ_CNTS) AS 배달거절사유
     ,    E.GOODNM AS 상품명
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
   AND    F.RGNCD IN ('56') and F.TEAM_LN IN ('4부문)4지역)영업3팀')
   WHERE    TO_CHAR(A.REGI_DTTM,'YYYYMMDD') BETWEEN to_char(sysdate-8,'YYYYMMDD')AND to_char(sysdate-1,'YYYYMMDD')
 AND    DLIV_RQUST_SP_CD NOT IN ('A','F')




SELECT    A.OPER_DT    AS 영업일자
     ,    A.BIZPL_CD   AS 점포코드
     ,    D.COOR_NOTE AS 배달주문업체
     ,    decode(A.DLIV_COOR_NM, null, '픽업' , A.DLIV_COOR_NM) AS 주문구분    
     ,    SUM(CASE WHEN A.TENDER_AMT >= 0 THEN 1 ELSE 0 END) AS 건수
  FROM    GSSCODS.TS_TR_DLIV_RQUST    A    /* TR_배달주문     */
  JOIN    LGMJVDP.TB_STORE_DM B
    ON    SUBSTR(A.ORIGIN_BIZPL_CD,2,4) = B.STORECD
     AND A.BIZPL_CD IN ('VGP77')  
  JOIN    LGMJVDP.TS_MS_BIZPL  C           /* MS_전사사업장   */
    ON    A.BIZPL_CD = C.BIZPL_CD
 JOIN    GSSCODS.TS_MS_COOR D
    ON    A.DLIV_RQUST_COOR_CD = D.TRADE_CD
full outer join (select    BIZPL_CD,
                    to_char(REGI_DTTM,'YYYY-MM-DD') AS 점포코드, 
            CASE 
                        WHEN DLIV_RQUST_SP_CD = 'C' THEN '취소'
                        WHEN DLIV_RQUST_SP_CD = 'R' THEN '반품'
                        WHEN DLIV_RQUST_SP_CD = 'D' THEN '거절'
                    END AS 구분, 
            TRIM(DLIV_ORDPS_REQ_CNTS) AS 배달거절사유 
            from   GSSCODS.TS_TS_DLIV_RQUST 
            where BIZPL_CD in ('VDS84') and to_char(REGI_DTTM,'YYYYMMDD') in ('20240315') 
            and DLIV_RQUST_SP_CD in ('C','R','D')) GG
     on  A.BIZPL_CD = GG.BIZPL_CD
     and a.OPER_DT = GG.점포코드
 WHERE    A.OPER_DT BETWEEN REPLACE('2024-03-17','-','') AND REPLACE('2024-03-17','-','')
 GROUP BY A.OPER_DT
     ,    A.BIZPL_CD
    ,     D.COOR_NOTE
     ,    A.DLIV_COOR_NM
















select    BIZPL_CD,

          to_char(REGI_DTTM,'YYYY-MM-DD') AS 점포코드, 
CASE 
               WHEN DLIV_RQUST_SP_CD = 'C' THEN '취소'
               WHEN DLIV_RQUST_SP_CD = 'R' THEN '반품'
               WHEN DLIV_RQUST_SP_CD = 'D' THEN '거절'
          END AS 구분, 
TRIM(DLIV_ORDPS_REQ_CNTS) AS 배달거절사유 
from   GSSCODS.TS_TS_DLIV_RQUST 
where BIZPL_CD in ('VDS84') and to_char(REGI_DTTM,'YYYYMMDD') in ('20240315') 
and DLIV_RQUST_SP_CD in ('C','R','D')






SELECT    A.OPER_DT    AS 영업일자,
    B.TEAM_LN,
    B.PART_LN,
    B.STORENM
     ,    A.BIZPL_CD   AS 점포코드
     ,    decode(A.DLIV_COOR_NM, null, '픽업', A.DLIV_COOR_NM) AS 주문구분    
     ,    SUM(CASE WHEN A.TENDER_AMT >= 0 THEN 1 ELSE 0 END) AS 건수 
  FROM    GSSCODS.TS_TR_DLIV_RQUST    A    /* TR_배달주문     */
  JOIN    LGMJVDP.TB_STORE_DM B
    ON    SUBSTR(A.ORIGIN_BIZPL_CD,2,4) = B.STORECD
        and B.RGNCD in ('56')
 WHERE    A.OPER_DT BETWEEN REPLACE('2024-03-01','-','') AND REPLACE('2024-03-17','-','')
 GROUP BY A.OPER_DT, A.BIZPL_CD, B.TEAM_LN, B.PART_LN,  B.STORENM, A.DLIV_COOR_NM 

UNION ALL

select    
    to_char(A.REGI_DTTM,'YYYYMMDD') AS 영업일자,
    B.TEAM_LN,
    B.PART_LN,
    B.STORENM,
    A.BIZPL_CD as 점포코드,
    CASE 
        WHEN A.DLIV_RQUST_SP_CD = 'C' THEN '취소'
        WHEN A.DLIV_RQUST_SP_CD = 'R' THEN '반품'
        WHEN A.DLIV_RQUST_SP_CD = 'D' THEN '거절'
    END AS 주문구분, 
    SUM ( CASE WHEN A.DLIV_RQUST_SP_CD = 'C' THEN 1
        WHEN A.DLIV_RQUST_SP_CD = 'R' THEN 1
        WHEN A.DLIV_RQUST_SP_CD = 'D' THEN 1 ELSE 0 END) AS 건수
    from   GSSCODS.TS_TS_DLIV_RQUST A
    JOIN    LGMJVDP.TB_STORE_DM B
    ON    SUBSTR(A.ORIGIN_BIZPL_CD,2,4) = B.STORECD
    where to_char(REGI_DTTM,'YYYYMMDD') BETWEEN ('20240301') AND ('20240317')
    and A.DLIV_RQUST_SP_CD in ('C','R','D')
    and B.RGNCD in ('56')
    group by A.BIZPL_CD, A.REGI_DTTM, A.DLIV_RQUST_SP_CD, B.STORENM, B.PART_LN, B.TEAM_LN