
import requests
from PIL import Image
from io import BytesIO
import openpyxl
import os
import webbrowser

# 세션 생성
session = requests.Session()


# URL 설정
baseurl = 'http://cvsscn.gsretail.com/cssc/portal/portal/Login.do'
url = 'http://cvsscn.gsretail.com/FileView.dwn'
fileSearch_url ='http://cvsscn.gsretail.com/cssc/common/RetrieveGoodList.do'

# 헤더 설정
headers = headers = {
    'Accept': 'application/xml, text/xml, */*',
    'Accept-Encoding': 'gzip, deflate',
    'Accept-Language': 'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7',
    'Cache-Control': 'no-cache, no-store',
    'Connection': 'keep-alive',
    'Content-Length': '700',
    'Content-Type': 'text/xml',
    'Cookie': 'WMONID=zGMRj_qMn58',
    'Expires': '-1',
    'Host': 'cvsscn.gsretail.com',
    'If-Modified-Since': 'Thu, 01 Jun 1970 00:00:00 GMT',
    'Origin': 'http://cvsscn.gsretail.com',
    'Pragma': 'no-cache',
    'Referer': 'http://cvsscn.gsretail.com/cssc/index.html',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36',
    'X-Requested-With': 'XMLHttpRequest'
}


payload_base = 'SSV:utf-8WMONID=zGMRj_qMn58Dataset:ds_login_RowType_USER_ID:STRING(256)PASSWD:STRING(256)URL:STRING(256)IP_INFO:STRING(256)SMS_AUTH:STRING(256)CONN_SYS_SP:STRING(256)CONN_SHPE_SP_CD:STRING(256)CONN_SUCC_YN:STRING(256)CONN_ERR_MSG_CD:STRING(256)CONN_CNF_SP_CD:STRING(256)LOG_CRT_YN:STRING(256)CONN_ERR_MSG_DTL:STRING(256)CONN_RESTR_FUNC_USE_YN:STRING(256)N2910508616017DC47907B85DAE0D3EB51F63F13B648A4BB76DDDECISICY'
# 로그인 데이터 설정
payload_search = 'SSV:utf-8WMONID=s1YTl2HPVGlCUR_PGM_ID=SMSGO02_GoodsMstDetailMDataset:ds_inInqCondSearch_RowType_ORIGIN_BIZPL_CD:STRING(256)GOODS_REGION_CD:STRING(256)CLASS_CD:STRING(256)GOODS_CD:STRING(256)GOODS_NM:STRING(256)BIZPL_CD:STRING(256)N88002798빙그레)바나나우유240ML'

payload_search = payload_search.encode('utf-8')

base_response = session.post(baseurl, data=payload_base, headers=headers)
respon_cookie = base_response.headers.get('Set-Cookie')
if respon_cookie :
    headers['Cookie'] = respon_cookie
    print(respon_cookie)

if base_response.status_code == 200:
    response = session.post(fileSearch_url, data=payload_search, headers=headers)
    print(response.text)
    print('ok')
else:
    print('no')



# 파일이름들
fileNms = []

# 엑셀 파일 열기
wb = openpyxl.load_workbook('your_excel_file.xlsx')  # 엑셀 파일 경로 및 이름 수정
sheet = wb.active

# 엑셀 파일 순회하며 이미지 파일 다운로드
for row in sheet.iter_rows(min_row=2, values_only=True):  # 첫 번째 행은 헤더이므로 무시
    file_name = row[0]  # 파일명은 첫 번째 열에 위치
    fileNms = file_name
    # 파일 다운로드 요청
    print(file_name)
    file_url = f'http://cvsscn.gsretail.com/FileView.dwn?fileNm={fileNms}'
    response = session.get(file_url, data=payload_base, headers=headers)

 # 파일 저장
    if response.status_code == 200:
        file_data = response.content
        try:
            imagee =  Image.open(BytesIO(file_data))
            imagee.show()
            print(imagee)

        except Exception as e:
            print('오류발생')
            fileNms = fileNms.replace('001.jpg','002.jpg')
            file_url = f'http://cvsscn.gsretail.com/FileView.dwn?fileNm={fileNms}'
            response = session.get(file_url, data=payload_base, headers=headers)
            file_path = os.path.join('img', fileNms)  # 이미지 파일 경로
            file_data = response.content

        file_path = os.path.join('img', fileNms)  # 이미지 파일 경로
        with open(file_path, 'wb') as f:
            f.write(file_data)
        print(f'파일 다운로드 완료: {file_name}')
    else:
        print(f'파일 다운로드 실패: {file_name}')
else:
    print(f'로그인 실패: {file_name}')

# 엑셀 파일 닫기
wb.close()
