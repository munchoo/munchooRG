from os import access
from numpy import heaviside
import requests
import webbrowser
import msal as msal 
from msal import PublicClientApplication
from sqlalchemy import false
  
APPLICATION_ID = '312435a5-4dd6-40f8-a606-49bbb30c254d'
CLIENT_SECRET = '6SH7Q~-bKmoBmiVopd-sRv6cjKwQd-HB9g2GL'
authority_url = 'https://login.microsoftonline.com/common'
base_url = 'https://graph.microsoft.com/v1.0/'


SCOPES = ['User.Read', 'Chat.ReadWrite', 'Chat.Create']

# methon 1 : 
client_instance = msal.ConfidentialClientApplication(
    client_id=APPLICATION_ID,
    client_credential=CLIENT_SECRET,
    authority=authority_url
)

authorization_request_url = client_instance.get_authorization_request_url(SCOPES)   
print(authorization_request_url)

webbrowser.open(authorization_request_url, new=True)

authorization_code = 'M.R3_BAY.d6390b82-7da0-28b7-ea1b-f60f18d4a183'
access_token = client_instance.acquire_token_by_authorization_code(
     code=authorization_code,
     scopes=SCOPES
)

print(access_token)

access_token_id = access_token['access_token']
headers = {'Authorization': 'Bearer ' + access_token_id}
bodys = {'body': {'content': 'My name:'}}


endpoint = base_url + 'chats/19:d43f046a47e749f78e5459cda683ac9a@thread.v2/messages'
response = requests.post(endpoint, headers=headers, data=bodys)
print(response.json())
 
