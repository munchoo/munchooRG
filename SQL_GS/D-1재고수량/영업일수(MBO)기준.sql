                SELECT 
                    distinct B.STORECD AS STORECD,
                    max(SUBSTR(B.STORENM,1,INSTR(B.STORENM,'(')-1 ))  STORENM,
                    max('V'||SUBSTR(B.STORENM,INSTR(B.STORENM,'(')+1, -( INSTR(B.STORENM,'(') -INSTR(B.STORENM,':'))-1))  CUR_CD,
                    B.OPENDT AS OPENDT,
                    CASE WHEN REGEXP_REPLACE(Z.LAST_OPEN_DT, '(.{4})(.{2})(.{2})', '\1\2\3') > Y.M2_MON||'10' THEN 
                        CASE WHEN REGEXP_REPLACE(Z.LAST_OPEN_DT, '(.{4})(.{2})(.{2})', '\1\2\3') = TO_CHAR(B.OPENDT,'YYYYMMDD') THEN '신규점제외'
                            WHEN SUBSTR(Z.LAST_OPEN_DT,1,6) >= Y.LAST_MON AND SUBSTR(Z.LAST_OPEN_DT,1,6) < CUR_MON + 1 THEN '양수도제외'
                        END
                    END 제외점,
                    REGEXP_REPLACE(Z.LAST_OPEN_DT, '(.{4})(.{2})(.{2})', '\1-\2-\3') 현경영주개점일,
                    B.TEAMCD  AS TEAMCD,
                    B.TEAM_LN AS TEAM_LN,
                    B.PART_SH AS PART_SH,
                    B.PART_LN AS PART_LN,
                    B.RGNCD AS RGNCD,
                    B.RGNNM AS RGNNM,
                    SUM(A.SALDT_CNT)   AS SALDT_CNT
            FROM LGMJVDP.TB_CVS_MAIN_TAB01 A,
                LGMJVDP.TB_STORE_DM       B,
                    (SELECT A.ORIGIN_BIZPL_CD, MAX(OPEN_DT) AS LAST_OPEN_DT
                    FROM LGMJVDP.TS_MS_BIZPL A
                    GROUP BY A.ORIGIN_BIZPL_CD
                    ) Z
                    ,
                    (
                    /*수정 김미정대리님 200113  Y절에서는 CUR_MON 현재 월과 LAST_MON 전월을 YYYYMM 형식으로 가져옴*/
                        SELECT YMCD AS CUR_MON
                            , to_char(add_months(datecd, - 1),'YYYYMM') AS LAST_MON          
                            , to_char(add_months(datecd, - 2),'YYYYMM') AS M2_MON
                            FROM LGMJVDP.TB_DATE_DM
                            WHERE DATECD = (SELECT MAX(DATECD) FROM LGMJVDP.TB_DATE_DM
                                --WHERE DATECD BETWEEN '2022-01-01' AND '2022-01-05'         /*화면 조회 일자와 동일하게 */ 
                                --where DATECD    BETWEEN trunc (sysdate, 'mm') AND SYSDATE 
                            )       
                    ) Y
                WHERE B.TEAMCD    is not null
                    AND A.STORECD = B.STORECD
                    --  AND B.STORECD in ('H538')
                    AND A.DATECD    BETWEEN trunc (sysdate, 'mm') AND SYSDATE   /* 하위 select절에서 조건으로 사이값 시스템월첫날 부터 시스템날짜까지*/
                    --AND A.DATECD BETWEEN '2022-01-01' AND '2022-01-01'  /* 화면 조회 일자와 동일하게 추출 */
                    AND A.NTSAL_GBCD IN ('01')
                    AND Z.ORIGIN_BIZPL_CD = 'V'||B.STORECD          
                    
                    AND ((A.PLNSAL_AMT <> 0 AND A.PLNSAL_AMT IS NOT NULL) OR (A.NTSAL_AMT <> 0 AND A.NTSAL_AMT IS NOT NULL))          
                    AND ( TO_CHAR(B.CLOSEDT,'YYYYMM') <> Y.CUR_MON OR B.CLOSEDT IS NULL )
            GROUP BY 
                B.STORECD,
                REGEXP_REPLACE(Z.LAST_OPEN_DT, '(.{4})(.{2})(.{2})', '\1-\2-\3'),
                B.OPENDT,
                    CASE WHEN REGEXP_REPLACE(Z.LAST_OPEN_DT, '(.{4})(.{2})(.{2})', '\1\2\3') > Y.M2_MON||'10' THEN 
                        CASE WHEN REGEXP_REPLACE(Z.LAST_OPEN_DT, '(.{4})(.{2})(.{2})', '\1\2\3') = TO_CHAR(B.OPENDT,'YYYYMMDD') THEN '신규점제외'
                            WHEN SUBSTR(Z.LAST_OPEN_DT,1,6) >= Y.LAST_MON AND SUBSTR(Z.LAST_OPEN_DT,1,6) < CUR_MON + 1 THEN '양수도제외'
                        END
                    END,
               B.TEAMCD,
                B.TEAM_LN,
                B.PART_SH,
                B.PART_LN,
                B.RGNCD,
                B.RGNNM