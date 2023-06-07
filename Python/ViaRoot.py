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

# Tmap api

param = {
						"startName" : "출발지",
						"startX" : "127.103259",
						"startY" : "37.402688",
						"startTime" : "201708081103",
						"endName" : "도착지",
						"endX" : "127.142571",
						"endY" : "37.414382",
						"reqCoordType" : "WGS84GEO",
						"resCoordType" : "EPSG3857"
            }

header = {'appkey':'8kUTBRbL2S4piT9XLnVcN2vX7PVe737wa11ycGXO','Content-Type':'application/json','callback':''}
# ----------------------------------------------
api_url = 'https://apis.openapi.sk.com/tmap/routes/routeSequential30'




root = tkinter.Tk()
root.withdraw()
# tkinter.messagebox.showinfo(title='정보', message='불러올 엑셀파일을 선택해주세요.\n컬럼구조는\n|점포코드|구주소|도로명주소|')
dir_path = filedialog.askopenfilename()


# 좌표불러오기
data = pd.read_excel(dir_path, usecols='A,B,C,D',names=['점포코드','도로명주소','위도','경도'])

# data = data[data['위도'].isnull()]

print(data.head(10))

# api이용 좌표 찾기

geo_coordi = []


  
# for add  in data['도로명주소']:
#     add_urlenc = parse.quote(add)
#     url = api_url + add_urlenc
#     request = Request(url)
#     request.add_header(header)
#     try:    
#         response = urlopen(request)
#     except HTTPError as e:
#         print('HTTP Error!')
#     else:
#         rescode = response.getcode()
#         if rescode == 200:
#             response_body = response.read().decode('utf-8')
#             response_body = json.loads(response_body)
#         else:
#             print('Response error code : %d' % rescode)



#save result
# writer = pd.ExcelWriter('output_v2.xlsx')
# pd_geo_coodi.to_excel(writer, sheet_name='Sheet1')
# writer.save()


