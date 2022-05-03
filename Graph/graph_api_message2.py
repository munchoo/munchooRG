from email import message
from os import access
from numpy import heaviside
import requests
import webbrowser
import msal as msal 
from msal import ConfidentialClientApplication
from sqlalchemy import false
import json
import pprint
import time
import pandas as pd

### 멤버정보 가져오기
file_path = './Graph/memInfo.json'
data = json.load(open(file_path, 'r', encoding='utf-8'))

### 앱 기본정보 입력
APPLICATION_ID = '312435a5-4dd6-40f8-a606-49bbb30c254d'
CLIENT_SECRET = '6SH7Q~-bKmoBmiVopd-sRv6cjKwQd-HB9g2GL'
authority_url = 'https://login.microsoftonline.com/gsretail.co.kr'
base_url = 'https://graph.microsoft.com/v1.0/'
username = "munchoo@gsretail.com"
password = "dud5@ska2"
SCOPES = ['User.Read', 'Chat.ReadWrite', 'Chat.Create']  ### permmition 불러오기 azure portal에서 등록해야함

### msal을 이용 인스턴스 만들기
client_instance = msal.ConfidentialClientApplication(
    client_id=APPLICATION_ID,
    client_credential=CLIENT_SECRET,
    authority=authority_url
)

### roct로 토큰 가져오기
access_token = client_instance.acquire_token_by_username_password(
     username,
     password,
     scopes=SCOPES
)
### 가져온 accecss_token을 API용 헤더에 넣기
access_token_id = access_token['access_token']
headers = {
    'Authorization': 'Bearer ' + access_token_id,
    'Accept' : 'application/json',
    'Content-Type' : 'application/json'
    }

####----------------------------------------------------------
df2 = pd.read_excel('./Graph/c.xlsx',  thousands = ',')
df2 = pd.DataFrame(df2)
df2['입고일'] = df2['입고일'].dt.strftime('%y-%m-%d')

sendMessage = {}

for idx, row in df2.iterrows():
    if row['OFC'] not in sendMessage:
        sendMessage[row['OFC']] = {}
    if row['점포명'] not in sendMessage[row['OFC']]:
        sendMessage[row['OFC']][row['점포명']] = f'[{row["점포명"]}]점 노후장비교체일자 안내<br>'
        sendMessage[row['OFC']][row['점포명']] += f"{'-'*15} <br>"
    if row['ICE1100'] > 0:
        c = '아이스냉동고1100'
    elif row['ICE1600'] > 0:
        c = '아이스냉동고1600'
    elif row['RIF1D'] > 0:
        c = 'RIF 1도어'
    elif row['RIF2D'] > 0:
        c = 'RIF 2도어'
    
    sendMessage[row['OFC']][row['점포명']] += f"교체장비 : {c} <br>입고일자 : {row['입고일']}"
print(sendMessage)

bd_message_send = {'body': {'contentType':'html','content': '메세지 TEST입니다.'}}

# 
for row in sendMessage.keys():
    endpoint_message = base_url + 'chats/' + data[row]['chat_id'] + '/messages'
    print(endpoint_message)
    for row2 in sendMessage[row].keys():
        bd_message_send['body']['content'] = sendMessage[row][row2]
        print(bd_message_send)
        data_message_send = json.dumps(bd_message_send)
        response = requests.post(endpoint_message, data=data_message_send, headers=headers)
        print(response.json())




# for idx, row in df.iterrows():
#     endpoint_message = base_url + 'chats/' + data[row.values[0]]['chat_id'] + '/messages'
#     bd_message_send['body']['content'] = f'{row.values[1]} <p> {row.values[2]}이다' 
#     print(bd_message_send)
#     data_message_send = json.dumps(bd_message_send)
#     response2 = requests.post(endpoint_message, data=data_message_send, headers=headers)


### 메세지 보내기 requests.post 
# for idx in data.keys():
#     endpoint_message = base_url + 'chats/' + data[idx]['chat_id'] + '/messages'
#     response2 = requests.post(endpoint_message, data=data_message_send, headers=headers)

# https://graph.microsoft.com/v1.0/chats/19:bbd521b3-17df-44f9-9461-0e4751e750a4_dc6321ca-2f64-41fe-aa20-8d1f28465edd@unq.gbl.spaces/messages