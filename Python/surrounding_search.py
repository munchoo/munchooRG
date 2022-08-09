#%%
import imp
from turtle import distance
import pandas as pd
import numpy as np
import requests
import pprint
import re

# 위도경도 파일 불러오기
df = pd.read_excel('storegps.xlsx')
storeNm = []
schoolNm = []
categoryNm = []
todistance = []
# 키워드 api 불러오기
url = 'https://dapi.kakao.com/v2/local/search/keyword.json' #원하는 검색어을 스타벅스 자리에, 경도는 x에, 위도는 y에, 반경은 10000에, 카테고리는 위의 표를 보고 해당되는 카테고리를 적어주세요 

for idx, row in df.iterrows():
    params = {'query' : '대학교', 'x' : row['경도'], 'y' : row['위도'], 'radius' : 500,'category_group_code' : 'SC4'} ## 본인의 카카오 맵 API의 REST API키를 바로 아래 한글로 된 코드를 지우고 입력해주세요 
    headers = {"Authorization": "KakaoAK 4cf2cd774c19e11caf8d9718d4deca0c"} 
    # total = requests.get(url, params=params, headers=headers).json() #places는 검색이 잘 되었는지 체크하는 용도로 확인해주시면 됩니다. 다시 말씀드리지만 places에는 45개 데이터가 한계입니다... ## 페이지 수를 늘려도, 한 페이지 안에서 보여줄 수 있는 한계치를 아무리 높혀도 45개 이상 안 보여 줍니다. 저는 페이지 설정은 보시다시피 하지는 않았습니다. 
    places = requests.get(url, params=params, headers=headers).json()['documents'] ## 원하는 개수는 total변수 안에 있습니다.
    try:
        for i, a in enumerate(places):
            storeNm.append(row['최초코드'])
            schoolNm.append(a['place_name'])
            todistance.append(a['distance'])
            slice_category = re.findall('학교\s\>.*',places[0]['category_name'])
            slice_category = re.sub('학교\s\>\s','',slice_category[0])
            categoryNm.append(slice_category)

            # df.iloc[idx,3] = a['place_name']
            # df.iloc[idx,4] = a['distance']
            # print(slice_category)
            # df.iloc[idx,5] = slice_category
            # print(f"{i['최초코드']} : {a['place_name']} ({a['distance']})")
            print(idx,'success')
    except:
        print('Fail')
        pass

surround_school = pd.DataFrame({'점포코드':storeNm,'학교명':schoolNm,'거리':todistance,'카테고리':categoryNm})

surround_school.to_excel('output_school3.xlsx',sheet_name='sample')

# aa = re.findall('학교\s\>.*',places[0]['category_name'])
# aa = re.sub('학교\s\>\s','',aa[0])
