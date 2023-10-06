select  a11.RBT_EVENT_YEAR,
        a11.RBT_EVENT_CD,
        a11.GOODS_REGION_CD,
        a14.EVENT_NM,
        a14.EVENT_PRVD_BASE_ARTIC,
        a14.DEL_STAT,
        a11.GOODS_CD, 
        a12.GOODNM, 
        a11.EVENT_START_DT,
        a11.EVENT_END_DT,
        a11.PRVD_BASE_QTY,
        a11.PRVD_RBT_AMT,
        a11.NOT_ACHVM_RBT_AMT,
        a11.RBT_LIMT_AMT,
        a11.REGI_USER_ID,
        a11.REGI_DTTM,
        a11.FINAL_MOD_USER_ID,
        a11.FINAL_MOD_DTTM,
        a11.INSERT_DTTM,
        a11.PRVD_BASE_COND_SP
from   LGMJVDP.TH_EV_RBT_EVENT_GOODS a11
left join LGMJVDP.TH_EV_RBT_EVENT a14
on a11.RBT_EVENT_CD = a14.RBT_EVENT_CD
and a11.RBT_EVENT_YEAR = a14.RBT_EVENT_YEAR
and a11.GOODS_REGION_CD = a14.GOODS_REGION_CD  
left join LGMJVDP.TB_GOOD_DM a12 
on a11.GOODS_CD = a12.GOODCD
left join LGMJVDP.TB_GOOD a13 
on a11.GOODS_CD = a13.GOODCD 
and a13.RGNCD in ('54') 
and a13.STATUSCD not in ('L') 
where a11.GOODS_REGION_CD in ('02')  
and a11.EVENT_END_DT like ('2023-08'||'%') 
order by 7
