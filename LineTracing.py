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
import motion

serial_use = 1

serial_port = None
Read_RX = 0
receiving_exit = 1
threading_Time = 0.01

# ---------camera-setting---------------
c_W = 320
c_H = 240
FPS = 60
# ------------------모션 제어---------------------------
def TX_data_py2(ser, one_byte):  # one_byte= 0~255
    """
        ser : 연결된 시리얼 번호
        one_byte : 모션에 Key값에 해당하는 번호를 입력
    """
    # ser.write(chr(int(one_byte)))          #python2.7
    ser.write(serial.to_bytes([one_byte]))  # python3


# -----------------------------------------------
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
            print("RX=" + str(RX))

            # -----  remocon 16 Code  Exit ------
            if RX == 16:
                receiving_exit = 0
                break

img = np.ndarray([])
# ----------------------------------------

def Camera(cap):
    global img

    while True:
        ret, img = cap.read()
        if not ret:
            break

def canny_img(img):
    img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    H = img_hsv[:, :, 0]
    S = img_hsv[:, :, 1]
    _, H_upper = cv2.threshold(H, 60, 255, cv2.THRESH_BINARY_INV)
    _, H_lower = cv2.threshold(H, 15, 255, cv2.THRESH_BINARY)
    _, S_lower = cv2.threshold(S, 100, 255, cv2.THRESH_BINARY)

    H = cv2.bitwise_and(H_upper, H_lower)
    H = cv2.bitwise_and(H, S_lower)

    kernel = np.ones((3, 3), np.uint8)
    result = cv2.morphologyEx(H, cv2.MORPH_OPEN, kernel)
    canny = cv2.Canny(result, 100, 255)
    return canny

arrow=0 #화살표 방향이 왼쪽이면 0 오른쪽이면 1
mission=0 #문자가 발견되지 않으면 0 발견되면 1

