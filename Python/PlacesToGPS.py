import tkinter
from urllib import request
import numpy as np
import pandas as pd
from urllib.request import urlopen
from urllib import parse
from urllib.request import Request
from urllib.error import HTTPError
from bs4 import BeautifulSoup
import os
from tkinter import filedialog
from tkinter import messagebox
import json
import time

# naver api
clientId = '0z3DRgjYfgzlVimw6uwc'
appkey = 'iu4Wtc9qQn'

api_url = 'https://openapi.naver.com/v1/search/local.json?query='

# 파일불러오는 다이얼로그
root = tkinter.Tk()
root.withdraw()
# tkinter.messagebox.showinfo(title='정보', message='불러올 엑셀파일을 선택해주세요.\n컬럼구조는\n|점포코드|구주소|도로명주소|')
# dir_path = filedialog.askopenfilename()
dir_path = 'D:/programming/storenames.xlsx'

data = pd.read_excel(dir_path, usecols='A',names=['점포명'])

geo_coordi = []




for add  in data['점포명']:
    add_urlenc = parse.quote(add)
    url = api_url + add_urlenc
    request = Request(url)
    # request.add_header('X-NCP-APIGW-API-KEY-ID', clientId)
    # request.add_header('X-NCP-APIGW-API-KEY', appkey)
    request.add_header('X-Naver-Client-Id', clientId)
    request.add_header('X-Naver-Client-Secret', appkey)

    try:    
        response = urlopen(request)
        time.sleep(0.5)
    except HTTPError as e:
        print('HTTP Error!')
        latitude = None
        longitude = None
    else:
        rescode = response.getcode()
        if rescode == 200:
            response_body = response.read().decode('utf-8')
            response_body = json.loads(response_body)
            try:    
                if 'mapx' in response_body['items'][0] and len(response_body['items'][0]['mapx']) > 0 :
                    longitude = (response_body['items'][0]['mapx'])[0:3] + '.' + (response_body['items'][0]['mapx'])[3:]
                    latitude = (response_body['items'][0]['mapy'])[0:2] + '.' + (response_body['items'][0]['mapy'])[2:]
                    print(f'{add} success')
                else:
                    print('result not exist!')
                    latitude = None
                    longitude = None
            except:
                print('Store not exist')
                latitude = None
                longitude = None
        else:
            print('Response error code : %d' % rescode)
            latitude = None
            longitude = None
    
    geo_coordi.append([latitude, longitude])
np_geo_coordi = np.array(geo_coordi)
pd_geo_coodi = pd.DataFrame({'점포명':data['점포명'].values,'위도': np_geo_coordi[:,0], '경도': np_geo_coordi[:,1]})


#save result
writer = pd.ExcelWriter('output_v3.xlsx')
pd_geo_coodi.to_excel(writer, sheet_name='Sheet1')
writer.close()





