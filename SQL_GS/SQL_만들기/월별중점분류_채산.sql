select 'V'||B.STORECD AS STORECD,
          SUBSTR(B.STORENM,1,INSTR(B.STORENM,'(')-1 ),
          C.TEAMCD  AS TEAMCD,
          C.TEAM_LN  AS TEAM_LN,
          B.PART_SH AS PART_SH,
          B.PART_LN AS PART_LN, 
          B.RGNCD AS RGNCD,
          B.RGNNM AS RGNNM,  
          M.Week||'주', 
          A.GOOD_CLS1CD AS 중분류 , 
          D.GOOD_CLS1NM AS 중분류명,
         sum(A.NTSAL_AMT) AS 매출액,
         sum(E.SALDT_CNT) AS 영업일수
     FROM LGMJVDP.TB_STK_DSG1_AG A,
          LGMJVDP.TB_STORE_DM B,
          LGMJVDP.TB_TEAM_DM C,
          LGMJVDP.TB_GOOD_CLS1_DM D,
          LGMJVDP.TB_SALDT_FT E,
          (SELECT A.ORIGIN_BIZPL_CD, MAX(OPEN_DT) AS LAST_OPEN_DT
          --현재오픈일
          FROM LGMJVDP.TS_MS_BIZPL A
          GROUP BY A.ORIGIN_BIZPL_CD
        ) Z
        ,
        (
          /*수정 김미정대리님 200113  Y절에서는 CUR_MON 현재 월과 LAST_MON 전월을 YYYYMM 형식으로 가져옴*/
          SELECT    YMCD AS CUR_MON
          ,to_char(add_months(datecd, - 1),'YYYYMM') AS LAST_MON          
          FROM LGMJVDP.TB_DATE_DM
          WHERE DATECD = (
            SELECT MAX(DATECD)
            FROM LGMJVDP.TB_DATE_DM
            --WHERE DATECD BETWEEN '2021-02-01' AND '2021-02-28'         /*화면 조회 일자와 동일하게 */ 
            where DATECD    BETWEEN trunc (sysdate, 'mm') AND SYSDATE )
        ) Y,

         (
          SELECT DATECD, to_char(DATECD, 'IW') AS Week 
          FROM LGMJVDP.TB_DATE_DM 
          WHERE  DATECD BETWEEN trunc (sysdate, 'mm') AND SYSDATE
        ) M   
      WHERE B.TEAMCD    is not null
       AND A.STORECD  = B.STORECD
       AND B.TEAMCD = C.TEAMCD   
       AND A.GOOD_CLS1CD = D.GOOD_CLS1CD
      AND A.DATECD = M.DATECD 
      AND E.DATECD = M.DATECD
      AND E.STORECD = B.STORECD
       AND A.DATECD BETWEEN trunc (sysdate, 'mm') AND SYSDATE
       AND A.GOOD_CLS1CD in ('43', '13', '46', '58')
       AND Z.ORIGIN_BIZPL_CD = 'V'||B.STORECD          
       AND ( ( SUBSTR(Z.LAST_OPEN_DT,1,6) <> Y.CUR_MON AND SUBSTR(Z.LAST_OPEN_DT,1,6) <> Y.LAST_MON AND TO_CHAR(B.OPENDT,'YYYYMM') <> Y.CUR_MON AND TO_CHAR(B.OPENDT,'YYYYMM') <> Y.LAST_MON  ) OR
             ( TO_CHAR(B.OPENDT,'YYYYMMDD') BETWEEN Y.LAST_MON||'01' AND Y.LAST_MON||'10' ) )
       AND ( TO_CHAR(B.CLOSEDT,'YYYYMM') <> Y.CUR_MON OR B.CLOSEDT IS NULL )
       AND B.
       \      
 
    GROUP BY B.STORECD,
         B.STORENM,
          C.TEAMCD,
          C.TEAM_LN,
          B.PART_SH,
          B.PART_LN, 
          B.RGNCD,  
          B.RGNNM,  
          M.Week, 
         A.GOOD_CLS1CD,
         D.GOOD_CLS1NM  
 
    order by  B.STORECD,
         B.STORENM,
          C.TEAMCD,
          C.TEAM_LN,
          B.PART_SH,
          B.PART_LN, 
          B.RGNCD,  
          B.RGNNM,  
          M.Week, 
         A.GOOD_CLS1CD,
         D.GOOD_CLS1NM