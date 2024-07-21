with 상품발주수량 as (
    select a11.STORECD,
           a11.GOODCD,
           sum(a11.ODR_QTY) as 발주수량
    from LGMJVDP.TB_STK_FT a11
    join LGMJVDP.TB_STORE_DM a12 on a11.STORECD = a12.STORECD
    where (
        (a11.DATECD between '2024-06-17' and '2024-06-30' and a11.GOODCD in ('8809718540141', '8809718540165', '8809741171831', '8809741171893', '8809741171817', '8809741171978', '8809741171442', '8809741171466', '8809741171619', '8809741171329', '8809741171596', '8809706306193', '8809706306209'))
        or
        (a11.DATECD between '2024-07-01' and '2024-07-31' and a11.GOODCD in ('8809718540141', '8809718540165', '8809741171831', '8809741171893', '8809741171817', '8809741171978', '8809741171442', '8809741171466', '8809741171619', '8809741171329', '8809741171596', '8809706306193', '8809706306209', '8809793600341', '8809793600310', '8809793600426', '8809793600396'))
    )
      and a12.RGNCD between '41' and '64'
    group by a11.STORECD, a11.GOODCD
), 취급상품수량 as (
    select a11.STORECD,
        COUNT(DISTINCT CASE WHEN a11.STK_QTY > 0 THEN a11.GOODCD ELSE NULL END) AS 취급상품수
    from LGMJVDP.TB_STK_FT a11
    join LGMJVDP.TB_STORE_DM a12 on a11.STORECD = a12.STORECD
    where 
        a11.DATECD between '2024-06-17' and '2024-06-30' 
        and a11.GOODCD in ('8809718540141', '8809718540165', '8809741171831', '8809741171893', '8809741171817', '8809741171978', '8809741171442', '8809741171466', '8809741171619', '8809741171329', '8809741171596', '8809706306193', '8809706306209', '8809793600341', '8809793600310', '8809793600426', '8809793600396')
        and a12.RGNCD between '41' and '64'
    group by a11.STORECD
    order by a11.STORECD
), 광고비계산 as (
    select STORECD,
           sum(case 
               when GOODCD in ('8809718540141', '8809718540165', '8809741171831', '8809741171893', '8809741171817', '8809741171978') and 발주수량 >= 4 then 5000
               when GOODCD in ('8809741171442', '8809741171466', '8809741171619', '8809741171329', '8809741171596') and 발주수량 >= 4 then 6000
               when GOODCD in ('8809706306193', '8809706306209') and 발주수량 >= 4 then 4000
               when GOODCD in ('8809793600341', '8809793600310', '8809793600426', '8809793600396') and 발주수량 >= 8 then 16000
               when GOODCD in ('8809793600341', '8809793600310', '8809793600426', '8809793600396') and 발주수량 >= 4 then 8000
               else 0 end) +
               case
               when count(distinct case when GOODCD in ('8809793600341', '8809793600310', '8809793600426', '8809793600396') and 발주수량 >= 4 then GOODCD end) = 4 then 8000
               when count(distinct case when GOODCD in ('8809706306209', '8809706306193') and 발주수량 >= 4 then GOODCD end) = 2 then 2000
            else 0 end as 광고비
    from 상품발주수량
    group by STORECD
)
select a13.STORECD as 최초코드,
       SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 ) as 매장명,
       max(a12.취급상품수) as 취급상품수,
       sum(a14.광고비) as 총광고비
from 취급상품수량 a12
join LGMJVDP.TB_STORE_DM a13 on a12.STORECD = a13.STORECD
join 광고비계산 a14 on a12.STORECD = a14.STORECD
group by a13.STORECD, a13.STORENM












-- 전년 대/중분류 일매출 추출을 위해 영업일수와 총매출을 추출하기
with gopa1 as (
    select a11.STORECD,
           sum(a11.NTSAL_AMT) as WJXBFS1
    from LGMJVDP.TB_STK_MSG1_AG a11
    join LGMJVDP.TB_GOOD_CLS1_DM a13 on a11.GOOD_CLS1CD = a13.GOOD_CLS1CD
    join LGMJVDP.TB_STORE_DM a14 on a11.STORECD = a14.STORECD
    where a13.GOOD_CLS1CD in ('65')
      and a14.RGNCD between '41' and '64'
      and a11.YMCD = '202307'
    group by a11.STORECD
),
gopa2 as (
    select a11.STORECD,
           sum(a11.SALDT_CNT) as WJXBFS1
    from LGMJVDP.TB_SALDT_MS_AG a11
    join LGMJVDP.TB_STORE_DM a13 on a11.STORECD = a13.STORECD
    where a13.RGNCD between '41' and '64'
      and a11.YMCD = '202307'
    group by a11.STORECD
),
gopa3 as (
    select coalesce(pa11.STORECD, pa12.STORECD) as STORECD,
           pa11.WJXBFS1 as 전년매출액,
           pa12.WJXBFS1 as 전년영업일수
    from gopa1 pa11
    full outer join gopa2 pa12 on pa11.STORECD = pa12.STORECD
),

