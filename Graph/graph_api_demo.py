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


authorization_code = '0.AVYAXMJFRnWXd02nNnAPq3ZhFqU1JDHWTfhApgZJu7MMJU1WAPk.AQABAAIAAAD--DLA3VO7QrddgJg7WevrVuRshbs44mxySA7zNdYQtmyMzmKQ0kw6QVE8zfCovCHRpFAazXr4L71064rCDo8E7kQFkFevv4P-jokK_JRqxnJFRoDfK8vlHmS9E4dLdw1Uaz-bcFLMwsLj1jCZ7D1kGQJD3PGMVanLdU-b-nSJHD7FmfMDsLzZGu6nxxfWPp3UtRPX6qxh9JTcn2qfHdah4KxfpteZ1f4BQc-9P-Oahbm2qgLWUTFbWRvFeLPGmvqpX9Okm-Z-aeTX3J7bZIvAVikXcWmMq13bQ0dLCDuXAdSLs701tTNyPZb1xWtkFpiy3a4Cp0MXcanQkgW5s0NU8qlaRZEOXZsyZfqmhTP3A8Tz-oLvWpC5Ue3lGQPDb2JbJUlPHGrHtE9aqPxF_PSJjIil0PUzLYUE9SbUmZHtYAajzl-B9sS_EUBTMfV7ohYplps29V7J_WrrdFWQCtz14uoOw1zrmaX4XpMny7bKOzKdpXw_GKjAHVTzlFORueD1AwDeYBpuue1MdkwSjnxPa4Q1vKsuT578bqOU5wS5mSQVmcweVs4MrrfX8WJkUUBBA5inURkxfD19sRDkTQYPFnFtiwZiJoAX4VS3S95V3b_NvAkinsN4fyKwZHffkpjc8m1GVKXblPiIMN8pkrqlJxoyQm6aTuknZXbIpPSwhOq7-wLCAp4qb6xSTegvlIJa2qFiwn-RJAnJfqE7Y5axkGs5jH5HdghqnVPnAJoPHwiKWMylz-aLcgEpuCdmuiuWuVYeD7_mcl1dIetqOP-KvstHvDfdHFFxxeCFGVtRWga93nf9dzz2tnACITZbcImkHmEvDXjKHG1u_s5dY460xc43w36Ye5X6HdGs2UGPP-cPtwz0-pL7TAmH5emfMbYXmUn8v-_RVsWhKURfvWE7O5s0Tr-U_LWLw-JqWlx9mHpkBsGnDbrinVvlHiZWicd09FbHFajXV_T7CRijpp--IAA&session_state=8c7603fa-7d85-42d5-bb29-d5ea29218289'
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
 
