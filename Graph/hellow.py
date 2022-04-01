from email import message
import json
from openpyxl import Workbook
import pandas as pd
import pprint
from tabulate import tabulate

# 엑셀로 memberinfo 추출하기
# with open('./Graph/memberinfo.json') as fp:
#     data = json.load(fp)
#     wb = Workbook()
#     ws = wb.active

#     ws.append(['이름','ID','ChatID'])
#     for ta in data.keys():
#         print(ta)
#         ws.append([ta,data[ta]['id'],data[ta]['chat_id']])
    
#     wb.save('./Graph/hellw.xlsx')

df = pd.read_excel('./Graph/a.xlsx')
df = pd.DataFrame(df)
df['최근입고일자'] = df['최근입고일자'].dt.strftime('%y-%m-%d')
df['예상유통기한'] = df['예상유통기한'].dt.strftime('%y-%m-%d')

checkName = ''
checkStore = ''
sendMessage = {}
initmessage = '유통기한경과상품'
fullName = {}
message_tem ={}

for idx, row in df.iterrows():
    if row['OFC'] not in sendMessage:
        sendMessage[row['OFC']] = {}
    if row['점포명'] not in sendMessage[row['OFC']]:
        sendMessage[row['OFC']][row['점포명']] = ''
    sendMessage[row['OFC']][row['점포명']] += f"상품 / {row['상품명']}"

print(tabulate(sendMessage,sendMessage.values))

