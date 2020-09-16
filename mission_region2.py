# -*- coding: utf-8 -*-

import platform
import numpy as np
import argparse
import cv2
import serial
import time
import sys
from threading import Thread

serial_use = 1

serial_port = None
Read_RX = 0
receiving_exit = 1
threading_Time = 0.01

# -----------------------------------------------

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


# -----------------------------------------------

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


# **************************************************
# **************************************************
# **************************************************
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

    # --------------시리얼 포트 불러옴--------------
    serial_port = serial.Serial('/dev/ttyS0', BPS, timeout=0.01)
    serial_port.flush()  # serial cls

    # serial_t 라는 함수 생성 후 쓰레드가 Receiving 메소드를 실행하도록 함
    serial_t = Thread(target=Receiving, args=(serial_port,))
    # daemon 쓰레드는 background에서 돌아가는 쓰레드. main이 종료되면 같이 종료됨
    serial_t.daemon = True
    serial_t.start()
    time.sleep(0.1)
    # ---------camera-setting---------------
    c_W = 320
    c_H = 240
    FPS = 90
    # 라즈베리파이의 카메라 연결
    cap = cv2.VideoCapture(0)
    cap.set(3, c_W)
    cap.set(4, c_H)
    # ---------------------------------------
    lower_green = (45, 65, 50)
    upper_green = (90, 255, 255)

    while True:
        # 영상 값 불러옴 img가 영상
        ret, img = cap.read()
        if not ret:
            break
        # -------녹색------------------------------------------------------------
        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        img_mask_green = cv2.inRange(hsv, lower_green, upper_green)
        img_result_green = cv2.bitwise_and(img, img, mask=img_mask_green)

        green_pixel = np.where(img_result_green[:, :] == 0)
        green_pixel = len(green_pixel[0])
        # -------검정색-----------------------------------------------------------
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        _, img_th = cv2.threshold(gray, 50, 255, cv2.THRESH_BINARY)

        black_pixel = np.where(img_th[:, :] == 255)
        black_pixel = len(black_pixel[0])

        print("green=", green_pixel, "black=", black_pixel)

        if green_pixel < 800000:
            print("green")
        else:
            print("black")

        cv2.imshow("src", img_result_green)
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








