import os
import time
from tricks import *
from ai import *
from config import *
if productive:
    from gevent import monkey
    monkey.patch_all()
from bottle import route, run, static_file, request, BaseRequest
import base64
import re
import cv2
import datetime
from PIL import Image

def do_paint():
    print('received')

#    sketchID = "new"
##    sketchID = "Apr_18_00_41_40"
#
#    # MARK - sketchID
#    if sketchID == 'new':
#        dstr = datetime.datetime.now().strftime('%b_%d_%H_%M_%S')
#        directory = 'record/' + dstr
#        if not os.path.exists(directory):
#            os.makedirs(directory) #create new directory
#
#        # reading images
#        referenceDataURL = cv2.imread("img/reference1.png", cv2.IMREAD_UNCHANGED)
#        sketchDataURL = cv2.imread("img/sketch1.png", cv2.IMREAD_UNCHANGED)
##        sketchDataURL = cv2.imread("img/sketchKeras_pured.jpg", cv2.IMREAD_UNCHANGED)
#
#
#        # saving images into "record" directory
#        cv2.imwrite('record/' + dstr + '/reference.png', referenceDataURL)
#        cv2.imwrite('record/' + dstr + '/sketch.png', sketchDataURL)
#    else:
#        dstr = sketchID
#        sketchDataURL = cv2.imread('record/' + dstr + '/sketch.png', cv2.IMREAD_UNCHANGED)
#        referenceDataURL = cv2.imread('record/' + dstr + '/reference.png', cv2.IMREAD_UNCHANGED)


    dstr = datetime.datetime.now().strftime('%b_%d_%H_%M_%S')

    # reading images
    referenceDataURL = cv2.imread("img/reference1.png")
    #sketchDataURL = cv2.imread("img/sketch1.png")
#    sketchDataURL = cv2.imread("img/sketchKeras_pured.jpg")
    sketchDataURL = cv2.imread("img/sketchKeras.jpg")
    
    
    
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
#    hintDataURL = cv2.imread('record/' + dstr + '/hint.png', cv2.IMREAD_UNCHANGED)
    hintDataURL = cv2.imread('img/hint.png', cv2.IMREAD_UNCHANGED)
    local_hint = hintDataURL

    if referenceDataURL is not None:
        global_hint = k_resize(x=s_enhance(referenceDataURL, 2.0), k=14)
        local_hint[:, :, 0:3] = s_enhance(local_hint[:, :, 0:3], 1.5)
    else:
        global_hint = None

    # MARK - sketchID
    norm_path = 'record/' + dstr + '/' + sketch_config + '.norm.jpg'
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
        cv2.imwrite('record/' + dstr + '.dull.jpg', global_hint)

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

    cv2.imwrite('record/' + dstr + '/fin.jpg', fin)
    cv2.imwrite('result/' + dstr + '_fin.jpg', fin)



do_paint()
