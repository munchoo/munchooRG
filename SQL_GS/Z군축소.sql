with	 gopa1 as
 (select	a11.STORECD  STORECD,
		sum(a11.SALDT_CNT)  WJXBFS1,
		sum(a11.STKDT_CNT)  WJXBFS2
	from	LGMJVDP.TB_SALDT_MS_AG	a11
		join	LGMJVDP.TB_STORE_DM	a12
		  on 	(a11.STORECD = a12.STORECD)
	where	(a12.RGNCD in ('54')
	 and a11.YMCD in ('202307')
	 and a12.TEAMCD in ('5405'))
	group by	a11.STORECD
	), 
	 gopa2 as
 (select	a11.STORECD  STORECD,
		sum(a11.NTSAL_CAMT)  WJXBFS1,
		sum(a11.STK_AMT)  WJXBFS2
	from	LGMJVDP.TB_STK_MS_AG	a11
		join	LGMJVDP.TB_STORE_DM	a12
		  on 	(a11.STORECD = a12.STORECD)
	where	(a12.RGNCD in ('54')
	 and a11.YMCD in ('202307')
	 and a12.TEAMCD in ('5405'))
	group by	a11.STORECD
	)
select	distinct coalesce(pa11.STORECD, pa12.STORECD)  STORECD,
	SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 )  STORENM,
	'V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1)  CustCol_31,
	pa11.WJXBFS1  WJXBFS1,
	pa12.WJXBFS1  WJXBFS2,
	pa11.WJXBFS2  WJXBFS3,
	pa12.WJXBFS2  WJXBFS4
from	gopa1	pa11
	full outer join	gopa2	pa12
	  on 	(pa11.STORECD = pa12.STORECD)
	join	LGMJVDP.TB_STORE_DM	a13
	  on 	(coalesce(pa11.STORECD, pa12.STORECD) = a13.STORECD)