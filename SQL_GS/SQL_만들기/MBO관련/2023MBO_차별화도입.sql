------------------- 점별 집계
--header는 상품 취급갯수 sale1은 일반상품 매출액

with header as (select	a11.STORECD  STORECD,
	--a11.GOODCD  GOODCD,
	--max(trim(trailing from a13.GOODNM))  GOODNM,
	sum(case when a11.STORE_CNT > 0 and a11.GOODCD in ('8801074008617', '8801392065026', '8809011835616', '8809083707330', '8809396242634', '8809056561518', '8809173676423', '8809027551005', '8691720013511', '8809693920068', '8801117472900', '8801206004494', '4004192004293', '8809900330222', '8809900330277') then 1 else 0 end) as  필수상품,
	sum(case when a11.STORE_CNT > 0 and a11.GOODCD in ('8809554253076', '8801045890333', '8809442490699') then 1 else 0 end) as  선택상품
from	LGMJVDP.TB_STK_MSG_AG	a11
	join	LGMJVDP.TB_STORE_DM	a12
	  on 	(a11.STORECD = a12.STORECD)
	join	LGMJVDP.TB_GOOD_DM	a13
	  on 	(a11.GOODCD = a13.GOODCD)
where	(a12.RGNCD in ('54')
 and a11.YMCD in to_char(sysdate, 'YYYYMM')
 and a11.GOODCD in ('8801074008617', '8801392065026', '8809011835616', '8809083707330', '8809396242634', '8809056561518', '8809173676423', '8809027551005', '8691720013511', '8809693920068', '8801117472900', '8801206004494', '4004192004293', '8809900330222', '8809900330277','8809554253076', '8801045890333', '8809442490699'))
group by	a11.STORECD

--전월 일반상품 매출 추출하기 
), sale1 as (
select a11.STORECD  STORECD,
a12.PART_LN,
a12.TEAM_LN,
a12.store_sz  store_sz0,
sum(a11.MBO6_NTSAL_AMT)  일반상품매출, 
sum(a11.SALDT_CNT) 영업일수
from LGMJVDP.TB_STORE_MS_AG a11
join LGMJVDP.TB_STORE_DM a12
  on  (a11.STORECD = a12.STORECD)
where (a12.RGNCD in ('54')
 and a11.YMCD in to_char(ADD_MONTHS(sysdate,-1),'YYYYMM'))
group by a11.STORECD,
a12.PART_LN,
a12.TEAM_LN,
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
where (a12.RGNCD in ('54')
 and a11.YMCD in to_char(sysdate, 'YYYYMM')
 and a11.GOODCD in ('8801074008617', '8801392065026', '8809011835616', '8809083707330', '8809396242634', '8809056561518', '8809173676423', '8809027551005', '8691720013511', '8809693920068', '8801117472900', '8801206004494', '4004192004293', '8809900330222', '8809900330277','8809554253076', '8801045890333', '8809442490699'))
group by a11.STORECD, a11.GOODCD 