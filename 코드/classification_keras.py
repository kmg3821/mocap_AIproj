#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
#from sklearn.preprocessing import LabelEncoder
from keras.utils import np_utils
from keras.models import Sequential
from keras.layers import Activation, Dense
from tensorflow.keras.losses import categorical_crossentropy

rawdata = pd.read_csv('./data/imudata_num.csv',names=["qu1","qu2","qu3","qu4","qu5","qu6","qu7","qu8","type"])


# In[2]:


print(rawdata)
print(type(rawdata))


# In[3]:


dataset = rawdata.values
X=dataset[:,0:8].astype(float)
Y_true=dataset[:,8]
Y_hat=np_utils.to_categorical(Y_true)
#Y_hat = Y_true
print(Y_hat)


# In[4]:


model = Sequential()
model.add(Dense(25,input_dim=8,activation='relu'))
model.add(Dense(5,activation='softmax'))

model.compile('adam',categorical_crossentropy,'accuracy')


model.fit(X, Y_hat, epochs=10, batch_size=50)


# In[5]:


print("\n 정확도 : %.4f" % (model.evaluate(X, Y_hat)[1]))


# In[6]:


model.summary()


# In[8]:


# 데이터 몇 개 가지고 테스트
test_x = pd.read_csv('./data/tete.csv',names=["qu1","qu2","qu3","qu4","qu5","qu6","qu7","qu8"])
y = model.predict(test_x)
aaa = y.tolist()


for i in range (len(aaa)):
    l1 = aaa[i]
    l2 = np.argmax(l1)
    if l2 == 0:
        print(f'차렷')
    elif l2 == 1:
        print(f'위')
    elif l2 == 2:
        print(f'옆')
    elif l2 == 3:
        print(f'위굽')
    elif l2 == 4:
        print(f'옆굽')


# In[ ]:




