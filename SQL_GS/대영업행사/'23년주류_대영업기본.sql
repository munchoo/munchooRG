--- 전년 대/중분류 일매출 추출을 위해 영업일수와 총매출을 추출하기
with  gopa1 as
 (select a11.STORECD  STORECD,
sum(a11.NTSAL_AMT)  WJXBFS1
from LGMJVDP.TB_STK_MSG1_AG a11
join LGMJVDP.TB_GOOD_CLS1_DM a13
  on  (a11.GOOD_CLS1CD = a13.GOOD_CLS1CD)
join LGMJVDP.TB_STORE_DM a14
  on  (a11.STORECD = a14.STORECD)
where (a13.GOOD_CLS0CD in ('09')
 and a14.RGNCD between ('41') and ('60')
and a14.TEAMCD not in ('4208') 
 and a11.YMCD in ('202304'))
group by a11.STORECD
), 
 gopa2 as
 (select a11.STORECD  STORECD,
sum(a11.SALDT_CNT)  WJXBFS1
from LGMJVDP.TB_SALDT_MS_AG a11
join LGMJVDP.TB_STORE_DM a13
  on  (a11.STORECD = a13.STORECD)
where a13.RGNCD between ('41') and ('60') 
and a13.TEAMCD not in ('4208') 
and a11.YMCD in ('202304')
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

--- 전월 대/중분류 일매출 추출을 위해 영업일수와 총매출을 추출하기
 gopa4 as
 (select a11.STORECD  STORECD,
sum(a11.SALDT_CNT)  WJXBFS1
from LGMJVDP.TB_SALDT_MS_AG a11
join LGMJVDP.TB_STORE_DM a12
  on  (a11.STORECD = a12.STORECD)
where (a11.YMCD in ('202404')
 and a12.RGNCD between ('41') and ('60')
 and a12.TEAMCD not in ('4208'))
group by a11.STORECD
), 
 gopa5 as
 (select a11.STORECD  STORECD,
sum(a11.NTSAL_AMT)  WJXBFS1
from LGMJVDP.TB_STK_MSG2_AG a11
join LGMJVDP.TB_GOOD_CLS2_DM a12
  on  (a11.GOOD_CLS2CD = a12.GOOD_CLS2CD)
join LGMJVDP.TB_STORE_DM a13
  on  (a11.STORECD = a13.STORECD)
where (a11.YMCD in ('202404')
--(GOOD_CLS0CD 대분류 GOOD_CLS1CD 중분류 둘다 00 두자리 코드)
 and a12.GOOD_CLS0CD in ('09')
 and a13.RGNCD between ('41') and ('60')
and a13.TEAMCD not in ('4208'))
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
-- 군자료에서의 영업일수
 GunOpenDt as
 (select a11.STORECD  STORECD,
sum(a11.SALDT_CNT)  WJXBFS1
from LGMJVDP.TB_SALDT_MS_AG a11
join LGMJVDP.TB_STORE_DM a12
  on  (a11.STORECD = a12.STORECD)
where (a11.YMCD in ('202403')
 and a12.RGNCD between ('41') and ('60')
and a12.TEAMCD not in ('4208'))
group by a11.STORECD
), 
-- 군자료에서의 매출액
 GunSale as
 (select a11.STORECD  STORECD,
sum(a11.NTSAL_AMT)  WJXBFS1
from LGMJVDP.TB_STK_MSG2_AG a11
join LGMJVDP.TB_GOOD_CLS2_DM a12
  on  (a11.GOOD_CLS2CD = a12.GOOD_CLS2CD)
join LGMJVDP.TB_STORE_DM a13
  on  (a11.STORECD = a13.STORECD)
where (a11.YMCD in ('202403')
 -- 군자료_중분류 (GOOD_CLS0CD 대분류 GOOD_CLS1CD 중분류 둘다 00 두자리 코드)
 and a12.GOOD_CLS0CD in ('09') 
 and a13.TEAMCD not in ('4208') 
 and a13.RGNCD between ('41') and ('60'))
group by a11.STORECD
), gopa9 as 
 ( select coalesce(pa11.STORECD, pa12.STORECD)  STORECD,
pa11.WJXBFS1  WJXBFS1,
pa12.WJXBFS1  WJXBFS2,  
pa12.WJXBFS1 / decode(pa11.WJXBFS1 , 0, null, pa11.WJXBFS1) 군일매출, 
row_number() over (order by pa12.WJXBFS1 / decode(pa11.WJXBFS1 , 0, null, pa11.WJXBFS1) desc ) 순위,
count(*) over () Fullcount, 
pa13.OPEN_DT 
from GunOpenDt pa11
join GunSale pa12
  on  (pa11.STORECD = pa12.STORECD)  
join LGMJVDP.TB_STORE_OP_DM pa13
 on (pa11.STORECD =  pa13.STORECD)
 -- 양수점포 제외하기 
 and pa13.OPEN_DT is not null and pa13.OPEN_DT < ('2024-04-01')  
join LGMJVDP.TB_STORE_OP_DM pa14 
 on (pa11.STORECD =  pa14.STORECD)
 -- 오픈일 기준 제외점 정하기 
and pa14.OPEN_DT < ('2024-03-11')  
where  pa11.WJXBFS1 > 0 and pa12.WJXBFS1 > 0) 
 
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
left join gopa9 pa13
  on  (pa12.STORECD = pa13.STORECD)  
join LGMJVDP.TB_STORE_OP_DM  pa14
  on  (pa13.STORECD =  pa14.STORECD) 
  and pa14.OPEN_DT < ('2024-04-01') 
where  pa12.WJXBFS1 > 0 and pa13.WJXBFS1 > 0 and pa13.WJXBFS2 > 0



