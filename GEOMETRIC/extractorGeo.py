import requests
import sys
import json


url = 'https://dapi.kakao.com/v2/local/search/address.json?'
apikey = "4cf2cd774c19e11caf8d9718d4deca0c"
query = address='korea '
r = requests.get(url, params = {'query':query}, headers={'Authorization' : 'KakaoAK ' + apikey })
dicts = json.dumps(r)
print(dicts)