select  a11.RBT_EVENT_YEAR,
        a11.RBT_EVENT_CD,
        a11.GOODS_REGION_CD,
        a11.GOODS_CD,
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
from   LGMJVDP.TH_EV_RBT_EVENT_GOODS  a11
join  LGMJVDP.TB_GOOD_DM a12
where EVENT_END_DT like ('2023-08'||'%')