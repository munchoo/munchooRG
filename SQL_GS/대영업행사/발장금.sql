WITH v_evt as ( SELECT 
                      b.rbt_cd,
                      b.event_nm,
                      b.goods_cd,
                      b.event_qty,
                      b.achvm_yn,
                      b.event_dur,
                      b.event_prvd_stand_brdn,
                      b.prvd_rbt_amt,
                      b.add_rbt_amt,
                      --b.event_tot_amt,
                      b.rbt_event_yyyy,
                      b.rbt_event_cd,
                      b.event_end_dt, --201621I 이벤트종료일자 sort용
                      b.line_cd,
                      b.class_cd,
                      b.subclass_cd ,
                      b. FOOD_TYPE
             FROM(
                 select 
                      a.rbt_cd,
                      a.event_nm,
                      a.goods_cd,
                      a.event_qty,
                      a.achvm_yn,
                      a.event_dur,
                      a.event_prvd_stand_brdn,
                      a.prvd_rbt_amt,
                      a.add_rbt_amt,
                      --a.event_tot_amt,
                      a.rbt_event_yyyy,
                      a.rbt_event_cd,
                      a.event_end_dt, --201621I 이벤트종료일자 sort용
                      a.line_cd,
                      a.class_cd,
                      a.subclass_cd ,
                      CASE WHEN /* e.CENTER_VNDR_SP IN ('1') AND */ (line_cd IN (SELECT ETC_CD FROM GSSCODS.TS_MS_ETC_CD_DETAIL WHERE ETC_CLASS_CD = 'ST12' AND MNG_ATTR_VAL1 = 'LINE' AND (STAT_SP IS NULL OR STAT_SP <> 'D'))
                                       OR (line_cd || class_cd) IN (SELECT ETC_CD FROM GSSCODS.TS_MS_ETC_CD_DETAIL WHERE ETC_CLASS_CD = 'ST12' AND MNG_ATTR_VAL1 = 'CLASS' AND (STAT_SP IS NULL OR STAT_SP <> 'D'))
                                          OR subclass_cd IN (SELECT ETC_CD FROM GSSCODS.TS_MS_ETC_CD_DETAIL WHERE ETC_CLASS_CD = 'ST12' AND MNG_ATTR_VAL1 = 'SUBCLASS' AND (STAT_SP IS NULL OR STAT_SP <> 'D')) ) THEN '1' --식품
                      ELSE '2'  --비식품
                     END AS FOOD_TYPE
    FROM(  SELECT a.rbt_event_yyyy || a.rbt_event_cd AS rbt_cd,
                      a.event_nm,
                      a.goods_cd,
                      a.event_qty,
                      (CASE WHEN a.prvd_stand_qty <= a.event_qty THEN 'Y' ELSE 'N' END) achvm_yn,
                      SUBSTR(a.event_start_dt,5,2)||'.'||SUBSTR(a.event_start_dt,7,2)||'~'||SUBSTR(a.event_end_dt,5,2)||'.'||SUBSTR(a.event_end_dt,7,2) as event_dur,
                      a.event_prvd_stand_brdn,
                      a.prvd_rbt_amt,
                      a.add_rbt_amt,
                      --a.event_tot_amt,
                      a.rbt_event_yyyy,
                      a.rbt_event_cd,
                      a.event_end_dt, --201621I 이벤트종료일자 sort용
                      CASE WHEN cls_appdt > '20240621' THEN b.line_cd_old ELSE b.line_cd  END AS line_cd,
                      CASE WHEN cls_appdt > '20240621' THEN b.class_cd_old ELSE b.class_cd END AS class_cd,
                      CASE WHEN cls_appdt > '20240621'  THEN b.subclass_cd_old ELSE b.subclass_cd END AS subclass_cd
                 FROM (
                       SELECT /* 20230418 Tuning(S) */ /*+ FULL(A) USE_HASH(A) */ /* 20230418 Tuning(E) */
                              a.rbt_event_yyyy, a.rbt_event_cd,
                              a.event_nm, a.event_start_dt, a.event_end_dt,
                              a.event_prvd_stand_brdn, b.prvd_rbt_amt, a.add_rbt_amt,
                              b.goods_cd, b.prvd_stand_qty, b.prvd_stand_cond_sp,
                              b.no_achvm_rbt_amt, b.rbt_limit_amt, a.prvd_stand_goods_cnt,
                              NVL((SELECT DECODE('1', '1', GREATEST(SUM(ORD_QTY),SUM(STKIN_QTY)), SUM(sale_qty))
                              FROM GSSCODS.TS_ST_SKU_PER_ACHIEVE
                             WHERE origin_bizpl_cd = C.ORIGIN_BIZPL_CD
                               AND goods_cd        = b.goods_cd
                               AND stk_eval_dt BETWEEN DECODE(C.ORIGIN_BIZPL_CD, C.BIZPL_CD, a.event_start_dt, GREATEST(c.open_dt, a.event_start_dt)) AND LEAST(c.close_dt, a.event_end_dt)
                           ), 0) as event_qty,
                              (SELECT NVL(count(goods_cd),0)
                                 FROM GSSCODS.TS_EV_RBT_EVENT_GOODS
                                WHERE rbt_event_yyyy  = a.rbt_event_yyyy
                                  AND rbt_event_cd    = a.rbt_event_cd
                                  AND goods_region_cd = a.goods_region_cd
                              ) event_goods_qty
                         FROM GSSCODS.TS_EV_RBT_EVENT a,
                              GSSCODS.TS_EV_RBT_EVENT_GOODS b,
                              (SELECT open_dt
                                     , NVL(close_dt, '99991231') close_dt
                                     , ORIGIN_BIZPL_CD
                                     , BIZPL_CD
                                     , GOODS_REGION_CD
                                 FROM GSSCODS.TS_MS_BIZPL
                                WHERE bizpl_cd = 'V6M86'
                              ) c
                        WHERE a.rbt_event_yyyy  = b.rbt_event_yyyy
                          AND a.rbt_event_cd    = b.rbt_event_cd
                          AND a.goods_region_cd = b.goods_region_cd
                          AND a.goods_region_cd = c.GOODS_REGION_CD
                           /* 일반장려금인 경우만  수행 201628v*/                                 
                          AND NVL(A.RBT_EVENT_SP,'1') = '1'     
                          AND '20240621' BETWEEN a.event_start_dt AND a.event_end_dt
                          AND a.prvd_stand_sp   = '1'
                       ) a , GSSCODS.TS_MS_GOODS b 
                where      a.goods_cd    = b.goods_cd 
                ) a 
                where a.achvm_yn = 'N'
                
                 ) b                                                                        
 WHERE        1=1   )
