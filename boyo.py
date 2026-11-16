import numpy as np
import pandas as pd
import matplotlib.pyplot as pltpython
df = pd.read_csv('C:/Users/ADMIN/Downloads/movies dataset.csv')
print(df)
print(df.head())   #first 5 rows
print(df.tail())    #last 5 rows
print(df.shape)     #rows,columns
print(df.info)    #info about df
print(df.describe)   #summary stats
print(df.columns)   #column names
 
 #SELECTING DATA
print(df['Title'])  #single column
print(df[['Title','Genre']])   #multiple columns
print(df[['Title','Genre','Year']])
print(df.loc[1])    #row by label
print(df.iloc[1])   #row by position
print(df.loc[0:2])   #inclusive
print(df.iloc[0:2])   #exclusive

#FILTERING DATA
print(df[df['Year']>2000])
print(df[(df['Year']>2000) & (df['IMDb_10']>5)])   #multiple conditions
print(df[(df['Year']>2000) & (df['IMDb_10']>5) &(df['Title']=='No Country for Old Men')])
print(df['Genre']. isin (['Drama']))  #movies in list
print(df[df['Genre']. str.startswith('D')])  #name starts with D

#SORTING
print(df.sort_values('Year')) #ascending
print(df.sort_values('Year', ascending=False))  #descending
print(df.sort_values(['Year','Title']))   #by multiple columns

#ADD/MODIFY COLUMNS
#print(df['City'] = ['Nairobi','Kiambu'])      #add new column
#print(df['Year'] = df['Mont'] *0.1)   #create from existing
#print(df.rename(columns={'Year': "Full name"}))  #remame column

#HANDLE MISSING VALUES
print(df.isnull())    #check missing
print(df.isnull().sum())    #count missing
#print(df.dropna())     #drop rows with NA
print(df.fillna(0))    #fill NA with 0
print(df.fillna({'IMDb_10':df['IMDb_10'].mean()}))     #fill with mean

#GROUP BY
print(df.groupby('IMDb_10').size())
print(df.groupby(['Year','IMDb_10']).size())   #by multiple columns
print(df.groupby('Genre')['Year'].mean())   #average year by genre

#AGGREGATION
print(df['IMDb_10'].mean())   #average rating
print(df['IMDb_10'].median())   #median rating
print(df['IMDb_10'].min())   #minimum rating
print(df['IMDb_10'].max())    #maximum rating
print(df['IMDb_10'].count())   #count
print(df['IMDb_10'].unique())    #unique count

#APPLY
print(df['IMDb_10'].apply(lambda x: x*2))   #double rating
print(df['Title'].apply(lambda x: x.upper()))   #uppercase title
print(df['Title'].apply(lambda x: x.lower())) 

#MERGE AND JOIN
print(df.merge(df, on='Title'))   #merge on title
print(df.merge(df, on='Title', how='left'))   #left join
pltpython.show()

#PIVOT TABLES
print(df.pivot_table(values='IMDb_10', index='Genre', columns='Year', aggfunc='mean'))   #pivot table
print(df.pivot_table(values='IMDb_10', index='Genre', columns='Year', aggfunc='sum'))   #pivot table

#CONCATENATE
#print(pd.concat([df1,df2]))   #row wise
#print(pd.concat([df1,df2], axis=1))   #column wise

#SAVING
print(df.to_csv('movies_output.csv', index=False))   #save to csv