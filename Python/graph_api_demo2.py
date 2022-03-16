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

# methon 2
app = PublicClientApplication(
    APPLICATION_ID,
    authority_url
)

app.get_accounts()
# # acctounts = app.get_accounts()
# # if acctounts:
# #     app.acquire_token_silent(scopes=SCOPES, acctounts=acctounts[0])

# flow = app.initiate_device_flow(scopes=SCOPES)
# print(flow)