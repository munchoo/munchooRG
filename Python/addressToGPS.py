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

# naver api
clientId = '7gbuolojz1'
appkey = 'JnGuxK4RYSLPlXaP1gCXAa3fKiku312v6SUGElID'
# ----------------------------------------------
api_url = 'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query='

root = tkinter.Tk()
root.withdraw()
tkinter.messagebox.showinfo(title='정보', message='불러올 엑셀파일을 선택해주세요.\n컬럼구조는\n|점포코드|구주소|도로명주소|')
dir_path = filedialog.askopenfilename()

print(dir_path.name)

# 주소목록
data = pd.read_excel(dir_path.name, usecols='A,B,C,D,E',names=['점포코드','구주소','도로명주소','위도','경도'])

data = data[data['위도'].isnull()]

print(data.head(10))

# api이용 좌표 찾기

geo_coordi = []

for add  in data['도로명주소']:
    add_urlenc = parse.quote(add)
    url = api_url + add_urlenc
    request = Request(url)
    request.add_header('X-NCP-APIGW-API-KEY-ID', clientId)
    request.add_header('X-NCP-APIGW-API-KEY', appkey)
    try:    
        response = urlopen(request)
    except HTTPError as e:
        print('HTTP Error!')
        latitude = None
        longitude = None
    else:
        rescode = response.getcode()
        if rescode == 200:
            response_body = response.read().decode('utf-8')
            response_body = json.loads(response_body)
            if 'addresses' in response_body and len(response_body['addresses']) > 0 :
                latitude = response_body['addresses'][0]['y']
                longitude = response_body['addresses'][0]['x']
                print('Success')
            else:
                print('result not exist!')
                latitude = None
                longitude = None
        else:
            print('Response error code : %d' % rescode)
            latitude = None
            longitude = None

    geo_coordi.append([latitude, longitude])

np_geo_coordi = np.array(geo_coordi)
pd_geo_coodi = pd.DataFrame({'점포코드':data['점포코드'].values,'구주소': data['구주소'].values, '도로명': data['도로명주소'].values, '위도': np_geo_coordi[:,0], '경도': np_geo_coordi[:,1]})

#save result
writer = pd.ExcelWriter('output_v2.xlsx')
pd_geo_coodi.to_excel(writer, sheet_name='Sheet1')
writer.save()


