/*상품별센터목록조회*/
        SELECT DECODE(e.center_bizpl_cd, NULL, 0, 1) AS chk_flag
              ,a.center_bizpl_cd
              ,i.goods_region_nm                  /* 상품지역명 */
              ,(CASE WHEN h.goods_stat_app_dt > TO_CHAR(SYSDATE, 'YYYYMMDD')
                     THEN h.goods_stat_old
                     ELSE h.goods_stat
                END) AS region_goods_stat         /* 지역상품상태 */
              ,b.abr_bizpl_nm AS center_bizpl_nm  /* 단축사업장명*/
              ,e.goods_stat_cd                    /* 상품상태코드*/
              ,e.goods_stat_cd_old
              ,e.goods_stat_app_dt
              ,DECODE(a.avg_rcvo_qty, NULL, 0, a.avg_rcvo_qty)   AS avg_rcvo_qty /* 평균수주수량 */
            /*GRIT-143898 상품별거래처발주관리와 가용재고 데이터 일치화*/
              ,DECODE(l.avail_stk_qty, NULL, 0, l.avail_stk_qty) AS avail_stk_qty /* 가용재고  */
            /*GRIT-131227  가맹지원시스템 재고 데이터 일치화 요청(원래 컬럼으로 변경)*/
              --,DECODE(f.avail_stk_qty, NULL, 0, f.avail_stk_qty) AS avail_stk_qty
            /*GRIT-103025  가맹지원시스템 센터별 상품상태관리 내 재고 컬럼 수정 요청*/
              --,DECODE(f.ORG_AVAIL_STK_QTY, NULL, 0, f.ORG_AVAIL_STK_QTY) AS avail_stk_qty
              ,a.goods_cd
              ,e.goods_stat_resn_cd
              ,(CASE WHEN h.goods_stat_app_dt > TO_CHAR(SYSDATE, 'YYYYMMDD')
                     THEN h.goods_stat_old
                     ELSE h.goods_stat
                END) AS goods_region_stat   /* 상품지역상태 */
              ,nvl(e.use_yn,'Y') as use_yn  /* 사용여부 */
              ,e.trade_ord_stat_app_dt      /* 거래처발주상태적용일자 */
              ,e.trade_ord_stat_cd          /* 거래처발주상태코드 */
              ,e.trade_ord_stat_cd_old      /* 거래처발주상태코드_구 */
              ,e.re_ord_app_dt              /* 재발주적용일 */
              ,e.eai_snd_sp                 /* eai전송여부 */
              ,(CASE WHEN j.goods_dctc_sp_app_dt > TO_CHAR(SYSDATE, 'YYYYMMDD')
                     THEN j.goods_dctc_sp_old
                     ELSE j.goods_dctc_sp
                END) AS goods_dctc_sp   /* 상품DCTC구분 VARCHAR2(1) */
              ,k.purchase_cd                /* 구매조건코드*/
              ,k.purchase_nm                /* 구매조건명*/
             -- ,e.rplc_goods_cd              /* 대체상품코드*/
             -- ,FN_GET_GOODS_NM(e.rplc_goods_cd) as rplc_goods_nm  /* 대체상품명*/
          FROM GSHQADM_TL_ML_STK_MNG              A /* ML_재고관리 */
              ,GSHQADM_TH_MS_ENTPRZ_BIZPL         B
              ,GSHQADM_TL_ML_CENTER_ORD_GOODS_MNG E /* ML_센터발주상품관리 */
              ,GSHQADM_TL_ST_WMS_AVAIL_STK        F /* WMS가용재고관리 */
              ,GSHQADM_TH_MS_BIZPL                G
              ,GSHQADM_TH_MS_GOODS_DETAIL         H
              ,GSHQADM_TH_MS_GOODS_REGION         I
              ,GSHQADM_TH_MS_GOODS                J
              ,GSHQADM_TE_WM_AVAIL_STK_RCV        L /* GRIT-143898 WMS 가용재고수신 테이블 추가*/
              ,(SELECT x1.goods_stkin_bizpl_cd
                      ,x1.goods_cd
                      ,x2.purchase_cd
                      ,x2.purchase_nm
                  FROM th_ms_goods_stkin_bizpl x1
                     , th_ms_purchase x2
                WHERE (CASE WHEN x1.purchase_ord_app_dt > TO_CHAR(SYSDATE,'YYYYMMDD')
                            THEN x1.purchase_cd_old
                            ELSE x1.purchase_cd
                       END) = x2.purchase_cd
                 AND x1.goods_stkin_bizpl_seq = 1) k
         WHERE a.center_bizpl_cd   = e.center_bizpl_cd(+)
           AND a.goods_cd          = e.goods_cd(+)
           AND a.center_bizpl_cd   = b.bizpl_cd
           AND a.center_bizpl_cd   = f.center_bizpl_cd(+)
           AND a.goods_cd          = f.goods_cd(+)
           AND a.center_bizpl_cd   = g.bizpl_cd
           AND a.goods_cd          = h.goods_cd
           AND a.center_bizpl_cd   = k.goods_stkin_bizpl_cd(+)
           AND a.goods_cd          = k.goods_cd(+)
           AND (CASE WHEN g.goods_region_cd_app_dt > TO_CHAR(SYSDATE, 'YYYYMMDD')
                     THEN g.goods_region_cd_old
                     ELSE g.goods_region_cd
                END)               = h.goods_region_cd
           AND a.goods_cd          = ${goodsCd}   /* P 상품코드*/
           AND h.goods_region_cd   = i.goods_region_cd
           AND a.goods_cd          = j.goods_cd
           AND a.center_bizpl_cd   = l.center_bizpl_cd(+)
           AND a.goods_cd          = l.goods_cd(+)
           AND a.center_bizpl_cd   = ${centerBizplCd} /* P 센터코드*/
         ORDER BY h.goods_region_cd, a.center_bizpl_cd






,(CASE WHEN h.goods_stat_app_dt > TO_CHAR(SYSDATE, 'YYYYMMDD')
                     THEN h.goods_stat_old
                     ELSE h.goods_stat
                END) AS goods_region_stat   /* 상품지역상태 */

FROM GSHQADM_TL_ML_CENTER_ORD_GOODS_MNG



SELECT
    goods_cd,
    CASE
        WHEN MIN(stst) = MAX(stst) THEN MIN(stst)
        ELSE 'MIX'
    END AS stst_group
FROM (
    SELECT
        goods_cd,
        CASE
            WHEN goods_stat_app_dt > date_format(current_date, '%Y%m%d')
                THEN goods_stat_cd_old
            ELSE goods_stat_cd
        END AS stst
    FROM GSHQADM_TL_ML_CENTER_ORD_GOODS_MNG
    WHERE goods_cd IN ('8809971931212')
) t
GROUP BY goods_cd;




select goods_stat_cd from GSHQADM_TL_ML_CENTER_ORD_GOODS_MNG GROUP BY 1


select goods_cd,
 (CASE WHEN goods_stat_app_dt > TO_CHAR(SYSDATE, 'YYYYMMDD')
                     THEN goods_stat_old
                     ELSE goods_stat
                END) AS goods_region_stat
FROM GSHQADM_TH_MS_GOODS_DETAIL
where GOODS_REGION_CD = '01'



