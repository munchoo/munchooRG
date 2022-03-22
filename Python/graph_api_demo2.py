from email import message
from os import access
from numpy import heaviside
import requests
import webbrowser
import msal as msal 
from msal import ConfidentialClientApplication
from sqlalchemy import false
import json
  
APPLICATION_ID = '312435a5-4dd6-40f8-a606-49bbb30c254d'
CLIENT_SECRET = '6SH7Q~-bKmoBmiVopd-sRv6cjKwQd-HB9g2GL'
authority_url = 'https://login.microsoftonline.com/gsretail.co.kr'
base_url = 'https://graph.microsoft.com/v1.0/'
username = "munchoo@gsretail.com"
password = "dud5@ska2"

SCOPES = ['User.Read', 'Chat.ReadWrite', 'Chat.Create']

# methon 1 : 
client_instance = msal.ConfidentialClientApplication(
    client_id=APPLICATION_ID,
    client_credential=CLIENT_SECRET,
    authority=authority_url
)
authorization_request_url = client_instance.get_authorization_request_url(SCOPES)   

access_token = client_instance.acquire_token_by_username_password(
     username,
     password,
     scopes=SCOPES
)


print(access_token)

access_token_id = access_token['access_token']
headers = {
    'Authorization': 'Bearer ' + access_token_id,
    'Accept' : 'application/json',
    'Content-Type' : 'application/json'
    }
bodys = {'body': {'content': 'test:'}}
send_message = json.dumps(bodys)
print(bodys)

endpoint = base_url + 'chats/19:bbd521b3-17df-44f9-9461-0e4751e750a4_dc6321ca-2f64-41fe-aa20-8d1f28465edd@unq.gbl.spaces/messages'
response = requests.post(endpoint, data=send_message, headers=headers)
print(response.json())

# https://graph.microsoft.com/v1.0/chats/19:bbd521b3-17df-44f9-9461-0e4751e750a4_dc6321ca-2f64-41fe-aa20-8d1f28465edd@unq.gbl.spaces/messages