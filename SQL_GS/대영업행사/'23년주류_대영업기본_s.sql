with     gopa1 as
 (select    a11.STORECD  STORECD,
        sum(case when a11.GOODCD in ('4901004057044', '4901004006813', '4901004006714', '4901777153325', '8801022023136', '8801022023037', '8809624620630', '8654000100417', '4002103003038', '4002103292876', '6901035628815', '8801021233642', '8801021233888', '8801021233987', '8801030949343', '8806142733620', '8809311393267', '8809556112593') then a11.NTSAL_AMT end) AS 행사상품_매출액,        sum(case when a11.GOODCD in ('5011007015534', '80432115114', '88352117942', '8806142716470', '5099873017623') then a11.NTSAL_AMT end) AS 양주_매출액
    from    LGMJVDP.TB_STK_MSG_AG    a11
        join    LGMJVDP.TB_STORE_DM    a12
          on     (a11.STORECD = a12.STORECD)
          and a12.OPENDT < ('2023-10-11')
    where    (a11.YMCD in ('202311','202312')
     and a11.GOODCD in ('8802340316818', '8802340306055', '8809899165058', '3262156120750', '3262151032751', '857641002654', '857641002142', '857641002890', '857674007886', '7804304002073', '3380820066767', '8032853722367', '9323956012240', '3326262251750', '7809579811870', '8420209036884', '7809604902962', '8802196004808', '8809041880242', '4022025370032', '8801048002436', '5010103913188', '5010103913225', '3175520018716', '3262151971753', '8809229011109', '8809664110443', '7804300136659', '8807225892586', '8807225892609', '8807225892616', '8802340315781', '5011007015534', '80432115114', '88352117942', '8806142716470', '5099873017623')
     and a12.RGNCD between ('41') and ('61')
     and a12.TEAMCD not in ('4208') )
    group by    a11.STORECD
    ), 
     gopa2 as
 (select    a11.STORECD  STORECD,
        sum(a11.SALDT_CNT)  영업일수
    from    LGMJVDP.TB_SALDT_MS_AG    a11
        join    LGMJVDP.TB_STORE_DM    a12
          on     (a11.STORECD = a12.STORECD)
          and a12.OPENDT < ('2023-10-11')
    where    (a11.YMCD in ('202311','202312')
     and a12.RGNCD between ('41') and ('61')
     and a12.TEAMCD not in ('4208') )
    group by    a11.STORECD
    )
select    distinct pa11.STORECD  STORECD,
    'V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1)  현재코드,
    SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 )  STORENM,
    a13.TEAM_LN  TEAM_LN,
    a13.PART_LN  PART_LN,
    a13.OPENDT  오픈일,
    pa11.년23차별화_매출액,
    pa11.차별화_매출액,
    pa11.와인_매출액,
    pa11.양주_매출액,
    pa12.영업일수
from    gopa1    pa11
    left outer join    gopa2    pa12
      on     (pa11.STORECD = pa12.STORECD)
    join    LGMJVDP.TB_STORE_DM    a13
      on     (pa11.STORECD = a13.STORECD 
      and     pa11.STORECD = a13.STORECD)






      --------------------   매출이익 포함


      with     gopa1 as
 (select    a11.STORECD  STORECD,
        sum(a11.SALPRF_AMT) AS 행사상품_매출이익,
        sum(case when a11.SALPRF_AMT > 0 then 1 else 0 end ) AS 상품취급
        from    LGMJVDP.TB_STK_MSG_AG    a11
        join    LGMJVDP.TB_STORE_DM    a12
        on     (a11.STORECD = a12.STORECD)
        and a12.OPENDT < ('2024-01-11')
        where    (a11.YMCD in ('202402','202403')
        and a11.GOODCD in ('8801062870585', '8801062628476', '8801062641826', '8801062641895', '8801062642021', '8801062860197', '8801062860159', '9556001216144', '9556001284358', '50426416', '3045140105502', '8804973308802', '8804973308789', '8801043067317', '6921211104292', '8801043068178', '9300682051507', '9300682053761', '4902750435230')
        and a12.RGNCD between ('41') and ('61'))
        group by    a11.STORECD
    ), 
     gopa2 as
 (select    a11.STORECD  STORECD,
        sum(a11.SALDT_CNT)  영업일수
    from    LGMJVDP.TB_SALDT_MS_AG    a11
        join    LGMJVDP.TB_STORE_DM    a12
          on     (a11.STORECD = a12.STORECD)
          and a12.OPENDT < ('2024-01-11')
    where    (a11.YMCD in ('202402','202403')
     and a12.RGNCD between ('41') and ('61'))
    group by    a11.STORECD
    )
select    distinct pa11.STORECD  STORECD,
    'V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1)  현재코드,
    SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 )  STORENM,
    a13.TEAM_LN  TEAM_LN,
    a13.PART_LN  PART_LN,
    a13.OPENDT  오픈일,
    pa11.행사상품_매출이익,
    pa11.상품취급,
    pa12.영업일수
from    gopa1    pa11
    left outer join    gopa2    pa12
      on     (pa11.STORECD = pa12.STORECD)
    join    LGMJVDP.TB_STORE_DM    a13
      on     (pa11.STORECD = a13.STORECD 
      and     pa11.STORECD = a13.STORECD)