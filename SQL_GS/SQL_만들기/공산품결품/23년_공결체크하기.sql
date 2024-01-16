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
    where a11.DATECD in to_char(SYSDATE-1, 'YYYY-MM-DD')
        and a13.TEAMCD in ('5601','5602','5603','5604', '5605','5606','5607','5608') 
        and a11.GOODCD in (select
            distinct(GOODS_CD)
            from   LGMJVDP.TS_OP_OUTSTK_SKU
            where OPER_DT in to_char(SYSDATE-1,'YYYYMMDD'))
    group by a11.STORECD, to_char(a11.DATECD,'YYYYMMDD'), a11.GOODCD
    having  sum(a11.ODR_QTY) > 0
)
----Body 쿼리
select a11.OPER_DT,
    a11.ORIGIN_BIZPL_CD,  
    a12.TEAM_LN,
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
from   LGMJVDP.TS_OP_OUTSTK_SKU a11 TS_OP_OUTSTK
join LGMJVDP.TB_STORE_DM a12 
on trim(a11.ORIGIN_BIZPL_CD) = 'V'||a12.STORECD  
left join LGMJVDP.TB_GOOD_DM a13
on trim(a11.GOODS_CD) = a13.GOODCD
----  추출된발주수량을 left 조인
left join OrderItem a14
on trim(a11.ORIGIN_BIZPL_CD) = 'V'||a14.STORECD
and a11.OPER_DT = a14.DATECD
and a11.GOODS_CD = a14.GOODCD
----
where a12.TEAMCD in ('5601','5602','5603','5604', '5605','5606','5607','5608') 
and OPER_DT like to_char(SYSDATE,'YYYYMM')||'%' 

  


------- 집계데이터 결품률 찾기 
select
    a11.OPER_DT,
    a11.ORIGIN_BIZPL_CD,
    count(a11.GOODS_CD) OUTCNT,
    a13.SAL_DT,
    a11.TARGET_GOODS_CNT TARGET_GOODS_CNT2,
    count(a11.GOODS_CD) / ( a13.SAL_DT  * a11.TARGET_GOODS_CNT ) O_ratio
from   LGMJVDP.TS_OP_OUTSTK_SKU a11
right join LGMJVDP.TB_STORE_DM a12 
on trim(a11.ORIGIN_BIZPL_CD) = 'V'||a12.STORECD   
join (select
        DATECD,
        SALDT_CNT AS SAL_DT,
        STORECD
    from LGMJVDP.TB_SALDT_FT
    where DATECD like (to_char(SYSDATE, 'YYYY-MM') || '%') and SALDT_CNT = 1 ) a13
on trim(a11.ORIGIN_BIZPL_CD) = 'V'||a13.STORECD
and a11.OPER_DT = to_char(a13.DATECD,'YYYYMMDD')
where a12.TEAMCD in ('5601','5602','5603','5604', '5605','5606','5607','5608') 
and OPER_DT like (to_char(SYSDATE, 'YYYYMM') || '%')
group by
    a11.OPER_DT,
    a11.ORIGIN_BIZPL_CD,   
    a11.TARGET_GOODS_CNT,
    a13.SAL_DT
