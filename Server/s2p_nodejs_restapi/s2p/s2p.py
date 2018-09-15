import os
import sys
import time
import cv2
import datetime
from tricks import *
from config import *
if productive:
    from gevent import monkey
    monkey.patch_all()
from ai import *

def do_paint():
    print('received')
    
    data = sys.argv[1]
    img_path = str(data)
    img_path = img_path.split()[0]
    sketchDataURL = cv2.imread(img_path)

    dstr = datetime.datetime.now().strftime('%b_%d_%H_%M_%S')

    # reading images
    referenceDataURL = cv2.imread("./s2p/img/reference1.png")
    #sketchDataURL = cv2.imread("./s2p/img/sketch1.png")



    # MARK - Algorithm Config
    sketchDenoise = "true"
    resultDenoise = "true"
    algrithom = "stability"
    method = "colorize"

    sketch_config = sketchDenoise + '_' + algrithom + '_' + method

    print('sketchDenoise: ' + sketchDenoise)
    print('resultDenoise: ' + resultDenoise)
    print('algrithom: ' + algrithom)
    print('method: ' + method)

    t = time.time()

    sketch = sketchDataURL
    raw_shape = sketch.shape

    # MARK - hintDataURL
    hintDataURL = cv2.imread('./s2p/img/hint.png', cv2.IMREAD_UNCHANGED)
    local_hint = hintDataURL

    if referenceDataURL is not None:
        global_hint = k_resize(x=s_enhance(referenceDataURL, 2.0), k=14)
        local_hint[:, :, 0:3] = s_enhance(local_hint[:, :, 0:3], 1.5)
    else:
        global_hint = None

    # MARK - sketchID
    norm_path = './s2p/record/' + dstr + '_' + sketch_config + '.norm.jpg'
    if os.path.exists(norm_path):
        sketch = cv2.imread(norm_path, cv2.IMREAD_GRAYSCALE)
    else:
        if sketchDenoise == 'false':
            if algrithom == 'stability':
                sketch = cv_denoise(k_resize(sketch, 48))
            else:
                sketch = cv_denoise(k_resize(sketch, 64))
        else:
            if algrithom == 'stability':
                sketch = m_resize(sketch, min(sketch.shape[0], sketch.shape[1], 512))
                sketch = go_tail(sketch, noisy=True)
                sketch = k_resize(sketch, 48)
            else:
                sketch = m_resize(sketch, min(sketch.shape[0], sketch.shape[1], 768))
                sketch = go_tail(sketch, noisy=True)
                sketch = k_resize(sketch, 64)
        if method == 'transfer':
            sketch = go_line(sketch)
        else:
            sketch = cv2.cvtColor(sketch, cv2.COLOR_RGB2GRAY)
        cv2.imwrite(norm_path, sketch)


    if global_hint is None:
        tiny_sketch = sk_resize(sketch, 32)
        global_hint = k_resize(go_tail(go_dull(tiny_sketch, n_resize(k8_down_hints(local_hint), tiny_sketch.shape)), False), 14)

    print('process: ' + str(time.time() - t))

    t = time.time()
    if algrithom == 'stability':
        local_hint = k_down_hints(local_hint)
    local_hint = d_resize(local_hint, sketch.shape)
    if method == 'render':
        painting = go_neck(sketch, global_hint, local_hint)
    else:
        painting = go_head(sketch, global_hint, local_hint)
    print('paint: ' + str(time.time() - t))

    t = time.time()
    fin = go_tail(painting, noisy=(resultDenoise == 'true'))
    fin = s_resize(fin, raw_shape)
    print('denoise: ' + str(time.time() - t))

    cv2.imwrite('./s2p/result/' + dstr + '_fin.jpg', fin)
    img_path = os.path.splitext(img_path)[0]
    cv2.imwrite(img_path + '_fin.jpg', fin)


do_paint()
