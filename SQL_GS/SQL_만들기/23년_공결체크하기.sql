with item_list as(
    select
    distinct(GOODS_CD)
    from   LGMJVDP.TS_OP_OUTSTK_SKU
    where OPER_DT between '20230601' and '20230630'
), order_DB as(
    select a11.STORECD  STORECD,
        a11.GOODCD GOODCD,
    sum(a11.ODR_QTY)  order_sum
    from LGMJVDP.TB_STK_FT a11
    join LGMJVDP.TB_STORE_DM a13
        on  (a11.STORECD = a13.STORECD)
    join item_list pa1
        on a11.GOODCD = pa1.GOODS_CD
    where (a11.DATECD in to_char(SYSDATE-1, 'YYYY-MM-DD')
        and a13.TEAMCD in ('5405'))
    group by a11.STORECD, a11.GOODCD
), stk_DB as(
    select a11.STORECD  STORECD,
        a13.PART_LN PART_LN,
        a13.STORENM,
        a11.GOODCD GOODCD,
        -- 발주수량을 d-1일만 되도록 수정해야함 0630
    sum(a11.PREV_QTY + a11.IN_QTY - a11.SAL_QTY)  stk_sum
    from LGMJVDP.TB_STK_FT a11
    join LGMJVDP.TB_STORE_DM a13
        on  (a11.STORECD = a13.STORECD)
    right join item_list pa1
        on a11.GOODCD = pa1.GOODS_CD
    where (a11.DATECD >= to_char(SYSDATE-2, 'YYYY-MM-DD')
        and a13.TEAMCD in ('5405'))    
    group by a11.STORECD,a13.PART_LN,a13.STORENM, a11.GOODCD
), Sale_DB as(
    select a11.STORECD  STORECD,
    a11.GOODCD GOODCD,
    max(a11.SAL_QTY)  sale_sum
    from LGMJVDP.TB_STK_FT a11
    join LGMJVDP.TB_STORE_DM a13
        on  (a11.STORECD = a13.STORECD)
    right join item_list pa1
        on a11.GOODCD = pa1.GOODS_CD
    where (a11.DATECD >= to_char(SYSDATE-14, 'YYYY-MM-DD')
        and a13.TEAMCD in ('5405'))    
    group by a11.STORECD, a11.GOODCD
)
select
    a11.STORECD,
    a11.PART_LN,
    a11.STORENM,
    a11.GOODCD,
    a14.GOODNM,
    coalesce(a11.stk_sum + a12.order_sum, 0) AS stk,
    coalesce(a13.sale_sum, 0) As Sale
from stk_DB a11
left outer join order_DB a12
    on a11.STORECD = a12.STORECD
    and a11.GOODCD = a12.GOODCD
left outer join Sale_DB a13
    on a11.STORECD = a13.STORECD
    and a11.GOODCD = a13.GOODCD
join LGMJVDP.TB_GOOD_DM a14
on a11.GOODCD = a14.GOODCD






--------공결대상상품의 전일자 발주 추출
with OrderItem as ( 
    select a11.STORECD  STORECD,
        to_char(a11.DATECD,'YYYYMMDD') DATECD,
        a11.GOODCD GOODCD,
    sum(a11.ODR_QTY)  order_sum,
    sum(a11.STK_QTY) STK_sum
    from LGMJVDP.TB_STK_FT a11
    join LGMJVDP.TB_STORE_DM a13
        on  (a11.STORECD = a13.STORECD)
    where (a11.DATECD in to_char(SYSDATE-1, 'YYYY-MM-DD')
        and a13.TEAMCD in ('5405'))
        and a11.GOODCD in (select
            distinct(GOODS_CD)
            from   LGMJVDP.TS_OP_OUTSTK_SKU
            where OPER_DT between '20230601' and '20230630') 
    group by a11.STORECD, to_char(a11.DATECD,'YYYYMMDD'), a11.GOODCD
    having  sum(a11.ODR_QTY) > 0
)
----Body 쿼리
select a11.OPER_DT,
    a11.ORIGIN_BIZPL_CD,  
    a12.PART_LN,
    a12.STORENM,
    -- 월 결품 일수를 row_number 함수로 만들기 주의** 점코드&상품코드를 그룹핑후 OPER_DT를 정렬시켜 row num 만들기
    row_number() over (partition by a11.ORIGIN_BIZPL_CD, a11.GOODS_CD order  by a11.OPER_DT  asc) as commu_OUTDAY, 
    a14.order_sum,
    a11.GOODS_SP,
    a11.GOODS_CD, 
    a13.GOODNM, 
    a11.GOODS_OPT_SP,
    a11.TARGET_GOODS_CNT,
    a11.OUTSTK_YN,
    a11.BIZPL_CD
from   LGMJVDP.TS_OP_OUTSTK_SKU a11 
join LGMJVDP.TB_STORE_DM a12 
on trim(a11.ORIGIN_BIZPL_CD) = 'V'||a12.STORECD  
join LGMJVDP.TB_GOOD_DM a13
on trim(a11.GOODS_CD) = a13.GOODCD
----  추출된발주수량을 left 조인
left join OrderItem a14
on trim(a11.ORIGIN_BIZPL_CD) = 'V'||a14.STORECD
and a11.OPER_DT = a14.DATECD
and a11.GOODS_CD = a14.GOODCD
----
where a12.RGNCD in ('54') 
and a12.TEAMCD in ('5405')
and a11.BIZPL_CD in ('V8S65')
and OPER_DT between '20230601' and '20230630'
and a11.GOODS_CD is not null  


------- 집계데이터 결품률 찾기 
select
    a11.OPER_DT,
    a11.ORIGIN_BIZPL_CD,   
    a12.PART_LN,
    a12.STORENM, 
    count(a11.GOODS_CD) OUTCNT,  
    a13.SAL_DT,
    a11.TARGET_GOODS_CNT TARGET_GOODS_CNT2,
    count(a11.GOODS_CD) / (      a13.SAL_DT    *     a11.TARGET_GOODS_CNT ) O_ratio
from   LGMJVDP.TS_OP_OUTSTK_SKU a11
right join LGMJVDP.TB_STORE_DM a12 
on trim(a11.ORIGIN_BIZPL_CD) = 'V'||a12.STORECD   
join (select
        DATECD,
        sum(SALDT_CNT) over (partition by STORECD) AS SAL_DT,
        STORECD
    from LGMJVDP.TB_SALDT_FT
    where DATECD between ('2023-06-01') and ('2023-06-30') and SALDT_CNT = 1 ) a13
on trim(a11.ORIGIN_BIZPL_CD) = 'V'||a13.STORECD
and a11.OPER_DT = to_char(a13.DATECD,'YYYYMMDD')
where a12.RGNCD in ('54') 
and a12.TEAMCD in ('5405') 
and OPER_DT between '20230601' and '20230630' 
group by
    a11.OPER_DT,
    a11.ORIGIN_BIZPL_CD,   
    a12.PART_LN,
    a12.STORENM, 
    a11.TARGET_GOODS_CNT,
    a13.SAL_DT
 order by 5 asc