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
# 각각의 정보를 리스트로 받아와서 최종으로 딕셔너리 형태로 합치기!
storeNm = []
schoolNm = []
categoryNm = []
todistance = []

# 키워드 api 불러오기
url = 'https://dapi.kakao.com/v2/local/search/keyword.json' 

# df의 경도,위도값을 불러와서 params값에 넣고, 헤더에는 api key 입력 하여 Request.get 요청하여 json 형태로 받아온다.
for idx, row in df.iterrows():
    # query는 검색할 검색어, x 는 경도, y는 위도, radius는 범위(서클형), 카테로그리 그룹코드는 필터링 SC4는 학교
    params = {'query' : '대학교', 'x' : row['경도'], 'y' : row['위도'], 'radius' : 500,'category_group_code' : 'SC4'} 
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
