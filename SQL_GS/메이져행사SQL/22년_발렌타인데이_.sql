

    select	
        a13.RGNNM,
        a11.GOODCD  GOODCD,
        sum(a11.NTSAL_AMT)  매출액,
        sum(a11.SAL_QTY)  판매수량,
		sum(a11.stk_qty)  재고수량
        from	LGMJVDP.TB_STK_FT	a11
            join	LGMJVDP.TB_GOOD_DM	a12
            on 	(a11.GOODCD = a12.GOODCD)
            join	LGMJVDP.TB_STORE_DM	a13
            on 	(a11.STORECD = a13.STORECD)
        where	a11.DATECD between '2022-02-01' and '2022-02-14'
        and a13.RGNCD in ('54')
        and a12.GOOD_CLS3CD in ('56012161')
        group by	a13.RGNNM,
            a11.GOODCD


/*-------------------------------------------------------------------*/

   
    select	
        '판' as Name,
        a11.DATECD,
        a13.RGNNM,
        -- max(SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 ))  STORENM,
        -- max('V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1))  CustCol_31,
        a11.GOODCD  GOODCD,
        max(trim(trailing from a12.GOODNM))  GOODNM,
        a12.GOOD_CLS1CD  GOOD_CLS1CD,
        max(a12.GOOD_CLS1NM)  GOOD_CLS1NM,
        a12.GOOD_CLS2CD  GOOD_CLS2CD,
        max(a12.GOOD_CLS2NM)  GOOD_CLS2NM,
        a12.GOOD_CLS3CD  GOOD_CLS3CD,
        max(a12.GOOD_CLS3NM)  GOOD_CLS3NM,
        sum(a11.NTSAL_AMT)  매출액,
        sum(a11.SAL_QTY)  판매수량,
		sum(a11.stk_qty)  재고수량
        from	LGMJVDP.TB_STK_FT	a11
            join	LGMJVDP.TB_GOOD_DM	a12
            on 	(a11.GOODCD = a12.GOODCD)
            join	LGMJVDP.TB_STORE_DM	a13
            on 	(a11.STORECD = a13.STORECD)
        where	a11.DATECD between '2022-02-01' and '2022-02-14'
        and a13.RGNCD between ('41') and ('60')
        and a12.GOOD_CLS3CD in ('56012161')
        group by	a13.RGNNM,
            a11.DATECD,
            a11.GOODCD,
            a12.GOOD_CLS1CD,
            a12.GOOD_CLS2CD,
            a12.GOOD_CLS3CD


    Union
    select
        '바' as Name,
        a11.DATECD,
        a13.RGNNM,
        -- max(SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 ))  STORENM,
        -- max('V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1))  CustCol_31,
        a11.GOODCD  GOODCD,
        max(trim(trailing from a12.GOODNM))  GOODNM,
        a12.GOOD_CLS1CD  GOOD_CLS1CD,
        max(a12.GOOD_CLS1NM)  GOOD_CLS1NM,
        a12.GOOD_CLS2CD  GOOD_CLS2CD,
        max(a12.GOOD_CLS2NM)  GOOD_CLS2NM,
        a12.GOOD_CLS3CD  GOOD_CLS3CD,
        max(a12.GOOD_CLS3NM)  GOOD_CLS3NM,
        sum(a11.NTSAL_AMT)  매출액,
        sum(a11.SAL_QTY)  판매수량,
		sum(a11.stk_qty)  재고수량
        from	LGMJVDP.TB_STK_FT	a11
            join	LGMJVDP.TB_GOOD_DM	a12
            on 	(a11.GOODCD = a12.GOODCD)
            join	LGMJVDP.TB_STORE_DM	a13
            on 	(a11.STORECD = a13.STORECD)
        where	a11.DATECD between '2022-02-01' and '2022-02-14'
        and a13.RGNCD between ('41') and ('60')
        and a12.GOOD_CLS3CD in ('56012160')
        group by a13.RGNNM,
            a11.DATECD,
            a11.GOODCD,
            a12.GOOD_CLS1CD,
            a12.GOOD_CLS2CD,
            a12.GOOD_CLS3CD
    Union
        select        
        '쉘' as Name,
        a11.DATECD,
        a13.RGNNM,
        -- max(SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 ))  STORENM,
        -- max('V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1))  CustCol_31,
        a11.GOODCD  GOODCD,
        max(trim(trailing from a12.GOODNM))  GOODNM,
        a12.GOOD_CLS1CD  GOOD_CLS1CD,
        max(a12.GOOD_CLS1NM)  GOOD_CLS1NM,
        a12.GOOD_CLS2CD  GOOD_CLS2CD,
        max(a12.GOOD_CLS2NM)  GOOD_CLS2NM,
        a12.GOOD_CLS3CD  GOOD_CLS3CD,
        max(a12.GOOD_CLS3NM)  GOOD_CLS3NM,
        sum(a11.NTSAL_AMT)  매출액,
        sum(a11.SAL_QTY)  판매수량,
		sum(a11.stk_qty)  재고수량
        from	LGMJVDP.TB_STK_FT	a11
            join	LGMJVDP.TB_GOOD_DM	a12
            on 	(a11.GOODCD = a12.GOODCD)
            join	LGMJVDP.TB_STORE_DM	a13
            on 	(a11.STORECD = a13.STORECD)
        where	a11.DATECD between '2022-02-01' and '2022-02-14'
        and a13.RGNCD between ('41') and ('60')
        and a12.GOOD_CLS3CD in ('56012159')
        group by a13.RGNNM,
        a11.DATECD,
            a11.GOODCD,
            a12.GOOD_CLS1CD,
            a12.GOOD_CLS2CD,
            a12.GOOD_CLS3CD
    Union
        select        
        '세트' as Name,
        a11.DATECD,
        a13.RGNNM,
        -- max(SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 ))  STORENM,
        -- max('V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1))  CustCol_31,
        a11.GOODCD  GOODCD,
        max(trim(trailing from a12.GOODNM))  GOODNM,
        a12.GOOD_CLS1CD  GOOD_CLS1CD,
        max(a12.GOOD_CLS1NM)  GOOD_CLS1NM,
        a12.GOOD_CLS2CD  GOOD_CLS2CD,
        max(a12.GOOD_CLS2NM)  GOOD_CLS2NM,
        a12.GOOD_CLS3CD  GOOD_CLS3CD,
        max(a12.GOOD_CLS3NM)  GOOD_CLS3NM,
        sum(a11.NTSAL_AMT)  매출액,
        sum(a11.SAL_QTY)  판매수량,
		sum(a11.stk_qty)  재고수량
        from	LGMJVDP.TB_STK_FT	a11
            join	LGMJVDP.TB_GOOD_DM	a12
            on 	(a11.GOODCD = a12.GOODCD)
            join	LGMJVDP.TB_STORE_DM	a13
            on 	(a11.STORECD = a13.STORECD)
        where	a11.DATECD between '2022-02-01' and '2022-02-14'
        and a13.RGNCD between ('41') and ('60')
        and (a12.GOOD_CLS3CD in ('56012164','56032166') or a11.GOODCD in ('032134811306','8809678520863','8437000014218','8809318027264','8809318027295','8809318027356','3435070024705','3435079014875','3435070015024','5601069112595','8809389601639','8809649053895','8809389602070','9555030108765','8809318026885','8809286494365','8718469320950','8809678521440','8809678521464','4037719657290','9555030108505','4000512992509','8801062334100','6942836711054','6942836712839','8801062334087','8804973306471','8804973306488','8809744800097','8809290406804','8801906169196','3481291016258','3481291016265','3481291016272'))
            group by a13.RGNNM,
            a11.DATECD,
            a11.GOODCD,
            a12.GOOD_CLS1CD,
            a12.GOOD_CLS2CD,
            a12.GOOD_CLS3CD    
    Union
        select        
        '봉제인형' as Name,
        a11.DATECD,
        a13.RGNNM,
        -- max(SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 ))  STORENM,
        -- max('V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1))  CustCol_31,
        a11.GOODCD  GOODCD,
        max(trim(trailing from a12.GOODNM))  GOODNM,
        a12.GOOD_CLS1CD  GOOD_CLS1CD,
        max(a12.GOOD_CLS1NM)  GOOD_CLS1NM,
        a12.GOOD_CLS2CD  GOOD_CLS2CD,
        max(a12.GOOD_CLS2NM)  GOOD_CLS2NM,
        a12.GOOD_CLS3CD  GOOD_CLS3CD,
        max(a12.GOOD_CLS3NM)  GOOD_CLS3NM,
        sum(a11.NTSAL_AMT)  매출액,
        sum(a11.SAL_QTY)  판매수량,
		sum(a11.stk_qty)  재고수량
        from	LGMJVDP.TB_STK_FT	a11
            join	LGMJVDP.TB_GOOD_DM	a12
            on 	(a11.GOODCD = a12.GOODCD)
            join	LGMJVDP.TB_STORE_DM	a13
            on 	(a11.STORECD = a13.STORECD)
        where	a11.DATECD between '2022-02-01' and '2022-02-14'
        and a13.RGNCD between ('41') and ('60')
        and a12.GOOD_CLS3CD in ('77032786')
            group by a13.RGNNM,
            a11.DATECD,
            a11.GOODCD,
            a12.GOOD_CLS1CD,
            a12.GOOD_CLS2CD,
            a12.GOOD_CLS3CD    
    Union
        select        
        '완구' as Name,
        a11.DATECD,
        a13.RGNNM,
        -- max(SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 ))  STORENM,
        -- max('V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1))  CustCol_31,
        a11.GOODCD  GOODCD,
        max(trim(trailing from a12.GOODNM))  GOODNM,
        a12.GOOD_CLS1CD  GOOD_CLS1CD,
        max(a12.GOOD_CLS1NM)  GOOD_CLS1NM,
        a12.GOOD_CLS2CD  GOOD_CLS2CD,
        max(a12.GOOD_CLS2NM)  GOOD_CLS2NM,
        a12.GOOD_CLS3CD  GOOD_CLS3CD,
        max(a12.GOOD_CLS3NM)  GOOD_CLS3NM,
        sum(a11.NTSAL_AMT)  매출액,
        sum(a11.SAL_QTY)  판매수량,
		sum(a11.stk_qty)  재고수량
        from	LGMJVDP.TB_STK_FT	a11
            join	LGMJVDP.TB_GOOD_DM	a12
            on 	(a11.GOODCD = a12.GOODCD)
            join	LGMJVDP.TB_STORE_DM	a13
            on 	(a11.STORECD = a13.STORECD)
        where	a11.DATECD between '2022-02-01' and '2022-02-14'
        and a13.RGNCD between ('41') and ('60')
        and a11.GOODCD in ('8809297198016','8809297198122','8809297198139','8809297198146','8809297198153','8809297198160','8809297198023','8809297198177','8809297198184','8809297198191','8809297198207','8809297198214','8809297198030','8809297198221','8809297198238','8809297198245','8809297198252','8809297198047','8809297198269','8809297198276','8809297198054','8809297198283','8809297198290','8809297198061','8809297198306','8809297198313','8809297198320','8809297198009','8809297198078','8809297198344','8809297198085','8809297198092','8809297198108','8809297198115','8809311977528','8809311977535','8809311974138','8809311974145','8809297198375','8809297198368','8809347870527','8809337630025','8809347870237','8809347870213','8809177894014','8809282300066')
            group by a13.RGNNM,
            a11.DATECD,
            a11.GOODCD,
            a12.GOOD_CLS1CD,
            a12.GOOD_CLS2CD,
            a12.GOOD_CLS3CD    
    Union
        select        
        '와인' as Name,
        a11.DATECD,
        a13.RGNNM,
        -- max(SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 ))  STORENM,
        -- max('V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1))  CustCol_31,
        a11.GOODCD  GOODCD,
        max(trim(trailing from a12.GOODNM))  GOODNM,
        a12.GOOD_CLS1CD  GOOD_CLS1CD,
        max(a12.GOOD_CLS1NM)  GOOD_CLS1NM,
        a12.GOOD_CLS2CD  GOOD_CLS2CD,
        max(a12.GOOD_CLS2NM)  GOOD_CLS2NM,
        a12.GOOD_CLS3CD  GOOD_CLS3CD,
        max(a12.GOOD_CLS3NM)  GOOD_CLS3NM,
        sum(a11.NTSAL_AMT)  매출액,
        sum(a11.SAL_QTY)  판매수량,
		sum(a11.stk_qty)  재고수량
        from	LGMJVDP.TB_STK_FT	a11
            join	LGMJVDP.TB_GOOD_DM	a12
            on 	(a11.GOODCD = a12.GOODCD)
            join	LGMJVDP.TB_STORE_DM	a13
            on 	(a11.STORECD = a13.STORECD)
        where	a11.DATECD between '2022-02-01' and '2022-02-14'
        and a13.RGNCD between ('41') and ('60')
        and (a12.GOOD_CLS1CD in ('90') 
                OR a12.GOOD_CLS2CD in ('5201') 
                OR a11.GOODCD in ('082184090480','5099873005101','5099873046173','5099873060711'))
            group by a13.RGNNM,
            a11.DATECD,
            a11.GOODCD,
            a12.GOOD_CLS1CD,
            a12.GOOD_CLS2CD,
            a12.GOOD_CLS3CD
    Union
        select        
        '기타파격' as Name,
        a11.DATECD,
        a13.RGNNM,
        -- max(SUBSTR(a13.STORENM,1,INSTR(a13.STORENM,'(')-1 ))  STORENM,
        -- max('V'||SUBSTR(a13.STORENM,INSTR(a13.STORENM,'(')+1, -( INSTR(a13.STORENM,'(') -INSTR(a13.STORENM,':'))-1))  CustCol_31,
        a11.GOODCD  GOODCD,
        max(trim(trailing from a12.GOODNM))  GOODNM,
        a12.GOOD_CLS1CD  GOOD_CLS1CD,
        max(a12.GOOD_CLS1NM)  GOOD_CLS1NM,
        a12.GOOD_CLS2CD  GOOD_CLS2CD,
        max(a12.GOOD_CLS2NM)  GOOD_CLS2NM,
        a12.GOOD_CLS3CD  GOOD_CLS3CD,
        max(a12.GOOD_CLS3NM)  GOOD_CLS3NM,
        sum(a11.NTSAL_AMT)  매출액,
        sum(a11.SAL_QTY)  판매수량,
		sum(a11.stk_qty)  재고수량
        from	LGMJVDP.TB_STK_FT	a11
            join	LGMJVDP.TB_GOOD_DM	a12
            on 	(a11.GOODCD = a12.GOODCD)
            join	LGMJVDP.TB_STORE_DM	a13
            on 	(a11.STORECD = a13.STORECD)
        where	a11.DATECD between '2022-02-01' and '2022-02-14'
        and a13.RGNCD between ('41') and ('60')
        and a11.GOODCD in ('8809247975155','8809534150104','8809534150111','8809534150128','8809534150142','8809805620350','8809805620367','8809240930250','8697439301925','8697439300799','8691720004960','8691720004977','8691216095939','4001686372586','4001686372975','4001686301555','4001686323366','4001686375754','4001686381328','5012035901738','5996379377360','8426617002473','8691216095557','8691216096134','8691216096370','8691216098794','8691216099074','9002975319003','8809415431803','8809415434217','6921211116660','8801725000786','8801725000809','8806002015828','8801128280884','8809396293322','8809396293346','8004800003423','8004800003409','80867586','80933113','8009280006759','8009280006766','8801111183062','8801019309571','8809447911786','8809447911793','8809447911809','8809470122043','8809470122067','8809264726693','8809264727331','8809264727348','8809264727317','8809264727355','8809308679466','8809308679473','8809432252153','8809432252818','2800032810077','2800032810084','2800063812422','2800063812439','8809290406019','2800071911094','2800071911100','8809311491109','8809311491116','8805123005794','8805123005800','8809328951825','8809328951849','8809328951832','8801051340273','8801051340297','8801051348934','8809369780774','8801051214826','8801051281729','8809587990016','8809587990023','8809587990030','8809495036714','4058222100103','8809442485060','8809442485077','8809442485091','8809442485084','2860036900006','8805123006197','8805123006203','8805123006210','8809056002950','8809056002929','8809056002936','8809587990153','8809587990160','8809587990139','8809587990146','8809587990122','8809542560681','8809542560261','8809542560254','8809066906613','8809616742173','2800100035913','2800100035920','2800100035937','2800100035395','2800100036026','2800100036033','8809587990115')
            group by a13.RGNNM,
            a11.DATECD,
            a11.GOODCD,
            a12.GOOD_CLS1CD,
            a12.GOOD_CLS2CD,
            a12.GOOD_CLS3CD    