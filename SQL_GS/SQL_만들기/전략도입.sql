------------------- 점별 집계
--header는 상품 취급갯수 sale1은 일반상품 매출액

with header as (select	a11.STORECD  STORECD,
	--a11.GOODCD  GOODCD,
	--max(trim(trailing from a13.GOODNM))  GOODNM,
	sum(case when a11.STORE_CNT > 0 then 1 else 0 end) as  취급상품
from	LGMJVDP.TB_STK_MSG_AG	a11
	join	LGMJVDP.TB_STORE_DM	a12
	  on 	(a11.STORECD = a12.STORECD)
	join	LGMJVDP.TB_GOOD_DM	a13
	  on 	(a11.GOODCD = a13.GOODCD)
where	(a12.RGNCD in ('54')
 and a11.YMCD in to_char(sysdate, 'YYYYMM')
 and a11.GOODCD in ('8888021305470', '8888021305463', '8809121477935', '8808024030933', '8809046593666', '8808024030957', '8809184807700', '8801223011994', '8801223011987', '8801007966878', '8809251331954', '8809266251704', '8807203002273', '8807203002297', '8801019611186', '8801062866052', '8809827250658', '8801045479910', '8801045628400', '8801007985855', '미정'))
group by	a11.STORECD

--전월 일반상품 매출 추출하기 
), sale1 as (
select a11.STORECD  STORECD,
a12.store_sz  store_sz0,
sum(a11.MBO6_NTSAL_AMT)  일반상품매출, 
sum(a11.SALDT_CNT) 영업일수
from LGMJVDP.TB_STORE_MS_AG a11
join LGMJVDP.TB_STORE_DM a12
  on  (a11.STORECD = a12.STORECD)
where (a12.RGNCD in ('54')
 and a11.YMCD in to_char(ADD_MONTHS(sysdate,-1),'YYYYMM'))
group by a11.STORECD,

--점포사이즈 가져오기 가맹지원시스템과 연동되어 있음. (입력 후 D+1 반영)
a12.store_sz
)
select 
	a1.STORECD,
	a1.취급상품,
	a2.store_sz0,
	a2.일반상품매출,
	a2.영업일수
from header a1
join sale1 a2
on a1.STORECD = a2.STORECD

--------------------------상품조회

select a11.STORECD  STORECD,
a11.GOODCD  GOODCD,
max(trim(trailing from a13.GOODNM))  GOODNM,
case when sum(a11.STORE_CNT) > 0 then 1 else 0 end as 취급
from LGMJVDP.TB_STK_MSG_AG a11
join LGMJVDP.TB_STORE_DM a12
  on  (a11.STORECD = a12.STORECD)
join LGMJVDP.TB_GOOD_DM a13
  on  (a11.GOODCD = a13.GOODCD)
where (a12.RGNCD in ('54')
 and a11.YMCD in to_char(sysdate, 'YYYYMM')
 and a11.GOODCD in ('8888021305470', '8888021305463', '8809121477935', '8808024030933', '8809046593666', '8808024030957', '8809184807700', '8801223011994', '8801223011987', '8801007966878', '8809251331954', '8809266251704', '8807203002273', '8807203002297', '8801019611186', '8801062866052', '8809827250658', '8801045479910', '8801045628400', '8801007985855', '미정'))
group by a11.STORECD, 
a11.GOODCD 