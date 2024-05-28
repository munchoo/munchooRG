with     gopa1 as
 (select    a11.STORECD  STORECD,
        sum(case when a11.GOODCD in ('9556001216144', '9556001198839', '8801019208300', '8801062636822', '8801062636846', '8801062859337', '8801062858279', '34000239344', '3424005', '3424102', '8809482998254', '8809482998230', '8801117472900', '8801062860159', '8801062860197', '9300682064828', '6917878047201', '8801019005909', '8804973308789', '8804973308802', '4902750379527')
        and a11.YMCD in ('202402') then a11.SALPRF_AMT end ) AS 행사상품_매출이익_2월,
        sum(case when a11.SALPRF_AMT > 0 and a11.GOODCD in ('9556001216144', '9556001198839', '8801019208300', '8801062636822', '8801062636846', '8801062859337', '8801062858279', '34000239344', '3424005', '3424102', '8809482998254', '8809482998230', '8801117472900', '8801062860159', '8801062860197', '9300682064828', '6917878047201', '8801019005909', '8804973308789', '8804973308802', '4902750379527')
        and a11.YMCD in ('202402') then 1 else 0 end ) AS 상품취급_2월,
        sum(case when a11.GOODCD in ('8801062870585', '8801062628476', '8801062641826', '8801062641895', '8801062642021', '8801062860197', '8801062860159', '9556001216144', '9556001284358', '50426416', '3045140105502', '8804973308802', '8804973308789', '8801043067317', '6921211104292', '8801043068178', '9300682051507', '9300682053761', '4902750435230')
        and a11.YMCD in ('202403') then a11.SALPRF_AMT end ) AS 행사상품_매출이익_3월,
        sum(case when a11.SALPRF_AMT > 0 and a11.GOODCD in ('8801062870585', '8801062628476', '8801062641826', '8801062641895', '8801062642021', '8801062860197', '8801062860159', '9556001216144', '9556001284358', '50426416', '3045140105502', '8804973308802', '8804973308789', '8801043067317', '6921211104292', '8801043068178', '9300682051507', '9300682053761', '4902750435230')
        and a11.YMCD in ('202403') then 1 else 0 end ) AS 상품취급_3월
        from    LGMJVDP.TB_STK_MSG_AG    a11
        join    LGMJVDP.TB_STORE_DM    a12
        on     (a11.STORECD = a12.STORECD)
        and a12.OPENDT < ('2024-01-11')
        where    (a11.YMCD in ('202402','202403')
        and a11.GOODCD in ('9556001216144', '9556001198839', '8801019208300', '8801062636822', '8801062636846', '8801062859337', '8801062858279', '34000239344', '3424005', '3424102', '8809482998254', '8809482998230', '8801117472900', '8801062860159', '8801062860197', '9300682064828', '6917878047201', '8801019005909', '8804973308789', '8804973308802', '4902750379527', '8801062870585', '8801062628476', '8801062641826', '8801062641895', '8801062642021', '8801062860197', '8801062860159', '9556001216144', '9556001284358', '50426416', '3045140105502', '8804973308802', '8804973308789', '8801043067317', '6921211104292', '8801043068178', '9300682051507', '9300682053761', '4902750435230')
        and a12.RGNCD between ('41') and ('61'))
        group by    a11.STORECD
    ), 
     gopa2 as
 (select    a11.STORECD  STORECD,
        sum(case when a11.YMCD in ('202402') then a11.SALDT_CNT else 0 end) 영업일수_2월,
        sum(case when a11.YMCD in ('202403') then a11.SALDT_CNT else 0 end) 영업일수_3월
    from    LGMJVDP.TB_SALDT_MS_AG    a11
        join    LGMJVDP.TB_STORE_DM    a12
          on     (a11.STORECD = a12.STORECD)
          and a12.OPENDT < ('2024-01-11')
    where    (a11.YMCD in ('202402','202403')
     and a12.RGNCD between ('41') and ('61'))
    group by    a11.STORECD
    --3월 행사상품
 )
select    distinct pa11.STORECD  STORECD,
    'V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1)  현재코드,
    SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 )  STORENM,
    a13.TEAM_LN  TEAM_LN,
    a13.PART_LN  PART_LN,
    a13.OPENDT  오픈일,
    pa11.행사상품_매출이익_2월,
    pa11.상품취급_2월,
    pa11.행사상품_매출이익_3월,
    pa11.상품취급_3월,    
    pa12.영업일수_2월,
    pa12.영업일수_3월

