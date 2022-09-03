#%%
from cmath import nan
from sqlite3 import Timestamp
import pandas as pd
import random as rd
import numpy as np
df = pd.DataFrame(
    {
        'sku' : [1] *25,
        'retail' : ['A'] * 20 + ['B'] * 5,
        'promotion_type' : [1] *10  + [2] * 10 + [2] *3 + [3] *2,
        'promotion_id' : ['A1-2019'] * 2 + ['A1-20201'] * 8 + ['A2-20201'] *3 + ['A2-20203'] * 5+ ['A2-20204'] * 2 + ['B2-20201'] * 3 + ['B3-20201'] *2 ,
        'date' : [
            pd.Timestamp(el) for el in ["2019-12-01", "2019-12-02", "2020-01-01",\
                                        "2020-01-02", "2020-01-03", "2020-01-04",\
                                        "2020-01-05", "2020-01-06", "2020-01-07",\
                                        "2020-01-08", "2020-01-21", "2020-01-22",\
                                        "2020-01-23", "2020-03-01", "2020-03-02",\
                                        "2020-03-03", "2020-03-04", "2020-03-05",\
                                        "2020-04-15", "2020-04-16", "2020-01-21",\
                                        "2020-01-22", "2020-01-23", "2020-01-21",\
                                        "2020-01-22"]],
        'sellin': [rd.randint(100, 200) for i in range(25)]
    }
)

df

# %%

horizon = 7

df = df.append(
    {
    'sku':1,
    'retail':'A',
    'promotion_type':3,
    'promotion_id':'A3-20203',
    'date':pd.Timestamp('2020-06-01'),
    'sellin':np.nan
    },

    ignore_index=True
)

df
# %%
df = df.merge(
    df.groupby(['sku','retail','promotion_id']).date.min().reset_index().rename(columns={'date':'min_promo_date'}), on=['sku','retail','promotion_id'],how='left'
)

df = df.sort_values('min_promo_date')

df['promo_rolling_mean'] = np.nan

df
# %%

# Definition of granularity levels to compute the rolling means, from the most granular 
# to the less granular
AGG_LEVELS = {
    "1": ["sku", "retail", "promotion_type"],
    "2": ["sku", "promotion_type"],
    "3": ["sku"]
}

# We iterate on the granularity levels (from the most granular to the less granular) in 
# order to compute the rolling mean on the most similar promotion for each row
for agg_level_number, agg_level_columns in AGG_LEVELS.items():
    
    # Once the rolling mean feature is filled, we break from the loop
    if df["promo_rolling_mean"].isna().sum() == 0:
            break
    
    # (1) We aggregate our dataframe to the current granularity level
    agg_level_df = df.groupby(["promotion_id"] + agg_level_columns) \
                   .agg({"sellin": "mean", "date": "min"}) \
                   .reset_index() \
                   .rename(columns={"date": "min_promo_date"}) \
                   .dropna(subset=["sellin"]) \
                   .sort_values("min_promo_date")

    # (2) We compute the rolling mean on the given horizon for the current granularity 
    # level
    agg_level_df["sellin"] = agg_level_df.groupby(agg_level_columns) \
                                         .rolling(horizon, 1)["sellin"] \
                                         .mean() \
                                         .droplevel(
                                            level=list(
                                                range(len(agg_level_columns))
                                            )
                                         )
    
    # (3) We merge the results with the main dataframe on the right columns and min promo 
    # date. We use the merge_asof to only take rolling means computed for dates before each 
    # observation date.
    df = pd.merge_asof(
            df,
            agg_level_df,
            by=agg_level_columns,
            on="min_promo_date",
            direction="backward",
            suffixes=(None, f"_{agg_level_number}"),
            allow_exact_matches=False
        )
    
    # We fill the feature with the rolling mean values for the current granularity level
    df["promo_rolling_mean"] = df["promo_rolling_mean"].fillna(
        df[f"sellin_{agg_level_number}"])
    
cols_to_keep = [
    "sku", "retail", "promotion_type", "promotion_id", "date", 
    "sellin", "promo_rolling_mean"
]

df = df[cols_to_keep].sort_values(
    by=['sku', 'retail', 'promotion_type', 'promotion_id', 'date'])

# %%
df