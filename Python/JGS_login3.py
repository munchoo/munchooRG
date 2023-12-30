import requests
from PIL import Image
from io import BytesIO
import openpyxl
import os
import re
import pandas as pd
import hashlib

BASE_URL = 'http://cvsscn.gsretail.com'
LOGIN_URL = f'{BASE_URL}/cssc/portal/portal/Login.do'
FILE_SEARCH_URL1 = f'{BASE_URL}/cssc/ord/hqord/RetrieveSkuPerOrdOganList.do'
IMG_ADDRESS_URL = f'{BASE_URL}/cssc/mst/goods/RetrieveGoodsMstDetail.do'
FILE_DOWNLOAD_URL = f'{BASE_URL}/FileView.dwn'

HEADERS = {
    'Accept': 'application/xml, text/xml, */*',
    'Accept-Encoding': 'gzip, deflate',
    'Accept-Language': 'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7',
    'Cache-Control': 'no-cache, no-store',
    'Connection': 'keep-alive',
    'Content-Length': '603',
    'Content-Type': 'text/xml',
    'Expires': '-1',
    'Host': 'cvsscn.gsretail.com',
    'If-Modified-Since': 'Thu, 01 Jun 1970 00:00:00 GMT',
    'Origin': 'http://cvsscn.gsretail.com',
    'Pragma': 'no-cache',
    'Referer': 'http://cvsscn.gsretail.com/cssc/index.html',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36',
    'X-Requested-With': 'XMLHttpRequest'
}

def update_headers(headers, additional_headers):
    updated_headers = headers.copy()
    updated_headers.update(additional_headers)
    return updated_headers

def login(session):
    # payload = 'SSV:utf-8WMONID=zGMRj_qMn58Dataset:ds_login_RowType_USER_ID:STRING(256)PASSWD:STRING(256)URL:STRING(256)IP_INFO:STRING(256)SMS_AUTH:STRING(256)CONN_SYS_SP:STRING(256)CONN_SHPE_SP_CD:STRING(256)CONN_SUCC_YN:STRING(256)CONN_ERR_MSG_CD:STRING(256)CONN_CNF_SP_CD:STRING(256)LOG_CRT_YN:STRING(256)CONN_ERR_MSG_DTL:STRING(256)CONN_RESTR_FUNC_USE_YN:STRING(256)N2910508616017B30911E454F92F08296E224AC3D612CF45704372CISICY'
    payload = f'SSV:utf-8WMONID=zGMRj_qMn58Dataset:ds_login_RowType_USER_ID:STRING(256)PASSWD:STRING(256)URL:STRING(256)IP_INFO:STRING(256)SMS_AUTH:STRING(256)CONN_SYS_SP:STRING(256)CONN_SHPE_SP_CD:STRING(256)CONN_SUCC_YN:STRING(256)CONN_ERR_MSG_CD:STRING(256)CONN_CNF_SP_CD:STRING(256)LOG_CRT_YN:STRING(256)CONN_ERR_MSG_DTL:STRING(256)CONN_RESTR_FUNC_USE_YN:STRING(256)N{lgid}{lgpw.upper()}CISICY'
    payload = payload.encode('utf-8')
    response = session.post(LOGIN_URL, data=payload, headers=HEADERS)
    if response.status_code == 200:
        print('로그인 성공')
        # print(response.headers.get('Set-Cookie'))
        return response.headers.get('Set-Cookie')
    else:
        print(f'로그인 실패: {response.status_code}')
        return None

def search_files(session, cookie):
    match = re.search(r'WMONID=([^;]+)', cookie)
    match2 = re.search(r'JSESSIONID=([^;]+)', cookie)
    if match:
        wmonid = match.group(1)
        # print(wmonid)
    else:
        print("WMONID를 찾을 수 없습니다.")
    if match2:
        JSESSIONID = match2.group(1)
        # print(JSESSIONID)
    else:
        print("JSESSIONID 찾을 수 없습니다.")        

    # headers = HEADERS.copy()
    new_header = update_headers(HEADERS,{'Cookie':f'_ga=GA1.1.99319122.1689267668; _ga_CHSRECZ6BZ=GS1.1.1689292043.2.0.1689292043.60.0.0; WMONID={wmonid}; _ga=GA1.1.99319122.1689267668; _ga_CHSRECZ6BZ=GS1.1.1689292043.2.0.1689292043.60.0.0; JSESSIONID={JSESSIONID}'})
    

    # if cookie :
    #     headers['Cookie'] = f'_ga=GA1.1.99319122.1689267668; _ga_CHSRECZ6BZ=GS1.1.1689292043.2.0.1689292043.60.0.0; WMONID={wmonid}; _ga=GA1.1.99319122.1689267668; _ga_CHSRECZ6BZ=GS1.1.1689292043.2.0.1689292043.60.0.0; JSESSIONID={JSESSIONID}'
    #     headers['Expires'] = '-1'
    #     # print(cookie)

    payload1 = f'SSV:utf-8_ga=GA1.1.99319122.1689267668_ga_CHSRECZ6BZ=GS1.1.1689292043.2.0.1689292043.60.0.0WMONID=j3VXlTEnzv4CUR_PGM_ID=SORHQ03_SkuPerOrdOganMDataset:ds_inInqCond_RowType_ORGAN_SP:STRING(256)ORGAN_CD:STRING(256)ORD_DT:STRING(256)GOODS_CD1:STRING(256)GOODS_CD2:STRING(256)GOODS_CD3:STRING(256)GOODS_CD4:STRING(256)GOODS_CD5:STRING(256)GOODS_CD6:STRING(256)GOODS_CD7:STRING(256)GOODS_CD8:STRING(256)GOODS_CD9:STRING(256)GOODS_CD10:STRING(256)USER_ID:STRING(256)USE_SP:STRING(256)PGM_ID:STRING(256)Nteam5600320231228{PLUdata}2910508616017QSORHQ03_SkuPerOrdOganM'

    payload1 = payload1.encode('utf-8')

    # print(payload1)

    response1 = session.post(FILE_SEARCH_URL1, data=payload1, headers=new_header)

    # print(response1.text)

    if response1.status_code == 200:
        return response1.text
    else:
        print(f'파일 검색 실패: {response1.status_code}')
        return None

