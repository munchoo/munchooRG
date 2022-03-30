import json
from openpyxl import Workbook
import pandas as pd

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
print(type(df))
for idx, row in df.iterrows():
    print(row.values)
