

---- 최근 30일 기준으로 최소재고 산정하기
with Min_stk AS(select	a11.STORECD  STORECD,
	max(SUBSTR(a12.STORENM,1,INSTR(a12.STORENM,'(')-1 ))  STORENM,
	max('V'||SUBSTR(a12.STORENM,INSTR(a12.STORENM,'(')+1, -( INSTR(a12.STORENM,'(') -INSTR(a12.STORENM,':'))-1))  CustCol_31,
    a11.GOODCD GOODCD,
	min(case when a11.GOODCD in ('8801062623495') then 0 else a11.stk_qty end) Minstk
from	LGMJVDP.TB_STK_FT	a11
	join	LGMJVDP.TB_STORE_DM	a12
	  on 	(a11.STORECD = a12.STORECD)
where	(a11.GOODCD in ('88002798','8801062623495','8801069417165','8801115114031')
 and a11.DATECD between to_char(sysdate-31, 'YYYY-MM-DD') and to_char(sysdate-2, 'YYYY-MM-DD')
 and a12.TEAMCD in ('5405'))
group by	a11.STORECD, a11.GOODCD
),Cur_stk as(
    select	a11.STORECD  STORECD,
        a12.PART_LN,
        max(SUBSTR(a12.STORENM,1,INSTR(a12.STORENM,'(')-1 ))  STORENM,
        max('V'||SUBSTR(a12.STORENM,INSTR(a12.STORENM,'(')+1, -( INSTR(a12.STORENM,'(') -INSTR(a12.STORENM,':'))-1))  CustCol_31,
        a11.GOODCD GOODCD,
        a13.GOODNM,
        -- D-2~1 이월재고 + 입고수량 - 판매수량 + 전일자 발주수량으로 현재 재고 추정
        sum(a11.PREV_QTY + a11.IN_QTY - a11.SAL_QTY) + sum(case when a11.DATECD = to_char(sysdate-1,'YYYY-MM-DD') then a11.ODR_QTY else 0 end) 재고수량
    from	LGMJVDP.TB_STK_FT	a11
        join	LGMJVDP.TB_STORE_DM	a12
        on 	(a11.STORECD = a12.STORECD)
        join LGMJVDP.TB_GOOD_DM a13
        on (a11.GOODCD = a13.GOODCD)
    where	(a11.GOODCD in ('88002798','8801062623495','8801069417165','8801115114031')
    and a11.DATECD between to_char(sysdate-2, 'YYYY-MM-DD') and to_char(sysdate-1, 'YYYY-MM-DD')
    and a12.TEAMCD in ('5405'))
    group by a12.PART_LN, a11.STORECD, a11.GOODCD, a13.GOODNM
), Safe_stk as(
        select
        a11.GOODCD,
        case when a11.GOODCD in ('88002798') then 6
            when a11.GOODCD in ('8801062623495') then 10
            when a11.GOODCD in ('8801069417165') then 3
            when a11.GOODCD in ('8801115114031') then 3 else 0 end as SafeSTK
        from LGMJVDP.TB_GOOD_DM a11
        where	a11.GOODCD in ('88002798','8801062623495','8801069417165','8801115114031')
), OFC_mail as (
    select
        a11.PART_LN,
        a12.EMAIL_ADDR
    from LGMJVDP.TB_STORE_DM a11
    join LGMJVDP.TB_INSA_BASIC_SMS a12
    on a11.PART_LN = a12.USER_NM
    where a11.TEAMCD in ('5405')
    group by a11.PART_LN, a12.EMAIL_ADDR
)
select
    pa1.PART_LN,
    pa4.EMAIL_ADDR,
    pa1.STORECD,
    pa1.STORENM,
    pa1.CustCol_31 STORECD_P,
    pa1.GOODCD,
    pa1.GOODNM,
    pa1.재고수량,
    pa3.SafeSTK,
    pa2.Minstk
from Cur_stk pa1
join Min_stk pa2
on pa1.STORECD = pa2.STORECD
and pa1.GOODCD = pa2.GOODCD
join Safe_stk pa3
on pa1.GOODCD = pa3.GOODCD
join OFC_mail pa4
on pa1.PART_LN = pa4.PART_LN