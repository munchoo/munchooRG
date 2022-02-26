with	 gopa1 as
 (select	a11.STORECD  STORECD,
		a12.WKCD  WKCD,
		sum(a11.NTSAL_AMT)  WJXBFS1
	from	LGMJVDP.TB_STK_DSG2_AG	a11
		join	LGMJVDP.TB_DATE_DM	a12
		  on 	(a11.DATECD = a12.DATECD)
		join	LGMJVDP.TB_STORE_DM	a13
		  on 	(a11.STORECD = a13.STORECD)
	where	(a11.DATECD between sysdate-28 AND sysdate
	 and a13.RGNCD in ('54')
	 and a11.GOOD_CLS2CD in ('0909', '0910'))
	group by	a11.STORECD,
		a12.WKCD
	), 
	 gopa2 as
 (select	a11.STORECD  STORECD,
		a12.WKCD  WKCD,
		sum(a11.SALDT_CNT)  WJXBFS1
	from	LGMJVDP.TB_SALDT_FT	a11
		join	LGMJVDP.TB_DATE_DM	a12
		  on 	(a11.DATECD = a12.DATECD)
		join	LGMJVDP.TB_STORE_DM	a13
		  on 	(a11.STORECD = a13.STORECD)
	where	(a11.DATECD between sysdate-28 AND sysdate
	 and a13.RGNCD in ('54'))
	group by	a11.STORECD,
		a12.WKCD
	)
select	distinct coalesce(pa11.STORECD, pa12.STORECD)  STORECD,
	SUBSTR(a14.STORENM,1,INSTR(a14.STORENM,'(')-1 )  STORENM,
	'V'||SUBSTR(a14.STORENM,INSTR(a14.STORENM,'(')+1, -( INSTR(a14.STORENM,'(') -INSTR(a14.STORENM,':'))-1)  CustCol_31,
	coalesce(pa11.WKCD, pa12.WKCD)  WKCD,
	a13.WKNM  WKNM,
	pa11.WJXBFS1  매출액,
	pa12.WJXBFS1  영업일수
from	gopa1	pa11
	full outer join	gopa2	pa12
	  on 	(pa11.STORECD = pa12.STORECD and 
	pa11.WKCD = pa12.WKCD)
	join	LGMJVDP.TB_WEEK_DM	a13
	  on 	(coalesce(pa11.WKCD, pa12.WKCD) = a13.WKCD)
	join	LGMJVDP.TB_STORE_DM	a14
	  on 	(coalesce(pa11.STORECD, pa12.STORECD) = a14.STORECD)