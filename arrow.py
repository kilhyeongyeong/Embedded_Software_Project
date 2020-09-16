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

# ---------camera-setting---------------
c_W = 320
c_H = 240
FPS = 90


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


Count_L = 0
Count_R = 0
y_left = 0
y_right = 0
ymax = 0

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

    # -----------------camera----------------------
    cap = cv2.VideoCapture(0)
    cap.set(3, c_W)
    cap.set(4, c_H)

    cnt = 0
    while True:
        # 영상 값 불러옴 img가 영상
        ret, img = cap.read()
        if not ret:
            break
        img = cv2.medianBlur(img, 5)

        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        _, img_th = cv2.threshold(gray, 50, 255, cv2.THRESH_BINARY)

        cv2.imshow("threshold", img_th)
        key = 0xFF & cv2.waitKey(1)
        if key == 27:  # ESC  Key
            cap.release()
            cv2.destroyAllWindows()
            break

        for j in range(240):
            for i in range(320):
                if img_th[j, i] == 0:
                    if ymax <= j:
                        x = i
                        ymax = j

        for i in range(240):
            if x - 20 <= 0:
                if img_th[i, 0] == 0:
                    y_left = i
            else:
                if img_th[i, x - 20] == 0:
                    y_left = i
            if x + 20 >= 320:
                if img_th[i, 319] == 0:
                    y_right = i
            else:
                if img_th[i, x + 20] == 0:
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
            ymax = 0
            break;
        elif Count_R == 3:
            print("RIGHT!")
            arrow = "R"
            Count_L = 0
            Count_R = 0
            ymax = 0
            break;
        else:
            ymax = 0
            y_left = 0
            y_right = 0
            x = 0
            continue

    # -----  remocon 16 Code  Exit ------
    while receiving_exit == 1:
        time.sleep(0.01)

    cap.release()
    cv2.destroyAllWindows()

    exit(1)
