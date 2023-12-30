import pandas as pd
import re

def ssv_to_dataframe(ssv_data):
    matches = re.findall(r'_RowType_.*?SALE_QTY10:bigdecimal\(\d+\)', ssv_data)
    result_list = []
    
    for match in matches:
        match_dict = {}
        match = re.sub(r'_RowType_.*?N.*?N', '', match)
        fields = re.findall(r'([^:]+):([^:]+)', match)
        for field, value in fields:
            match_dict[field.strip()] = value.strip()
        result_list.append(match_dict)

    df = pd.DataFrame(result_list)

    return df

def process_ssv_data(ssv_data):
    ssv_records = ssv_data.split('')
    dfs = []
    
    for i, record in enumerate(ssv_records):
        df = ssv_to_dataframe(record)
        dfs.append(df)
        
        # Concatenate DataFrames every 11 records
        if (i + 1) % 11 == 0:
            result_df = pd.concat(dfs, ignore_index=True)
            dfs = []
            yield result_df
    
    # Return any remaining DataFrames
    if dfs:
        result_df = pd.concat(dfs, ignore_index=True)
        yield result_df

# 테스트용 데이터
ssv_data = '''SSV:UTF-8ErrorCode:int=0ErrorMsg:string=successDataset:ds_outSummary_RowType_BIZPL_NM:string(256)BIZPL_CD:string(256)ORD_QTY1:bigdecimal(256)ORD_QTY2:bigdecimal(256)ORD_QTY3:bigdecimal(256)ORD_QTY4:bigdecimal(256)ORD_QTY5:bigdecimal(256)ORD_QTY6:bigdecimal(256)ORD_QTY7:bigdecimal(256)ORD_QTY8:bigdecimal(256)ORD_QTY9:bigdecimal(256)ORD_QTY10:bigdecimal(256)STK_QTY1:bigdecimal(256)STK_QTY2:bigdecimal(256)STK_QTY3:bigdecimal(256)STK_QTY4:bigdecimal(256)STK_QTY5:bigdecimal(256)STK_QTY6:bigdecimal(256)STK_QTY7:bigdecimal(256)STK_QTY8:bigdecimal(256)STK_QTY9:bigdecimal(256)STK_QTY10:bigdecimal(256)SALE_QTY1:bigdecimal(256)SALE_QTY2:bigdecimal(256)SALE_QTY3:bigdecimal(256)SALE_QTY4:bigdecimal(256)SALE_QTY5:bigdecimal(256)SALE_QTY6:bigdecimal(256)SALE_QTY7:bigdecimal(256)SALE_QTY8:bigdecimal(256)SALE_QTY9:bigdecimal(256)SALE_QTY10:bigdecimal(256)NGS25강진서성점V2C3900000000000000000000000000000'''

for i, result_df in enumerate(process_ssv_data(ssv_data)):
    print(f"DataFrame {i + 1}:\n{result_df}\n")