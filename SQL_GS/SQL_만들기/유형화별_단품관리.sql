select	a11.GOODCD  GOODCD,
	max(trim(trailing from a12.GOODNM))  GOODNM,
	sum(a11.NTSAL_AMT)  WJXBFS1
from	LGMJVDP.TB_STK_DRG_AG	a11
	join	LGMJVDP.TB_GOOD_DM	a12
	  on 	(a11.GOODCD = a12.GOODCD)
where	(a11.DATECD in ('2022-09-05')
 and a12.GOOD_CLS1CD in ('07', '08', '09', '13', '14', '15', '20', '21', '22', '23', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59', '60', '61', '62', '63', '64', '65', '66', '67', '68', '69', '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '80'))
group by	a11.GOODCD
