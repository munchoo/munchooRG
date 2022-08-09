#%%
from urllib import parse
from matplotlib.pyplot import axes, axis
import pandas as pd
import openpyxl
import re
import os
import shutil


wb = openpyxl.Workbook()
ws = wb.active

df = pd.read_excel('C:/Users/Administrator/Desktop/GSpay홍보물취합_자동화/lastsource.xlsx')
# df_ofcinfo = pd.read_excel('C:/Users/Administrator/Desktop/GSpay홍보물취합_자동화/ofcmat.xlsx')
img_source_path = ['D:/OneDrive - GS Retail Co., Ltd/앱/Microsoft Forms/GS pay 홍보물 취합/질문/','D:/OneDrive - GS Retail Co., Ltd/앱/Microsoft Forms/GS pay 홍보물 취합/질문 1/','D:/OneDrive - GS Retail Co., Ltd/앱/Microsoft Forms/GS pay 홍보물 취합/질문 2/']
img_destnation_path = 'C:/Users/Administrator/Desktop/GSpay홍보물취합_자동화/img/'

df1 = df.iloc[:,lambda df:[0,2,3,4,5,6]]

# df_ofcinfo = df_ofcinfo.iloc[:,1:3]
# df_ofcinfo = df_ofcinfo.dropna()
# df_ofcinfo = df_ofcinfo.groupby(['조직','OFC']).size().reset_index(name='점포수')

# df3 = df1.join(df_ofcinfo.set_index('OFC')).iloc[:,:]
# df1.info()

for idx, row in df1.iterrows():
    
    for i in range(3,6):  
        print(row)
        try:
            a = parse.unquote(row[i])
            aa = re.findall('질문\s*\d*\/.*\.jpg|질문\s*\d*\/.*\.jpeg',a)
            aaa = re.sub('질문\s*\d*\/|질문\s*\d*\/','',aa[0])
            row[i] = aaa
            shutil.copy(img_source_path[i-3]+aaa,img_destnation_path+row[2]+f'_{i-2}.jpg')
            print(img_destnation_path+row[2]+f'_{i-2}.jpg')
        except:
            pass
       
df1.to_excel('output.xlsx', sheet_name='go')
