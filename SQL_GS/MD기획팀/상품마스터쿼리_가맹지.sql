/* 편의점 운영팀 김형진 M 전달 받은 쿼리문 
   가맹지원시스템 상품마스터의 출력 쿼리 */

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
                -- , f.lct_cons_type_nm   /* 입지강화유형명 VARCHAR2(40) */
                , g.cmkt_yn            /* C마켓여부 VARCHAR2(1) */
                , g.rtn_posbl_yn       /* 반품가능여부 VARCHAR2(1) */
                , g.harmful_goods_yn   /* 유해상품여부 VARCHAR2(1) */
                , g.pb_goods_sp        /* PB상품구분 VARCHAR2(1) */
                , g.goods_rank         /* 상품등급 VARCHAR2(1) */
            FROM gshqadm.TH_MS_LINE l            /* MS_중분류 */
                , gshqadm.TH_MS_CLASS c           /* MS_소분류 */
                , gshqadm.TH_MS_SUBCLASS s        /* MS_세분류 */
                , gshqadm.TH_MS_GOODS_REGION r    /* MS_상품지역 */
                , gshqadm.TH_MS_MULTI_VNDR m      /* MS_다벤더 */
                , gshqadm.TH_MS_DIST_CO d         /* MS_배송처 */
                , gshqadm.TH_SS_ETC_CD_DETAIL  e  /* SS_공통코드상세 */
                -- , gshqadm.TH_MS_LCT_CONS_TYPE f   /* MS_입지강화유형 */
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
                            FROM gshqadm.TH_SS_ETC_CD_DETAIL  /* SS_공통코드상세 */
                            WHERE etc_class_cd = 'MS046'
                                AND etc_cd       = a.decson_base
                        ) AS decson_base
                        , a.lct_cons_type_cd
                        , a.cmkt_yn
                        , b.rtn_posbl_yn
                        , a.harmful_goods_yn
                        , ( SELECT NVL(etc_cd_nm,'')
                            FROM gshqadm.TH_SS_ETC_CD_DETAIL  /* SS_공통코드상세 */
                            WHERE etc_class_cd = 'MS053'
                                AND etc_cd       = DECODE(SIGN(a.pb_goods_app_dt - '20251217' ), 1, a.pb_goods_sp_old, a.pb_goods_sp)
                        ) AS pb_goods_sp
                    FROM gshqadm.TH_CA_GOODS_BTL c     /* CA_상품공병 */
                        , gshqadm.TH_MS_GOODS_DETAIL b  /* MS_상품상세 */
                        , gshqadm.TH_MS_GOODS a         /* MS_상품 */
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





------------------   athena 쿼리 로 변환 하기 ----------------------

-- Athena / Trino SQL
-- base_dt = '20251217'
-- select count(*) as counts
-- from (
SELECT g.goods_region_cd, /*[PK] 상품지역코드 VARchar2(2) */
	r.goods_region_nm,  -- 상품지역명
	p.depart_cd,  -- 대분류코드 VARCHAR(2) 대분류 VARCHAR2(2)
	p.depart_nm,  -- 대분류명 (VARCHAR20))
	g.line_cd,   -- 중분류코드
	l.line_nm,   -- 중분류명
	g.class_cd,  -- 소분류코드
	c.class_nm,  -- 소분류명
	g.subclass_cd,  -- 세분류코드
	s.subclass_nm,  -- 세분류명
	g.goods_cd,  -- 상품코드
	g.goods_nm,  -- 상품명
	g.box_per_qty,  -- 상자당수량
	g.ord_min_qty,  -- 발주최소수량
	g.decson_base,  -- 판단기준
	g.ord_unit,  -- 발주단위
	g.ord_max_qty,  -- 최대발주수량
	g.goods_stat,  -- 상품상태
	g.goods_stat_app_dt,  -- 상태적용일자
	g.ord_app_dt,  -- 발주적용일자
	g.cost,  -- 원가
	g.prc,  -- 매가
	g.cmkt_prc,  -- c마켓매가
	CASE WHEN g.prc <> 0 THEN g.profit_rate ELSE 0 END AS profit_rate,  -- 매가 0이 아닐때만 매익률 개산
	g.sale_only_cd_yn,  -- 판매전용코드여부
	g.multi_vndr_no,  -- 다벤더번호
	m.multi_vndr_nm,  -- 다벤드명
	g.dist_co_cd,  -- 배송처코드
	d.dist_co_nm,  -- 배송처명
	e.etc_cd_nm,  -- 공통코드명
	g.lct_cons_type_cd,  -- 특화점 코드
	--f.lct_cons_type_nm,
	g.cmkt_yn,  -- C마켓 여부
	g.rtn_posbl_yn,  -- 반품가능 여부
	g.harmful_goods_yn,  -- 유해상품 여부
	g.pb_goods_sp,  -- pb상품구분
	g.goods_rank  -- 상품등급
