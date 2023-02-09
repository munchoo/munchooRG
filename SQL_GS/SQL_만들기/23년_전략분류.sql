
SELECT    RGNCD  AS  RGNCD
     ,    RGNNM  AS  RGNNM
     ,    5 STRATEGY_DIV
     ,    AVG(STRATEGY_CNT) AS STRATEGY_CNT
     ,    AVG(STRATEGY_PTN) AS STRATEGY_PTN
     ,    DW_RGNCD
  FROM    (     
             SELECT    RGN_GRPCD
                  ,    RGN_GRPNM
                  ,    RGNCD
                  ,    RGNNM
                  ,    TEAMCD
                  ,    TEAM_LN
                  ,    PARTCD
                  ,    PART_LN
                  ,    STORECD
                  ,    STORENM
                  ,    CAST(CASE WHEN GOAL_02 > 100 THEN 1 ELSE 0 END +
                       CASE WHEN GOAL_05 > 100 THEN 1 ELSE 0 END +
                       CASE WHEN GOAL_11 > 100 THEN 1 ELSE 0 END +
                       CASE WHEN GOAL_12 > 100 THEN 1 ELSE 0 END +
                       CASE WHEN GOAL_13 > 100 THEN 1 ELSE 0 END AS FLOAT) AS STRATEGY_CNT
                  ,    CASE WHEN CASE WHEN GOAL_02 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_05 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_11 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_12 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_13 > 100 THEN 1 ELSE 0 END = 5 THEN 5.5
                            WHEN CASE WHEN GOAL_02 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_05 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_11 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_12 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_13 > 100 THEN 1 ELSE 0 END = 4 THEN 5.0
                            WHEN CASE WHEN GOAL_02 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_05 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_11 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_12 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_13 > 100 THEN 1 ELSE 0 END = 3 THEN 4.0
                            WHEN CASE WHEN GOAL_02 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_05 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_11 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_12 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_13 > 100 THEN 1 ELSE 0 END = 2 THEN 3.0
                            WHEN CASE WHEN GOAL_02 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_05 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_11 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_12 > 100 THEN 1 ELSE 0 END +
                                 CASE WHEN GOAL_13 > 100 THEN 1 ELSE 0 END = 1 THEN 2.0
                       ELSE
                            1.0
                       END +
                       CASE WHEN GOAL_02 > 120 THEN 0.2 ELSE CASE WHEN GOAL_02 > 110 THEN 0.1 ELSE 0 END END +
                       CASE WHEN GOAL_05 > 120 THEN 0.2 ELSE CASE WHEN GOAL_05 > 110 THEN 0.1 ELSE 0 END END +
                       CASE WHEN GOAL_11 > 120 THEN 0.2 ELSE CASE WHEN GOAL_11 > 110 THEN 0.1 ELSE 0 END END +
                       CASE WHEN GOAL_12 > 120 THEN 0.2 ELSE CASE WHEN GOAL_12 > 110 THEN 0.1 ELSE 0 END END +
                       CASE WHEN GOAL_13 > 120 THEN 0.2 ELSE CASE WHEN GOAL_13 > 110 THEN 0.1 ELSE 0 END END AS STRATEGY_PTN
                  ,    DW_RGNCD
                  ,    GOAL_02 AS GOAL_02  --Fresh Food
                  ,    GOAL_05 AS GOAL_05  --�ż�
                  ,    GOAL_11 AS GOAL_11  --����
                  ,    GOAL_12 AS GOAL_12  --������(����/�õ�)
                  ,    GOAL_13 AS GOAL_13  --�ַ�        
               FROM    (     
                          SELECT    RGN_GRPCD
                               ,    RGN_GRPNM
                               ,    RGNCD
                               ,    RGNNM
                               ,    TEAMCD
                               ,    TEAM_LN
                               ,    PARTCD
                               ,    PART_LN
                               ,    STORECD
                               ,    STORENM
                               ,    SUM(CASE WHEN NTSAL_GBCD = '02' THEN
                                         CASE WHEN PLNSAL_AMT = 0 OR SALDT_CNT = 0 OR PLNDT_CNT = 0 THEN 0 ELSE CAST( (NTSAL_AMT /  SALDT_CNT) AS FLOAT) / (PLNSAL_AMT /  PLNDT_CNT) * 100 END
                                    END) AS GOAL_02
                               ,    SUM(CASE WHEN NTSAL_GBCD = '05' THEN
                                         CASE WHEN PLNSAL_AMT = 0 OR SALDT_CNT = 0 OR PLNDT_CNT = 0 THEN 0 ELSE CAST( (NTSAL_AMT /  SALDT_CNT) AS FLOAT) / (PLNSAL_AMT /  PLNDT_CNT) * 100 END
                                    END) AS GOAL_05
                               ,    SUM(CASE WHEN NTSAL_GBCD = '11' THEN
                                         CASE WHEN PLNSAL_AMT = 0 OR SALDT_CNT = 0 OR PLNDT_CNT = 0 THEN 0 ELSE CAST( (NTSAL_AMT /  SALDT_CNT) AS FLOAT) / (PLNSAL_AMT /  PLNDT_CNT) * 100 END
                                    END) AS GOAL_11  
                               ,    SUM(CASE WHEN NTSAL_GBCD = '12' THEN
                                         CASE WHEN PLNSAL_AMT = 0 OR SALDT_CNT = 0 OR PLNDT_CNT = 0 THEN 0 ELSE CAST( (NTSAL_AMT /  SALDT_CNT) AS FLOAT) / (PLNSAL_AMT /  PLNDT_CNT) * 100 END
                                    END) AS GOAL_12
                               ,    SUM(CASE WHEN NTSAL_GBCD = '13' THEN
                                         CASE WHEN PLNSAL_AMT = 0 OR SALDT_CNT = 0 OR PLNDT_CNT = 0 THEN 0 ELSE CAST( (NTSAL_AMT /  SALDT_CNT) AS FLOAT) / (PLNSAL_AMT /  PLNDT_CNT) * 100 END
                                    END) AS GOAL_13
                               ,    DW_RGNCD         
                            FROM    (          
                                        SELECT    B.RGN_GRPCD
                                             ,    B.RGN_GRPNM
                                             ,    B.RGNCD
                                             ,    B.RGNNM
                                             ,    B.TEAMCD
                                             ,    B.TEAM_LN
                                             ,    B.PARTCD
                                             ,    B.PART_LN
                                             ,    B.STORECD
                                             ,    B.STORENM
                                             ,    A.NTSAL_GBCD
                                             ,    SUM(A.NTSAL_AMT) AS NTSAL_AMT
                                             ,    SUM(A.PLNSAL_AMT) AS PLNSAL_AMT
                                             ,    SUM(A.SALDT_CNT ) AS SALDT_CNT 
                                             ,    SUM(A.PLNDT_CNT ) AS PLNDT_CNT
                                             ,    C.DW_RGNCD AS DW_RGNCD
                                          FROM    LGMJVDP.TB_CVS_MAIN_TAB01 A
                                          JOIN    LGMJVDP.TB_STORE_DM B  
                                            ON    A.STORECD = B.STORECD
                                           AND    B.ACCTCD  =   'A'
                                          JOIN    LGMJVDP.TB_RGN_DM C
                                            ON    B.RGNCD = C.RGNCD
                                          JOIN    (
                                                     SELECT    A.ORIGIN_BIZPL_CD
                                                          ,    MAX(OPEN_DT) AS LAST_OPEN_DT --���������
                                                       FROM    LGMJVDP.TS_MS_BIZPL A
                                                      GROUP BY A.ORIGIN_BIZPL_CD
                                                  ) D
                                            ON    'V'||B.STORECD = D.ORIGIN_BIZPL_CD      
                                           AND    (
                                                    ( ( SUBSTR(D.LAST_OPEN_DT,1,6) NOT IN ('202301' , '202212') ) AND (TO_CHAR(B.OPENDT,'YYYYMM') NOT IN ('202301' , '202212') ) )
                                                     OR
                                                    ( TO_CHAR(B.OPENDT,'YYYYMMDD') BETWEEN '20221201' AND '20221210' )
                                                  )
                                           AND    ( TO_CHAR(B.CLOSEDT,'YYYYMM') NOT IN ('202301') OR B.CLOSEDT IS NULL )                                                                
                                         WHERE    A.DATECD = '2023-01-08'
                                           AND    A.PLNSAL_AMT > 0
                                           --AND    A.NTSAL_AMT <> 0
                                           AND    A.NTSAL_GBCD IN ('02','05','11','12','13')
                                         GROUP BY B.RGN_GRPCD
                                             ,    B.RGN_GRPNM
                                             ,    B.RGNCD
                                             ,    B.RGNNM
                                             ,    B.TEAMCD
                                             ,    B.TEAM_LN
                                             ,    B.PARTCD
                                             ,    B.PART_LN
                                             ,    B.STORECD
                                             ,    B.STORENM
                                             ,    A.NTSAL_GBCD
                                             ,    C.DW_RGNCD
                                    )
                           GROUP BY RGN_GRPCD
                               ,    RGN_GRPNM
                               ,    RGNCD
                               ,    RGNNM
                               ,    TEAMCD
                               ,    TEAM_LN
                               ,    PARTCD
                               ,    PART_LN
                               ,    STORECD
                               ,    STORENM
                               ,    DW_RGNCD
                       )
          ) 
 GROUP BY RGNCD
     ,    RGNNM
     ,    DW_RGNCD
 ORDER BY DW_RGNCD
     ,    RGNCD

