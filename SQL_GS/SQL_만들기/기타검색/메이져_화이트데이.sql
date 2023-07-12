    select
        '봉제인형' as 분류,
        a11.STORECD  STORECD,
        max(SUBSTR(a14.STORENM,1,INSTR(a14.STORENM,'(')-1 ))  STORENM,
        max('V'||SUBSTR(a14.STORENM,INSTR(a14.STORENM,'(')+1, -( INSTR(a14.STORENM,'(') -INSTR(a14.STORENM,':'))-1))  CustCol_31,
        a12.YMCD 년도,
        a11.DATECD  DATECD,
        sum(a11.STK_AMT) 재고원가,
        sum(a11.STK_QTY) 재고수량,
        sum(a11.NTSAL_AMT)  매출액,
        sum(a11.SAL_QTY)  판매수량
        from    LGMJVDP.TB_STK_FT    a11
        join    LGMJVDP.TB_DATE_DM    a12
        on     (a11.DATECD = a12.DATECD)
        join    LGMJVDP.TB_GOOD_DM    a13
        on     (a11.GOODCD = a13.GOODCD)
        join    LGMJVDP.TB_STORE_DM    a14
        on     (a11.STORECD = a14.STORECD)
    where    (a12.DATECD BETWEEN ('2022-02-01') and ('2022-02-16')
    or a12.DATECD BETWEEN ('2023-02-01') and ('2023-02-16'))
    and a14.RGNCD in ('54')
    and (a13.GOOD_CLS3CD in ('52012102', '52012103', '52012104', '52012105', '52012106', '52014084', '56012159', '56012160', '56012161', '56012164', '56032166', '77032786')
        or a13.GOOD_CLS1CD in ('90'))
    group by    
    a11.STORECD,
    a12.YMCD,
    a11.DATECD

    union