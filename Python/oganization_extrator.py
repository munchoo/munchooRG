import requests
from bs4 import BeautifulSoup
from urllib.request import urlretrieve
import re
import pandas as pd

#접속하기위한 요청헤더
#cookies는 직원 조회화면 쿠키, cookies2는 개별조회화면 쿠키
cookies = 'InitechEamUURL=https%3A%2F%2Fspsif.gsretail.com%2F; InitechEamRTOA=1; InitechEamNoCacheNonce=UjNHkGUM0qX8RxiJ%2FvcF5w%3D%3D; cps_ck1=eKQ0V02oV6Cq2rwZT5LU4JJPQ16IOy9C6TMimZcdCeOS2p5uxXMAUHViHWrmd+JM; SSO_Info=s7zn2g3yQL78Uel2RiK6hw==:b92LcCSoJRSTjGUB+C427Q==:as1aCoI2mjoSMsCNZkYf6w==:rRNhfg7us6bRUzXQed0hWg==:False; Login_Info=eKQ0V02oV6Cq2rwZT5LU4JJPQ16IOy9C6TMimZcdCeOS2p5uxXMAUHViHWrmd+JM; cps_cc=GSR; ASP.NET_SessionId=l5nrpdej0nx0hw4tlg2xh0ei; Smart2Application=52AB27D38212FFAC85F87DC23F0AF79B10EA50512DEF74C91D1758210ADCEEB22562522BA6C4627466EE838DA105C7747465B821615A5EC831B865B4589445745A295CA278699D101BD3AD450527FA955F5D00100D1932D3AAD32DF9362FD59DF52F07522A70E29D821891B31DF1299BD9840C24C2DE56F1C386CEB317EFF4FD1AEE70312867F1EC24469A5E18551C94'
cookies2 = 'InitechEamUURL=https%3A%2F%2Fspsif.gsretail.com%2F; InitechEamRTOA=1; InitechEamNoCacheNonce=UjNHkGUM0qX8RxiJ%2FvcF5w%3D%3D; cps_ck1=eKQ0V02oV6Cq2rwZT5LU4JJPQ16IOy9C6TMimZcdCeOS2p5uxXMAUHViHWrmd+JM; SSO_Info=s7zn2g3yQL78Uel2RiK6hw==:b92LcCSoJRSTjGUB+C427Q==:as1aCoI2mjoSMsCNZkYf6w==:rRNhfg7us6bRUzXQed0hWg==:False; Login_Info=eKQ0V02oV6Cq2rwZT5LU4JJPQ16IOy9C6TMimZcdCeOS2p5uxXMAUHViHWrmd+JM; cps_cc=GSR; ASP.NET_SessionId=l5nrpdej0nx0hw4tlg2xh0ei; Smart2Application=28354ED0890722FC22D597CA8107067D8802409BE83F4514DA0557E13AA06415EA9743405137F1809AAB05085D020E4EE29A7275292B79ED9A013D103920EBE59CC288562925A0DD0C2AD3209B47B85675C86853F9A455E6986A6E480FFB6845E335AA976B5FABF6D2901B36FF32E33FD2FDD2F967B225E8EC4F271038D0B22CF64F2070417EB642B1C7903430798217'

# headers2 = {'Accept':' */*', 'Accept-Encoding':' gzip, deflate', 'Accept-Language':' ko', 'Cookie':' _ga=GA1.2.612828677.1602417527; InitechEamUURL=https%3A%2F%2Fspsif.gsretail.com%2FLogin_exec.aspx; InitechEamRTOA=1; InitechEamNoCacheNonce=aaqfugfvtnE%2FnLA8aXXfLw%3D%3D; cps_ck1=eKQ0V02oV6Cq2rwZT5LU4JJPQ16IOy9C6TMimZcdCeOS2p5uxXMAUHViHWrmd+JM; SSO_Info=s7zn2g3yQL78Uel2RiK6hw==', 'Host':' gw.gsretail.com', 'If-Modified-Since':' Wed, 06 Apr 2016 07', 'If-None-Match':' "0245894d78fd11'}
headers = {'Accept':'image/gif, image/jpeg, image/pjpeg, application/x-ms-application, application/xaml+xml, application/x-ms-xbap, */*', 'Accept-Encoding':'gzip, deflate', 'Accept-Language':'ko', 'Cookie':cookies, 'Host':'gw.gsretail.com', 'User-Agent':'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 10.0; WOW64; Trident/7.0; .NET4.0C; .NET4.0E; .NET CLR 2.0.50727; .NET CLR 3.0.30729; .NET CLR 3.5.30729; Tablet PC 2.0; MARKANYREPORT#25105)'}
headers2 ={'Accept':'*/*', 'Accept-Encoding':'gzip, deflate', 'Accept-Language':'ko', 'Cookie':cookies2, 'Host':'gw.gsretail.com', 'User-Agent': 'User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 10.0; WOW64; Trident/7.0; .NET4.0C; .NET4.0E; .NET CLR 2.0.50727; .NET CLR 3.0.30729; .NET CLR 3.5.30729; Tablet PC 2.0; MARKANYREPORT#25105)'}  