FROM (
		SELECT b.goods_region_cd,
			a.goods_cd,
			a.goods_nm -- DECODE(SIGN(date - base), 1, old, new) 패턴 → CASE로 변환
,
			CASE WHEN a.cls_app_dt > '20251217' THEN a.line_cd_old ELSE a.line_cd END AS line_cd,
			CASE WHEN a.cls_app_dt > '20251217' THEN a.class_cd_old ELSE a.class_cd	END AS class_cd,
			CASE WHEN a.cls_app_dt > '20251217' THEN a.subclass_cd_old ELSE a.subclass_cd END AS subclass_cd,
			CASE WHEN a.box_per_qty_app_dt > '20251217' THEN a.box_per_qty_old ELSE a.box_per_qty END AS box_per_qty,
			CASE WHEN b.ord_posbl_qty_app_dt > '20251217' THEN b.ord_min_qty_old ELSE b.ord_min_qty END AS ord_min_qty,
            CASE WHEN b.ord_posbl_qty_app_dt > '20251217' THEN b.ord_unit_old ELSE b.ord_unit END AS ord_unit,
			CASE WHEN b.ord_posbl_qty_app_dt > '20251217' THEN b.ord_max_qty_old ELSE b.ord_max_qty END AS ord_max_qty,
			CASE WHEN b.goods_stat_app_dt > '20251217' THEN b.goods_stat_old ELSE b.goods_stat
			END AS goods_stat,
			b.goods_stat_app_dt,
			b.ord_app_dt,
			a.sale_only_cd_yn -- ⚠️ Oracle 사용자정의 함수는 Athena에서 호출 불가 → 대체 필요
,
			CAST(NULL AS double) AS cost,
			CAST(NULL AS double) AS profit_rate,
			CASE
				WHEN b.prc_app_dt > '20251217' THEN b.prc_old ELSE b.prc
			END AS prc,
			CASE
				WHEN b.cmkt_prc_app_dt > '20251217' THEN b.cmkt_prc_old ELSE b.cmkt_prc
			END AS cmkt_prc,
			CASE
				WHEN a.vat_sp_app_dt > '20251217' THEN a.vat_sp_old ELSE a.vat_sp
			END AS vat_sp -- NVL/DECODE 혼합 → COALESCE + CASE
,
			CASE
				WHEN b.multi_vndr_no_app_dt > '20251217' THEN b.multi_vndr_no_old ELSE b.multi_vndr_no
			END AS multi_vndr_no,
			CASE
				WHEN b.dist_co_app_dt > '20251217' THEN b.dist_co_cd_old ELSE b.dist_co_cd
			END AS dist_co_cd -- SYSDATE → current_date / current_timestamp
			-- TO_CHAR(SYSDATE,'yyyymmdd') BETWEEN ... : 문자열 비교로 유지(데이터가 yyyymmdd 문자열이라면)
,
			CASE
				WHEN date_format(current_date, '%Y%m%d') BETWEEN b.goods_rank_app_start_dt AND b.goods_rank_app_end_dt THEN b.goods_rank ELSE '2'
			END AS goods_rank -- 상관서브쿼리(공통코드명)
,
			(
				SELECT COALESCE(etc_cd_nm, '')
				FROM gshqadm_TH_SS_ETC_CD_DETAIL
				WHERE etc_class_cd = 'MS046'
					AND etc_cd = a.decson_base
			) AS decson_base,
			a.lct_cons_type_cd,
			a.cmkt_yn,
			b.rtn_posbl_yn,
			a.harmful_goods_yn,
			(
				SELECT COALESCE(etc_cd_nm, '')
				FROM gshqadm_TH_SS_ETC_CD_DETAIL
				WHERE etc_class_cd = 'MS053'
					AND etc_cd = CASE
						WHEN a.pb_goods_app_dt > '20251217' THEN a.pb_goods_sp_old ELSE a.pb_goods_sp
					END
			) AS pb_goods_sp
		FROM gshqadm_TH_MS_GOODS a
			JOIN gshqadm_TH_MS_GOODS_DETAIL b ON a.goods_cd = b.goods_cd
			AND b.goods_region_cd = '01'
		WHERE a.goods_regi_stat = 'A' -- TO_CHAR(a.regi_dttm,'yyyymmdd') <= '20251217'
			AND date_format(a.regi_dttm, '%Y%m%d') <= '20251217'
	) g 
	
	-- 여기부터가 Oracle WHERE 조인(+ 포함) → ANSI JOIN 변환
	JOIN gshqadm_TH_MS_LINE l ON g.line_cd = l.line_cd
	JOIN gshqadm_TH_MS_CLASS c ON g.line_cd = c.line_cd
	AND g.class_cd = c.class_cd
	JOIN gshqadm_TH_MS_SUBCLASS s ON g.line_cd = s.line_cd
	AND g.class_cd = s.class_cd
	AND g.subclass_cd = s.subclass_cd
	JOIN gshqadm_TH_MS_GOODS_REGION r ON g.goods_region_cd = r.goods_region_cd
	LEFT JOIN gshqadm_TH_MS_MULTI_VNDR m ON g.multi_vndr_no = m.multi_vndr_no
	LEFT JOIN gshqadm_TH_MS_DIST_CO d ON g.dist_co_cd = d.dist_co_cd --   LEFT JOIN gshqadm_TH_MS_LCT_CONS_TYPE f
	--     ON g.lct_cons_type_cd = f.lct_cons_type_cd
	JOIN gshqadm_TH_SS_ETC_CD_DETAIL e ON g.goods_rank = e.etc_cd
	AND e.etc_class_cd = 'MS059'
	JOIN gshqadm_TH_MS_DEPART p ON l.depart_cd = p.depart_cd





















