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

    #변수 설정--------------------------------------
    start_y = 150
    end_y = 210
    front_st=1 #0:길 발견 1: 1번 구역 검사 2: 2번 구역 검사
    #구역을 세세하게 나눈 이유는 대각선 방향을 찾기 위해 2중 for문을 돌릴때 최대한 작게 돌리고 싶어서....
    front_prev=0
    h=60
    x=0
    w=320
    y=start_y
    start_yy=180
    end_yy=240
    #----------------------------------------------

    while True:
        pixel=0
        y_right=0
        y_std=0
        dabinoid.kyeong_front()
        
        canny = canny_img(img)
        cv2.imshow('img', canny)
        roi = canny[y:y + h, x: x + w]
        cv2.imshow('roi', roi)

        key = 0xFF & cv2.waitKey(1)
        if key == 27:  # ESC  Key
            cap.release()
            cv2.destroyAllWindows()
            break

        if front_st==0:
            if front_prev==11:
                for yy in range(start_yy,end_yy):
                    for xx in range(160):
                        if canny[yy,xx]==255:
                            x_std=xx
                            y_std=xx
                            break
                        else:
                            x_std=0
                            y_std=0
                    if x_std!=0 or y_std!=0:
                        break
                    elif x_std==0 and y_std==0:
                        continue
                    else:
                        pass
                for yy in range(240):
                    if x_std + 5 >= 319:
                        if canny[yy, 319] == 255:
                            y_right = yy
                    else:
                        if canny[yy, x_std + 5] == 255:
                            y_right = yy
                print(y_std,", ", y_right,", ",y_std-y_right)
                if y_std-y_right>5: #\요런 대각선
                    print("11Left_Turn")
                    dabinoid.Left_Turn()
                    front_st=1
                    continue
                elif y_std-y_right<-5: #/요런 대각선
                    print("11Right_Turn")
                    dabinoid.Right_Turn()
                    front_st=1
                    continue
                else:
                    print("11finish!")
                    for i in range(2):
                        dabinoid.Go_Front()
                    break
                front_prev = 0
            elif front_prev==12:
                for yy in range(start_yy,end_yy):
                    for xx in range(161,319):
                        if canny[yy,xx]==255:
                            x_std=xx
                            y_std=xx
                            break
                        else:
                            x_std=0
                            y_std=0
                    if x_std!=0 or y_std!=0:
                        break
                for yy in range(240):
                    if x_std+5>=319:
                        if canny[yy,319]==255:
                            y_right=yy
                    else:
                        if canny[yy,x_std+5]==255:
                            y_right=yy
                print(y_std,", ", y_right,", ",y_std-y_right)
                if y_std-y_right>5: #\요런 대각선
                    print("12Left_Turn")
                    dabinoid.Left_Turn()
                    front_st=1
                    continue
                elif y_std-y_right<-5: #/요런 대각선
                    print("12right_turn")
                    dabinoid.Right_Turn()
                    front_st=1
                    continue
                else:
                    print("12finish!")
                    for i in range(2):
                        dabinoid.Go_Front()
                    break
                front_prev = 0
            else:
                print("1_front_check_Error!")
                front_st=1
        elif front_st==1: #1번 구역 검사
            pixel=0
            pixel = np.where(canny[start_y:end_y, :] == 255)
            pixel = len(pixel[0])

            if pixel >= 3: #1번구역에서 노란색이 발견 된 경우
                pixel=0
                pixel = np.where(canny[start_y:end_y,:160] == 255)
                pixel = len(pixel[0])

                if pixel >=3:   #1-1구역에서 노란색이 발견된 경우
                    front_prev=11
                    front_st=0
                else:
                    pixel=0
                    pixel = np.where(canny[ start_y:end_y,160:] == 255)
                    pixel = len(pixel[0])

                    if pixel >=3: #1-2구역에서 노란색이 발견된 경우
                        front_prev=12
                        front_st=0
                    else:
                        front_st=2
                        continue
            else: #1번 구역에서 노란색이 발견 되지 않은 경우
                front_st=2
                continue
        elif front_st==2:
            pixel=0
            pixel = np.where(canny[:start_y,160:] == 255)
            pixel = len(pixel[0])

            if pixel>=3:
                print("go front")
                dabinoid.Go_Front()
                front_st=1
            else:
                print("backstep")
                dabinoid.Back_Step()
                front_st=1
        else:
            print("0_front_check_Error!")
            front_st=1

    # -----  remocon 16 Code  Exit ------
    while receiving_exit == 1:
        time.sleep(0.01)

    cap.release()
    cv2.destroyAllWindows()

    exit(1)