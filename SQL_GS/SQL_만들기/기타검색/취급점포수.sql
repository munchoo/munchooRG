with	 gopa1 as
 (select	a11.STORECD  STORECD,
		count(distinct a11.STORECD)  WJXBFS1
	from	LGMJVDP.TB_STK_FT	a11
		join	LGMJVDP.TB_DATE_DM	a12
		  on 	(a11.DATECD = a12.DATECD)
	where	(a11.STORE_CNT = 1
	 and a11.GOODCD in ('8801223011987')
	 and a12.YMCD in ('202204'))
	group by	a11.STORECD
	), 
	 gopa2 as
 (select	a11.STORECD  STORECD,
		sum(a11.STORE_CNT)  WJXBFS1
	from	LGMJVDP.TB_STK_MSG_AG	a11
	where	(a11.GOODCD in ('8801223011987')
	 and a11.YMCD in ('202204'))
	group by	a11.STORECD
	)
select	distinct coalesce(pa11.STORECD, pa12.STORECD)  STORECD,
	SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 )  STORENM,
	'V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1)  CustCol_31,
	a13.RGNCD  RGNCD,
	a13.RGNNM  RGNNM,
	pa11.WJXBFS1  WJXBFS1,
	pa12.WJXBFS1  WJXBFS2
from	gopa1	pa11
	full outer join	gopa2	pa12
	  on 	(pa11.STORECD = pa12.STORECD)
	join	LGMJVDP.TB_STORE_DM	a13
	  on 	(coalesce(pa11.STORECD, pa12.STORECD) = a13.STORECD)