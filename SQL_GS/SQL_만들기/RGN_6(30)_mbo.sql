SELECT B.STORECD AS STORECD,
          B.STORENM AS STORENM,
          C.TEAMCD  AS TEAMCD,
          C.TEAM_LN  AS TEAM_LN,
          B.PART_SH AS PART_SH,
          B.PART_LN AS PART_LN, 
          B.RGNCD AS RGNCD,
          B.RGNNM AS RGNNM,  
          M.Week,
          A.NTSAL_GBCD, 
          CASE  WHEN ((sum(A.PLNSAL_AMT) <> 0 AND sum(A.PLNSAL_AMT) IS NOT NULL) OR (sum(A.NTSAL_AMT) <> 0 AND sum(A.NTSAL_AMT) IS NOT NULL)) THEN 0
                else 1
                END AS mc,        
          CASE  WHEN A.NTSAL_GBCD = '01' THEN '상품매출'
                WHEN A.NTSAL_GBCD = '02' THEN 'F/F'
                WHEN A.NTSAL_GBCD = '03' THEN '햄버거/샌드위치'
                WHEN A.NTSAL_GBCD = '04' THEN '조리빵'
                WHEN A.NTSAL_GBCD = '05' THEN '농축수산'
                WHEN A.NTSAL_GBCD = '06' THEN '전체'  
                WHEN A.NTSAL_GBCD = '08' THEN '카페25'  
                WHEN A.NTSAL_GBCD = '09' THEN '치킨25' 
                WHEN A.NTSAL_GBCD = '10' THEN '간편식' 
                WHEN A.NTSAL_GBCD = '11' THEN '빵'   
                WHEN A.NTSAL_GBCD = '12' THEN 'HMR'   
               END AS NTSAL_GBNM,
               SUM(A.NTSAL_AMT)   AS NTSAL_AMT,
               SUM(A.SALDT_CNT)   AS SALDT_CNT,
               SUM(A.PLNSAL_AMT)   AS PLNSAL_AMT,
               SUM(A.PLNDT_CNT)   AS PLNDT_CNT,
               SUM(A.CUST_CNT)   AS CUST_CNT

     FROM LGMJVDP.TB_CVS_MAIN_TAB01 A,
          LGMJVDP.TB_STORE_DM       B,
          LGMJVDP.TB_TEAM_DM          C,
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
      AND A.DATECD = M.DATECD 
       AND A.DATECD BETWEEN trunc (sysdate, 'mm') AND SYSDATE
       AND A.NTSAL_GBCD IN ('01', '02', '03','04','05','06','08','09','10','11','12')
       AND Z.ORIGIN_BIZPL_CD = 'V'||B.STORECD          
       -- AND ((A.PLNSAL_AMT <> 0 AND A.PLNSAL_AMT IS NOT NULL) OR (A.NTSAL_AMT <> 0 AND A.NTSAL_AMT IS NOT NULL))          
       -- 1차요청) MBO실적제외 대상점이 되는 D월 및 D-1월 양수도/신규오픈점포와 D월 폐점점포의 표시제외 - 20190805 최정훈
       -- 2차요청) (최초오픈일 = 현재오픈일인 신규점의 D월 당월누계(MBO) 확인시, D-1월 1일~10일 최초오픈점 리스트 미제외)
       AND ( ( SUBSTR(Z.LAST_OPEN_DT,1,6) <> Y.CUR_MON AND SUBSTR(Z.LAST_OPEN_DT,1,6) <> Y.LAST_MON AND TO_CHAR(B.OPENDT,'YYYYMM') <> Y.CUR_MON AND TO_CHAR(B.OPENDT,'YYYYMM') <> Y.LAST_MON  ) OR
             ( TO_CHAR(B.OPENDT,'YYYYMMDD') BETWEEN Y.LAST_MON||'01' AND Y.LAST_MON||'10' ) )
       AND ( TO_CHAR(B.CLOSEDT,'YYYYMM') <> Y.CUR_MON OR B.CLOSEDT IS NULL )
       AND ( (A.NTSAL_GBCD IN  ('01', '02', '03','04','05','06','08','09','10','11','12') AND A.PLNSAL_AMT >0 ) OR (A.NTSAL_GBCD IN ('06')) )
       AND B.RGNCD IN ('30')
     GROUP BY B.STORECD,
                  B.STORENM, 
                  C.TEAMCD, 
                  C.TEAM_LN,
                  B.PART_SH,  
                  B.PART_LN, 
                  M.Week,
                  B.RGNCD,
                  B.RGNNM,           
                  A.NTSAL_GBCD 
    order By  B.STORECD,
                  C.TEAMCD, 
                  B.PART_SH,  
                  M.Week,
                  A.NTSAL_GBCD




