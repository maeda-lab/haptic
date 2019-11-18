'''
参考
https://qiita.com/mhangyo/items/76db7c6a6ebba6cf4330
'''
import numpy as np

#f = open(r"C:\Users\saku_\Documents\GitHub\haptic\sensor\Height_Row_0000.data",mode='rb')
f = open(r"\\FS1\Maedalab\home\junjie-hua\wave\fourD_sensor\rawdata\20191101\test1_belly\Height\Height Row 0000.data",mode='rb')
topo = np.fromfile(f, dtype='>f',sep='').reshape(1024,10000)


print(topo)
#print(topo[1])
#print(topo[:1])