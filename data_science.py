import numpy as np
import time

def test_run():
    print np.empty(5)
    print np.array([(2,3,4),(1,2,3)])

    t1 = time.time()
    nd1 = np.random.random((1000, 10000))
    t2 = time.time()
    print t2-t1

    b = np.random.randint(0, 10, size=(5, 4))
    b[np.unravel_index(b.argmax(), b.shape)]


if __name__ == '__main__':
    test_run()