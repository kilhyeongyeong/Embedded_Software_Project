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
import sys
import motion
import logging


serial_use = 1

serial_port =  None
Read_RX =  0
receiving_exit = 1
threading_Time = 0.01

pytesseract.pytesseract.tesseract_cmd = r'/usr/bin/tesseract'
logging.info("start Dabinoid")
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

    #로봇 인스턴스 생성
    dabinoid = motion.Robot(serial_port)

    #serial_t 라는 함수 생성 후 쓰레드가 Receiving 메소드를 실행하도록 함
    serial_t = Thread(target=Receiving, args=(serial_port,))
    #daemon 쓰레드는 background에서 돌아가는 쓰레드. main이 종료되면 같이 종료됨
    serial_t.daemon = True
    serial_t.start()
    time.sleep(0.1)

    #-----------------camera----------------------
    cap = cv2.VideoCapture(0)
    cap.set(3, c_W)
    cap.set(4, c_H)

    #단계 변수 설정
    check_EWSN = True
    check_direction = False
    #------------------------------------------
    fine_alphabet = False
    #변수 설정
    count = [0, 0, 0, 0]
    finish = False
    im_cnt = 0
    count_R = 0
    count_L = 0

    while True: 
        #영상 값 불러옴 img가 영상
        ret, img = cap.read()
        if not ret:
            break
        
        #2.방위확인-------------------------------------
        if check_EWSN == True:
            if find_alphabet == False:
                img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
                img_binary = cv2.adaptiveThreshold(img_gray, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 205, 70)
                left_pixel = np.where(img_binary[:, :160] == 0)
                right_pixel = np.where(img_binary[:, 160:320] == 0)

                if left_pixel > right_pixel:
                    logging.info("left")
                else:
                    logging.info("right")
                
                find_alphabet = False

            alphabet = pytesseract.image_to_string(img, lang='eng', config='--psm 7 -c preserve_interword_spaces=1')
            print(alphabet)
            if alphabet.find("E")>=0 or alphabet.find("e")>=0:
                count[0] += 1
                if count[0] == 3:
                    # 방위에 따른 동작....!
                    count = [0, 0, 0, 0]
                    print("finish_E")
                    dabinoid.east()
                    check_EWSN = False
            elif alphabet.find("W")>=0 or alphabet.find("w")>=0:
                count[1] += 1
                if count[1] == 3:
                    # 방위에 따른 동작....!
                    count = [0, 0, 0, 0]
                    print("finish_W")
                    dabinoid.west()
                    check_EWSN = False
            elif alphabet.find("S")>=0 or alphabet.find("s")>=0:
                count[2] += 1
                if count[2] == 3:
                    # 방위에 따른 동작....!
                    count = [0, 0, 0, 0]
                    print("finish_S")
                    dabinoid.south()
                    check_EWSN = False
            elif alphabet.find("N")>=0 or alphabet.find("n")>=0:
                count[3] += 1
                if count[3] == 3:
                    # 방위에 따른 동작....!
                    count = [0, 0, 0, 0]
                    print("finish_N")
                    dabinoid.north()
                    check_EWSN = False
            else:
                pass

            if check_EWSN == False:
                check_direction = True


    #3.문열기(걷기)----------------------------------
    
    #4.화살표확인------------------------------------
        if check_direction == True:
            logging.info("check direction")
            # 영상 값 불러옴 img가 영상

            gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
            corners = cv2.goodFeaturesToTrack(gray, 100, 0.01, 5, blockSize=3, useHarrisDetector=True, k=0.03)

            try:
                ymax = 0
                for i in corners:
                    ymax = max(ymax, i[0, 1])
                    cv2.circle(img, tuple(i[0]), 3, (0, 0, 255), 2)

                cv2.imwrite('/home/pi/Desktop/run/' + 'im_{}.jpg'.format(im_cnt), img)

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
                    count_L += 1
                else:
                    print("R")
                    count_R += 1

                if count_L == 3:
                    print("LEFT!")
                    arrow = "L"
                    count_L = 0
                    count_R = 0
                    break;
                elif count_R == 3:
                    print("RIGHT!")
                    arrow = "R"
                    count_L = 0
                    count_R = 0
                    break;
                else:
                    continue
            except Exception:
                logging.info("y_left, y_right error!")

            cv2.imshow('Video Test', img)
            key = 0xFF & cv2.waitKey(1)
            if key == 27:  # ESC  Key
                cap.release()
                cv2.destroyAllWindows()
                break
    #5.라인찾기
        #이건 함수 쓰자
        #FindLine()
    #6.걷는다
    
    #7.미션
        #미션도 3번해야하니 함수쓰자
        #mission()
    #8.라인찾기
        #FindLine()
    #9.걷는다
    ##7~9까지 두번 반복
    #10.문을 열고 나가면 끝
    
    # -----  remocon 16 Code  Exit ------
    while receiving_exit == 1:
        time.sleep(0.01)
      
    cap.release()
    cv2.destroyAllWindows()

    exit(1)