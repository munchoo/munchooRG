import simplejson,requests
import sys
url = "https://dapi.kakao.com/v2/local/search/keyword.json?"
apikey = "4cf2cd774c19e11caf8d9718d4deca0c"
query = "gs25운남삼성"
r = requests.get( url, params = {'query':query}, headers={'Authorization' : 'KakaoAK ' + apikey } )
js = simplejson.JSONEncoder().encode(r.json())
r.json()
print(js)