def download_image(session, file_name, cookie):
    payload = 'SSV:utf-8WMONID=zGMRj_qMn58Dataset:ds_login_RowType_USER_ID:STRING(256)PASSWD:STRING(256)URL:STRING(256)IP_INFO:STRING(256)SMS_AUTH:STRING(256)CONN_SYS_SP:STRING(256)CONN_SHPE_SP_CD:STRING(256)CONN_SUCC_YN:STRING(256)CONN_ERR_MSG_CD:STRING(256)CONN_CNF_SP_CD:STRING(256)LOG_CRT_YN:STRING(256)CONN_ERR_MSG_DTL:STRING(256)CONN_RESTR_FUNC_USE_YN:STRING(256)N2910508616017B30911E454F92F08296E224AC3D612CF45704372CISICY'
    payload = payload.encode('utf-8')
    headers = HEADERS.copy()
    headers['Cookie'] = cookie
    response = session.get(f'{FILE_DOWNLOAD_URL}?fileNm={file_name}',data=payload, headers=headers)
    
    file_data = response.content

    if response.status_code == 200:
        try:
            image = Image.open(BytesIO(file_data))
            file_path = os.path.join('img', file_name)
            with open(file_path, 'wb') as f:
                f.write(file_data)
            print(f'파일 다운로드 완료: {file_name}')
            # 이미지 처리 코드 추가
        except Exception as e:
            print(f'이미지 처리 중 오류 발생: {e}')
            # 처리 중 오류 발생 시의 추가 처리
    else:
        print(f'이미지 다운로드 실패: {response.status_code}')


def stk_ck(ssv_data):
    # 정규표현식을 사용하여 필요한 정보 추출
    matches = re.findall(r'SALE_QTY10:bigdecimal\(256\).*', ssv_data)
    
    # 결과를 저장할 리스트
    result_list = []
    
    for match in matches:
        # _RowType_으로 시작하는 부분을 제거
        match = re.sub(r'SALE_QTY10:bigdecimal\(256\)', '', match)
        result_list = re.split(r'N\x1f',match)
    return result_list
    


def main_imgdown():
    session = requests.Session()

    # 로그인
    cookie = login(session)

    if cookie:
        # 파일 검색
        file_search_result = search_files(session, cookie)
        # print(file_search_result)

        if file_search_result:
            # 엑셀 파일 열기 (예시)
            wb = openpyxl.load_workbook('your_excel_file.xlsx')
            sheet = wb.active

            # 엑셀 파일 순회하며 이미지 파일 다운로드
            for row in sheet.iter_rows(min_row=2, values_only=True):
                file_name = row[0]
                download_image(session, file_name, cookie)

            # 엑셀 파일 닫기
            wb.close()

def main_stkcheck():
    session = requests.Session()

    # 로그인
    cookie = login(session)

    if cookie:
        file_search_result = search_files(session, cookie)
        # print(file_search_result)
    return file_search_result



# 메인 시작
if __name__ == "__main__":
    select = input('1:그림다운로드, 2:재고확인 -----')
    lgid = input('ID:')
    lgpw = input('PW:')
    h = hashlib.new('sha1')
    h.update(lgpw.encode('utf-8'))
    lgpw = h.hexdigest()

    if select == '1':
        main_imgdown()
    elif select == '2':
        excel_file_path = 'input_excel.xlsx'  # 실제 파일 경로로 변경해야 합니다.
        df = pd.read_excel(excel_file_path)
    
        length = df.shape[0]

        data_frame = []

        for add in range(0, length, 10):
            search_command = ''
            for ix in range(10):
                try:
                    search_command += f'{df.iloc[add+ix][0]}'
                except:
                    search_command += ''
        
            PLUdata = search_command

            if __name__ == "__main__":
                ssv_data = main_stkcheck()
            result_dict = stk_ck(ssv_data)
            df_from_list = pd.DataFrame([sub.split('') for sub in result_dict])
            
            df_from_list = df_from_list.iloc[1:,0:]
            
            df_from_list_columns = []
            df_from_list_columns = ['점포명']+['현재코드']
            col_repeat_data = ['발주_','재고_','판매_']
            for idx in col_repeat_data:    
                for add2 in range(10):    
                    try:
                        df_from_list_columns += [f'{idx}{df.iloc[add+add2][0]}']
                    except:
                        df_from_list_columns += ['No']
            df_from_list.columns = df_from_list_columns

            df_from_list_columns[2:] = sorted(df_from_list_columns[2:], reverse=True)

            df_from_list = df_from_list[df_from_list_columns]
            if add > 0:
                df_from_list.drop(columns=['점포명','현재코드'],inplace= True)
            try:    
                df_from_list.drop(columns='No', inplace=True)
            except:
                print('추가 검색')
            
            data_frame.append(df_from_list)
        result_frame = pd.concat(data_frame, axis= 1)
        result_frame = pd.melt(result_frame,id_vars=['점포명','현재코드'],var_name='구분',value_name='값')
        result_frame[['구분', '상품코드']] = result_frame['구분'].str.split('_', expand=True)
        result_frame = result_frame.query('구분 == "재고"')
        result_frame.to_excel("출력파일.xlsx", index=False)

