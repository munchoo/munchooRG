#%%
import imp
from matplotlib import offsetbox
import openpyxl
from openpyxl.drawing.image import Image as im3
import glob
import os
import tkinter
from tkinter import Image, filedialog
import pandas as pd

path = os.getcwd()
Ofc_list = pd.read_excel('C:/Users/Administrator/Desktop/GSpay홍보물취합_자동화/ofclist.xlsx')

# 워크시트 불러오기 tkinter
# root = tkinter.Tk()
# root.withdraw()
# dir_path = filedialog.askopenfile(filetypes=[('엑셀','*.xlsx')])

dir_path = 'C:/Users/Administrator/Desktop/GSpay홍보물취합_자동화/source.xlsx'
save_path2 = 'C:/Users/Administrator/Desktop/GSpay홍보물취합_자동화/source2.xlsx'
img_path = 'C:/Users/Administrator/Desktop/GSpay홍보물취합_자동화/img/'
wb = openpyxl.load_workbook(dir_path)

img_height = 247.6
img_width = 312.8
row_num = 5
col_num = 3

source = wb[wb.sheetnames[0]]


# Uniq_team = Ofc_list['점포(팀)'].unique()
a = Ofc_list[Ofc_list['점포(팀)'] == '신규점팀']
unique_name = a['시트명'].unique()

# 파트별 시트만들기
for i in unique_name:
    target = wb.copy_worksheet(source)
    target.title = i
    c = a[a['시트명']==i]   
    row_num = 5
# 시트에 사진넣기
    for idx, row in c.iterrows():
        try:
            img = im3(f'{img_path}{row["점포명"]}_1.jpg')
            img2 = im3(f'{img_path}{row["점포명"]}_2.jpg')
            img3 = im3(f'{img_path}{row["점포명"]}_3.jpg')

            img.height = img_height
            img.width = img_width
            img2.height = img_height
            img2.width = img_width
            img3.height = img_height
            img3.width = img_width

            #점포명과 이미지 넣기
            target.cell(row=row_num, column=col_num, value=row['점포명'])
            target.add_image(img, f'D{row_num}')
            target.add_image(img2, f'E{row_num}')
            target.add_image(img3, f'F{row_num}')
            row_num += 1
        except:
            continue
# save_path = dir_path.name.replace('source.xlsx','hi')
wb.remove_sheet(wb['원시'])
wb.save(save_path2)
 



# wb.chartsheets


# target = wb.copy_worksheet(source)
# target.title = '1파트)김충필'


# wb.save(dir_path.name)