-- 전월 대/중분류 일매출 추출을 위해 영업일수와 총매출을 추출하기
gopa4 as (
    select a11.STORECD,
           sum(a11.SALDT_CNT) as WJXBFS1
    from LGMJVDP.TB_SALDT_MS_AG a11
    join LGMJVDP.TB_STORE_DM a12 on a11.STORECD = a12.STORECD
    where a11.YMCD = '202407'
      and a12.RGNCD between '41' and '64'
    group by a11.STORECD
),
gopa5 as (
    select a11.STORECD,
           sum(a11.NTSAL_AMT) as WJXBFS1
    from LGMJVDP.TB_STK_MSG2_AG a11
    join LGMJVDP.TB_GOOD_CLS2_DM a12 on a11.GOOD_CLS2CD = a12.GOOD_CLS2CD
    join LGMJVDP.TB_STORE_DM a13 on a11.STORECD = a13.STORECD
    where a11.YMCD = '202407'
      and a12.GOOD_CLS1CD in ('65')
      and a13.RGNCD between '41' and '64'
    group by a11.STORECD
),
gopa6 as (
    select coalesce(pa11.STORECD, pa12.STORECD) as STORECD,
           pa11.WJXBFS1 as 영업일수,
           pa12.WJXBFS1 as 매출액
    from gopa4 pa11
    full outer join gopa5 pa12 on pa11.STORECD = pa12.STORECD
),

-- 군자료에서의 영업일수
GunOpenDt as (
    select a11.STORECD,
           sum(a11.SALDT_CNT) as WJXBFS1
    from LGMJVDP.TB_SALDT_MS_AG a11
    join LGMJVDP.TB_STORE_DM a12 on a11.STORECD = a12.STORECD
    where a11.YMCD = '202406'
      and a12.RGNCD between '41' and '64'
    group by a11.STORECD
),

-- 군자료에서의 매출액
GunSale as (
    select a11.STORECD,
           sum(a11.NTSAL_AMT) as WJXBFS1
    from LGMJVDP.TB_STK_MSG2_AG a11
    join LGMJVDP.TB_GOOD_CLS2_DM a12 on a11.GOOD_CLS2CD = a12.GOOD_CLS2CD
    join LGMJVDP.TB_STORE_DM a13 on a11.STORECD = a13.STORECD
    where a11.YMCD = '202406'
      and a12.GOOD_CLS1CD in ('65')
      and a13.RGNCD between '41' and '64'
    group by a11.STORECD
),
gopa9 as (
    select coalesce(pa11.STORECD, pa12.STORECD) as STORECD,
           pa11.WJXBFS1 as 군영업일수,
           pa12.WJXBFS1 as 군매출액,
           pa12.WJXBFS1 / decode(pa11.WJXBFS1, 0, null, pa11.WJXBFS1) as 군일매출,
           row_number() over (order by pa12.WJXBFS1 / decode(pa11.WJXBFS1, 0, null, pa11.WJXBFS1) desc) as 순위,
           count(*) over () as Fullcount,
           pa13.OPEN_DT
    from GunOpenDt pa11
    join GunSale pa12 on pa11.STORECD = pa12.STORECD
    join LGMJVDP.TB_STORE_OP_DM pa13 on pa11.STORECD = pa13.STORECD
    where pa11.WJXBFS1 > 0 and pa12.WJXBFS1 > 0
)

select trim(coalesce(pa11.STORECD, pa12.STORECD, pa13.STORECD)) as STORECD,
       SUBSTR(a13.STORENM, 1, INSTR(a13.STORENM, '(') - 1) as STORENM,
       a13.TEAM_LN,
       a13.PART_LN,
       pa13.전년매출액,
       pa13.전년영업일수,
       pa12.영업일수,
       pa12.매출액,
       pa11.군영업일수,
       pa11.군매출액,
       pa11.군일매출,
       pa11.순위,
       pa14.CLOSE_DT,
       case when pa11.순위 < (pa11.Fullcount / 10) then 1
            when pa11.순위 < (pa11.Fullcount / 10) * 2 then 2
            when pa11.순위 < (pa11.Fullcount / 10) * 3 then 3
            when pa11.순위 < (pa11.Fullcount / 10) * 4 then 4
            when pa11.순위 < (pa11.Fullcount / 10) * 5 then 5
            when pa11.순위 < (pa11.Fullcount / 10) * 6 then 6
            when pa11.순위 < (pa11.Fullcount / 10) * 7 then 7
            when pa11.순위 < (pa11.Fullcount / 10) * 8 then 8
            when pa11.순위 < (pa11.Fullcount / 10) * 9 then 9
            else 10 end as 군
from gopa9 pa11
left join gopa6 pa12 on pa11.STORECD = pa12.STORECD
left join gopa3 pa13 on coalesce(pa11.STORECD, pa12.STORECD) = pa13.STORECD
join LGMJVDP.TB_STORE_OP_DM pa14 on coalesce(pa11.STORECD, pa12.STORECD, pa13.STORECD) = pa14.STORECD
join LGMJVDP.TB_STORE_DM a13 on coalesce(pa11.STORECD, pa12.STORECD, pa13.STORECD) = a13.STORECD
where pa11.군영업일수 > 0 and pa11.군매출액 > 0
  and a13.PART_LN in ('김영남')
  and pa14.OPEN_DT < '2024-06-01'
  and pa14.CLOSE_DT is null 
  and a13.OPENDT < '2024-06-11' 
order by STORECD;