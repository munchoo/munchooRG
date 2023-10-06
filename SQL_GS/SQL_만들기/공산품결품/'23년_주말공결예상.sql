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

--------새롭게 만든 공결 ^^^^^^ -------