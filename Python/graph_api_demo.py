from os import access
from numpy import heaviside
import requests
import webbrowser
import msal as msal 
from msal import ConfidentialClientApplication
from sqlalchemy import false
import urllib
  
APPLICATION_ID = '312435a5-4dd6-40f8-a606-49bbb30c254d'
CLIENT_SECRET = '6SH7Q~-bKmoBmiVopd-sRv6cjKwQd-HB9g2GL'
authority_url = 'https://login.microsoftonline.com/gsretail.co.kr'
base_url = 'https://graph.microsoft.com/v1.0/'


SCOPES = ['User.Read', 'Chat.ReadWrite', 'Chat.Create', 'Chat.Read', 'Chat.ReadBasic', 'Chat.ReadWrite', 'ChatMessage.Send', 'ChannelMessage.Send' ]

# methon 1 : 
client_instance = msal.ConfidentialClientApplication(
    client_id=APPLICATION_ID,
    client_credential=CLIENT_SECRET,
    authority=authority_url
)

authorization_request_url = client_instance.get_authorization_request_url(SCOPES)   
print(authorization_request_url)


# webbrowser.open(authorization_request_url, new=True)

# my_response = input("Paste the full URL redirect here: ")
# query_dict = urllib.parse.parse_qs(my_response)
# print(query_dict)

# authorization_code = query_dict['http://localhost:8000/get_auto_token?code']
authorization_code = query_dict['http://localhost:8000/get_auto_token?code']
access_token = client_instance.acquire_token_by_authorization_code(
     code=authorization_code,
     scopes=SCOPES
)

print(access_token)

access_token_id = access_token['access_token']
# headers = {'Authorization': 'Bearer ' + access_token_id}
headers = { 
'User-Agent' : 'python_tutorial/1.0',
'Authorization': 'Bearer ' + access_token_id,
'Accept' : 'application/json',
'Content-Type' : 'application/json'
}
# bodys = {
#     "body": {
#         "content": "Hello world"
#     }
# }


a = 'chats/19:bbd521b3-17df-44f9-9461-0e4751e750a4_dc6321ca-2f64-41fe-aa20-8d1f28465edd@unq.gbl.spaces'
b = 'me/chats/'
endpoint = base_url + b
response = requests.get(endpoint, headers=headers)
print(response.json())
 