from    gopa1    pa11
    left outer join    gopa2    pa12
      on     (pa11.STORECD = pa12.STORECD)
    join    LGMJVDP.TB_STORE_DM    a13
      on     (pa11.STORECD = a13.STORECD 
      and     pa11.STORECD = a13.STORECD)




--------------------------------군


--- 중분류일매출
with  gopa1 as
 (select a11.STORECD  STORECD,
 a11.YMCD,
sum(a11.NTSAL_AMT)  WJXBFS1
from LGMJVDP.TB_STK_MSG1_AG a11
join LGMJVDP.TB_GOOD_CLS1_DM a13
  on  (a11.GOOD_CLS1CD = a13.GOOD_CLS1CD)
join LGMJVDP.TB_STORE_DM a14
  on  (a11.STORECD = a14.STORECD)
where (a13.GOOD_CLS1CD in ('55','56')
 and a14.RGNCD between ('41') and ('60')
and a14.TEAMCD not in ('4208') 
 and a11.YMCD in ('202302','202303','202402','202403'))
group by a11.STORECD, a11.YMCD
), 
 gopa2 as
 (select a11.STORECD  STORECD,
 a11.YMCD,
sum(a11.SALDT_CNT)  WJXBFS1
from LGMJVDP.TB_SALDT_MS_AG a11
join LGMJVDP.TB_STORE_DM a13
  on  (a11.STORECD = a13.STORECD)
where a13.RGNCD between ('41') and ('60') 
and a13.TEAMCD not in ('4208') 
and a11.YMCD in ('202302','202303','202402','202403')
group by a11.STORECD, a11.YMCD
), 
 gopa3 as
 (select pa12.STORECD  STORECD,
 pa12.YMCD  YMCD,
pa11.WJXBFS1  WJXBFS1,
pa12.WJXBFS1  WJXBFS2
from gopa1 pa11
right join gopa2 pa12
  on  (pa11.STORECD = pa12.STORECD)
  and (pa11.YMCD = pa12.YMCD)
),  gopa7 as
 (select a11.STORECD  STORECD,
sum(a11.SALDT_CNT)  WJXBFS1
from LGMJVDP.TB_SALDT_MS_AG a11
join LGMJVDP.TB_STORE_DM a12
  on  (a11.STORECD = a12.STORECD)
where (a11.YMCD in ('202401')
 and a12.RGNCD between ('41') and ('60')
and a12.TEAMCD not in ('4208'))
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
where (a11.YMCD in ('202401')
 and a12.GOOD_CLS1CD in ('55','56') 
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
 and pa13.OPEN_DT is not null and pa13.OPEN_DT < ('2024-02-01')  
join LGMJVDP.TB_STORE_OP_DM pa14 
 on (pa11.STORECD =  pa14.STORECD) 
and pa14.OPEN_DT < ('2024-01-11')  
where  pa11.WJXBFS1 > 0 and pa12.WJXBFS1 > 0)
 
select pa11.STORECD  STORECD,
max(case when pa11.YMCD = '202302' then pa11.WJXBFS1 / decode(pa11.WJXBFS2 , 0, null, pa11.WJXBFS2) end) 일매출액_23년2월,
max(case when pa11.YMCD = '202303' then pa11.WJXBFS1 / decode(pa11.WJXBFS2 , 0, null, pa11.WJXBFS2) end) 일매출액_23년3월,
max(case when pa11.YMCD = '202402' then pa11.WJXBFS1 / decode(pa11.WJXBFS2 , 0, null, pa11.WJXBFS2) end) 일매출액_24년2월,
max(case when pa11.YMCD = '202403' then pa11.WJXBFS1 / decode(pa11.WJXBFS2 , 0, null, pa11.WJXBFS2) end) 일매출액_24년3월,
max(pa13.군일매출) 군일매출, 
max(pa13.순위) 순위, 
max(case when pa13.순위 < (pa13.Fullcount/5) then 1
     when pa13.순위 < (pa13.Fullcount/5) * 2 then 2
     when pa13.순위 < (pa13.Fullcount/5) * 3 then 3
     when pa13.순위 < (pa13.Fullcount/5) * 4 then 4 else 5 end) as 군
from gopa3 pa11
left join gopa9 pa13
  on  (pa11.STORECD = pa13.STORECD)
join LGMJVDP.TB_STORE_OP_DM  pa14
  on  (pa13.STORECD =  pa14.STORECD) 
  and pa14.OPEN_DT < ('2024-02-01')
  and pa14.CLOSE_DT is null
where pa13.WJXBFS2 > 0 and pa11.WJXBFS2 > 0
group by pa11.STORECD