import numpy as np


data = np.genfromtxt('temperature.csv', dtype=float, delimiter=',', names=True)

print(data[0])


