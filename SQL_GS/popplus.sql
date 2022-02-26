/* 더팝플러스 추출에 대한 사항 
   gscrmods.tb_pm_pmbs_use 테이블에 더팝플러스 팩트 테이블 
   lgmjvdp.tb_store_dm 스토에 네임*/



SELECT  A14.RGNCD AS 지역팀코드
        ,a14.rgnnm AS 지역팀
        ,a13.team_ln AS 영업팀
        ,a12.part_ln AS OFC
        ,'V'||a12.STORECD AS 최초코드
        ,'V'||SUBSTR(a12.STORENM,INSTR(a12.STORENM,'(')+1, -( INSTR(a12.STORENM,'(') -INSTR(a12.STORENM,':'))-1) AS 점포코드
        ,SUBSTR(a12.STORENM,1,INSTR(a12.STORENM,'(')-1 ) AS 점포명 
        ,A11.PMBS_SVC_NO AS 유료멤버십서비스번호
        ,A16.PMBS_SVC_NM AS 유료멤버십서비스명
        ,A15.DATECD AS 승인일자
        ,A11.CUST_NO AS 고유회원수
        ,COUNT(A11.CUST_NO) AS 사용회원수
        ,SUM(A11.ITEM_QTY) AS 상품수량
        ,SUM(A11.PMBS_DC_AMT) AS 유료멤버십할인금액
        ,SUM(A11.TDR_AMT) AS 결제금액
FROM gscrmods.tb_pm_pmbs_use a11
LEFT JOIN lgmjvdp.tb_store_dm a12
ON a11.str_cd = 'V'||SUBSTR(a12.STORENM,INSTR(a12.STORENM,'(')+1, -( INSTR(a12.STORENM,'(') -INSTR(a12.STORENM,':'))-1)
LEFT JOIN LGMJVDP.TB_TEAM_DM A13
ON A12.TEAMCD = A13.TEAMCD
LEFT JOIN LGMJVDP.TB_RGN_DM A14
ON A12.RGNCD = A14.RGNCD
LEFT JOIN LGMJVDP.TB_DATE_DM A15
ON TO_CHAR(TO_DATE(A11.CPN_APPR_DT,'YYYYMMDD'), 'YYYY-MM-DD') = A15.DATECD
LEFT JOIN GSCRMODS.TB_PM_PMBS_SVC A16
ON A11.PMBS_SVC_NO = A16.PMBS_SVC_NO
where a11.bd_sp_cd = 'C'
AND A14.RGNCD in ('25','26','27','28','29','30','31','32')
AND A15.DATECD BETWEEN TO_DATE('2021-02-01', 'YYYY-MM-DD') AND TO_DATE('2021-03-16','YYYY-MM-DD')
GROUP BY A14.RGNCD
        ,a14.rgnnm
        ,A13.TEAMCD
        ,a13.team_ln
        ,A12.PARTCD
        ,a12.part_ln
        ,'V'||a12.STORECD
        ,'V'||SUBSTR(a12.STORENM,INSTR(a12.STORENM,'(')+1, -( INSTR(a12.STORENM,'(') -INSTR(a12.STORENM,':'))-1)
        ,SUBSTR(a12.STORENM,1,INSTR(a12.STORENM,'(')-1 )
        ,A11.CUST_NO
        ,A11.PMBS_SVC_NO
        ,A16.PMBS_SVC_NM
        ,A15.DATECD
ORDER BY A14.RGNCD
        ,a14.rgnnm
        ,A13.TEAMCD
        ,a13.team_ln
        ,A12.PARTCD
        ,a12.part_ln
        ,'V'||a12.STORECD
        ,'V'||SUBSTR(a12.STORENM,INSTR(a12.STORENM,'(')+1, -( INSTR(a12.STORENM,'(') -INSTR(a12.STORENM,':'))-1)
        ,SUBSTR(a12.STORENM,1,INSTR(a12.STORENM,'(')-1 )
        ,A11.CUST_NO
        ,A11.PMBS_SVC_NO
        ,A16.PMBS_SVC_NM
        ,A15.DATECD