select	a13.RGNCD  RGNCD,
	max(a13.RGNNM)  RGNNM,
	a13.TEAMCD  TEAMCD,
	max(a13.TEAM_LN)  TEAM_LN,
	max(a13.team_dist_seq)  team_dist_seq,
	a13.PARTCD  PARTCD,
	max(a13.PART_LN)  PART_LN,
	max(a13.part_dist_seq)  part_dist_seq,
	a11.STORECD  STORECD,
	max(SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 ))  STORENM,
	max('V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1))  CustCol_31,
	a12.GOOD_CLS1CD  GOOD_CLS1CD,
	max(a12.GOOD_CLS1NM)  GOOD_CLS1NM,
	a11.GOODCD  GOODCD,
	max(trim(trailing from a12.GOODNM))  GOODNM,
	max(a11.RCT_IN_DATECD)  WJXBFS1,
	sum(a11.CUR_STK_QTY)  WJXBFS2,
	max(a11.ORIGIN_VALID_DUR)  WJXBFS3,
	max(a11.VALID_DUR)  WJXBFS4
from	LGMJVDP.TB_STORE_RCT_IN_AG	a11
	join	LGMJVDP.TB_GOOD_DM	a12
	  on 	(a11.GOODCD = a12.GOODCD)
	join	LGMJVDP.TB_STORE_DM	a13
	  on 	(a11.STORECD = a13.STORECD)
where	(a12.GOOD_CLS1CD in ('08')
 and a13.RGNCD in ('54'))
group by	a13.RGNCD,
	a13.TEAMCD,
	a13.PARTCD,
	a11.STORECD,
	a12.GOOD_CLS1CD,
	a11.GOODCD

[분석엔진 계산 단계:
	1.  cross-tabbing 수행
]
