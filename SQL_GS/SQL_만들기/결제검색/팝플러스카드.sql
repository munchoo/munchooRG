  SELECT SUBSTR(T1.OPER_DT, 1, 6) AS "년월"		
        , S.TEAM_LN
       , T1.TENDER_CD as 결제수단코드 			
       , CASE  WHEN T1.TENDER_CD = '01' THEN '현금'
               WHEN T1.TENDER_CD = '02' THEN '복권교환'
               WHEN T1.TENDER_CD = '03' THEN '타사상품권'
               WHEN T1.TENDER_CD = '04' THEN '자사상품권'
               WHEN T1.TENDER_CD = '05' THEN '할인쿠폰'
               WHEN T1.TENDER_CD = '06' THEN '신용카드'
               WHEN T1.TENDER_CD = '07' THEN '선불카드'
               WHEN T1.TENDER_CD = '08' THEN '직원카드'
               WHEN T1.TENDER_CD = '09' THEN '사은권'
               WHEN T1.TENDER_CD = '10' THEN '교통카드'
               WHEN T1.TENDER_CD = '11' THEN 'GS상품권(카드)'
               WHEN T1.TENDER_CD = '12' THEN '칼텍스포인트'
               WHEN T1.TENDER_CD = '13' THEN '체크카드'
               WHEN T1.TENDER_CD = '14' THEN '모바일증정'
               WHEN T1.TENDER_CD = '15' THEN '리테일포인트'
               WHEN T1.TENDER_CD = '16' THEN '기프티콘결제'
               WHEN T1.TENDER_CD = '17' THEN '신용카드수탁'
               WHEN T1.TENDER_CD = '18' THEN '사원카드'
               WHEN T1.TENDER_CD = '19' THEN '2D요금계좌이체'
               WHEN T1.TENDER_CD = '20' THEN '2D요금신용카드'
               WHEN T1.TENDER_CD = '21' THEN '아동급식카드'
               WHEN T1.TENDER_CD = '22' THEN 'CMS쿠폰'
               WHEN T1.TENDER_CD = '23' THEN 'KB오굿할인'
               WHEN T1.TENDER_CD = '24' THEN 'KT할인'
               WHEN T1.TENDER_CD = '25' THEN '휴대폰결제'
               WHEN T1.TENDER_CD = '26' THEN '마일리지(티머니)'
               WHEN T1.TENDER_CD = '27' THEN '카드현장할인'
               WHEN T1.TENDER_CD = '28' THEN '신한나라사랑할인'
               WHEN T1.TENDER_CD = '29' THEN '티코인결제'
               WHEN T1.TENDER_CD = '30' THEN '모바일상품권결제'
               WHEN T1.TENDER_CD = '31' THEN '결제수단할인'
               WHEN T1.TENDER_CD = '32' THEN '자판기기타'
               WHEN T1.TENDER_CD = '33' THEN '현대M포인트결재'
               WHEN T1.TENDER_CD = '34' THEN '금융팝카드'
               WHEN T1.TENDER_CD = '36' THEN '한코인결제'
               WHEN T1.TENDER_CD = '37' THEN '에코머니결제'
               WHEN T1.TENDER_CD = '38' THEN '팝기프트카드결제'
               WHEN T1.TENDER_CD = '39' THEN '팝캐시넛결제'
               WHEN T1.TENDER_CD = '40' THEN 'U포인트결제'
               WHEN T1.TENDER_CD = '41' THEN '이마트포인트결제'
               WHEN T1.TENDER_CD = '42' THEN '알리페이결제'
               WHEN T1.TENDER_CD = '43' THEN '팝충전권결제'
               WHEN T1.TENDER_CD = '44' THEN 'LGU+제휴충전결제'
               WHEN T1.TENDER_CD = '45' THEN 'GS쿠폰결제'
               WHEN T1.TENDER_CD = '46' THEN '내국세환급'
               WHEN T1.TENDER_CD = '47' THEN '예약수취결제'
               WHEN T1.TENDER_CD = '48' THEN 'POSA신규결제수단교환권결제'
               WHEN T1.TENDER_CD = '50' THEN 'LGU+소액결제'
               WHEN T1.TENDER_CD = '51' THEN '우리꿀머니포인트결제'
               WHEN T1.TENDER_CD = '52' THEN '카카오머니결제'
               WHEN T1.TENDER_CD = '53' THEN '제로페이'
               WHEN T1.TENDER_CD = '54' THEN '페이코포인트결제'
               WHEN T1.TENDER_CD = '55' THEN '페이코쿠폰결제'
               WHEN T1.TENDER_CD = '56' THEN '배달서비스'
               WHEN T1.TENDER_CD = '59' THEN '카카오카드할인'
               WHEN T1.TENDER_CD = 'AA' THEN 'POP제휴신용체크카드결제'
      WHEN T1.TENDER_CD = 'BB' THEN'팝앱카드팝판촉및멤버십자동적립'
   WHEN T1.TENDER_CD = 'CC' THEN'BCQR카드팝판촉'
   WHEN T1.TENDER_CD = 'DD' THEN'BCQR카드팝판촉'
   WHEN T1.TENDER_CD = 'LD' THEN'세탁서비스망취소'
               ELSE '기타'			
         END   AS 결제수단명,			
       SUM(CASE WHEN T1.NOR_CANCEL_SP = '0' THEN 1			
                WHEN T1.NOR_CANCEL_SP = '9' THEN 0			
           END)  AS 정상건수,			
       SUM(CASE WHEN T1.NOR_CANCEL_SP = '0' THEN 0			
                WHEN T1.NOR_CANCEL_SP = '9' THEN -1			
           END)  AS 취소건수,			
       SUM(CASE WHEN T1.NOR_CANCEL_SP = '0' THEN 1			
                WHEN T1.NOR_CANCEL_SP = '9' THEN -1			
           END)  AS 전체건수,			
       SUM(CASE WHEN T1.NOR_CANCEL_SP = '0' THEN T1.TENDER_AMT - T1.CHANGE			
                WHEN T1.NOR_CANCEL_SP = '9' THEN 0			
           END)  AS 정상금액,			
       SUM(CASE WHEN T1.NOR_CANCEL_SP = '0' THEN 0			
                WHEN T1.NOR_CANCEL_SP = '9' THEN T1.TENDER_AMT - T1.CHANGE			
           END)  AS 취소금액,			
       SUM(T1.TENDER_AMT - T1.CHANGE) AS 전체금액			
    FROM gsscods.TS_TR_TENDER T1	
inner join LGMJVDP.TB_STORE_DM S
ON SUBSTR(T1.ORIGIN_BIZPL_CD,2,4) = S.STORECD		
   WHERE T1.OPER_DT BETWEEN REPLACE('2021-07-01','-','')  AND REPLACE('2021-07-31','-','')

AND S.RGNCD IN ('30')

""" RGNCD 30은 6부문 """

GROUP BY SUBSTR(T1.OPER_DT, 1, 6)	
            ,S.TEAM_LN
           ,T1.TENDER_CD 			
   ORDER BY SUBSTR(T1.OPER_DT, 1, 6)			
            ,S.TEAM_LN
           ,T1.TENDER_CD			
   WITH UR			
;			
