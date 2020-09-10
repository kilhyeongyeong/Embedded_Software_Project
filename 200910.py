# -*- coding: utf-8 -*-

import platform
import numpy as np
import argparse
import cv2
import serial
import time
import sys
import pytesseract
from threading import Thread
from 200910 import line.py

pytesseract.pytesseract.tesseract_cmd = r'C:/Program Files/Tesseract-OCR/tesseract'

serial_use = 1

serial_port =  None
Read_RX =  0
receiving_exit = 1
threading_Time = 0.01

# ---------camera-setting---------------
c_W = 320
c_H = 240
FPS = 90

#------------------모션 제어--------------------------- 
def TX_data_py2(ser, one_byte):  # one_byte= 0~255
    """
        ser : 연결된 시리얼 번호
        one_byte : 모션에 Key값에 해당하는 번호를 입력
    """
    #ser.write(chr(int(one_byte)))          #python2.7
    ser.write(serial.to_bytes([one_byte]))  #python3
#-----------------------------------------------
def RX_data(ser):

    if ser.inWaiting() > 0:
        result = ser.read(1)
        RX = ord(result)
        return RX
    else:
        return 0

# *************************
def Receiving(ser):
    global receiving_exit

    global X_255_point
    global Y_255_point
    global X_Size
    global Y_Size
    global Area, Angle

    receiving_exit = 1
    while True:
        if receiving_exit == 0:
            break
        time.sleep(threading_Time)
        while ser.inWaiting() > 0:
            result = ser.read(1)
            RX = ord(result)
            print ("RX=" + str(RX))
            
            # -----  remocon 16 Code  Exit ------
            if RX == 16:
                receiving_exit = 0
                break
                
# -------------라인찾기------------------------------
def FindLine():
    pass
    #해야됨