SELECT 
         ginfo.bizpl_cd,
         ginfo.bizpl_nm,
         CASE WHEN goods_cd_old IS NULL THEN goods_nm
              ELSE '*'||goods_nm END AS goods_nm,
         ginfo.goods_cd,    
         ginfo.achvm_yn,
         ginfo.RCMD_SP_NM,  /* P202305043 김병섭 상품추천구분명 */
         RCMD_SP_DESC,
         ginfo.ord_stk,         
         ginfo.ord_min_qty,
         prc,
         DECODE(SUBSTR(ginfo.ORD_POSBL_DOW_SP, 1, 1), 'Y', '일', NULL) || DECODE(SUBSTR(ginfo.ORD_POSBL_DOW_SP, 2, 1), 'Y', '월', NULL) ||
         DECODE(SUBSTR(ginfo.ORD_POSBL_DOW_SP, 3, 1), 'Y', '화', NULL) || DECODE(SUBSTR(ginfo.ORD_POSBL_DOW_SP, 4, 1), 'Y', '수', NULL) ||
         DECODE(SUBSTR(ginfo.ORD_POSBL_DOW_SP, 5, 1), 'Y', '목', NULL) || DECODE(SUBSTR(ginfo.ORD_POSBL_DOW_SP, 6, 1), 'Y', '금', NULL) ||
         DECODE(SUBSTR(ginfo.ORD_POSBL_DOW_SP, 7, 1), 'Y', '토', NULL) AS ORD_POSBL_DOW,
         ginfo.event_prvd_stand_brdn,                      
         ginfo.event_dur,
         ginfo.prvd_rbt_amt
    FROM (
          SELECT /*+ no_merge(b) */
                 g.bizpl_nm,
                 g.goods_cd,
                 line_cd,
                 class_cd,
                 subclass_cd,
                 goods_nm,
                 CASE WHEN dir_buy_cash_buy_sp IS NULL
                      THEN 'N' ELSE 'Y' END AS dir_buy_ord_yn,
                 -- 201831M  원가 , 매익률 계산 기준 정보 시작

                 -- 201831M  원가 , 매익률 계산 기준 정보 종료
                 ord_min_qty,
                 ord_max_qty,
                 ord_unit,
                 goods_cmkt_yn,
                 ord_appdt,
                 sale_cd_yn,
                 dc.center_vndr_sp,
                 CASE WHEN dc.center_vndr_sp IN ('1','2')
                      THEN dc.goods_stkin_bizpl_cd
                      ELSE r.bizpl_cd_bill
                      END AS goods_stkin_bizpl_cd,
                 CASE WHEN dc.center_vndr_sp IN ('1','2')
                      THEN (SELECT sb.purchase_cd
                              FROM GSSCODS.TS_MS_GOODS_STKIN_BIZPL sb
                             /* 센터위탁의 경우, TS_MS_DIST_CO.상품입고사업장코드 사용 */
                             WHERE sb.goods_stkin_bizpl_cd = dc.goods_stkin_bizpl_cd 
                               AND sb.goods_cd             = g.goods_cd)
                      ELSE (SELECT sb.purchase_cd
                              FROM (SELECT CASE WHEN t1.purchase_appdt > '20240621'
                                                THEN purchase_cd_old ELSE purchase_cd
                                                END AS purchase_cd,
                                           goods_cd,
                                           goods_stkin_bizpl_cd
                                      FROM GSSCODS.TS_MS_GOODS_STKIN_BIZPL t1) sb,
                                   TS_MS_PURCHASE_CON pc
                             /* 그외의 경우, TS_MS_REGION.사업장코드_징취 사용*/
                             WHERE sb.goods_stkin_bizpl_cd = r.bizpl_cd_bill
                               AND sb.goods_cd = g.goods_cd
                               AND sb.purchase_cd          = pc.purchase_cd
                               AND pc.supl_cd              = dc.supl_cd)
                      END AS purchase_cd,         /* 매입처코드 */
                 CASE WHEN dc.center_vndr_sp = '1'
                      THEN (SELECT CASE WHEN ord_posbl_dow_appdt > g.ord_dt
                                        THEN ord_posbl_dow_sp_old ELSE ord_posbl_dow_sp
                                        END AS ord_posbl_dow_sp
                              FROM GSSCODS.TS_MS_CENTER_ORD_DOW cod
                             WHERE cod.multi_vndr_no   = g.multi_vndr_no
                               AND cod.goods_region_cd = g.goods_region_cd)
                      ELSE (SELECT CASE WHEN ord_posbl_dow_appdt > g.ord_dt
                                        THEN ord_posbl_dow_sp_old ELSE ord_posbl_dow_sp
                                        END AS ord_posbl_dow_sp
                              FROM GSSCODS.TS_MS_BIZPL_PER_ORD_DOW bpod
                             WHERE bpod.origin_bizpl_cd = b.origin_bizpl_cd
                               AND bpod.dist_co_cd      = g.dist_co_cd)
                      END AS ord_posbl_dow_sp,     /* 발주가능요일 */
                 CASE WHEN dc.center_vndr_sp = '1'
                      THEN (SELECT CASE WHEN ord_posbl_dow_appdt > g.prev_ord_dt
                                        THEN ord_posbl_dow_sp_old ELSE ord_posbl_dow_sp
                                        END AS ord_posbl_dow_sp
                              FROM GSSCODS.TS_MS_CENTER_ORD_DOW cod
                             WHERE cod.multi_vndr_no   = g.multi_vndr_no
                               AND cod.goods_region_cd = g.goods_region_cd)
                      ELSE (SELECT CASE WHEN ord_posbl_dow_appdt > g.prev_ord_dt
                                        THEN ord_posbl_dow_sp_old ELSE ord_posbl_dow_sp
                                        END AS ord_posbl_dow_sp
                              FROM GSSCODS.TS_MS_BIZPL_PER_ORD_DOW bpod
                             WHERE bpod.origin_bizpl_cd = b.origin_bizpl_cd
                               AND bpod.dist_co_cd      = g.dist_co_cd)
                      END AS prev_ord_posbl_dow_sp,
                 CASE WHEN DECODE(SIGN(g.ord_dt - cmkt_appdt), -1, cmkt_yn_old, cmkt_yn)='Y'
                      THEN 'Y' ELSE 'N'
                      END AS bizpl_cmkt_yn,     /* C마켓점포여부 */
                 CASE WHEN cmkt_appdt <= g.ord_dt AND cmkt_yn='Y' AND cmkt_prc_app_yn='Y'
                      THEN CASE WHEN cmkt_prc_appdt > g.ord_dt
                           THEN cmkt_prc_old ELSE cmkt_prc END
                      ELSE CASE WHEN prc_appdt > g.ord_dt THEN prc_old ELSE prc END
                      END AS prc,
                 nvl(dc.stkin_lead_tm,1) AS stkin_lead_tm,
                 sun_dist_yn,
                 vat_sp, btl_deposit_cost, b.origin_bizpl_cd, ord_dt, g.goods_region_cd,
                 b.bizpl_cd, dc.dist_co_cd,
                 CASE WHEN dir_buy_cash_buy_sp IS NULL THEN 'Y'
                      WHEN dir_buy_cash_buy_sp = '2'   THEN 'N'
                      ELSE dir_buy_ord_posbl_yn
                      END AS dir_buy_ord_posbl_yn,
                 dc.dist_goods_grp_cd, goods_cd_old, b.close_dt, af_bizpl_cd,
                 CASE WHEN dc.center_vndr_sp IN ('1','2')
                      THEN (SELECT NVL(MIN(work_dt), TO_CHAR(TO_DATE(g.ord_dt,'YYYYMMDD')+nvl(dc.stkin_lead_tm,0),'YYYYMMDD'))
                              FROM GSSCODS.TS_OR_DIST_GOODS_GRP_PER_HD hd
                             WHERE work_dt           >= TO_CHAR(TO_DATE(g.ord_dt,'YYYYMMDD')+nvl(dc.stkin_lead_tm,0),'YYYYMMDD')
                               AND work_dt           <= TO_CHAR(TO_DATE(g.ord_dt,'YYYYMMDD')+nvl(dc.stkin_lead_tm,0)+10,'YYYYMMDD')
                               AND bizpl_cd_center   = dc.goods_stkin_bizpl_cd
                               AND dist_goods_grp_cd = dc.dist_goods_grp_cd
                               AND stkout_holiday_yn = 'N')
                      ELSE CASE WHEN dc.sun_dist_yn = 'Y'
                           THEN TO_CHAR(TO_DATE(g.ord_dt,'YYYYMMDD')+nvl(dc.stkin_lead_tm,0),'YYYYMMDD')
                           ELSE CASE WHEN TO_CHAR(TO_DATE(g.ord_dt,'YYYYMMDD')+nvl(dc.stkin_lead_tm,0),'D') = 1
                                     THEN TO_CHAR(TO_DATE(g.ord_dt,'YYYYMMDD')+nvl(dc.stkin_lead_tm,0)+1,'YYYYMMDD')
                                     ELSE TO_CHAR(TO_DATE(g.ord_dt,'YYYYMMDD')+nvl(dc.stkin_lead_tm,0),'YYYYMMDD')
                                     END
                           END
                      END AS goods_stkin_plan_dd,        /* 상품입고예정일 */
                 CASE WHEN LINE_CD||CLASS_CD IN (SELECT ETC_CD FROM GSSCODS.TS_MS_ETC_CD_DETAIL WHERE ETC_CLASS_CD = 'MS19' AND STAT_SP IS NULL)
                      THEN NULL
                      ELSE -- 발주재고(장부재고) 상품코드
                          NVL((SELECT NVL(book_stk_qty, 0)
                             FROM GSSCODS.TS_ST_SKU_PER_STK
                            WHERE origin_bizpl_cd = g.ORIGIN_BIZPL_CD
                              AND goods_cd        = g.goods_cd
                              AND stk_eval_dt     = g.SKU_PER_STK_STAND_DT
                          ), 0) -
                          NVL((SELECT NVL(book_stk_qty, 0) - NVL(real_stk_qty, 0)
                                 FROM GSSCODS.TS_ST_INV_TDAY_STK_EVAL
                                WHERE origin_bizpl_cd = g.ORIGIN_BIZPL_CD
                                  AND goods_cd        = g.goods_cd
                                  AND inv_dt         >  g.SKU_PER_STK_STAND_DT
                                  AND inv_dt         <= g.ORD_DT
                               ), 0) +
                          --발주재고(실적SUM) 상품코드
                          NVL((SELECT SUM(NVL(a.rtn_qty,    0) + NVL(a.mv_stkout_qty,  0) + NVL(a.mv_stkin_qty,   0) +
                                          NVL(a.sku_mv_qty, 0) + NVL(a.present_qty,    0) + NVL(a.hq_buy_mod_qty, 0) - NVL(a.sale_qty, 0) +
                                          CASE WHEN a.ship_rcv_yn = 'Y' THEN NVL(a.stkin_qty, 0) ELSE NVL(a.ship_plan_qty, 0) END
                                      )
                                     +  NVL(SUM(CASE WHEN A.STK_EVAL_DT = TO_CHAR(TO_DATE(g.ORD_DT,'YYYYMMDD') -1, 'YYYYMMDD') AND DC.STKIN_LEAD_TM = '2'
                                                THEN A.ORD_QTY
                                                ELSE 0
                                           END), 0) /*입고리드2일상품 전일발주수량 합산(이형민)*/
                                      AS sum_stk
                             FROM GSSCODS.TS_ST_SKU_PER_ACHIEVE      a
                            WHERE 1 = 1
                              AND a.goods_cd        = g.goods_cd
                              AND a.origin_bizpl_cd = g.ORIGIN_BIZPL_CD
                              AND a.stk_eval_dt     > g.SKU_PER_STK_STAND_DT
                              AND a.stk_eval_dt     <= g.ORD_DT
                          ), 0) -
                          NVL((SELECT NVL(oinv.bizpl_stk_gap_qty,0)
                                    FROM GSSCODS.TS_ST_ORD_STK_MOD oinv
                                   WHERE 1=1
                                     AND oinv.origin_bizpl_cd = g.origin_bizpl_cd
                                     AND oinv.goods_cd        = g.goods_cd
                                     AND oinv.inv_dt          = g.max_mod_dt
                          ), 0) -
                          /* [P202302009] 폐기수량 조회 테이블 변경 : START */
                          --NVL((SELECT NVL(ROUND(SUM(discard_qty),1),0) FROM TS_ST_SKU_PER_ACHIEVE
                          --      WHERE origin_bizpl_cd = g.origin_bizpl_cd
                          --        AND goods_cd        = g.goods_cd
                          --        /* 최종재고조사일자(재고조사당일수불or점자체재고조사) 이후의 폐기수량 */
                          --        AND stk_eval_dt     > CASE WHEN max_mod_dt < max_inv_dt THEN max_inv_dt ELSE max_mod_dt END
                          --        AND stk_eval_dt     <= ORD_DT
                          --), 0) +
                          NVL((SELECT NVL(ROUND(SUM(discard_qty),1),0)
                                 FROM GSSCODS.TS_ST_DISCARD_TOT
                                WHERE ORIGIN_BIZPL_CD = G.ORIGIN_BIZPL_CD
                                  AND GOODS_CD        = G.GOODS_CD
                                  AND DISCARD_DT      > CASE WHEN MAX_MOD_DT < MAX_INV_DT
                                                             THEN MAX_INV_DT
                                                             ELSE MAX_MOD_DT
                                                         END
                                  AND DISCARD_DT     <= g.ORD_DT
                          ), 0) +
                          /* [P202302009] 폐기수량 조회 테이블 변경 : END */  
                          --발주재고(장부재고) 상품코드_구
                          NVL((SELECT NVL(book_stk_qty, 0)
                             FROM GSSCODS.TS_ST_SKU_PER_STK
                            WHERE origin_bizpl_cd = g.ORIGIN_BIZPL_CD
                              AND goods_cd        = g.goods_cd_old
                              AND stk_eval_dt     = g.SKU_PER_STK_STAND_DT
                          ), 0) -
                          NVL((SELECT NVL(book_stk_qty, 0) - NVL(real_stk_qty, 0)
                                 FROM GSSCODS.TS_ST_INV_TDAY_STK_EVAL
                                WHERE origin_bizpl_cd = g.ORIGIN_BIZPL_CD
                                  AND goods_cd        = g.goods_cd_old
                                  AND inv_dt         >  g.SKU_PER_STK_STAND_DT
                                  AND inv_dt         <= g.ORD_DT
                               ), 0) +
                          --발주재고(실적SUM) 상품코드_구
                          NVL((SELECT SUM(NVL(a.rtn_qty,    0) + NVL(a.mv_stkout_qty,  0) + NVL(a.mv_stkin_qty,   0) +
                                          NVL(a.sku_mv_qty, 0) + NVL(a.present_qty,    0) + NVL(a.hq_buy_mod_qty, 0) - NVL(a.sale_qty, 0) +
                                          CASE WHEN a.ship_rcv_yn = 'Y' THEN NVL(a.stkin_qty, 0) ELSE NVL(a.ship_plan_qty, 0) END
                                      )
                                      +  NVL(SUM(CASE WHEN A.STK_EVAL_DT = TO_CHAR(TO_DATE(g.ORD_DT,'YYYYMMDD') -1, 'YYYYMMDD') AND DC.STKIN_LEAD_TM = '2'
                                                THEN A.ORD_QTY
                                                ELSE 0
                                           END), 0) /*입고리드2일상품 전일발주수량 합산(이형민)*/
                                      AS sum_stk
                             FROM GSSCODS.TS_ST_SKU_PER_ACHIEVE a
                            WHERE 1 = 1
                              AND a.origin_bizpl_cd = g.ORIGIN_BIZPL_CD
                              AND a.goods_cd        = g.goods_cd_old
                              AND a.stk_eval_dt     > g.SKU_PER_STK_STAND_DT
                              AND a.stk_eval_dt     <= g.ORD_DT
                          ), 0) -
                          NVL((SELECT NVL(oinv.bizpl_stk_gap_qty,0)
                                    FROM GSSCODS.TS_ST_ORD_STK_MOD oinv
                                   WHERE 1=1
                                     AND oinv.origin_bizpl_cd = g.origin_bizpl_cd
                                     AND oinv.goods_cd        = g.goods_cd_old
                                     AND oinv.inv_dt          = g.max_mod_dt_old
                          ), 0) -
                          /* [P202302009] 폐기수량 조회 테이블 변경 : START */
                          --NVL((SELECT NVL(ROUND(SUM(discard_qty),1),0) FROM TS_ST_SKU_PER_ACHIEVE
                          --     WHERE origin_bizpl_cd = g.origin_bizpl_cd
                          --       AND goods_cd        = g.goods_cd_old
                          --       /* 최종재고조사일자(재고조사당일수불or점자체재고조사) 이후의 폐기수량*/
                          --       AND stk_eval_dt     > CASE WHEN max_mod_dt_old < max_inv_dt THEN max_inv_dt ELSE max_mod_dt_old END
                          --       AND stk_eval_dt     <= ORD_DT
                          --), 0)
                          NVL((SELECT NVL(ROUND(SUM(discard_qty),1),0)
                                 FROM GSSCODS.TS_ST_DISCARD_TOT
                                WHERE ORIGIN_BIZPL_CD = G.ORIGIN_BIZPL_CD
                                  AND GOODS_CD        = G.GOODS_CD_OLD
                                  AND DISCARD_DT      > CASE WHEN max_mod_dt_old < max_inv_dt THEN max_inv_dt 
                                                             ELSE max_mod_dt_old 
                                                        END
                                  AND DISCARD_DT     <= g.ORD_DT
                          ), 0)
                          /* [P202302009] 폐기수량 조회 테이블 변경 : END */ 
                  END AS ord_stk,
                  g.ord_qty,
                  g.rbt_cd,
                  g.event_nm,
                  g.event_qty,
                  g.achvm_yn,
                  g.event_dur,
                  g.event_prvd_stand_brdn,
                  g.prvd_rbt_amt,
                  g.add_rbt_amt,
                  --g.event_tot_amt,
                  g.rbt_event_yyyy,
                  g.rbt_event_cd,
                  g.goods_stat,
                  g.tm_stat,
                  g.tm_yn,
                  g.GOODS_RANK_CD_NM,
                  g.VALID_DUR_CNT,
                 g.BOX_PER_QTY,
                 g.event_end_dt, --201621I 이벤트종료일자 sort용
                 DECODE(G.RTN_POSBL_YN_CUR,'N',
                        DECODE(NVL((SELECT 'N'
                                       FROM GSSCODS.TS_MS_DIST_CO m
                                      WHERE (EXISTS (SELECT goods_cd
                                                       FROM GSSCODS.TS_MS_USUAL_RTN_OBJ_GOODS
                                                      WHERE goods_cd = g.goods_cd
                                                        AND rtn_start_dt <= g.ORD_DT
                                                        AND rtn_end_dt >= g.ORD_DT
                                                        AND stat = 'M' ) OR
                                             EXISTS (SELECT goods_cd
                                                       FROM GSSCODS.TS_MS_BIZPL_RTN_LIMIT_GOODS
                                                      WHERE goods_cd = g.goods_cd
                                                        AND rtn_start_dt <= g.ORD_DT
                                                        AND rtn_end_dt >= g.ORD_DT
                                                        AND origin_bizpl_cd = g.ORIGIN_BIZPL_CD) OR
                                                            m.rtn_limit_yn ='N' )
                                                        AND m.dist_co_cd = dc.dist_co_cd ),'Y'),'Y','재고처리불가',
                                                       (CASE WHEN G.RTN_POSBL_YN_APPDT > g.ORD_DT AND G.RTN_POSBL_YN = 'Y' THEN '일시무재고처리(' || SUBSTR(G.RTN_POSBL_YN_APPDT,5,2)||'/'||SUBSTR(G.RTN_POSBL_YN_APPDT,7,2) ||'부터재고처리가능)' ELSE '재고처리불가' END)), -- [201747V] 반품->재고처리 /*2016-06-21 일시무재고처리용어변경*/ 
                         DECODE(NVL((SELECT 'N'
                                       FROM GSSCODS.TS_MS_DIST_CO m
                                      WHERE (EXISTS (SELECT goods_cd
                                                       FROM GSSCODS.TS_MS_USUAL_RTN_OBJ_GOODS
                                                      WHERE goods_cd = g.goods_cd
                                                        AND rtn_start_dt <= g.ORD_DT
                                                        AND rtn_end_dt >= g.ORD_DT
                                                        AND stat = 'M' ) OR
                                             EXISTS (SELECT goods_cd
                                                       FROM GSSCODS.TS_MS_BIZPL_RTN_LIMIT_GOODS
                                                      WHERE goods_cd = g.goods_cd
                                                        AND rtn_start_dt <= g.ORD_DT
                                                        AND rtn_end_dt >= g.ORD_DT
                                                        AND origin_bizpl_cd = g.ORIGIN_BIZPL_CD) OR
                                                            m.rtn_limit_yn ='N' )
                                                        AND m.dist_co_cd = dc.dist_co_cd ),'Y'),'Y','한도적용','한도미적용')) AS RTNYN_DISPLAY,
                 (SELECT /*+INDEX_DESC (TS_OP_COST_DC_GOODS PK_OP_COST_DC_GOODS)*/
                   ROUND((COST_OLD - COST) / COST_OLD * 100,0) || '% ('
                   ||TO_CHAR(TO_DATE(COST_DC_START_DT,'YYYYMMDD'),'MM/DD')||' ~ '
                   ||TO_CHAR(TO_DATE(COST_DC_END_DT,'YYYYMMDD'),'MM/DD')||')'
              FROM GSSCODS.TS_OP_COST_DC_GOODS
             WHERE GOODS_CD = G.GOODS_CD
               AND GOODS_REGION_CD = G.GOODS_REGION_CD
               AND TO_CHAR(TO_DATE(g.ORD_DT,'YYYYMMDD')+ NVL(DC.STKIN_LEAD_TM, 1) ,'YYYYMMDD') BETWEEN COST_DC_START_DT AND COST_DC_END_DT
               AND ROWNUM = 1) AS COST_DC_RATE, /* 원가DC 2015-05-08*/
               g.RCMD_SP_NM,  /* P202305043 김병섭 상품추천구분명 */
               g.RCMD_SP_DESC /* P202305043 김병섭 상품추천구분설명 */
            FROM (--상품마스터 조회
                  SELECT /*+ LEADING(F T2 T1) USE_HASH(T3 O1) USE_NL(GR GT) */ /* 20230713 인프라팀 튜닝 AS-IS : LEADING(F T2 T1) USE_HASH(T3 O1) */
                         t1.goods_cd,
                         t1.goods_nm,
                         CASE WHEN cls_appdt > '20240621' THEN t1.line_cd_old ELSE t1.line_cd  END AS line_cd,
                         CASE WHEN cls_appdt > '20240621' THEN t1.class_cd_old ELSE t1.class_cd END AS class_cd,
                      CASE WHEN cls_appdt > '20240621'  THEN t1.subclass_cd_old ELSE t1.subclass_cd END AS subclass_cd,
                         t1.sale_cd_yn,           /* 판매용코드 */
                         t1.cmkt_yn AS goods_cmkt_yn,
                         t1.vat_sp,
                         t1.btl_deposit_cost,
                         t2.ord_appdt,            /* 발주적용일자 */
                         DECODE(SIGN('20240621' - t2.goods_stat_appdt), -1, t2.new_goods_stat_old, t2.new_goods_stat) AS goods_stat,
                         CASE WHEN t1.target_market_yn = 'Y' AND tm.target_market_sp IS NOT NULL
                              THEN DECODE(SIGN('20240621' - tm.stat_appdt), -1, tm.stat_old, tm.stat) ELSE 'L'
                         END AS tm_stat,
                         t1.target_market_yn AS tm_yn,
                        /*유효기간 추가 2015-05-08*/
                         CASE WHEN NVL(TRIM(t1.STKOUT_INSPT_BASE_MONTH_CNT),0) + NVL(TRIM(t1.STKOUT_INSPT_BASE_DD_CNT),0) + NVL(TRIM(t1.STKOUT_INSPT_BASE_TIME),0) > 0
                              THEN CASE WHEN NVL(t1.STKOUT_INSPT_BASE_MONTH_CNT,t1.STKOUT_INSPT_BASE_DD_CNT) = t1.STKOUT_INSPT_BASE_MONTH_CNT
                                        THEN t1.STKOUT_INSPT_BASE_MONTH_CNT||'개월 '||DECODE(t1.STKOUT_INSPT_BASE_DD_CNT, NULL, ' ', t1.STKOUT_INSPT_BASE_DD_CNT||'일 ')
                                        WHEN NVL(t1.STKOUT_INSPT_BASE_DD_CNT,t1.STKOUT_INSPT_BASE_TIME) = t1.STKOUT_INSPT_BASE_DD_CNT
                                        THEN t1.STKOUT_INSPT_BASE_DD_CNT||'일 '||DECODE(t1.STKOUT_INSPT_BASE_TIME, NULL, ' ', t1.STKOUT_INSPT_BASE_TIME||'시 ')
                                    END
                              ELSE t1.VALID_DUR_MM_CNT||DECODE(t1.VALID_DUR_MM_CNT,NULL,' ','개월 ') ||
                                   t1.VALID_DUR_DD_CNT||DECODE(t1.VALID_DUR_DD_CNT,NULL,' ','일')
                          END AS VALID_DUR_CNT,
                      CASE WHEN T1.BOX_PER_QTY_APPDT > TO_CHAR(SYSDATE, 'YYYYMMDD') 
                              THEN T1.BOX_PER_QTY_OLD 
                              ELSE T1.BOX_PER_QTY 
                          END AS BOX_PER_QTY,
                         T2.RTN_POSBL_YN,         /*2016-05-25*/
                         T2.RTN_POSBL_YN_APPDT,   /*2016-05-25*/
                         DECODE(SIGN('20240621' - T2.RTN_POSBL_YN_APPDT), -1, T2.RTN_POSBL_YN_OLD, T2.RTN_POSBL_YN) AS RTN_POSBL_YN_CUR,  /*2015-05-08*/
                         t2.dir_buy_cash_buy_sp,
                         DECODE(SIGN('20240621' - t2.multi_vndr_no_appdt), -1, t2.multi_vndr_no_old, t2.multi_vndr_no) AS multi_vndr_no,
                         DECODE(SIGN('20240621' - t2.ord_posbl_qty_appdt), -1, t2.ord_min_qty_old, t2.ord_min_qty) AS ord_min_qty,
                         DECODE(SIGN('20240621' - t2.ord_posbl_qty_appdt), -1, t2.ord_max_qty_old, t2.ord_max_qty) AS ord_max_qty,
                         DECODE(SIGN('20240621' - t2.ord_posbl_qty_appdt), -1, t2.ord_unit_old, t2.ord_unit) AS ord_unit,
                         t2.prc,
                         t2.prc_old,
                         t2.prc_appdt,
                         t2.cmkt_prc,
                         t2.cmkt_prc_old,
                         t2.cmkt_prc_appdt,
                         -- 201831M  매익률 계산을 위한 행사원가 추출 , 원가 계산방식 변경  시작 
                         --            > 매익률 기준 변경 : 기준원가 -> 행사원가
                         --            > 원가 계산방식 변경 : 기준원가 -> 적용원가(행사+증정)
                         /*
                         CASE WHEN cost_appdt > '20240621' THEN cost_old ELSE cost END AS ori_cost,
                         CASE WHEN '20240621' BETWEEN dc_cost_app_start_dt AND dc_cost_app_end_dt THEN dc_cost
                              ELSE NULL
                              END AS dc_cost,
                         t2.dc_cost_app_start_dt,
                         t2.dc_cost_app_end_dt, 
                         */

                         -- 201831M  매익률 계산을 위한 행사원가 추출 , 원가 계산방식 변경  종료
                         t2.goods_cd_old,
                        CASE WHEN '20240621' BETWEEN GOODS_RANK_APP_START_DT AND GOODS_RANK_APP_END_DT --2015-05-07 민경섭
                            THEN CASE WHEN T2.GOODS_RANK = '1'
                                      THEN CASE WHEN ORD_APPDT >= TO_CHAR(ADD_MONTHS(TO_DATE( '20240621','YYYYMMDD'), -1) ,'YYYYMM') || '01'
                                                THEN (SELECT ETC_CD_NM -- 신필
                                                        FROM GSSCODS.TS_MS_ETC_CD_DETAIL
                                                       WHERE ETC_CLASS_CD = 'MG12'
                                                         AND ETC_CD = '3'
                                                         AND STAT_SP IS NULL)
                                                ELSE (SELECT ETC_CD_NM -- 필수
                                                        FROM GSSCODS.TS_MS_ETC_CD_DETAIL
                                                       WHERE ETC_CLASS_CD = 'MG12'
                                                         AND ETC_CD = '1'
                                                         AND STAT_SP IS NULL)
                                           END
                                      ELSE CASE WHEN ORD_APPDT >= TO_CHAR(ADD_MONTHS(TO_DATE( '20240621','YYYYMMDD'), -1) ,'YYYYMM') || '01'
                                                THEN (SELECT ETC_CD_NM -- 신규
                                                        FROM GSSCODS.TS_MS_ETC_CD_DETAIL
                                                       WHERE ETC_CLASS_CD = 'MG12'
                                                         AND ETC_CD = '4'
                                                         AND STAT_SP IS NULL)
                                                WHEN ORD_APPDT >= TO_CHAR(ADD_MONTHS(TO_DATE( '20240621','YYYYMMDD'), -3) ,'YYYYMMDD')
                                                THEN ' '
                                                ELSE NULL
                                           END
                                 END
                            ELSE CASE WHEN ORD_APPDT >= TO_CHAR(ADD_MONTHS(TO_DATE( '20240621','YYYYMMDD'), -1) ,'YYYYMM') || '01'
                                      THEN (SELECT ETC_CD_NM
                                              FROM GSSCODS.TS_MS_ETC_CD_DETAIL
                                             WHERE ETC_CLASS_CD = 'MG12'
                                               AND ETC_CD = '4'
                                               AND STAT_SP IS NULL)
                                      WHEN ORD_APPDT >= TO_CHAR(ADD_MONTHS(TO_DATE( '20240621','YYYYMMDD'), -3) ,'YYYYMMDD')
                                      THEN ' '
                                      ELSE NULL
                                 END
                         END AS GOODS_RANK_CD_NM,
                         NVL(CASE WHEN t3.dist_co_ord_appdt > '20240621'
                                  THEN t3.dist_co_cd_old ELSE t3.dist_co_cd
                                  END,
                             CASE WHEN t2.dist_co_ord_appdt > '20240621'
                                  THEN t2.dist_co_cd_old ELSE t2.dist_co_cd
                                  END) AS dist_co_cd,              /*배송처코드 */
                         BIZ.GOODS_REGION_CD AS goods_region_cd,
                         BIZ.ORIGIN_BIZPL_CD AS origin_bizpl_cd,
                         BIZ.BIZPL_CD AS bizpl_cd,
                         BIZ.BIZPL_NM,
                         '20240621' AS ord_dt,
                         TO_CHAR(TO_DATE('20240621','YYYYMMDD')-1,'YYYYMMDD') AS prev_ord_dt,
                         BIZ.SKU_PER_STK_STAND_DT AS sku_per_stk_stand_dt,
                         BIZ.MAX_INV_DT AS max_inv_dt,
                         /* 발주재고(최종점자체재고조사일자) 상품코드 */
                         nvl((SELECT MAX(inv_dt) FROM GSSCODS.TS_ST_ORD_STK_MOD
                               WHERE origin_bizpl_cd =  BIZ.ORIGIN_BIZPL_CD
                                 AND goods_cd        =  t1.goods_cd
                                 AND inv_dt          <= '20240621'),'19910101') AS max_mod_dt,
                         /* 발주재고(최종점자체재고조사일자) 상품코드_구 */
                         nvl((SELECT MAX(inv_dt) FROM GSSCODS.TS_ST_ORD_STK_MOD
                         WHERE   origin_bizpl_cd =  BIZ.ORIGIN_BIZPL_CD
                                   AND  goods_cd =  t2.goods_cd_old
                                 AND inv_dt          <= '20240621'),'19910101') AS max_mod_dt_old,
                         o1.ord_qty,
                         f.rbt_cd,
                         f.event_nm,
                         f.event_qty,
                         f.achvm_yn,
                         f.event_dur,
                         f.event_prvd_stand_brdn,
                         f.prvd_rbt_amt,
                         f.add_rbt_amt,
                         --f.event_tot_amt,
                         f.rbt_event_yyyy,
                         f.rbt_event_cd,
                      f.event_end_dt, --201621I 이벤트종료일자 sort용
                         CASE WHEN  gr.RBT_ORD_STRMD_YN = 'Y' THEN '강력'
                              WHEN  gr.RBT_ORD_RCMD_YN = 'Y' THEN '추천'
                              WHEN  TO_DATE(f.event_end_dt,'YYYYMMDD') - TO_DATE('20240621','YYYYMMDD') BETWEEN 0 AND 6 THEN '종료임박'
                              WHEN  gt.RBT_ORD_TPFC_YN = 'Y' THEN '유형화'
                          END AS RCMD_SP_NM, /* P202305043 */
                         CASE WHEN  gr.RBT_ORD_STRMD_YN = 'Y' THEN '발주만넣어도 돈 되는 상품'
                              WHEN  gr.RBT_ORD_RCMD_YN = 'Y' THEN '한 개만 팔려도 돈 되는 상품'
                              WHEN  TO_DATE(f.event_end_dt,'YYYYMMDD') - TO_DATE('20240621','YYYYMMDD') BETWEEN 0 AND 6 THEN '장려금 행사 종료 임박 상품'
                              WHEN  gt.RBT_ORD_TPFC_YN = 'Y' THEN '동일 유형점포 30% 이상 발주 상품 '
                          END AS RCMD_SP_DESC /* P202305043 */
                    FROM GSSCODS.TS_MS_GOODS        t1,
                         GSSCODS.TS_MS_GOODS_DETAIL t2,
                         LGMJVDP.TS_MS_BIZPL_MULTI_VNDR t3,
                         v_evt f,
                         TS_MS_BIZPL_TM_GOODS tm,
                          (SELECT goods_cd, ord_qty
                             FROM GSSCODS.TH_OR_STR@DL_PCSOR
                            WHERE bizpl_cd = 'V6M86'
                              AND ord_dt = '20240621'
                          ) o1 ,
                         TS_EV_RBT_GOODS_RCMD gr, /* P202305043 */
                         TS_EV_RBT_GOODS_TPFC gt,  /* P202305043 */
   
                         (SELECT ORIGIN_BIZPL_CD
                                ,BIZPL_CD 
                                ,BIZPL_NM
                                ,GOODS_REGION_CD
                                ,NVL((SELECT MAX(INV_DT)
                                    FROM GSSCODS.TS_ST_INV_TDAY_STK_EVAL 
                                    WHERE ORIGIN_BIZPL_CD= BIZ.ORIGIN_BIZPL_CD
                                ),'19000101') AS MAX_INV_DT
                                ,NVL((SELECT SKU_PER_STK_STAND_DT
                                    FROM GSSCODS.TS_ST_SKU_PER_STK_STAND_DT 
                                    WHERE ORIGIN_BIZPL_CD= BIZ.ORIGIN_BIZPL_CD
                                ),'19000101') AS SKU_PER_STK_STAND_DT     
                                ,'20240621' AS ORD_DT
                            FROM GSSCODS.TS_MS_BIZPL BIZ
                           WHERE BIZPL_CD = 'V6M86'
                         ) BIZ
                   WHERE f.goods_cd            = t1.goods_cd
                     AND t2.goods_region_cd    = BIZ.GOODS_REGION_CD
                     AND t3.multi_vndr_no   (+)= CASE WHEN '20240621' < t2.multi_vndr_no_appdt THEN t2.multi_vndr_no_old ELSE t2.multi_vndr_no END
                     AND t3.origin_bizpl_cd (+)= BIZ.ORIGIN_BIZPL_CD
                     AND f.goods_cd            = t2.goods_cd
                     AND f.goods_cd            = tm.goods_cd(+)
                     AND tm.bizpl_cd        (+)= BIZ.BIZPL_CD
                     AND f.goods_cd            = o1.goods_cd(+)
                     AND sale_cd_yn            = 'N'              /* 판매용코드*/
                     AND ord_appdt             <= '20240621'         /* 발주적용일자 (발주적용일자이후)*/
                     AND NOT EXISTS (SELECT '' FROM GSSCODS.TS_OR_ORD_BAN_GOODS t /* 발주금지상품 (상품코드)*/
                                      WHERE t.ord_dt          = '20240621'
                     AND t.goods_region_cd = t2.goods_region_cd
                                        AND t.goods_cd        = t1.goods_cd
                                        AND t.stat_sp         IS NULL)
                     AND (CASE WHEN TO_CHAR(TO_DATE( '20240621','YYYYMMDD'),'d') = 1 /* 발주일이 일요일이고*/
                                     AND TO_CHAR(SYSDATE,'d') = 1                 /* 오늘이 일요일이면*/
                               THEN t2.sun_ord_posbl_yn ELSE 'Y' END) = 'Y'
                     AND (CASE WHEN TO_CHAR(TO_DATE( '20240621','YYYYMMDD'),'d') = 1 /* 발주일이 일요일이고*/
                                    AND TO_CHAR(SYSDATE,'d') = 7                  /* 오늘이 토요일이고*/
                                    AND (SELECT DECODE(SIGN(TO_CHAR(SYSDATE,'YYYYMMDD') - bizpl_cnf_cd_val_appdt),
                                                      -1, bizpl_cnf_cd_val_old, bizpl_cnf_cd_val)
                                           FROM GSSCODS.TS_SS_BIZPL_CNF
                                          WHERE bizpl_cnf_cd = 'ORD_CLOSING_TIME'
                                            AND bizpl_cnf_app_scope_sp_cd = (SELECT DECODE(SIGN(TO_CHAR(SYSDATE,'YYYYMMDD') - acct_organ_appdt),
                                                                                      -1, region_cd_old, region_cd)
                                                                               FROM GSSCODS.TS_MS_BIZPL
                                                                              WHERE bizpl_cd = 'V6M86')
                                         ) < TO_CHAR(SYSDATE,'HH24MI')            /* 발주마감시간이후면*/
                               THEN t2.sun_ord_posbl_yn ELSE 'Y' END) = 'Y'
                     AND                       f.rbt_event_yyyy = gr.RBT_EVENT_YYYY(+) /* P202305043 김병섭 상품추천*/
                     AND f.rbt_event_cd = gr.RBT_EVENT_CD(+)     /* P202305043 김병섭 상품추천*/
                     AND f.goods_cd = gr.GOODS_CD(+)             /* P202305043 김병섭 상품추천*/
                     AND gr.ORIGIN_BIZPL_CD(+) = BIZ.ORIGIN_BIZPL_CD    /* P202305043 김병섭 상품추천*/
                     AND gr.rbt_event_yyyy = gt.RBT_EVENT_YYYY(+) /* P202305043 김병섭 상품유형화*/
                     AND gr.rbt_event_cd = gt.RBT_EVENT_CD(+)     /* P202305043 김병섭 상품유형화*/
                     AND gr.goods_cd = gt.GOODS_CD(+)             /* P202305043 김병섭 상품유형화*/
                     AND gr.STR_CL_DIV_CD = gt.STR_CL_DIV_CD(+) /* P202305043 김병섭 상품유형화*/
                 ) g,
                 TS_MS_DIST_CO dc,
                 (SELECT CASE WHEN acct_organ_appdt > '20240621' THEN region_cd_old ELSE region_cd END AS region_cd,
                         origin_bizpl_cd,
                         cmkt_appdt,
                         cmkt_yn,
                         cmkt_yn_old,
                         cmkt_prc_app_yn,
                         bizpl_cd,
                         close_dt,
                         af_bizpl_cd
                    FROM GSSCODS.TS_MS_BIZPL WHERE bizpl_cd = 'V6M86') b,
                 TS_MS_REGION r
           WHERE g.dist_co_cd = dc.dist_co_cd
             AND r.region_cd = b.region_cd
             AND g.goods_stat = 'M'
         ) ginfo,
         TS_MS_CENTER_PER_GOODS_STAT cg
   WHERE ginfo.purchase_cd IS NOT NULL                          /* 매입처코드가 존재해야함 */
     AND ginfo.goods_stkin_bizpl_cd = cg.center_bizpl_cd(+)
     AND ginfo.goods_cd = cg.goods_cd(+)
     AND NOT EXISTS (SELECT '' FROM GSSCODS.TS_OR_ORD_BAN_DIST_CO t     /* 발주금지배송처 (배송처코드) */
                      WHERE t.ord_dt          = ginfo.ord_dt
                     and t.goods_region_cd = ginfo.goods_region_cd
                        AND t.dist_co_cd      = ginfo.dist_co_cd
                        AND t.stat_sp         IS NULL)
     AND NOT EXISTS (SELECT '' FROM GSSCODS.TS_OR_ORD_BAN_PURCHASE t    /* 발주금지구매조건 (매입처코드) */
                      WHERE t.ord_dt          = ginfo.ord_dt
                        AND t.goods_region_cd = ginfo.goods_region_cd
                        AND t.purchase_cd     = ginfo.purchase_cd
                        AND t.stat_sp         IS NULL)
     AND dir_buy_ord_posbl_yn     = 'Y'
