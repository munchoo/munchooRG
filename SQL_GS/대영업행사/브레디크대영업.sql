SELECT  
          Z.STORECD
        , SUBSTR(Z.STORENM,1,INSTR(Z.STORENM,'(')-1) STORENM
        , Z.RGNCD
        , Z.RGNNM      
        , Z.TEAMCD
        , Z.TEAM_LN
        , Z.PART_SH
        , Z.PART_LN
        , CASE WHEN Z.ExStore > 0 Then '제외' else null end 제외점
        , sum(Z.NTSAL_AMT) 매출액
        , sum(Z.SALDT_CNT) 영업일수
        , sum(Z.PLNDT_CNT) 계획영업일수
        , sum(CASE WHEN Z.PLNDT_CNT = 0 THEN 0
                ELSE Z.PLNSAL_AMT * 1.0000
        END) 매출목표 
        , sum(H.빵매출) AS 빵매출
FROM (
            SELECT 
                B.STORECD AS STORECD,
                B.STORENM AS STORENM,
                C.TEAMCD           AS TEAMCD,
                C.TEAM_LN          AS TEAM_LN,
                B.PART_SH AS PART_SH,
                B.PART_LN AS PART_LN,
                B.RGNCD AS RGNCD,
                B.RGNNM AS RGNNM,          
                A.NTSAL_GBCD,        
                sum(CASE when SUBSTR(Z.LAST_OPEN_DT,1,6) <> Y.CUR_MON AND SUBSTR(Z.LAST_OPEN_DT,1,6) <> Y.LAST_MON AND TO_CHAR(B.OPENDT,'YYYYMM') <> Y.CUR_MON AND TO_CHAR(B.OPENDT,'YYYYMM') <> Y.LAST_MON OR ( TO_CHAR(B.OPENDT,'YYYYMMDD') BETWEEN Y.LAST_MON||'01' AND Y.LAST_MON||'10' ) AND ( TO_CHAR(B.CLOSEDT,'YYYYMM') <> Y.CUR_MON OR B.CLOSEDT IS NULL ) then 0 else 1 end) ExStore,
    /*변경 쿼리 =================================*/
                SUM(A.NTSAL_AMT) AS NTSAL_AMT,
                SUM(A.SALDT_CNT)   AS SALDT_CNT,
                SUM(A.PLNSAL_AMT)   AS PLNSAL_AMT,
                SUM(A.PLNDT_CNT)   AS PLNDT_CNT,
    /*변경 쿼리 =================================*/
                C.TEAM_DIST_SEQ  AS TEAM_SEQ
        FROM LGMJVDP.TB_CVS_MAIN_TAB01 A,
            LGMJVDP.TB_STORE_DM       B,
            LGMJVDP.TB_TEAM_DM        C,
                (SELECT A.ORIGIN_BIZPL_CD, MAX(OPEN_DT) AS LAST_OPEN_DT
                --현재오픈일
                FROM LGMJVDP.TS_MS_BIZPL A
                GROUP BY A.ORIGIN_BIZPL_CD
                ) Z
                ,
                (
                /*수정 김미정대리님 200113  Y절에서는 CUR_MON 현재 월과 LAST_MON 전월을 YYYYMM 형식으로 가져옴*/
                    SELECT YMCD AS CUR_MON
                        , to_char(add_months(datecd, - 1),'YYYYMM') AS LAST_MON          
                        FROM LGMJVDP.TB_DATE_DM
                        WHERE DATECD = (
                            SELECT MAX(DATECD)
                            FROM LGMJVDP.TB_DATE_DM
                            --WHERE DATECD BETWEEN '2022-01-01' AND '2022-01-05'         /*화면 조회 일자와 동일하게 */ 
                            --where DATECD    BETWEEN trunc (sysdate, 'mm') AND SYSDATE 
                        )       
                ) Y
            WHERE B.TEAMCD    is not null
                AND A.STORECD = B.STORECD
                AND B.TEAMCD    =    C.TEAMCD
                AND A.DATECD BETWEEN '2022-01-01' AND '2022-02-28'  /* 화면 조회 일자와 동일하게 추출 */
                AND A.NTSAL_GBCD IN ('11')
                AND Z.ORIGIN_BIZPL_CD = 'V'||B.STORECD          
                AND ((A.PLNSAL_AMT <> 0 AND A.PLNSAL_AMT IS NOT NULL) OR (A.NTSAL_AMT <> 0 AND A.NTSAL_AMT IS NOT NULL))          
                -- 1차요청) MBO실적제외 대상점이 되는 D월 및 D-1월 양수도/신규오픈점포와 D월 폐점점포의 표시제외 - 20190805 최정훈
                -- 2차요청) (최초오픈일 = 현재오픈일인 신규점의 D월 당월누계(MBO) 확인시, D-1월 1일~10일 최초오픈점 리스트 미제외)
             --   AND ( ( SUBSTR(Z.LAST_OPEN_DT,1,6) <> Y.CUR_MON AND SUBSTR(Z.LAST_OPEN_DT,1,6) <> Y.LAST_MON AND TO_CHAR(B.OPENDT,'YYYYMM') <> Y.CUR_MON AND TO_CHAR(B.OPENDT,'YYYYMM') <> Y.LAST_MON  ) OR
                 --       ( TO_CHAR(B.OPENDT,'YYYYMMDD') BETWEEN Y.LAST_MON||'01' AND Y.LAST_MON||'10' ) )
               -- AND ( TO_CHAR(B.CLOSEDT,'YYYYMM') <> Y.CUR_MON OR B.CLOSEDT IS NULL )
                -- AND ( (A.NTSAL_GBCD IN  ('01', '02', '05', '08', '09', '11', '12', '13', '14') AND A.PLNSAL_AMT >0 )) 
        GROUP BY 
            B.STORECD,
            B.STORENM,
            C.TEAMCD,
            C.TEAM_LN,
            B.PART_SH,
            B.PART_LN,
            B.RGNCD,
            B.RGNNM,
            A.NTSAL_GBCD,
            C.TEAM_DIST_SEQ
    ) Z
    left outer join
        (
        select	a11.STORECD  STORECD,
	    sum(a11.NTSAL_AMT)  빵매출
        from	LGMJVDP.TB_STK_DSG2_AG	a11
	        join	LGMJVDP.TB_GOOD_CLS2_DM	a12
	        on 	(a11.GOOD_CLS2CD = a12.GOOD_CLS2CD)
	        join	LGMJVDP.TB_STORE_DM	a13
	        on 	(a11.STORECD = a13.STORECD)
        where	(a12.GOOD_CLS1CD in ('09')
        and a11.DATECD BETWEEN ('2022-01-01') and ('2022-02-28')
        and a13.RGNCD in ('54'))
        group by a11.STORECD) H on Z.STORECD = H.STORECD

    where Z.RGNCD in ('54')
    and Z.PLNSAL_AMT > 0
    group by  Z.STORECD
        , Z.STORENM
        , Z.RGNCD
        , Z.RGNNM      
        , Z.TEAMCD
        , Z.TEAM_LN
        , Z.PART_SH
        , Z.PART_LN
        , CASE WHEN Z.ExStore > 0 Then '제외' else null end
