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
 WHERE    A.OPER_DT BETWEEN REPLACE('20220215') AND REPLACE('20220215')
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

 WHERE    A.OPER_DT BETWEEN REPLACE('2022-02-15','-','') AND REPLACE('2022-02-15','-','')
   AND    A.SALE_SP IN ('1', '2')  --장상판매 , 고객반품
   AND    A.SKU_CANCEL_YN   =  'N'
   AND    A.GOODS_CD IN ('2800100146954', '2800100147098', '8806136631642', '8806136631871')   
  
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
-- ,
-- TENDER AS (
-- SELECT    A.OPER_DT
--      ,    A.ORIGIN_BIZPL_CD
--      ,    A.POS_NO
--      ,    A.SALE_SEQ
--      ,    CASE WHEN A.CARD_CO_CD = '01' THEN '신한카드'
--                WHEN A.CARD_CO_CD = '03' THEN '삼성카드'
--                WHEN A.CARD_CO_CD = '04' THEN '비씨카드'
--                WHEN A.CARD_CO_CD = '05' THEN '국민카드'
--                WHEN A.CARD_CO_CD = '06' THEN '현대카드'
--                WHEN A.CARD_CO_CD = '08' THEN '롯데카드'
--                WHEN A.CARD_CO_CD = '09' THEN '외환카드'
--                WHEN A.CARD_CO_CD = '10' THEN '아동-신한'
--                WHEN A.CARD_CO_CD = '11' THEN '아동-유카드'
--                WHEN A.CARD_CO_CD = '12' THEN '아동'
--                WHEN A.CARD_CO_CD = '13' THEN '아동'
--                WHEN A.CARD_CO_CD = '14' THEN '아동-서울'
--                WHEN A.CARD_CO_CD = '15' THEN '아동-푸르미'
--                WHEN A.CARD_CO_CD = '16' THEN '아동-카드넷'
--                WHEN A.CARD_CO_CD = '17' THEN '바우처서비스(주)'
--                WHEN A.CARD_CO_CD = '21' THEN '하나SK'
--                WHEN A.CARD_CO_CD = '22' THEN 'NH농협'
--                WHEN A.CARD_CO_CD = 'RP' THEN '리테일포인트결제'
--                WHEN A.CARD_CO_CD = 'Z1' THEN '교통카드'
--           ELSE
--                A.CARD_CO_CD
--           END AS CARD_CO_CD
--      ,    CARD_NO
--      ,    B.ETC_CD_NM
--      ,    SUBSTR(CARD_NO,1,6) AS PIN_NO
--      ,    SUM(A.TENDER_AMT - A.CHANGE ) AS TENDER_AMT
--   FROM    GSSCODS.TS_TR_TENDER A
--   JOIN    GSSCODS.TS_MS_ETC_CD_DETAIL B --결제수단
--     ON    B.ETC_CLASS_CD ='PM02'
--    AND    A.TENDER_CD = B.ETC_CD
--  WHERE    A.OPER_DT BETWEEN REPLACE('2022-02-15','-','') AND REPLACE('2022-02-15','-','')
   
--  GROUP BY A.OPER_DT
--      ,    A.ORIGIN_BIZPL_CD
--      ,    A.POS_NO
--      ,    A.SALE_SEQ
--      ,    CASE WHEN A.CARD_CO_CD = '01' THEN '신한카드'
--                WHEN A.CARD_CO_CD = '03' THEN '삼성카드'
--                WHEN A.CARD_CO_CD = '04' THEN '비씨카드'
--                WHEN A.CARD_CO_CD = '05' THEN '국민카드'
--                WHEN A.CARD_CO_CD = '06' THEN '현대카드'
--                WHEN A.CARD_CO_CD = '08' THEN '롯데카드'
--                WHEN A.CARD_CO_CD = '09' THEN '외환카드'
--                WHEN A.CARD_CO_CD = '10' THEN '아동-신한'
--                WHEN A.CARD_CO_CD = '11' THEN '아동-유카드'
--                WHEN A.CARD_CO_CD = '12' THEN '아동'
--                WHEN A.CARD_CO_CD = '13' THEN '아동'
--                WHEN A.CARD_CO_CD = '14' THEN '아동-서울'
--                WHEN A.CARD_CO_CD = '15' THEN '아동-푸르미'
--                WHEN A.CARD_CO_CD = '16' THEN '아동-카드넷'
--                WHEN A.CARD_CO_CD = '17' THEN '바우처서비스(주)'
--                WHEN A.CARD_CO_CD = '21' THEN '하나SK'
--                WHEN A.CARD_CO_CD = '22' THEN 'NH농협'
--                WHEN A.CARD_CO_CD = 'RP' THEN '리테일포인트결제'
--                WHEN A.CARD_CO_CD = 'Z1' THEN '교통카드'
--           ELSE
--                A.CARD_CO_CD
--           END
--      ,    CARD_NO
--      ,    SUBSTR(CARD_NO,1,6)
--      ,    B.ETC_CD_NM
-- --   AND    TENDER_CD = '01'  -- 현금
-- )
-- ,
-- --포인트 적립 정보 추출
-- GSRSAV AS (
--   SELECT    ORIGIN_BIZPL_CD
--        ,    OPER_DT
--        ,    POS_NO
--        ,    SALE_SEQ
--        ,    CARD_NO
--        ,    CUST_NO
--     FROM    GSSCODS.TS_TR_GSRSAVE  C
--    WHERE    OPER_DT BETWEEN REPLACE('2022-02-15','-','') AND REPLACE('2022-02-15','-','')
--      AND    NOR_CANCEL_SP = '0' --정상
  
-- )
-- ,MBRDC AS (
--    SELECT    A.ORIGIN_BIZPL_CD
--         ,    A.OPER_DT
--         ,    A.POS_NO
--         ,    A.SALE_SEQ
--         ,    CASE WHEN MBR_CORP_CD ='01' THEN 'LG유플러스'
--                   WHEN MBR_CORP_CD ='02' THEN 'GS리테일'
--                   WHEN MBR_CORP_CD ='03' THEN 'GS칼텍스'
--                   WHEN MBR_CORP_CD ='04' THEN '다음 POMM'
--                   WHEN MBR_CORP_CD ='05' THEN 'KT멤버십'
--                   WHEN MBR_CORP_CD ='07' THEN '금융팝카드'
--                   WHEN MBR_CORP_CD ='08' THEN '신한나라사랑'
--                   WHEN MBR_CORP_CD ='09' THEN '오포인트'
--                   WHEN MBR_CORP_CD ='10' THEN '삼성U포인트'
--                   WHEN MBR_CORP_CD ='11' THEN '이마트포인트'
--                   WHEN MBR_CORP_CD ='12' THEN '해피포인트'
--                   WHEN MBR_CORP_CD ='13' THEN '신한제휴할인카드'
--                   WHEN MBR_CORP_CD ='14' THEN '위비꿀머니'
--                   WHEN MBR_CORP_CD ='15' THEN '기아 레드멤버스'
--                   WHEN MBR_CORP_CD ='16' THEN '카카오페이(머니)'
--                   WHEN MBR_CORP_CD ='17' THEN 'BC페이북멤버십카드'
--              ELSE
--                   '기타'
--              END AS MBR_CORP_NM
--      FROM    GSSCODS.TS_TR_MBRDC A
--     WHERE    A.OPER_DT BETWEEN REPLACE('2022-02-15','-','') AND REPLACE('2022-02-15','-','')
--       AND    A.DC_AMT <> 0
        
-- )
SELECT    A.OPER_DT    AS 영업일자
     ,    A.RGN_GRPNM  AS 부문명
     ,    A.RGNNM      AS 지역명
     ,    A.TEAM_LN    AS 팀명
     ,    A.PART_LN    AS OFC명
     ,    A.ORIGIN_BIZPL_CD AS 최초점포코드
     ,    A.STORECD    AS 점포코드
     ,    A.STORENM    AS 점포명
     ,    A.POS_NO     AS 포스번호
     ,    A.SALE_SEQ   AS 판매일련번호
     ,    B.RECEIPT_NO   AS 영수증번호
     ,    B.SALE_END_DTTM  AS 구매일시
     ,    B.TIME_CD        AS 구매시간
     ,    C.CARD_CO_CD   AS 카드사명
     ,    C.CARD_NO      AS 카드번호
     ,    C.PIN_NO       AS BIN번호
     ,    C.ETC_CD_NM      AS 거래구분
     ,    D.CARD_NO        AS 고객멤버십카드번호
     ,    D.CUST_NO        AS 회원정보
     ,    E.MBR_CORP_NM    AS 멤버스제휴사명
     ,    A.GOOD_CLS1NM  AS 중분류명
     ,    A.GOOD_CLS2NM  AS 소분류명
     ,    A.GOODS_CD     AS 상품코드
     ,    A.GOODNM       AS 상품명
     ,    MAX(A.DC_PRC)      AS 매가
     ,    SUM(A.MBR_DC_AMT)  AS 멤버십할인금액
     ,    SUM(A.PRMT_DC_AMT) AS 판촉할인금액
     ,    SUM(A.SALE_QTY)    AS 판매수량
     ,    SUM(A.SALE_AMT)    AS 매출액
     ,    SUM(C.TENDER_AMT)     AS 결제금액
     ,    SUM(B.TOT_AMT)     AS 영수증합계금액
  FROM    ITEM  A
  JOIN    HEADER B
    ON    A.OPER_DT = B.OPER_DT
   AND    A.ORIGIN_BIZPL_CD   = B.ORIGIN_BIZPL_CD
   AND    A.POS_NO = B.POS_NO
   AND    A.SALE_SEQ = B.SALE_SEQ
