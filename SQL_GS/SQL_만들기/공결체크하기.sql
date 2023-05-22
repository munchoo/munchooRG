select a11.OPER_DT,
          a11.ORIGIN_BIZPL_CD,  
          a12.STORENM, 
         row_number() over (partition by a11.ORIGIN_BIZPL_CD, a11.GOODS_CD order  by a11.OPER_DT  asc) as commu_OUTDAY, 
          a11.GOODS_SP,
          a11.GOODS_CD, 
          a13.GOODNM, 
          a11.GOODS_OPT_SP,
          a11.TARGET_GOODS_CNT,
          a11.OUTSTK_YN,
          a11.BIZPL_CD,
          a11.REGI_USER_ID,
          a11.REGI_DTTM,
          a11.FINAL_MOD_USER_ID,
          a11.FINAL_MOD_DTTM,
          a11.INSERT_DTTM
from   LGMJVDP.TS_OP_OUTSTK_SKU a11 
join LGMJVDP.TB_STORE_DM a12 
on trim(a11.BIZPL_CD) = 'V'||a12.STORECD  
join LGMJVDP.TB_GOOD_DM a13
on trim(a11.GOODS_CD) = a13.GOODCD
where a12.RGNCD in ('54') 
and a12.TEAMCD in ('5402') 
and OPER_DT between '20230501' and '20230530'
and a11.GOODS_CD is not null  
order by 4 desc