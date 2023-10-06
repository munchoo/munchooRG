--- 주류일매출
with  gopa1 as
 (select a11.STORECD  STORECD,
sum(a11.NTSAL_AMT)  WJXBFS1
from LGMJVDP.TB_STK_MSG1_AG a11
join LGMJVDP.TB_GOOD_CLS1_DM a13
  on  (a11.GOOD_CLS1CD = a13.GOOD_CLS1CD)
join LGMJVDP.TB_STORE_DM a14
  on  (a11.STORECD = a14.STORECD)
where (a13.GOOD_CLS0CD in ('12')
 and a14.RGNCD in ('54'))
 and a11.YMCD in ('202208')
group by a11.STORECD
), 
 gopa2 as
 (select a11.STORECD  STORECD,
sum(a11.SALDT_CNT)  WJXBFS1
from LGMJVDP.TB_SALDT_MS_AG a11
join LGMJVDP.TB_STORE_DM a13
  on  (a11.STORECD = a13.STORECD)
where a13.RGNCD in ('54')
and a11.YMCD in ('202208')
group by a11.STORECD
), 
 gopa3 as
 (select coalesce(pa11.STORECD, pa12.STORECD)  STORECD,
pa11.WJXBFS1  WJXBFS1,
pa12.WJXBFS1  WJXBFS2
from gopa1 pa11
full outer join gopa2 pa12
  on  (pa11.STORECD = pa12.STORECD)
), 
 gopa4 as
 (select a11.STORECD  STORECD,
sum(a11.SALDT_CNT)  WJXBFS1
from LGMJVDP.TB_SALDT_MS_AG a11
join LGMJVDP.TB_STORE_DM a12
  on  (a11.STORECD = a12.STORECD)
where (a11.YMCD in ('202308')
 and a12.RGNCD in ('54'))
group by a11.STORECD
), 
 gopa5 as
 (select a11.STORECD  STORECD,
sum(a11.NTSAL_AMT)  WJXBFS1
from LGMJVDP.TB_STK_MSG1_AG a11
join LGMJVDP.TB_GOOD_CLS1_DM a12
  on  (a11.GOOD_CLS1CD = a12.GOOD_CLS1CD)
join LGMJVDP.TB_STORE_DM a13
  on  (a11.STORECD = a13.STORECD)
where (a11.YMCD in ('202308')
 and a12.GOOD_CLS0CD in ('12')
 and a13.RGNCD in ('54'))
group by a11.STORECD
), 
 gopa6 as
 (select coalesce(pa11.STORECD, pa12.STORECD)  STORECD,
pa11.WJXBFS1  WJXBFS1,
pa12.WJXBFS1  WJXBFS2
from gopa4 pa11
full outer join gopa5 pa12
  on  (pa11.STORECD = pa12.STORECD)
), 
 gopa7 as
 (select a11.STORECD  STORECD,
sum(a11.SALDT_CNT)  WJXBFS1
from LGMJVDP.TB_SALDT_MS_AG a11
join LGMJVDP.TB_STORE_DM a12
  on  (a11.STORECD = a12.STORECD)
where (a11.YMCD in ('202307')
 and a12.RGNCD in ('54'))
group by a11.STORECD
), 
 gopa8 as
 (select a11.STORECD  STORECD,
sum(a11.NTSAL_AMT)  WJXBFS1
from LGMJVDP.TB_STK_MSG1_AG a11
join LGMJVDP.TB_GOOD_CLS1_DM a12
  on  (a11.GOOD_CLS1CD = a12.GOOD_CLS1CD)
join LGMJVDP.TB_STORE_DM a13
  on  (a11.STORECD = a13.STORECD)
where (a11.YMCD in ('202307')
 and a12.GOOD_CLS0CD in ('12')
 and a13.RGNCD in ('54'))
group by a11.STORECD
), 
 gopa9 as
 (select coalesce(pa11.STORECD, pa12.STORECD)  STORECD,
pa11.WJXBFS1  WJXBFS1,
pa12.WJXBFS1  WJXBFS2,  
pa12.WJXBFS1 / decode(pa11.WJXBFS1 , 0, null, pa11.WJXBFS1) 군일매출, 
row_number() over (order by pa12.WJXBFS1 / decode(pa11.WJXBFS1 , 0, null, pa11.WJXBFS1) desc ) 순위,
count(*) over () Fullcount
from gopa7 pa11
full outer join gopa8 pa12
  on  (pa11.STORECD = pa12.STORECD) 
where  pa11.WJXBFS1 > 0
)
select trim(coalesce(pa11.STORECD, pa12.STORECD, pa13.STORECD))  STORECD,
pa11.WJXBFS1  전년매출액,
pa11.WJXBFS2  전년영업일수,
pa12.WJXBFS1  영업일수,
pa12.WJXBFS2  매출액,   
pa13.WJXBFS1 군영업일수,
pa13.WJXBFS2  군매출액,
pa13.군일매출, 
pa13.순위, 
case when pa13.순위 < (pa13.Fullcount/10) then 1
     when pa13.순위 < (pa13.Fullcount/10) * 2 then 2
     when pa13.순위 < (pa13.Fullcount/10) * 3 then 3
     when pa13.순위 < (pa13.Fullcount/10) * 4 then 4
     when pa13.순위 < (pa13.Fullcount/10) * 5 then 5
     when pa13.순위 < (pa13.Fullcount/10) * 6 then 6
     when pa13.순위 < (pa13.Fullcount/10) * 7 then 7
     when pa13.순위 < (pa13.Fullcount/10) * 8 then 8
     when pa13.순위 < (pa13.Fullcount/10) * 9 then 9 else 10 end as 군
from gopa3 pa11
full outer join gopa6 pa12
  on  (pa11.STORECD = pa12.STORECD) 
full outer join gopa9 pa13
  on  (pa12.STORECD = pa13.STORECD)  
where  pa12.WJXBFS1 > 0 and pa13.WJXBFS1 > 0 