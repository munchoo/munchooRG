
select a11.RBT_EVENT_YEAR,
        a11.RBT_EVENT_CD, 
        a12.EVENT_NM, 
        a11.GOODS_REGION_CD,
        a11.GOODS_CD,
        a11.BIZPL_CD,
        a11.ORD_DT,
        a11.ORD_QTY,
        a11.SUPP_QTY,
        a11.SUPP_AMT,
        a11.ADDT_SUPP_AMT,
        a11.EVENT_START_DT,
        a11.EVENT_END_DT,
        a11.ADDT_RBT_AMT,
        a11.PRVD_BASE_GOODS_CNT,
        a11.PRVD_BASE_QTY,
        a11.PRVD_RBT_AMT,
        a11.RBT_LIMT_AMT,
        a11.RBT_EVENT_GOODS_CNT,
        a11.INSERT_DTTM,
        a11.PRVD_BASE_COND_SP
from   LGMJVDP.TH_EV_RBT_EVENT_ACHV a11
join LGMJVDP.TH_EV_RBT_EVENT a12
    on a11.RBT_EVENT_CD = a12.RBT_EVENT_CD 
    and  a11.RBT_EVENT_YEAR = a12.RBT_EVENT_YEAR
    and a12.EVENT_NM not like ('%PX%')
    and a12.GOODS_REGION_CD in ('01')
where a11.BIZPL_CD in ('VEK99') 
and a11.RBT_EVENT_YEAR in ('2023') 
order by 5 desc 