--   JOIN    TENDER C
--     ON    A.OPER_DT = C.OPER_DT
--    AND    A.ORIGIN_BIZPL_CD   = C.ORIGIN_BIZPL_CD
--    AND    A.POS_NO = C.POS_NO
--    AND    A.SALE_SEQ = C.SALE_SEQ
--   LEFT    OUTER JOIN GSRSAV D
--     ON    A.ORIGIN_BIZPL_CD   = D.ORIGIN_BIZPL_CD
--    AND    A.OPER_DT = D.OPER_DT
--    AND    A.POS_NO = D.POS_NO
--    AND    A.SALE_SEQ = D.SALE_SEQ
--   LEFT    OUTER JOIN MBRDC E
--     ON    A.ORIGIN_BIZPL_CD   = E.ORIGIN_BIZPL_CD
--    AND    A.OPER_DT = E.OPER_DT
--    AND    A.POS_NO = E.POS_NO
--    AND    A.SALE_SEQ = E.SALE_SEQ
 GROUP BY A.OPER_DT
     ,    A.RGN_GRPNM
     ,    A.RGNNM
     ,    A.TEAM_LN
     ,    A.PART_LN
     ,    A.ORIGIN_BIZPL_CD
     ,    A.STORECD
     ,    A.STORENM
     ,    A.POS_NO
     ,    A.SALE_SEQ
     ,    B.RECEIPT_NO
     -- ,    C.CARD_CO_CD
     -- ,    C.CARD_NO
     -- ,    C.PIN_NO
     -- ,    A.GOOD_CLS1NM
     -- ,    A.GOOD_CLS2NM
     -- ,    A.GOODS_CD
     -- ,    A.GOODNM
     -- ,    B.SALE_END_DTTM
     -- ,    B.TIME_CD
     -- ,    C.ETC_CD_NM
     -- ,    D.CARD_NO
     -- ,    D.CUST_NO
     -- ,    E.MBR_CORP_NM