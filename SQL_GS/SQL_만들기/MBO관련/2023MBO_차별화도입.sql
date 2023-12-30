------------------- 점별 집계
--header는 상품 취급갯수 sale1은 일반상품 매출액

with header as (select	a11.STORECD  STORECD,
	--a11.GOODCD  GOODCD,
	--max(trim(trailing from a13.GOODNM))  GOODNM,
	sum(case when a11.STORE_CNT > 0 and a11.GOODCD in ('8809443710369', '8809258273714', '8809109112919', '8809695252594', '8801019611971', '8801308480028', '6971258740618', '8809898131344', '8809704426831', '8801117112905', '8809402815104', '8801206004685', '8801155743741', '8809762121518') then 1 else 0 end) as  필수상품,
	sum(case when a11.STORE_CNT > 0 and a11.GOODCD in ('8803051881602', '8809267021016', '8801019611988', '8801045890333') then 1 else 0 end) as  선택상품
from	LGMJVDP.TB_STK_MSG_AG	a11
	join	LGMJVDP.TB_STORE_DM	a12
	  on 	(a11.STORECD = a12.STORECD)
	join	LGMJVDP.TB_GOOD_DM	a13
	  on 	(a11.GOODCD = a13.GOODCD)
where	(a12.RGNCD in ('56')
 and a11.YMCD in to_char(sysdate, 'YYYYMM')
 and a11.GOODCD in ('8809443710369', '8809258273714', '8809109112919', '8809695252594', '8801019611971', '8801308480028', '6971258740618', '8809898131344', '8809704426831', '8801117112905', '8809402815104', '8801206004685', '8801155743741', '8809762121518','8803051881602', '8809267021016', '8801019611988', '8801045890333'))
group by	a11.STORECD

--전월 일반상품 매출 추출하기 
), sale1 as (
select a11.STORECD  STORECD,
a12.PART_LN,
a12.STORENM,
a12.TEAM_LN,
a12.store_sz  store_sz0,
sum(a11.MBO6_NTSAL_AMT)  일반상품매출, 
sum(a11.SALDT_CNT) 영업일수
from LGMJVDP.TB_STORE_MS_AG a11
join LGMJVDP.TB_STORE_DM a12
  on  (a11.STORECD = a12.STORECD)
where (a12.RGNCD in ('56')
 and a11.YMCD in to_char(ADD_MONTHS(sysdate,-1),'YYYYMM'))
group by a11.STORECD,
a12.PART_LN,
a12.TEAM_LN,
a12.STORENM,
--점포사이즈 가져오기 가맹지원시스템과 연동되어 있음. (입력 후 D+1 반영)
a12.store_sz
)
select 
	a2.STORECD,
	a2.PART_LN,
	a2.TEAM_LN,
	decode(a1.필수상품, null, 0, a1.필수상품) as 필수상품,
	decode(a1.선택상품, null, 0, a1.선택상품) as 선택상품,
	a2.store_sz0,
	a2.일반상품매출,
	a2.영업일수
from header a1
right join sale1 a2
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
where (a12.RGNCD in ('56')
 and a11.YMCD in to_char(sysdate, 'YYYYMM')
 and a11.GOODCD in ('8809443710369', '8809258273714', '8809109112919', '8809695252594', '8801019611971', '8801308480028', '6971258740618', '8809898131344', '8809704426831', '8801117112905', '8809402815104', '8801206004685', '8801155743741', '8809762121518','8803051881602', '8809267021016', '8801019611988', '8801045890333'))
group by a11.STORECD, a11.GOODCD 