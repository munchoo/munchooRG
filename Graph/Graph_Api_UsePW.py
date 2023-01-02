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
password = "dud5@ska1"
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

####-------------- 유통기한 메세지 -------------------------
# df2 = pd.read_excel('./Graph/a.xlsx')
# df2 = pd.DataFrame(df2)
# df2['최근입고일자'] = df2['최근입고일자'].dt.strftime('%y-%m-%d')
# df2['예상유통기한'] = df2['예상유통기한'].dt.strftime('%y-%m-%d')

# sendMessage = {}

# for idx, row in df2.iterrows():
#     if row['OFC'] not in sendMessage:
#         sendMessage[row['OFC']] = {}
#     if row['점포명'] not in sendMessage[row['OFC']]:
#         sendMessage[row['OFC']][row['점포명']] = f'[{row["점포명"]}]점 유통기한 경과 의심상품입니다.<br>'
#         sendMessage[row['OFC']][row['점포명']] += f"{'-'*15} <br>"
#     sendMessage[row['OFC']][row['점포명']] += f"+ {row['상품명']} : 재고({row['현재재고']}개)<br>"
# print(sendMessage)

# bd_message_send = {'body': {'contentType':'html','content': '메세지 TEST입니다.'}}

# # 
# for row in sendMessage.keys():
#     endpoint_message = base_url + 'chats/' + data[row]['chat_id'] + '/messages'
#     print(endpoint_message)
#     for row2 in sendMessage[row].keys():
#         bd_message_send['body']['content'] = sendMessage[row][row2]
#         print(bd_message_send)
#         data_message_send = json.dumps(bd_message_send)
#         response = requests.post(endpoint_message, data=data_message_send, headers=headers)
#         print(response.json())
####-----------다른메세지 보내기------------------------------

df2 = pd.read_excel('./Graph/send_message.xlsx')
df2 = pd.DataFrame(df2)

sendMessage = {}

## pandas로 받는 Dataframe파일을 반복문으로 딕셔너리형태로 메세지화 한다.
## {'OFC명':{'점포명':'메세지1','점포명2':'메세지2','점포명3':'메세지3'}}

for idx, row in df2.iterrows():
    if row['OFC'] not in sendMessage:
        sendMessage[row['OFC']] = {}
    if row['점포명'] not in sendMessage[row['OFC']]:
        # 제목줄 만들기
        sendMessage[row['OFC']][row['점포명']] = f'[{row["점포명"]}] 8월 김밥 레벨업 행사 안내 <br>'
        # 대쉬바로 구분선 설정하기 
        sendMessage[row['OFC']][row['점포명']] += f"{'-'*15} <br>"
        # 엑셀로 불로온 데이터 메세지 넣기 (html 방식으로 <br> 줄넘기기)
        sendMessage[row['OFC']][row['점포명']] += f"{row['메시지']}"
print(sendMessage)

## msal로 보내기전 json 형태의 빈 딕셔너리를 하나 만들어준다 
## msal의 Json - {'body':{'contentType':'html','content':'메세지'}}
## 중간에 딕셔너리형태를 Json.dumps로 json형태로 변환
# https://graph.microsoft.com/v1.0/chats/19:bbd521b3-17df-44f9-9461-0e4751e750a4_dc6321ca-2f64-41fe-aa20-8d1f28465edd@unq.gbl.spaces/messages

bd_message_send = {'body': {'contentType':'html','content': '메세지 TEST입니다.'}}
for row in sendMessage.keys():
    if row in data:
        endpoint_message = base_url + 'chats/' + data[row]['chat_id'] + '/messages'
        print(endpoint_message)
        for row2 in sendMessage[row].keys():
            bd_message_send['body']['content'] = sendMessage[row][row2]
            print(bd_message_send)
            data_message_send = json.dumps(bd_message_send)
            # response = requests.post(endpoint_message, data=data_message_send, headers=headers)
            # print(response.json())
            ## too many send msg 에러 방지를 위해 지연 추가. ('22년 6월 2일)
            time.sleep(2)

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