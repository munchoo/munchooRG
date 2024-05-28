import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import hashlib
import requests
import openpyxl
import pandas as pd
from PIL import Image
from io import BytesIO
import re
import os

# Base URLs and Headers
BASE_URL = 'http://cvsscn.gsretail.com'
LOGIN_URL = f'{BASE_URL}/cssc/portal/portal/Login.do'
FILE_SEARCH_URL1 = f'{BASE_URL}/cssc/ord/hqord/RetrieveSkuPerOrdOganList.do'
IMG_ADDRESS_URL1 = f'{BASE_URL}/cssc/mst/goods/RetrieveGoodsMstDetail.do'
FILE_DOWNLOAD_URL = f'{BASE_URL}/FileView.dwn'
HEADERS = {
    'Accept': 'application/xml, text/xml, */*',
    'Accept-Encoding': 'gzip, deflate',
    'Accept-Language': 'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7',
    'Cache-Control': 'no-cache, no-store',
    'Connection': 'keep-alive',
    'Content-Length': '417',
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

def login(session, lgid, lgpw):
    payload = f'SSV:utf-8WMONID=zGMRj_qMn58Dataset:ds_login_RowType_USER_ID:STRING(256)PASSWD:STRING(256)URL:STRING(256)IP_INFO:STRING(256)SMS_AUTH:STRING(256)CONN_SYS_SP:STRING(256)CONN_SHPE_SP_CD:STRING(256)CONN_SUCC_YN:STRING(256)CONN_ERR_MSG_CD:STRING(256)CONN_CNF_SP_CD:STRING(256)LOG_CRT_YN:STRING(256)CONN_ERR_MSG_DTL:STRING(256)CONN_RESTR_FUNC_USE_YN:STRING(256)N{lgid}{lgpw.upper()}CISICY'
    payload = payload.encode('utf-8')
    response = session.post(LOGIN_URL, data=payload, headers=HEADERS)
    if response.status_code == 200:
        return response.headers.get('Set-Cookie')
    else:
        return None

def search_files(session, cookie, PLUdata):
    wmonid = None
    JSESSIONID = None
    
    match = re.search(r'WMONID=([^;]+)', cookie)
    match2 = re.search(r'JSESSIONID=([^;]+)', cookie)
    if match:
        wmonid = match.group(1)
    else:
        print("WMONID를 찾을 수 없습니다.")
    if match2:
        JSESSIONID = match2.group(1)
    else:
        print("JSESSIONID를 찾을 수 없습니다.")

    if wmonid and JSESSIONID:
        new_header = update_headers(HEADERS, {'Cookie': f'_ga=GA1.1.153126700.1689945979; _ga_CHSRECZ6BZ=GS1.1.1697849921.2.1.1697850054.60.0.0; WMONID={wmonid}; JSESSIONID={JSESSIONID}:1avt0fa4q', 'Expires': '-1'})
        payload1 = f'SSV:utf-8_ga=GA1.1.99319122.1689267668_ga_CHSRECZ6BZ=GS1.1.1689292043.2.0.1689292043.60.0.0WMONID=j3VXlTEnzv4CUR_PGM_ID=SORHQ03_SkuPerOrdOganMDataset:ds_inInqCond_RowType_ORGAN_SP:STRING(256)ORGAN_CD:STRING(256)ORD_DT:STRING(256)GOODS_CD1:STRING(256)GOODS_CD2:STRING(256)GOODS_CD3:STRING(256)GOODS_CD4:STRING(256)GOODS_CD5:STRING(256)GOODS_CD6:STRING(256)GOODS_CD7:STRING(256)GOODS_CD8:STRING(256)GOODS_CD9:STRING(256)GOODS_CD10:STRING(256)USER_ID:STRING(256)USE_SP:STRING(256)PGM_ID:STRING(256)Nteam5600320240109{PLUdata}2910508616017QSORHQ03_SkuPerOrdOganM'
        payload1 = payload1.encode('utf-8')
        response1 = session.post(FILE_SEARCH_URL1, data=payload1, headers=new_header)

        if response1.status_code == 200:
            return response1.text
        else:
            print(f'파일 검색 실패: {response1.status_code}')
            return None
    else:
        print("WMONID 또는 JSESSIONID가 설정되지 않았습니다.")
        return None

def download_image(session, file_name, cookie):
    match = re.search(r'WMONID=([^;]+)', cookie)
    match2 = re.search(r'JSESSIONID=([^;]+)', cookie)
    if match:
        wmonid = match.group(1)
    else:
        print("WMONID를 찾을 수 없습니다.")
    if match2:
        JSESSIONID = match2.group(1)
    else:
        print("JSESSIONID 찾을 수 없습니다.") 

    payload = f'SSV:utf-8WMONID={wmonid}Dataset:ds_login_RowType_USER_ID:STRING(256)PASSWD:STRING(256)URL:STRING(256)IP_INFO:STRING(256)SMS_AUTH:STRING(256)CONN_SYS_SP:STRING(256)CONN_SHPE_SP_CD:STRING(256)CONN_SUCC_YN:STRING(256)CONN_ERR_MSG_CD:STRING(256)CONN_CNF_SP_CD:STRING(256)LOG_CRT_YN:STRING(256)CONN_ERR_MSG_DTL:STRING(256)CONN_RESTR_FUNC_USE_YN:STRING(256)N2910508616017B30911E454F92F08296E224AC3D612CF45704372CISICY'
    payload = payload.encode('utf-8')
    headers = HEADERS.copy()
    headers['Cookie'] = cookie
    response = session.get(f'{FILE_DOWNLOAD_URL}?fileNm={file_name}', data=payload, headers=headers)
    
    file_data = response.content

    if response.status_code == 200:
        try:
            image = Image.open(BytesIO(file_data))
            if not os.path.exists('img'):
                os.makedirs('img')
            file_path = os.path.join('img', file_name)
            with open(file_path, 'wb') as f:
                f.write(file_data)
            print(f'파일 다운로드 완료: {file_name}')
        except Exception as e:
            print(f'이미지 처리 중 오류 발생: {e}')
    else:
        print(f'이미지 다운로드 실패: {response.status_code}')

def stk_ck(ssv_data):
    matches = re.findall(r'SALE_QTY10:bigdecimal\(256\).*', ssv_data)
    result_list = []
    
    for match in matches:
        match = re.sub(r'SALE_QTY10:bigdecimal\(256\)', '', match)
        result_list = re.split(r'N\x1f', match)
    return result_list

def main_imgdown(session, cookie, excel_file_path):
    update_status("엑셀 파일을 읽는 중...")
    wb = openpyxl.load_workbook(excel_file_path)
    sheet = wb.active
    for GOOODCDidx in sheet.iter_rows(min_row=2, values_only=True):
        imgAddressName = search_Imgaddress(session, cookie, GOOODCDidx)
        if imgAddressName:
            download_image(session, imgAddressName, cookie)
        else:
            print('이미지 주소 검색 실패')
            continue
    update_status("이미지 다운로드 완료")


def main_stkcheck(session, cookie, df):
    update_status("파일을 검색하는 중...")
    length = df.shape[0]
    data_frame = []

    for add in range(0, length, 10):
        search_command = ''
        for ix in range(10):
            try:
                search_command += f'{df.iloc[add + ix, 0]}'
            except:
                search_command += ''
        
        PLUdata = search_command

        file_search_result = search_files(session, cookie, PLUdata)
        result_dict = stk_ck(file_search_result)
        df_from_list = pd.DataFrame([sub.split('') for sub in result_dict])
        
        df_from_list = df_from_list.iloc[1:, 0:]
        
        df_from_list_columns = ['점포명', '현재코드']
        col_repeat_data = ['발주_', '재고_', '판매_']
        for idx in col_repeat_data:
            for add2 in range(10):
                try:
                    df_from_list_columns += [f'{idx}{df.iloc[add + add2, 0]}']
                except:
                    df_from_list_columns += ['No']
        df_from_list.columns = df_from_list_columns

        df_from_list_columns[2:] = sorted(df_from_list_columns[2:], reverse=True)

        df_from_list = df_from_list[df_from_list_columns]
        if add > 0:
            df_from_list.drop(columns=['점포명', '현재코드'], inplace=True)
        try:
            df_from_list.drop(columns='No', inplace=True)
        except:
            print('추가 검색')
        
        data_frame.append(df_from_list)
    result_frame = pd.concat(data_frame, axis=1)
    result_frame = pd.melt(result_frame, id_vars=['점포명', '현재코드'], var_name='구분', value_name='값')
    result_frame[['구분', '상품코드']] = result_frame['구분'].str.split('_', expand=True)
    # result_frame = result_frame.query('구분 == "발주"')
    result_frame.to_excel("출력파일.xlsx", index=False)

    # Treeview에 데이터 표시
    update_status("결과를 표시하는 중...")
    tree["columns"] = list(result_frame.columns)
    tree["show"] = "headings"
    
    for col in result_frame.columns:
        tree.heading(col, text=col)
        tree.column(col, anchor="w", stretch=True)
    
    for index, row in result_frame.iterrows():
        tree.insert("", "end", values=list(row))

    update_status("재고 확인 완료")


def run_program():
    select = selection_var.get()
    lgid = id_entry.get()
    lgpw = password_entry.get()

    if not lgid or not lgpw:
        messagebox.showwarning("경고", "아이디와 비밀번호를 입력하세요.")
        return

    h = hashlib.new('sha1')
    h.update(lgpw.encode('utf-8'))
    lgpw = h.hexdigest()

    excel_file_path = file_path_var.get()

    if not excel_file_path:
        messagebox.showwarning("경고", "엑셀 파일을 선택하세요.")
        return

    session = requests.Session()
    update_status("로그인 중...")
    cookie = login(session, lgid, lgpw)

    if not cookie:
        messagebox.showerror("오류", "로그인에 실패했습니다.")
        update_status("로그인 실패")
        return

    if select == '1':
        main_imgdown(session, cookie, excel_file_path)
    elif select == '2':
        df = pd.read_excel(excel_file_path)
        main_stkcheck(session, cookie, df)
    else:
        messagebox.showwarning("경고", "작업을 선택하세요.")

def select_file():
    file_path = filedialog.askopenfilename(filetypes=[("Excel files", "*.xlsx *.xls")])
    file_path_var.set(file_path)

def update_status(message):
    status_var.set(message)
    root.update_idletasks()

# GUI 설정
root = tk.Tk()
root.title("샘플 GUI 레이아웃")
root.geometry("800x600")

# 아이디와 비밀번호 입력
tk.Label(root, text="아이디:").pack()
id_entry = tk.Entry(root)
id_entry.pack()

tk.Label(root, text="비밀번호:").pack()
password_entry = tk.Entry(root, show="*")
password_entry.pack()

# 파일 선택 버튼과 경로 표시
file_path_var = tk.StringVar()
tk.Button(root, text="엑셀 파일 선택", command=select_file).pack()
tk.Label(root, textvariable=file_path_var).pack()

# 작업 선택 라디오 버튼
selection_var = tk.StringVar()
tk.Radiobutton(root, text="그림 다운로드", variable=selection_var, value='1').pack()
tk.Radiobutton(root, text="재고 확인", variable=selection_var, value='2').pack()

# 상태 표시 라벨
status_var = tk.StringVar()
tk.Label(root, textvariable=status_var).pack()

# 실행 버튼
tk.Button(root, text="실행", command=run_program).pack()

tree = ttk.Treeview(root)
tree.pack(expand=True, fill='both')
scrollbar = ttk.Scrollbar(root, orient="vertical", command=tree.yview)
scrollbar.pack(side='right', fill='y')
tree.configure(yscrollcommand=scrollbar.set)


root.mainloop()
