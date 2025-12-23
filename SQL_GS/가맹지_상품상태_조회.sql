
        SELECT COUNT(*) AS list_cnt
          FROM (SELECT g.goods_region_cd    /* [PK] 상품지역코드 VARCHAR2(2) */
                     , r.goods_region_nm    /* 상품지역명 VARCHAR2(20) */
                     , p.depart_cd          /* 대분류코드 VARCHAR2(2) */      /* [CR190122032] 대분류  VARCHAR2(2) */
                     , p.depart_nm          /* 대분류명 VARCHAR2(20) */      /* [CR190122032] 대분류  VARCHAR2(20) */
                     , g.line_cd            /* 중분류코드 VARCHAR2(2) */
                     , l.line_nm            /* 중분류명 VARCHAR2(20) */
                     , g.class_cd           /* 소분류코드 VARCHAR2(2) */
                     , c.class_nm           /* 소분류명 VARCHAR2(20) */
                     , g.subclass_cd        /* 세분류코드 VARCHAR2(2) */
                     , s.subclass_nm        /* 세분류명 VARCHAR2(20) */
                     , g.goods_cd           /* [PK] 상품코드 VARCHAR2(13) */
                     , g.goods_nm           /* 상품명 VARCHAR2(30) */
                     , g.box_per_qty        /* 상자당수량 NUMBER(7) */
                     , g.ord_min_qty        /* 발주최소수량 NUMBER(7) */
                     , g.decson_base        /* 판단기준 VARCHAR2(1) */
                     , g.ord_unit           /* 발주단위 NUMBER(5) */
                     , g.ord_max_qty        /* 발주최대수량 NUMBER(7) */
                     , g.goods_stat         /* 상품상태 VARCHAR2(1) */
                     , g.goods_stat_app_dt  /* 상품상태적용일자 VARCHAR2(8) */
                     , g.ord_app_dt         /* 발주적용일자 VARCHAR2(8) */
                     , g.cost               /* 원가 NUMBER(11, 2) */
                     , g.prc                /* 매가 NUMBER(9) */
                     , g.cmkt_prc           /* C마켓매가 NUMBER(11, 2) */
                     , CASE WHEN g.prc <> 0 THEN g.profit_rate ELSE 0 END AS profit_rate /* [201838M] 매가 0이 아닐때만 매익율 계산. */
                     , g.sale_only_cd_yn    /* 판매전용코드여부 VARCHAR2(1) */
                     , g.multi_vndr_no      /* 다벤더번호 VARCHAR2(2) */
                     , m.multi_vndr_nm      /* 다벤더명 VARCHAR2(30) */
                     , g.dist_co_cd         /* 배송처코드 VARCHAR2(6) */
                     , d.dist_co_nm         /* 배송처명 VARCHAR2(40) */
                     , e.etc_cd_nm          /* 공통코드명 VARCHAR2(100) */
                     , g.lct_cons_type_cd   /* 입지강화유형코드 VARCHAR2(4) */
                     , f.lct_cons_type_nm   /* 입지강화유형명 VARCHAR2(40) */
                     , g.cmkt_yn            /* C마켓여부 VARCHAR2(1) */
                     , g.rtn_posbl_yn       /* 반품가능여부 VARCHAR2(1) */
                     , g.harmful_goods_yn   /* 유해상품여부 VARCHAR2(1) */
                     , g.pb_goods_sp        /* PB상품구분 VARCHAR2(1) */
                     , g.goods_rank         /* 상품등급 VARCHAR2(1) */
                  FROM TH_MS_LINE l            /* MS_중분류 */
                     , TH_MS_CLASS c           /* MS_소분류 */
                     , TH_MS_SUBCLASS s        /* MS_세분류 */
                     , TH_MS_GOODS_REGION r    /* MS_상품지역 */
                     , TH_MS_MULTI_VNDR m      /* MS_다벤더 */
                     , TH_MS_DIST_CO d         /* MS_배송처 */
                     , TH_SS_ETC_CD_DETAIL  e  /* SS_공통코드상세 */
                     , TH_MS_LCT_CONS_TYPE f   /* MS_입지강화유형 */
                     , ( SELECT b.goods_region_cd
                              , a.goods_cd
                              , a.goods_nm
                              , DECODE(SIGN(a.cls_app_dt - '20251217'), 1, a.line_cd_old, a.line_cd)                   AS line_cd
                              , DECODE(SIGN(a.cls_app_dt - '20251217'), 1, a.class_cd_old, a.class_cd)                 AS class_cd
                              , DECODE(SIGN(a.cls_app_dt - '20251217'), 1, a.subclass_cd_old, a.subclass_cd)           AS subclass_cd
                              , DECODE(SIGN(a.box_per_qty_app_dt - '20251217'), 1, a.box_per_qty_old, a.box_per_qty)   AS box_per_qty
                              , DECODE(SIGN(b.ord_posbl_qty_app_dt - '20251217'), 1, b.ord_min_qty_old, b.ord_min_qty) AS ord_min_qty
                              , DECODE(SIGN(b.ord_posbl_qty_app_dt - '20251217'), 1, b.ord_unit_old, b.ord_unit)       AS ord_unit
                              , DECODE(SIGN(b.ord_posbl_qty_app_dt - '20251217'), 1, b.ord_max_qty_old, b.ord_max_qty) AS ord_max_qty
                              , DECODE(SIGN(b.goods_stat_app_dt - '20251217'), 1, b.goods_stat_old, b.goods_stat)      AS goods_stat
                              , b.goods_stat_app_dt
                              , b.ord_app_dt
                              , a.sale_only_cd_yn
                           /* , DECODE(SIGN(b.cost_app_dt -  {baseDt}), 1, b.cost_old, b.cost)                        AS cost */
                              ,(SELECT FN_GET_GOODS_COST('1', '1:2', '20251217', a.goods_cd, '2', b.goods_region_cd) FROM DUAL) AS cost                 /* 원가   - [201831M] 적용원가 반영  */
                              ,(SELECT FN_GET_GOODS_COST('2', '1:2', '20251217', a.goods_cd, '2', b.goods_region_cd) FROM DUAL) AS profit_rate  /* 매익율 - [201831M] 적용원가 반영 - 성능개선으로 Biz에서 Query로 옮김 - start */
                              , DECODE(SIGN(b.prc_app_dt - '20251217'), 1, b.prc_old, b.prc)                           AS prc
                              , DECODE(SIGN(b.cmkt_prc_app_dt - '20251217'), 1, b.cmkt_prc_old, b.cmkt_prc)            AS cmkt_prc
                              , DECODE(SIGN(a.vat_sp_app_dt - '20251217'), 1, a.vat_sp_old, a.vat_sp)                  AS vat_sp
                              , DECODE(a.btl_hld_yn, 'Y', NVL(DECODE(SIGN(c.btl_deposit_amt_uprc_app_dt - '20251217'), 1, c.btl_deposit_amt_uprc_old, c.btl_deposit_amt_uprc), 0), 0 ) AS btl_deposit_amt_uprc
                              , DECODE(SIGN(b.multi_vndr_no_app_dt - '20251217'), 1, b.multi_vndr_no_old, b.multi_vndr_no) AS multi_vndr_no
                              , DECODE(SIGN(b.dist_co_app_dt - '20251217'), 1, b.dist_co_cd_old, b.dist_co_cd)         AS dist_co_cd
                              , CASE WHEN TO_CHAR(SYSDATE, 'yyyymmdd') BETWEEN b.goods_rank_app_start_dt AND b.goods_rank_app_end_dt
                                     THEN b.goods_rank
                                     ELSE '2'
                                 END goods_rank
                              , ( SELECT NVL(etc_cd_nm,'')
                                    FROM TH_SS_ETC_CD_DETAIL  /* SS_공통코드상세 */
                                   WHERE etc_class_cd = 'MS046'
                                     AND etc_cd       = a.decson_base
                                ) AS decson_base
                              , a.lct_cons_type_cd
                              , a.cmkt_yn
                              , b.rtn_posbl_yn
                              , a.harmful_goods_yn
                              , ( SELECT NVL(etc_cd_nm,'')
                                    FROM TH_SS_ETC_CD_DETAIL  /* SS_공통코드상세 */
                                   WHERE etc_class_cd = 'MS053'
                                     AND etc_cd       = DECODE(SIGN(a.pb_goods_app_dt - '20251217' ), 1, a.pb_goods_sp_old, a.pb_goods_sp)
                                ) AS pb_goods_sp
                           FROM TH_CA_GOODS_BTL c     /* CA_상품공병 */
                              , TH_MS_GOODS_DETAIL b  /* MS_상품상세 */
                              , TH_MS_GOODS a         /* MS_상품 */
                          WHERE a.goods_cd        = c.goods_cd(+)
                            AND a.goods_cd        = b.goods_cd
                            AND a.goods_regi_stat = 'A'
                            AND b.goods_region_cd = '01' 
                            
                            /* [CR201021056] 대상상품 수 계산 쿼리를 추출 쿼리와 동일하게 변경 */
                            AND TO_CHAR(a.regi_dttm, 'yyyymmdd') <= '20251217'
                       ) g
                       , TH_MS_DEPART p            /* MS_대분류 */                   /* [CR190122032] 대분류 추가 */
                 WHERE g.line_cd          = l.line_cd
                   AND g.line_cd          = c.line_cd
                   AND g.class_cd         = c.class_cd
                   AND g.line_cd          = s.line_cd
                   AND g.class_cd         = s.class_cd
                   AND g.subclass_cd      = s.subclass_cd
                   AND g.goods_region_cd  = r.goods_region_cd
                   AND g.multi_vndr_no    = m.multi_vndr_no(+)
                   AND g.dist_co_cd       = d.dist_co_cd(+)
                   AND g.lct_cons_type_cd = f.lct_cons_type_cd(+)
                   AND g.goods_rank       = e.etc_cd
                   AND e.etc_class_cd     = 'MS059'
                   AND l.depart_cd        = p.depart_cd                            /* [CR190122032] 대분류 추가 */
                   AND g.goods_stat <> 'D' 
               )
        /* ONLINE : [CSHQ.md.goods].[TH_MS_GOODS.xml].[countGoodsMstExcelInfoList] */

