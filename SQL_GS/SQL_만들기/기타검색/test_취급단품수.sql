with	 gopa1 as
 (select	a11.DATECD  DATECD,
		sum(a11.STORE_CNT)  WJXBFS1,
		(Case when max((Case when a11.STORE_CNT = 1 then 1 else 0 end)) = 1 then count(distinct (Case when a11.STORE_CNT = 1 then a11.STORECD else NULL end)) else NULL end)  WJXBFS2
	from	LGMJVDP.TB_STK_FT	a11
	where	(a11.STORECD in ('S355 ')
	 and a11.DATECD in ('2022-09-04')
	 and a11.GOODCD in ('88002798     '))
	group by	a11.DATECD
	)
select	pa12.DATECD  DATECD,
	pa12.WJXBFS1  WJXBFS1,
	pa12.WJXBFS2  WJXBFS2
from	gopa1	pa12