## 쿠키부분만 수정.
# header는 basicUrlC1 주소에서 가져오기
# header2은 basicUrlc2 에서 가져오기


#기본주소
basicUrl ='https://gw.gsretail.com'
#부문조직도를 가져오기위한 첫번째 주소
basicUrlC1 ='https://gw.gsretail.com/WebSite/Common/OrgMap/ListEx.aspx'
#paramsC1 = {'Type':'A0','Group':'Y','AllCompany':'Y','Target':'U','SearchType':'DN','SearchText':'3%eb%b6%80%eb%ac%b8','SubSystem':'PORTAL','TreeKind':'Dept','Caller':'User','SelectedItemID':'','IframeName':'','OpenName':'divOrgMap','CallBackMethod':'','CuCode':'','CFN_OpenLayerName':'divOrgMap'}
paramsC1 = {'Type':'A0','DN_ID':'1','Target':'U','SearchType':'DN','SearchText':'4부문','ViewType':'LIST','ContainLowerGR':'N'}
#개별품목 조회할때 매개변수
basicUrlC2 = 'https://gw.gsretail.com/WebSite/Common/Personal/Profile/UserProfile.aspx'

   

session = requests.session()

name = []
email =[]
wid=[]
position=[]
damdang=[]
teamName=[]
officePhoneNum=[]
cellPhoneNum=[]
officeNum=[]

bumonList = session.post(url=basicUrlC1, headers=headers2, params=paramsC1)
soup = BeautifulSoup(bumonList.content, 'html.parser')
print(soup)

for nameTag in soup.find_all('span', class_='txt_bb12'):
    name.append(nameTag.get_text())

for deptTag in soup.find_all('span', class_='spanImnmark'):
    email.append(deptTag.get('sipaddress'))
    wid.append(deptTag.get('sipaddress').split('@')[0])

for deptTag2 in soup.find_all('p',class_='ellipsis2'):
    if deptTag2.get_text() != '':
        imsi = deptTag2.get_text().split(',')
        position.append(imsi[0].split('(')[1])
        damdang.append(imsi[1].strip())
        teamName.append(imsi[2].strip())
        officePhoneNum.append(imsi[3].rstrip(')'))
        cellPhoneNum.append(imsi[-1].rstrip(')'))

#데이터형식변환data = {'name':name, 'email':email, 'wid':wid}

comNum = []
pcurl = 'D:/4부문사진/'

for URCode_a, nameT in zip(wid, name):
        if URCode_a == '':
            print('제외')
            officeNum.append('제외')
            continue    
        paramsC2 = {'URCode':URCode_a, 'CFN_OpenWindowName':'UserProfile_1ce02836b4763d'}
        indiList = session.post(url=basicUrlC2, headers=headers, params=paramsC2)
        soupIndi = BeautifulSoup(indiList.content, 'html.parser')
        imageLocation = soupIndi.find('img',{'id':'spPhotoPath'})['src']
        PosionNum = imageLocation.split(sep='/')[4]
        print(imageLocation, nameT, PosionNum)
        urlretrieve (basicUrl + imageLocation, pcurl+PosionNum)
        officeNum.append(PosionNum)


data = {'name':name, 'email':email, 'wid':wid,'position':position, 'teamName':teamName, 'cellPhoneNum':cellPhoneNum, 'offciePhoneNum':officePhoneNum, 'officeNum':officeNum}
df = pd.DataFrame(data)
print(df)
df.to_excel("D:/4부문사진/ogani.xlsx")



