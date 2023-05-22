import requests
from bs4 import BeautifulSoup
import gzip


s = requests.session()
cookies2 = 'WMONID=ZNNT1AqXS1L; JSESSIONID=0001vaHfWhiC-NLhdFRWimkfnIE:1b3rmbf21'
headers2 ={'Accept':'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7', 'Accept-Encoding':'gzip, deflate', 'Accept-Language':'ko-KR,ko;q=0.9,en-US;q=0.8,en;q=0.7', 'Cookie':cookies2, 'Host':'cvsscn.gsretail.com', 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36'} 
parm = {'fileNm':'GD_8802521894760_001.jpg'}

req = s.get('http://cvsscn.gsretail.com/cssc/index.html', headers=headers2)



# html 소스가져오기
html = req.text
header = req.headers
status = req.status_code
soup = BeautifulSoup(req.text, 'html.parser')
print(soup)

