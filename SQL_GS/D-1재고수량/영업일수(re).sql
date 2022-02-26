select	
    a12.RGN_GRPCD  RGN_GRPCD,
	max(a12.RGN_GRPNM)  RGN_GRPNM,
	a12.RGNCD  RGNCD,
	max(a12.RGNNM)  RGNNM,
    a12.TEAMCD  TEAMCD,
	max(a12.TEAM_LN)  TEAM_LN,
	max(a12.team_dist_seq)  team_dist_seq,
	a12.PARTCD  PARTCD,
	max(a12.PART_LN)  PART_LN,
	max(a12.part_dist_seq)  part_dist_seq,
 -- ## D-2개월 해당월의 10일 < 최초오픈일 AND 최초오픈일 = 경영주오픈일 이면 '신규점제외'   ///  D-1개월 >= 경영주 오픈일일경우 양수도 제외 (D+1개월은 제외)
 -- ## TS_MS_BIZPL.OPEN_DT 현경영주 오픈일 , TB_STORE_DM.OPENDT 최초오픈일
 -- ## To_Char로 변경이 되지 않아서 정규식으로 변경 후 판단.
     CASE WHEN REGEXP_REPLACE(a13.OPEN_DT, '(.{4})(.{2})(.{2})', '\1\2\3') > to_char(add_months(sysdate,-2),'YYYYMM')||'10' THEN 
        CASE WHEN REGEXP_REPLACE(a13.OPEN_DT, '(.{4})(.{2})(.{2})', '\1\2\3') = TO_CHAR(a12.OPENDT,'YYYYMMDD') THEN '신규점제외'
            WHEN SUBSTR(a13.OPEN_DT,1,6) >= to_char(add_months(sysdate,-1),'YYYYMM') AND SUBSTR(a13.OPEN_DT,1,6) < to_char(add_months(sysdate,1),'YYYYMM') THEN '양수도제외'
        END
    ELSE
 -- ## 연속 5일 이상 휴점일 경우 표시
        CASE WHEN a14.YN in ('Y') THEN '휴점' END
    END as extor,
    a12.STORECD  STORECD,
    max(a12.OPENDT) OPEN_DT,
    max(to_char(to_date(a13.OPEN_DT,'YYYYMMDD'),'YYYY-MM-DD')) CUR_OPEN_DT,
	max(SUBSTR(a12.STORENM,1,INSTR(a12.STORENM,'(')-1 ))  STORENM,
	max('V'||SUBSTR(a12.STORENM,INSTR(a12.STORENM,'(')+1, -( INSTR(a12.STORENM,'(') -INSTR(a12.STORENM,':'))-1))  CUR_STORECD,
	sum(a11.SALDT_CNT)  SALDT_CNT
from	LGMJVDP.TB_SALDT_FT	a11
	join	LGMJVDP.TB_STORE_DM	a12
	    on 	(a11.STORECD = a12.STORECD)
    join LGMJVDP.TS_MS_BIZPL a13
        on ('V'||SUBSTR(a12.STORENM,INSTR(a12.STORENM,'(')+1, -( INSTR(a12.STORENM,'(') -INSTR(a12.STORENM,':'))-1) = a13.BIZPL_CD)
    -- 휴점 판단가져오기 연속 5일 이상 휴점 시 Y반환
    join (
        select STORECD,
            CASE WHEN
            LISTAGG(SALDT_CNT) WITHIN GROUP(order by DATECD)
            LIKE '%00000%' THEN 'Y' ELSE 'N' END AS YN
            from   LGMJVDP.TB_SALDT_FT
            where DATECD BETWEEN trunc(sysdate, 'mm') AND sysdate
            group by STORECD
            order by STORECD
        ) a14
        on a12.STORECD = a14.STORECD
where	a11.DATECD BETWEEN trunc(sysdate, 'mm') AND sysdate
-- and a12.STORECD in ('P023') /*점포테스트용*/
group by
	a12.RGN_GRPCD,
	a12.RGNCD,
	a12.TEAMCD,
	a12.PARTCD,
    CASE WHEN REGEXP_REPLACE(a13.OPEN_DT, '(.{4})(.{2})(.{2})', '\1\2\3') > to_char(add_months(sysdate,-2),'YYYYMM')||'10' THEN 
        CASE WHEN REGEXP_REPLACE(a13.OPEN_DT, '(.{4})(.{2})(.{2})', '\1\2\3') = TO_CHAR(a12.OPENDT,'YYYYMMDD') THEN '신규점제외'
            WHEN SUBSTR(a13.OPEN_DT,1,6) >= to_char(add_months(sysdate,-1),'YYYYMM') AND SUBSTR(a13.OPEN_DT,1,6) < to_char(add_months(sysdate,1),'YYYYMM') THEN '양수도제외'
        END
    ELSE
        CASE WHEN a14.YN in ('Y') THEN '휴점' END
    END,
    a12.STORECD

order by  a12.RGN_GRPCD,
	a12.RGNCD,
	a12.TEAMCD,
	a12.PARTCD,
    CASE WHEN REGEXP_REPLACE(a13.OPEN_DT, '(.{4})(.{2})(.{2})', '\1\2\3') > to_char(add_months(sysdate,-2),'YYYYMM')||'10' THEN 
        CASE WHEN REGEXP_REPLACE(a13.OPEN_DT, '(.{4})(.{2})(.{2})', '\1\2\3') = TO_CHAR(a12.OPENDT,'YYYYMMDD') THEN '신규점제외'
            WHEN SUBSTR(a13.OPEN_DT,1,6) >= to_char(add_months(sysdate,-1),'YYYYMM') AND SUBSTR(a13.OPEN_DT,1,6) < to_char(add_months(sysdate,1),'YYYYMM') THEN '양수도제외'
        END
    ELSE
        CASE WHEN a14.YN in ('Y') THEN '휴점' END
    END,
    a12.STORECD


