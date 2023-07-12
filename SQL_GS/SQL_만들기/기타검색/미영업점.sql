with	 Header as
 (select	substr(a11.ORIGIN_BIZPL_CD,2,4)  STORECD,
		a11.SALE_HR  SALE_HR,
		SUBSTR(a11.OPER_DT,1,4)||'-'||SUBSTR(a11.OPER_DT,5,2)||'-'||SUBSTR(a11.OPER_DT,7,2)  DATECD,
		sum(a11.NET_SALE_AMT)  매출액
	from	LGMJVDP.TS_SL_TIME_CUST_SALE	a11
		join	LGMJVDP.TB_STORE_DM	a12
		  on 	(substr(a11.ORIGIN_BIZPL_CD,2,4) = a12.STORECD)
	where	(a12.RGNCD in ('54')
	 -- and SUBSTR(a11.OPER_DT,1,4)||'-'||SUBSTR(a11.OPER_DT,5,2)||'-'||SUBSTR(a11.OPER_DT,7,2) in ('2022-06-15', '2022-06-14', '2022-06-13', '2022-06-12', '2022-06-11')
	 and a11.OPER_DT between to_char(sysdate-8, 'YYYYMMDD') and to_char(sysdate-1, 'YYYYMMDD')
	 and a11.SALE_HR in ('01', '02', '03', '04', '05', '06'))
	group by	substr(a11.ORIGIN_BIZPL_CD,2,4),
		a11.SALE_HR,
		SUBSTR(a11.OPER_DT,1,4)||'-'||SUBSTR(a11.OPER_DT,5,2)||'-'||SUBSTR(a11.OPER_DT,7,2)
	), 

Body_date as
(
    select	a11.STORECD  STORECD,
		a11.DATECD  DATECD,
		sum(a11.SALDT_CNT)  영업일수
	from	LGMJVDP.TB_SALDT_FT	a11
		join	LGMJVDP.TB_STORE_DM	a12
	    on 	(a11.STORECD = a12.STORECD)
	where	(a12.RGNCD in ('54')
	and a11.DATECD between to_char(sysdate-8, 'YYYY-MM-DD') and to_char(sysdate-1, 'YYYY-MM-DD'))
	group by	a11.STORECD,
		a11.DATECD
	)

select	distinct 'V'||pa11.STORECD  STORECD,
	SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 )  STORENM,
	'V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1)  현재코드,
	pa11.DATECD  DATECD,
	a13.TEAMCD  TEAMCD,
	a13.TEAM_LN  TEAM_LN,
	a13.team_dist_seq  team_dist_seq,
	pa11.SALE_HR  SALE_HR,
	pa11.매출액  매출액,
	pa12.영업일수  영업일수
from	Header	pa11
	left outer join	Body_date	pa12
	  on 	(pa11.DATECD = pa12.DATECD and 
	pa11.STORECD = pa12.STORECD)
	join	LGMJVDP.TB_STORE_DM	a13
	  on 	(pa11.STORECD = a13.STORECD)

----------------24시간 영업시간확인 쿼리

Body_24H as 

select BIZPL_CD_ORIGIN 최초코드, 
   max('V'||SUBSTR(a12.STORENM,INSTR(a12.STORENM,'(')+1, -( INSTR(a12.STORENM,'(') -INSTR(a12.STORENM,':'))-1)) 현재코드,
    max(OPEN_DT) 오픈일,
    max(OPER_HH) 영업시간
    from   LGMJVDP.TS_MB_BIZPL a11
    join LGMJVDP.TB_STORE_DM a12  
on a11.BIZPL_CD = 'V'||SUBSTR(a12.STORENM,INSTR(a12.STORENM,'(')+1, -( INSTR(a12.STORENM,'(') -INSTR(a12.STORENM,':'))-1) 
and a12.RGNCD in ('54') 
group by BIZPL_CD_ORIGIN

