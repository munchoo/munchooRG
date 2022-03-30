import json

### 구성원 ID불러오기 완료되면 종료

file_path = './Graph/address.json'
idmatt = {}
with open(file_path, 'r', encoding='utf-8') as file:
    data = json.load(file)
    data = data.get('value')
    for idx in data:
        idmatt[idx.get('givenName')] = {'id':idx.get('id'),'chat_id':''}

with open ('./Graph/meminfo2.json', 'w', encoding='utf-8') as file:
    json.dump(idmatt, file , indent=4, ensure_ascii=False )