/*
     AND CASE WHEN ginfo.line_cd = '65'
              AND (SELECT DECODE(SIGN(TO_CHAR(SYSDATE,'YYYYMMDD') - bizpl_cnf_cd_val_appdt), -1, bizpl_cnf_cd_val_old, bizpl_cnf_cd_val)
                     FROM GSSCODS.TS_SS_BIZPL_CNF
                    WHERE bizpl_cnf_cd = 'KTG_APPROVAL_YN' 
                      AND bizpl_cnf_app_scope_sp_cd = 'V6M86') <> 'Y'
              THEN 'N' ELSE 'Y' END     = 'Y'
*/
/* 20180220 담배인허가제외점포도 전자담배기기 발주가능하도록 수정 */
/* 201833M 담배 상품코드 변경 51 -> 65*/
     AND CASE WHEN GINFO.LINE_CD = '65'
                   AND NOT EXISTS (SELECT ''
                                     FROM GSSCODS.TS_MS_GOODS
                                    WHERE GOODS_CD = GINFO.GOODS_CD 
                                      AND CASE WHEN '20240621' < CLS_APPDT THEN LINE_CD_OLD ELSE LINE_CD END = '65'
                                      AND CASE WHEN '20240621' < CLS_APPDT THEN CLASS_CD_OLD ELSE CLASS_CD END
                                        ||CASE WHEN '20240621' < CLS_APPDT THEN SUBCLASS_CD_OLD ELSE SUBCLASS_CD END
                                        IN (SELECT ETC_CD FROM GSSCODS.TS_MS_ETC_CD_DETAIL WHERE ETC_CLASS_CD = 'MS50'
                                                                                    AND (STAT_SP IS NULL OR STAT_SP <> 'D'))) 
                   AND (SELECT DECODE(SIGN(TO_CHAR(SYSDATE,'YYYYMMDD') - BIZPL_CNF_CD_VAL_APPDT), -1, BIZPL_CNF_CD_VAL_OLD, BIZPL_CNF_CD_VAL)
                          FROM GSSCODS.TS_SS_BIZPL_CNF
                         WHERE BIZPL_CNF_CD = 'KTG_APPROVAL_YN' /*담배인허가여부*/
                           AND BIZPL_CNF_APP_SCOPE_SP_CD = 'V6M86') <> 'Y'
              THEN 'N'
              ELSE 'Y' 
         END = 'Y'
     AND substr(ord_posbl_dow_sp,to_char(to_date(ginfo.ord_dt,'YYYYMMDD'),'D'),1) = 'Y'  /* 발주가능요일 */
     AND (CASE WHEN bizpl_cmkt_yn  = 'Y' THEN 'N' ELSE goods_cmkt_yn END)         = 'N'
     AND NOT (nvl(close_dt,'99991231') < ginfo.goods_stkin_plan_dd AND af_bizpl_cd IS NULL)

     AND CASE WHEN cg.goods_cd IS NULL
              THEN CASE WHEN tm_yn = 'N'
                        THEN ginfo.goods_stat
                        ELSE tm_stat
                   END
              ELSE CASE WHEN cg.goods_stat_appdt > '20240621'
                        THEN CASE WHEN cg.goods_stat_old = 'M' AND tm_yn = 'Y'
                                  THEN tm_stat
                                  ELSE cg.goods_stat_old
                             END
                        ELSE CASE WHEN cg.goods_stat = 'M' AND tm_yn = 'Y'
                                  THEN tm_stat
                                  ELSE cg.goods_stat
                             END
                    END
          END = 'M'
ORDER BY  ginfo.rbt_cd, ginfo.goods_cd