if __name__ == '__main__':
    os_version = platform.platform()
    print(" ---> OS " + os_version)
    python_version = ".".join(map(str, sys.version_info[:3]))
    print(" ---> Python " + python_version)
    opencv_version = cv2.__version__
    print(" ---> OpenCV  " + opencv_version)
    print("-------------------------------------")

    BPS = 4800  # 4800,9600,14400, 19200,28800, 57600, 115200

    # ---------local Serial Port : ttyS0 --------
    # ---------USB Serial Port : ttyAMA0 --------

    # --------------시리얼 포트 불러옴--------------(포트,BPS,timeout)
    serial_port = serial.Serial('/dev/ttyS0', BPS, timeout=0.01)
    serial_port.flush()  # serial cls

    # serial_t 라는 함수 생성 후 쓰레드가 Receiving 메소드를 실행하도록 함
    serial_t = Thread(target=Receiving, args=(serial_port,))
    # daemon 쓰레드는 background에서 돌아가는 쓰레드. main이 종료되면 같이 종료됨
    serial_t.daemon = True
    serial_t.start()
    time.sleep(0.1)

    # 로봇 인스턴스 생성-----------------------------
    dabinoid = motion.Robot(serial_port)

    # -----------------camera----------------------
    cap = cv2.VideoCapture(0)
    cap.set(3, c_W)
    cap.set(4, c_H)
    im_cnt = 0

    camera = Thread(target=Camera, args=(cap,))
    camera.daemon = True
    camera.start()
    time.sleep(1)

    dabinoid.default()

    # -------------------------------변수설정-----------------------------------
    x = 110;
    w = 20;
    y = 0;
    h = 240;

    st = 11
    y_left=0
    y_right=0
    # ------------------------------------------------------------------------
    while True:
        print(st)
        canny = canny_img(img)

        # -----------------------------------------------------------------
        if st == 11:
            # 고개숙이기(모션)
            dabinoid.kyeong_front()
            canny = canny_img(img)
            cv2.imshow('img',canny)
            # roi--------------------------------------------------------------
            roi = canny[y:y + h, x: x + w]
            # 1-1(roi부분 노란색 탐색)--------------------------------------------
            pixel = np.where(roi[:, :] == 255)
            pixel = len(pixel[0])
            print("pixel=",pixel)
            if pixel >= 100:  # 두줄이 일자로 쫙 있는거!
                # 직진
                print("1-1직진")
                for i in range(5):
                    dabinoid.Go_Front()
            else:  # 두 줄이 많이 기울어져 있거나 없는거!
                pixel2 = np.where(roi[:120, :])
                pixel2 = len(pixel2[0])
                if pixel2 >= 3:
                    # 살짝꿍 앞으로 직진(모션)
                    print("1-1: roi에서 윗부분에 보여서 살짝 직진")
                    dabinoid.Go_Front()
                    continue
                if pixel == 0:  # 노란색이 roi부분엔 없는거...!
                    L_pixel = np.where(canny[:, :x] == 255)
                    L_pixel = len(L_pixel[0])
                    R_pixel = np.where(canny[:, x + w:] == 255)
                    R_pixel = len(R_pixel[0])
                    if L_pixel >= 3:  # 왼쪽에 일직선으로 있는거!
                        # 왼쪽으로 살짝꿍 걷기(모션)
                        print("1-2:왼쪽으로 살짝꿍 걷기")
                        dabinoid.Left_Walk()
                    elif R_pixel >= 3:  # 오른쪽에 일직선으로 있는거!
                        # 오른쪽으로 살짝꿍 걷기(모션)
                        print("1-2:오른쪽으로 살짝꿍 걷기")
                        dabinoid.Right_Walk()
                    else:  # 고개를 숙인 상태에는 없는거
                        st = 13
                else:  # roi부분엔 있되 많이 기울어져 있어서 흰색 부분이 많이 보이지 않는 거!
                    aa=0 #대각선이면 0, 직각이면 1
                    for yy in range(240):
                        if roi[yy,0]==255:
                            y1=yy
                        if roi[yy,3]==255:
                            y2=yy
                        if roi[yy,19]==255:
                            y3=yy
                        if roi[yy,16]==255:
                            y4=yy
                    print(y1,",",y2,",",y3,",",y4)
                    if (y1-y2)>0 and (y3-y4)>0: #대각선
                        aa=0
                    elif (y1-y2)>0 and (y3-y4)<0: #직각
                        aa=1
                    elif (y1-y2)<0 and (y3-y4)<0: #대각선
                        aa=0
                    elif (y1-y2)<0 and (y3-y4)>0: #직각
                        aa=1
                    else:
                        if arrow == 0:
                            print("1-2 : 왼쪽으로 턴")
                            dabinoid.Left_Turn()
                        else:
                            print("1-2 : 오른쪽으로 턴")
                            dabinoid.Right_Turn()
                    if aa==1:
                        if mission==1:
                            print("미션 실행")
                            continue
                        else:
                            if arrow==0:
                                print("1-2 : 왼쪽으로 턴")
                                dabinoid.Left_Turn()
                            else:
                                print("1-2 : 오른쪽으로 턴")
                                dabinoid.Right_Turn()
                    else:
                        for yy in range(240):
                            if roi[yy,5]==255:
                                y_left=yy
                            if roi[yy,10]==255:
                                y_right=yy
                                
                        if arrow==0:
                            if y_left>=y_right:
                                print("1-2 : 왼쪽으로 턴")
                                dabinoid.Left_Turn()
                            else:
                                print("1-2 : 오른쪽으로 턴")
                                dabinoid.Right_Turn()
                        else:
                            if y_left>=y_right:
                                print("1-2 : 오른쪽으로 턴")
                                dabinoid.Right_Turn()
                            else:
                                print("1-2 : 왼쪽으로 턴")
                                dabinoid.Left_Turn()
                    y_left=0; y_right=0
            pixel=0
        elif st == 13:
            # 고개 숙인채 왼쪽으로 고개 돌리기(모션)
            dabinoid.kyeong_left()
            canny = canny_img(img)
            cv2.imshow('img', canny)
            pixel = np.where(canny[:, :] == 255)
            pixel = len(pixel[0])
            if pixel >= 3:  # 노란색이 발견되면
                # 왼쪽으로 이동
                print("1-3:왼쪽으로 이동")
                for i in range(2):
                    dabinoid.Left_Walk()
                st = 11
            else:
                st = 14
            pixel = 0
        elif st == 14:
            # 고개 숙인채 오른쪽으로 고개 돌리기(모션)
            dabinoid.kyeong_right()
            canny = canny_img(img)
            cv2.imshow('img', canny)
            pixel = np.where(canny[:, :] == 255)
            pixel = len(pixel[0])
            if pixel >= 3:  # 노란색이 발견되면
                # 오른쪽으로 이동
                print("1-4:오른쪽으로 이동")
                for i in range(2):
                    dabinoid.Right_Walk()
                st = 11
            else:
                st = 21
            pixel = 0
        elif st == 21:
            # 고개를 살짝 든 상태에서 정면(모션)
            dabinoid.hyeon_front()
            canny = canny_img(img)
            cv2.imshow('img', canny)
            pixel = np.where(canny[:, :] == 255)
            pixel = len(pixel[0])
            if pixel >= 3:  # 노란색이 발견되면
                # 앞으로 이동
                print("2-1:앞으로 이동")
                for i in range(2):
                    dabinoid.Go_Front()
                st = 11
            else:
                st = 22
            pixel = 0
        elif st == 22:
            # 고개를 든 상태에서 왼쪽으로(모션)
            dabinoid.hyeon_left()
            canny = canny_img(img)
            cv2.imshow('img', canny)
            pixel = np.where(canny[:, :] == 255)
            pixel = len(pixel[0])
            if pixel >= 3:
                # 왼쪽으로 이동
                print("2-2:왼쪽으로 이동")
                for i in range(3):
                    dabinoid.Left_Walk()
                st = 11
            else:
                st = 23
            pixel = 0
        elif st == 23:
            # 고래를 든 상태에서 오른쪽으로(모션)
            dabinoid.hyeon_right()
            canny = canny_img(img)
            cv2.imshow('img', canny)
            pixel = np.where(canny[:, :] == 255)
            pixel = len(pixel[0])
            if pixel >= 3:
                # 오른쪽으로 이동
                print("2-3:오른쪽으로 이동")
                for i in range(3):
                    dabinoid.Right_Walk()
            else:
                # 뒤돌기
                print("뒤돌기")
                for i in range(7):
                    dabinoid.Left_Turn()
            st = 11
            pixel = 0
        else:
            print("Line_Error!!")

        cv2.imshow('img', img)
        key = 0xFF & cv2.waitKey(1)
        if key == 27:  # ESC  Key
            cap.release()
            cv2.destroyAllWindows()
            break
    # -----  remocon 16 Code  Exit ------
    while receiving_exit == 1:
        time.sleep(0.01)

    cap.release()
    cv2.destroyAllWindows()

    exit(1)