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


#### 구성원 ID불러오기 
file_path = './Graph/address.json'
idmatt = {}
with open(file_path, 'r', encoding='utf-8') as file:
    data = json.load(file)
    data = data.get('value')
    for idx in data:
        idmatt[idx.get('givenName')] = {'id':idx.get('id'),'chat_id':''}

### 앱 기본정보 입력
APPLICATION_ID = '312435a5-4dd6-40f8-a606-49bbb30c254d'
CLIENT_SECRET = '6SH7Q~-bKmoBmiVopd-sRv6cjKwQd-HB9g2GL'
authority_url = 'https://login.microsoftonline.com/gsretail.co.kr'
base_url = 'https://graph.microsoft.com/v1.0/'
username = "munchoo@gsretail.com"
password = "dud5@ska2"
SCOPES = ['User.Read', 'Chat.ReadWrite', 'Chat.Create']  ### permmition 불러오기 azure portal에서 등록해야함

### msal을 이용 인스턴스 만들기 api용
client_instance = msal.ConfidentialClientApplication(
    client_id=APPLICATION_ID,
    client_credential=CLIENT_SECRET,
    authority=authority_url
)

### 인증필요한 request_url받아오기 이젠 구지 필요 없음.
authorization_request_url = client_instance.get_authorization_request_url(SCOPES)   

### roct로 토큰 가져오기
access_token = client_instance.acquire_token_by_username_password(
     username,
     password,
     scopes=SCOPES
)
### 가져온 토큰으로 헤더에 넣기
access_token_id = access_token['access_token']
headers = {
    'Authorization': 'Bearer ' + access_token_id,
    'Accept' : 'application/json',
    'Content-Type' : 'application/json'
    }

#보낸는사람 #받는사람 #chat_sender는 김영남
chat_receiver = 'dc6321ca-2f64-41fe-aa20-8d1f28465edd'

for OFCName in idmatt.keys():
    #chat 생성하기 
    bd_chat_creat = {
        "chatType": "oneOnOne",
        "members": [
            {
                "@odata.type": "#microsoft.graph.aadUserConversationMember",
                "roles": [
                    "owner"
                ],
                "user@odata.bind": "https://graph.microsoft.com/v1.0/users('bbd521b3-17df-44f9-9461-0e4751e750a4')"
            },
            {
                "@odata.type": "#microsoft.graph.aadUserConversationMember",
                "roles": [
                    "owner"
                ],
                "user@odata.bind": "https://graph.microsoft.com/v1.0/users('')"
            }
        ]
    }

    #### chat_sender 보내는 사람 설정하기
    bd_chat_creat['members'][1]['user@odata.bind'] = f"https://graph.microsoft.com/v1.0/users(\'{idmatt[OFCName]['id']}\')"
    ##### 보내는 메세지 json
    # bd_message_send = {'body': {'content': 'test:'}}

    data_chat_creat = json.dumps(bd_chat_creat)
# data_message_send = json.dumps(bd_message_send)

# ### 챗 생성하기 requests.post
    endpoint = base_url + 'chats'
    response = requests.post(endpoint, data=data_chat_creat, headers=headers)
    idmatt[OFCName]['chat_id'] = response.json()['id']
    print(idmatt)
    time.sleep(5)

with open('./Graph/memberinfo.json', 'w', encoding='utf-8') as wfile:
    json.dump(idmatt, wfile, indent=4)
    
    

# # ### 메세지 보내기 requests.post 
# # endpoint_message = base_url + 'chats/' + response.json()['id'] + '/messages'
# # response2 = requests.post(endpoint_message, data=data_message_send, headers=headers)

# # # https://graph.microsoft.com/v1.0/chats/19:bbd521b3-17df-44f9-9461-0e4751e750a4_dc6321ca-2f64-41fe-aa20-8d1f28465edd@unq.gbl.spaces/messages