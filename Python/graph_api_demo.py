from os import access
from numpy import heaviside
import requests
import webbrowser
import msal as msal 
from msal import PublicClientApplication
  
APPLICATION_ID = '312435a5-4dd6-40f8-a606-49bbb30c254d'
CLIENT_SECRET = '6SH7Q~-bKmoBmiVopd-sRv6cjKwQd-HB9g2GL'
authority_url = 'https://login.microsoftonline.com/consumers/'
base_url = 'https://graph.microsoft.com/v1.0/'


SCOPES = ['User.Read', 'User.Export.All']

# methon 1 : 
client_instance = msal.ConfidentialClientApplication(
    client_id=APPLICATION_ID,
    client_credential=CLIENT_SECRET,
    authority=authority_url
)

authorization_request_url = client_instance.get_authorization_request_url(SCOPES)   
print(authorization_request_url)
webbrowser.open(authorization_request_url, new=True)

authorization_code = 'M.R3_BAY.a0dc02b2-f255-49e8-2630-f86b9e924137'
access_token = client_instance.acquire_token_by_authorization_code(
     code=authorization_code,
     scopes=SCOPES
)

print(access_token)

access_token_id = access_token['access_token']
print(access_token_id)
headers = {'Authorization': 'Bearer ' + access_token_id}


endpoint = base_url + 'me'
response = requests.get(endpoint, headers=headers)
print(response.json())
 