WITH
-- 1) 원본 조건을 그대로 적용한 필터링 결과(한 번만 스캔)
BASE_SALES AS (
    SELECT
        A11.YMCD,
        A11.GOODCD,
        A11.NTSAL_AMT,
        A11.STORE_CNT
    FROM LGMJVDP.TB_STK_MTG_AG A11
    JOIN LGMJVDP.TB_GOOD_DM     A12 ON A11.GOODCD = A12.GOODCD
    WHERE
        -- 날짜 조건: BETWEEN 하나로 단일화 (원본 YMCD IN 은 YYYYMM 범위로 포함됨)
        A11.YMCD BETWEEN '202412' AND '202511'
        -- 원본의 중분류/대분류 제외 조건 유지
        AND A12.GOOD_CLS2CD NOT IN (
            '4403','4518','4618','0604','0104','0204','0405','0508','8106','1608','1707','1807','2107','2205','2306','2408','2509','2617','2712','2810','2906','3009','3104','3206','3308','3407','3517','3608','3712','3809','4204','6116','6613','6713','6907','7009','7111','7209','7309','7508','7612','7718','7810','7910','8006','0714','0810','0903','1304','1614','1910','2112','2310','2405','2516','2632','2722','2818','3014','3210','3314','3412','3532','3614','3722','3815','4617','4906','5106','5203','5303','5405','5505','5603','5706','5708','5909','6007','6114','6209','6404','6711','6905','7610','7716','7808','7908','5204','9003','0712','0808','1103','1106','1109','1303','1605','1705','2104','2303','2404','2506','2614','2807','3709','4003','4517','5404','5504','5602','5705','6006','6113','6208','6609','6709','6804','6904','7109','7207','7609','7715','7807','7907','8004','0103','0203','0304','0404','0605','0713','0809','0904','1305','1404','1506','1607','1706','1806','1905','2005','2106','2204','2305','2406','2508','2616','2711','2809','2905','3006','3103','3205','3307','3406','3516','3607','3711','3808','3907','4004','4203','4307','4317','4507','4519','4606','4619','4708','4803','4908','5304','5406','5506','5604','5707','5806','5910','6008','6115','6210','6307','6405','6610','6712','6805','6906','7008','7110','7208','7308','7507','7611','7717','7809','7909','8005','9116','0505','7607','0506'
        )
        AND A12.GOOD_CLS1CD NOT IN ('65','66','90','91')
        -- 상품명 제외(원본 정규식 유지)
        AND NOT REGEXP_LIKE(
            A12.GOODNM,
            '특화|한강공원|소모|이벤|특정|특판|TEST|아주대|TEST|주문|행사|예약|판촉|아동|군PX|뮤비페|우한|잼버리|백병원|경쟁사|마사|식풘|야구장|축구장|잠실|CASE$'
        )
),
-- 2) 지역코드 '01' 기준 최신 1건만 확정
GOODS_DETAIL_LATEST AS (
    SELECT GOODS_CD, GOODS_REGION_CD, ORD_APP_DT, GOODS_STAT
    FROM (
        SELECT
            A14.GOODS_CD,
            A14.GOODS_REGION_CD,
            A14.ORD_APP_DT,
            A14.GOODS_STAT,
            ROW_NUMBER() OVER (
                PARTITION BY A14.GOODS_CD, A14.GOODS_REGION_CD
                ORDER BY A14.ORD_APP_DT DESC
            ) AS RN
        FROM GSCSODS.TH_MS_GOODS_DETAIL A14
        WHERE A14.GOODS_REGION_CD = '01'
    ) T
    WHERE T.RN = 1
),
-- 3) 최종 집계 (원본 HAVING: SUM(NTSAL_AMT) > 0 유지)
FINAL_SALE AS (
    SELECT
        DM.GOOD_CLS0CD                                  AS GOOD_CLS0CD,
        MAX(DM.GOOD_CLS0NM)                             AS GOOD_CLS0NM,
        DM.GOOD_CLS1CD                                  AS GOOD_CLS1CD,
        MAX(DM.GOOD_CLS1NM)                             AS GOOD_CLS1NM,
        DM.GOOD_CLS2CD                                  AS GOOD_CLS2CD,
        MAX(DM.GOOD_CLS2NM)                             AS GOOD_CLS2NM,
        BS.GOODCD                                       AS GOODCD,
        MAX(GL.ORD_APP_DT)                              AS RELEASE_DT,
        MAX(TRIM(TRAILING FROM DM.GOODNM))              AS GOODNM,
        MAX(GL.GOODS_STAT)                              AS GOODS_STATUS,
        SUM(BS.NTSAL_AMT)                               AS TOTSAL_AMT,
        SUM(BS.STORE_CNT)                               AS STORE_CNT,
        MAX(MS.LCT_CONS_GOODS_YN)                       AS LCT_CONS_GOODS_YN,
        MAX(MS.PB_GOODS_SP)                             AS PB_GOODS_SP
    FROM BASE_SALES BS
    JOIN LGMJVDP.TB_GOOD_DM DM
      ON BS.GOODCD = DM.GOODCD
    JOIN GOODS_DETAIL_LATEST GL
      ON BS.GOODCD = GL.GOODS_CD        -- 지역 '01' 최신 1건 보장
    LEFT JOIN GSCSODS.TH_MS_GOODS MS
      ON BS.GOODCD = MS.GOODS_CD
    GROUP BY
        DM.GOOD_CLS0CD, DM.GOOD_CLS1CD, DM.GOOD_CLS2CD, BS.GOODCD
    HAVING
        SUM(BS.NTSAL_AMT) > 0
)
-- 4) 윈도우 계산(불필요한 GROUP BY 제거)
SELECT
    GOOD_CLS0CD, GOOD_CLS0NM,
    GOOD_CLS1CD, GOOD_CLS1NM,
    GOOD_CLS2CD, GOOD_CLS2NM,
    GOODCD, RELEASE_DT, GOODNM, GOODS_STATUS,
    TOTSAL_AMT, STORE_CNT, LCT_CONS_GOODS_YN, PB_GOODS_SP,
    SUM(STORE_CNT) OVER (PARTITION BY GOOD_CLS2NM) AS STORE_CNT_ALL,
    SUM(TOTSAL_AMT) OVER (
        PARTITION BY GOOD_CLS2NM
        ORDER BY TOTSAL_AMT
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS CUMUL_SALES_AMT_ASC,
    SUM(TOTSAL_AMT) OVER (
        PARTITION BY GOOD_CLS2NM
        ORDER BY TOTSAL_AMT DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS CUMUL_SALES_AMT_DESC,
    (STORE_CNT * 1.0) / NULLIF(SUM(STORE_CNT) OVER (PARTITION BY GOOD_CLS2NM), 0) AS ADOPTION_RATE
FROM FINAL_SALE