# **************************************************
# **************************************************
if __name__ == '__main__':

    #-------------------------------------
    print ("-------------------------------------")
    print ("---- (2020-1-20)  MINIROBOT Corp. ---")
    print ("-------------------------------------")
   
    os_version = platform.platform()
    print (" ---> OS " + os_version)
    python_version = ".".join(map(str, sys.version_info[:3]))
    print (" ---> Python " + python_version)
    opencv_version = cv2.__version__
    print (" ---> OpenCV  " + opencv_version)
    print ("-------------------------------------")
 
    BPS =  4800  # 4800,9600,14400, 19200,28800, 57600, 115200

    #---------local Serial Port : ttyS0 --------
    #---------USB Serial Port : ttyAMA0 --------
    
    #--------------시리얼 포트 불러옴--------------(포트,BPS,timeout)
    serial_port = serial.Serial('/dev/ttyS0', BPS, timeout=0.01)
    serial_port.flush() # serial cls
    
    #serial_t 라는 함수 생성 후 쓰레드가 Receiving 메소드를 실행하도록 함
    serial_t = Thread(target=Receiving, args=(serial_port,))
    #daemon 쓰레드는 background에서 돌아가는 쓰레드. main이 종료되면 같이 종료됨
    serial_t.daemon = True
    serial_t.start()
    time.sleep(0.1)

    # 로봇 인스턴스 생성-----------------------------
    dabinoid = motion.Robot(serial_port)

    #-----------------camera----------------------
    cap = cv2.VideoCapture(0)
    cap.set(3, c_W)
    cap.set(4, c_H)
    #-------------------------------------------------Setting----------------------------------------------------------

    #1.방위확인  
    bearing = [0, 0, 0, 0]  # EWSN(동서남북)
    while True:
        # 영상 값 불러옴 img가 영상
        ret, img = cap.read()
        if not ret:
            break

        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        gray = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)[1]

        cv2.imshow('Video Test', gray)
        key = 0xFF & cv2.waitKey(1)
        if key == 27:  # ESC  Key
            cap.release()
            cv2.destroyAllWindows()
            break

        alphabet = pytesseract.image_to_string(img, lang='eng', config='--psm 10 -c preserve_interword_spaces=1')

        if alphabet.find("E") >= 0 or alphabet.find("e") >= 0:
            bearing[0] += 1
            if bearing[0] == 3:
                bearing = [0, 0, 0, 0]
                print("finish_E")
                dabinoid.east()
                break;
        elif alphabet.find("W") >= 0 or alphabet.find("w") >= 0:
            bearing[1] += 1
            if bearing[1] == 3:
                bearing = [0, 0, 0, 0]
                print("finish_W")
                dabinoid.west()
                break;
        elif alphabet.find("S") >= 0 or alphabet.find("s") >= 0:
            bearing[2] += 1
            if bearing[2] == 3:
                bearing = [0, 0, 0, 0]
                print("finish_S")
                dabinoid.south()
                break;
        elif alphabet.find("N") >= 0 or alphabet.find("n") >= 0:
            bearing[3] += 1
            if bearing[3] == 3:
                bearing = [0, 0, 0, 0]
                print("finish_N")
                dabinoid.north()
                break;
        else:
            continue
    #2.라인찾기
    findline(cap)
    #2-1.모션
    #걷기
    #3.화살표 찾기
    arrow = ""
    Count_L = 0
    Count_R = 0
    y_left = 0
    y_right = 0
    im_cnt = 0
    #--------------화살표 찾기 변수들----------------
    while True:
        # 영상 값 불러옴 img가 영상
        ret, img = cap.read()
        if not ret:
            break

        gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
        corners = cv2.goodFeaturesToTrack(gray, 100, 0.01, 5, blockSize=3, useHarrisDetector=True, k=0.03)

        ymax = 0
        for i in corners:
            ymax = max(ymax, i[0, 1])
            cv2.circle(img, tuple(i[0]), 3, (0, 0, 255), 2)

        cv2.imwrite('/home/pi/Desktop/run/' + 'im_{}.jpg'.format(im_cnt), img)

        cv2.imshow('Video Test', img)
        key = 0xFF & cv2.waitKey(1)
        if key == 27:  # ESC  Key
            cap.release()
            cv2.destroyAllWindows()
            break

        for i in corners:
            if i[0, 1] == ymax:
                x = i[0, 0]

        edge = cv2.Canny(gray, 50, 150)
        cv2.imwrite('/home/pi/Desktop/run/' + 'Canny_{}.jpg'.format(im_cnt), edge)
        im_cnt += 1

        for i in range(0, 240):
            if edge[i, int(x - 10)] != 0:
                y_left = i
            if edge[i, int(x + 10)] != 0:
                y_right = i

        if y_left > y_right:
            print("L")
            Count_L += 1
        else:
            print("R")
            Count_R += 1

        if Count_L == 3:
            print("LEFT!")
            arrow = "L"
            Count_L = 0
            Count_R = 0
            break;
        elif Count_R == 3:
            print("RIGHT!")
            arrow = "R"
            Count_L = 0
            Count_R = 0
            break;
        else:
            continue
    #3-1.모션
    #조금 더 앞으로 나온 후 화살표 방향대로 몸통 틀기!!!
    #4.라인찾기
    fineline(cap)
    #4-1.모션
    #걷기
    #5.미션

    # -----  remocon 16 Code  Exit ------
    while receiving_exit == 1:
        time.sleep(0.01)
      
    cap.release()
    cv2.destroyAllWindows()

    #----------------------------------------------------초기화----------------------------------------------------------
    bearing = [0, 0, 0, 0]

    exit(1)
    
    #라인찾는소스가 워낙에 길어서 저렇게 클래스로 빼고 싶은데 
    #저렇게 사용하는게 맞는지는 모르겠당....... (line.py에 클래스 있엉...) 
    #우선은 저런식으로 하는건 어때? while문으로 한꺼번에 묶진 않았어...!
    #미션할때는 3번 반복해야 하니까 그때 while문으로 묶을까 하는데 어떨지 모르겠...!
