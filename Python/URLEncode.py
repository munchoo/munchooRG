#%%
from urllib import parse
import pandas as pd
import openpyxl
import re


wb = openpyxl.Workbook()
ws = wb.active

df = pd.read_excel('D:/Download/asb.xlsx')
df1 = df.iloc[:,lambda df:[5,6,7,8]]

for idx, row in df1.iterrows():
    try:
        a = parse.unquote(row[1])
        aa = re.findall('질문\/.*[.jpg|.jpeg]',a)
        aaa = aa[0].strip('질문/')
        row[1] = aaa
    except:
        pass
    try:
        b = parse.unquote(row[2])
        bb = re.findall('질문 1\/.*[.jpg|.jpeg]',b)
        bbb = bb[0].strip('질문 1/')
        row[2] = bbb
    except:
        pass
    try:        
        c = parse.unquote(row[3])
        cc = re.findall('질문 2\/.*[.jpg|.jpeg]',c)
        ccc = cc[0].strip('질문 2/')
        row[3] = ccc
    except:
        pass       

df1.to_excel('output.xlsx', sheet_name='go')
