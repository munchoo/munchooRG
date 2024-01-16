import xml.etree.ElementTree as ET

xml_data = b'<?xml version="1.0" encoding="UTF-8"?>\n<Root xmlns="http://www.nexacro.com/platform/dataset" ver="5000">\n\t<Parameters>\n\t\t<Parameter id="ErrorCode" type="string">-991</Parameter>\n\t\t<Parameter id="ErrorMsg" type="string">Running&#32;Server&#32;Sys&#32;Exception&#32;:&#32;java.lang.NullPointerException</Parameter>\n\t</Parameters>\n</Root>\n'

# XML 파싱
root = ET.fromstring(xml_data)

# 네임스페이스 정의
namespace = {'ns': 'http://www.nexacro.com/platform/dataset'}

# ErrorCode와 ErrorMsg 값을 추출
error_code = root.find('.//ns:Parameter[@id="ErrorCode"]', namespace).text
error_msg = root.find('.//ns:Parameter[@id="ErrorMsg"]', namespace).text

print(f'ErrorCode: {error_code}')
print(f'ErrorMsg: {error_msg}')
