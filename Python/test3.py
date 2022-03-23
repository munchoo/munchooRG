import adal
import requests
import json

tenant = "gsretail.co.kr"
client_id = "312435a5-4dd6-40f8-a606-49bbb30c254d"
client_secret = "6SH7Q~-bKmoBmiVopd-sRv6cjKwQd-HB9g2GL"

username = "munchoo@gsretail.com"
password = "dud5@ska2"

authority = "https://login.microsoftonline.com/" + tenant
RESOURCE = "https://graph.microsoft.com"

context = adal.AuthenticationContext(authority)

# Use this for Client Credentials
#token = context.acquire_token_with_client_credentials(
#    RESOURCE,
#    client_id,
#    client_secret
#    )

# Use this for Resource Owner Password Credentials (ROPC)  
token = context.acquire_token_with_username_password(RESOURCE, username, password, client_id);

graph_api_endpoint = 'https://graph.microsoft.com/v1.0{0}'

# /me only works with ROPC, for Client Credentials you'll need /<UsersObjectId/
request_url = graph_api_endpoint.format('/chats')
headers = { 
'User-Agent' : 'python_tutorial/1.0',
'Authorization' : 'Bearer {0}'.format(token["accessToken"]),
'Accept' : 'application/json',
'Content-Type' : 'application/json'
}

bodys = {'body': {'content': 'My name:'}}


response = requests.post(url = request_url, headers = headers, data=bodys)
print (response.content)