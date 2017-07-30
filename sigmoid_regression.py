import numpy as np
import matplotlib.pyplot as plt
import scipy.optimize as spo

def sigmoid(a):
    return 1 / (1 + np.exp(-a))

def phi(x, mu, s = 0.1):
    return(sigmoid((x-mu)/s))


def error_function(w, y, phi_mtx):
    return np.sum((y-phi_mtx.dot(w))**2)+np.sum(np.abs(w)**4)

x = np.arange(-1, 1, 0.05)
mu = np.arange(-2, 2.01, 0.2)

for m in mu:
    plt.plot(x, phi(x,m))


#y = phi(x, 0) + np.random.normal(0,0.1,size=len(x))

#y = x*2 + np.random.normal(0,0.1,size=len(x))


plt.plot(x, phi(x,0))
plt.plot(x, y, 'ro')

rows = []

for m in mu:
    rows.append(phi(x,m))

phi_mtx = np.vstack(rows).T

w0 = np.ones(len(mu))

min_result = spo.minimize(error_function, w0, (y, phi_mtx), method="SLSQP", options={'disp':True})

plt.plot(x, phi_mtx.dot(min_result.x))
plt.plot(x, y, 'ro')