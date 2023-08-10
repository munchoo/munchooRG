with	 gopa1 as
 (select	a11.STORECD  STORECD,
			sum(a11.NTSAL_AMT)  WJXBFS1
		from	LGMJVDP.TB_STK_MSG1_AG	a11
			join	LGMJVDP.TB_MONTH_DM	a12
			  on 	(a11.YMCD = to_char(to_date(a12.YMCD,'yyyymm') -1 year,'yyyymm'))
			join	LGMJVDP.TB_GOOD_CLS1_DM	a13
			  on 	(a11.GOOD_CLS1CD = a13.GOOD_CLS1CD)
			join	LGMJVDP.TB_STORE_DM	a14
			  on 	(a11.STORECD = a14.STORECD)
		where	(a12.YMCD in ('202308')
		 and a13.GOOD_CLS0CD in ('12')
		 and a14.RGNCD in ('54'))
		group by	a11.STORECD
		), 
	 gopa2 as
 (select	a11.STORECD  STORECD,
			sum(a11.SALDT_CNT)  WJXBFS1
		from	LGMJVDP.TB_SALDT_MS_AG	a11
			join	LGMJVDP.TB_MONTH_DM	a12
			  on 	(a11.YMCD = to_char(to_date(a12.YMCD,'yyyymm') -1 year,'yyyymm'))
			join	LGMJVDP.TB_STORE_DM	a13
			  on 	(a11.STORECD = a13.STORECD)
		where	(a12.YMCD in ('202308')
		 and a13.RGNCD in ('54'))
		group by	a11.STORECD
		), 
	 gopa3 as
 (select	coalesce(pa11.STORECD, pa12.STORECD)  STORECD,
		pa11.WJXBFS1  WJXBFS1,
		pa12.WJXBFS1  WJXBFS2
	from	gopa1	pa11
		full outer join	gopa2	pa12
		  on 	(pa11.STORECD = pa12.STORECD)
	), 
	 gopa4 as
 (select	a11.STORECD  STORECD,
			sum(a11.SALDT_CNT)  WJXBFS1
		from	LGMJVDP.TB_SALDT_MS_AG	a11
			join	LGMJVDP.TB_STORE_DM	a12
			  on 	(a11.STORECD = a12.STORECD)
		where	(a11.YMCD in ('202308')
		 and a12.RGNCD in ('54'))
		group by	a11.STORECD
		), 
	 gopa5 as
 (select	a11.STORECD  STORECD,
			sum(a11.NTSAL_AMT)  WJXBFS1
		from	LGMJVDP.TB_STK_MSG1_AG	a11
			join	LGMJVDP.TB_GOOD_CLS1_DM	a12
			  on 	(a11.GOOD_CLS1CD = a12.GOOD_CLS1CD)
			join	LGMJVDP.TB_STORE_DM	a13
			  on 	(a11.STORECD = a13.STORECD)
		where	(a11.YMCD in ('202308')
		 and a12.GOOD_CLS0CD in ('12')
		 and a13.RGNCD in ('54'))
		group by	a11.STORECD
		), 
	 gopa6 as
 (select	coalesce(pa11.STORECD, pa12.STORECD)  STORECD,
		pa11.WJXBFS1  WJXBFS1,
		pa12.WJXBFS1  WJXBFS2
	from	gopa4	pa11
		full outer join	gopa5	pa12
		  on 	(pa11.STORECD = pa12.STORECD)
	)
select	distinct a13.TEAMCD  TEAMCD,
	a13.TEAM_LN  TEAM_LN,
	a13.team_dist_seq  team_dist_seq,
	coalesce(pa11.STORECD, pa12.STORECD)  STORECD,
	SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 )  STORENM,
	'V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1)  CustCol_31,
	pa11.WJXBFS1  WJXBFS1,
	pa11.WJXBFS2  WJXBFS2,
	pa12.WJXBFS1  WJXBFS3,
	pa12.WJXBFS2  WJXBFS4
from	gopa3	pa11
	full outer join	gopa6	pa12
	  on 	(pa11.STORECD = pa12.STORECD)
	join	LGMJVDP.TB_STORE_DM	a13
	  on 	(coalesce(pa11.STORECD, pa12.STORECD) = a13.STORECD)