SELECT B.STORECD AS STORECD,
          B.STORENM AS STORENM,
          C.TEAMCD  AS TEAMCD,
          C.TEAM_LN  AS TEAM_LN,
          B.PART_SH AS PART_SH,
          B.PART_LN AS PART_LN, 
          B.RGNCD AS RGNCD,
          B.RGNNM AS RGNNM,  
          M.Week,
          A.NTSAL_GBCD, 
          CASE  WHEN ((sum(A.PLNSAL_AMT) <> 0 AND sum(A.PLNSAL_AMT) ISn NOT NULL) OR (sum(A.NTSAL_AMT) <> 0 AND sum(A.NTSAL_AMT) IS NOT NULL)) THEN 0
                else 1
                END AS CLOSE_STORE,       
          CASE  WHEN A.NTSAL_GBCD = '01' THEN '상품매출'
                WHEN A.NTSAL_GBCD = '02' THEN 'F/F'
                WHEN A.NTSAL_GBCD = '03' THEN '햄버거/샌드위치'
                WHEN A.NTSAL_GBCD = '04' THEN '조리빵'
                WHEN A.NTSAL_GBCD = '05' THEN '농축수산'
                WHEN A.NTSAL_GBCD = '06' THEN '전체'  
                WHEN A.NTSAL_GBCD = '08' THEN '카페25'  
                WHEN A.NTSAL_GBCD = '09' THEN '치킨25' 
                WHEN A.NTSAL_GBCD = '10' THEN '간편식' 
                WHEN A.NTSAL_GBCD = '11' THEN '빵'   
                WHEN A.NTSAL_GBCD = '12' THEN 'HMR'   
               END AS NTSAL_GBNM,
               SUM(A.NTSAL_AMT)   AS NTSAL_AMT,
               SUM(A.SALDT_CNT)   AS SALDT_CNT,
               SUM(A.PLNSAL_AMT)   AS PLNSAL_AMT,
               SUM(A.PLNDT_CNT)   AS PLNDT_CNT,
               SUM(A.CUST_CNT)   AS CUST_CNT

     FROM LGMJVDP.TB_CVS_MAIN_TAB01 A,
          LGMJVDP.TB_STORE_DM       B,
          LGMJVDP.TB_TEAM_DM          C,
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
      AND A.DATECD = M.DATECD 
       AND A.DATECD BETWEEN trunc (sysdate, 'mm') AND SYSDATE
       AND A.NTSAL_GBCD IN ('01', '02', '03','04','05','06','08','09','10','11','12')
       AND Z.ORIGIN_BIZPL_CD = 'V'||B.STORECD          
       -- AND ((A.PLNSAL_AMT <> 0 AND A.PLNSAL_AMT IS NOT NULL) OR (A.NTSAL_AMT <> 0 AND A.NTSAL_AMT IS NOT NULL))          
       -- 1차요청) MBO실적제외 대상점이 되는 D월 및 D-1월 양수도/신규오픈점포와 D월 폐점점포의 표시제외 - 20190805 최정훈
       -- 2차요청) (최초오픈일 = 현재오픈일인 신규점의 D월 당월누계(MBO) 확인시, D-1월 1일~10일 최초오픈점 리스트 미제외)
       AND ( ( SUBSTR(Z.LAST_OPEN_DT,1,6) <> Y.CUR_MON AND SUBSTR(Z.LAST_OPEN_DT,1,6) <> Y.LAST_MON AND TO_CHAR(B.OPENDT,'YYYYMM') <> Y.CUR_MON AND TO_CHAR(B.OPENDT,'YYYYMM') <> Y.LAST_MON  ) OR
             ( TO_CHAR(B.OPENDT,'YYYYMMDD') BETWEEN Y.LAST_MON||'01' AND Y.LAST_MON||'10' ) )
       AND ( TO_CHAR(B.CLOSEDT,'YYYYMM') <> Y.CUR_MON OR B.CLOSEDT IS NULL )
       AND ( (A.NTSAL_GBCD IN  ('01', '02', '03','04','05','06','08','09','10','11','12') AND A.PLNSAL_AMT >0 ) OR (A.NTSAL_GBCD IN ('06')) )
       AND B.RGNCD IN ('30') 
       AND C.TEAMCD <> '3015' 
     GROUP BY B.STORECD,
                  B.STORENM, 
                  C.TEAMCD, 
                  C.TEAM_LN,
                  B.PART_SH,  
                  B.PART_LN, 
                  M.Week,
                  B.RGNCD,
                  B.RGNNM,           
                  A.NTSAL_GBCD 
    order By MC DESC, 
  B.STORECD,
                  C.TEAMCD, 
                  B.PART_SH,  
                  M.Week,
                  A.NTSAL_GBCD





