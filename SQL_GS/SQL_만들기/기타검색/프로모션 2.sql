with     gopa1 as
 (select    a11.STORECD  STORECD,
        sum(case when a11.GOODCD in ('8809038475420', '8809038475437', '8809038475871', '8809038475901', '8801123410392', '8801123410347', '8801123311064', '8801123307289', '8801123311019', '8801123309498', '8801123304219', '8801123311095', '8801007034980', '8801007899985', '8801007882703', '8801007880402', '8801492384423', '8801066062108', '8801066062092', '8801492385642', '8801066310520', '8801066056558', '8801077657706', '8801077657805', '8801077609200', '8801077701003') then a11.NTSAL_AMT end) AS 냉장_매출액
    from    LGMJVDP.TB_STK_MSG_AG    a11
        join    LGMJVDP.TB_STORE_DM    a12
          on     (a11.STORECD = a12.STORECD)
          and a12.OPENDT < ('2023-09-11')
    where    (a11.YMCD in ('202310')
     and a11.GOODCD in ('8809038475420', '8809038475437', '8809038475871', '8809038475901', '8801123410392', '8801123410347', '8801123311064', '8801123307289', '8801123311019', '8801123309498', '8801123304219', '8801123311095', '8801007034980', '8801007899985', '8801007882703', '8801007880402', '8801492384423', '8801066062108', '8801066062092', '8801492385642', '8801066310520', '8801066056558', '8801077657706', '8801077657805', '8801077609200', '8801077701003')
     and a12.RGNCD between ('41') and ('61'))
    group by    a11.STORECD
    ), 
     gopa2 as
 (select    a11.STORECD  STORECD,
        sum(a11.SALDT_CNT)  영업일수
    from    LGMJVDP.TB_SALDT_MS_AG    a11
        join    LGMJVDP.TB_STORE_DM    a12
          on     (a11.STORECD = a12.STORECD)
          and a12.OPENDT < ('2023-09-11')
    where    (a11.YMCD in ('202310')
     and a12.RGNCD between ('41') and ('61'))
    group by    a11.STORECD
    )
select    distinct pa11.STORECD  STORECD,
    'V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1)  현재코드,
    SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 )  STORENM,
    a13.TEAM_LN  TEAM_LN,
    a13.PART_LN  PART_LN,
    a13.OPENDT  오픈일,
    pa11.냉장_매출액,
    pa12.영업일수
from    gopa1    pa11
    left outer join    gopa2    pa12
      on     (pa11.STORECD = pa12.STORECD)
    join    LGMJVDP.TB_STORE_DM    a13
      on     (pa11.STORECD = a13.STORECD 
      and     pa11.STORECD = a13.STORECD)










--- 주류일매출
with  gopa1 as
 (select a11.STORECD  STORECD,
sum(a11.NTSAL_AMT)  WJXBFS1
from LGMJVDP.TB_STK_MSG1_AG a11
join LGMJVDP.TB_GOOD_CLS1_DM a13
  on  (a11.GOOD_CLS1CD = a13.GOOD_CLS1CD)
join LGMJVDP.TB_STORE_DM a14
  on  (a11.STORECD = a14.STORECD)
where (a13.GOOD_CLS1CD in ('13','14')
 and a14.RGNCD between ('41') and ('60')
and a14.TEAMCD not in ('4208') 
 and a11.YMCD in ('202210'))
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
and a11.YMCD in ('202210')
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
where (a11.YMCD in ('202310')
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
where (a11.YMCD in ('202310')
 and a12.GOOD_CLS1CD in ('13','14')
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
),  gopa7 as
 (select a11.STORECD  STORECD,
sum(a11.SALDT_CNT)  WJXBFS1
from LGMJVDP.TB_SALDT_MS_AG a11
join LGMJVDP.TB_STORE_DM a12
  on  (a11.STORECD = a12.STORECD)
where (a11.YMCD in ('202308')
 and a12.RGNCD between ('41') and ('60')
and a12.TEAMCD not in ('4208'))
group by a11.STORECD
), 
 gopa8 as
 (select a11.STORECD  STORECD,
sum(a11.NTSAL_AMT)  WJXBFS1
from LGMJVDP.TB_STK_MSG2_AG a11
join LGMJVDP.TB_GOOD_CLS2_DM a12
  on  (a11.GOOD_CLS2CD = a12.GOOD_CLS2CD)
join LGMJVDP.TB_STORE_DM a13
  on  (a11.STORECD = a13.STORECD)
where (a11.YMCD in ('202308')
 and a12.GOOD_CLS1CD in ('13','14') 
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
from gopa7 pa11
join gopa8 pa12
  on  (pa11.STORECD = pa12.STORECD)  
join LGMJVDP.TB_STORE_OP_DM pa13
 on (pa11.STORECD =  pa13.STORECD)
 -- 양수점포 제외하기 
 and pa13.OPEN_DT is not null and pa13.OPEN_DT < ('2023-10-01')  
join LGMJVDP.TB_STORE_OP_DM pa14 
 on (pa11.STORECD =  pa14.STORECD)
 -- 오픈일 기준 정하기 
and pa14.OPEN_DT < ('2023-09-11')  
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
  and pa14.OPEN_DT < ('2023-10-01') 
where  pa12.WJXBFS1 > 0 and pa13.WJXBFS1 > 0 and pa13.WJXBFS2 > 0
