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

serial_use = 1

serial_port = None
Read_RX = 0
receiving_exit = 1
threading_Time = 0.01

# pytesseract.pytesseract.tesseract_cmd = '/usr/bin/tesseract'
pytesseract.pytesseract.tesseract_cmd = r'C:/Program Files/Tesseract-OCR/tesseract'
custom_config = r'--psm 10'


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
    # serial_port = serial.Serial('/dev/ttyS0', BPS, timeout=0.01)
    # serial_port.flush()  # serial cls

    # serial_t 라는 함수 생성 후 쓰레드가 Receiving 메소드를 실행하도록 함
    # serial_t = Thread(target=Receiving, args=(serial_port,))
    # daemon 쓰레드는 background에서 돌아가는 쓰레드. main이 종료되면 같이 종료됨
    # serial_t.daemon = True
    # serial_t.start()
    # time.sleep(0.1)
    # ---------camera-setting---------------
    c_W = 320
    c_H = 240
    FPS = 90
    # 라즈베리파이의 카메라 연결
    cap = cv2.VideoCapture(0)
    cap.set(3, c_W)
    cap.set(4, c_H)
    # ---------------------------------------
    lower_blue = (80, 100, 80)
    upper_blue = (130, 255, 255)

    lower_red = (130, 70, 100)
    upper_red = (360, 255, 255)

    color_check = 0  # 0이면 파란색에서 검사, 1이면 빨간색에서 검사
    count_region = [0, 0, 0, 0, 0]  # A,B,C,D,나머지 순서

    while True:
        # 영상 값 불러옴 img가 영상
        ret, img = cap.read()
        if not ret:
            break

        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

        if color_check == 0:  # 파란색일경우
            img_mask_blue = cv2.inRange(hsv, lower_blue, upper_blue)
            img_result_blue = cv2.bitwise_and(img, img, mask=img_mask_blue)

            blue_pixel = np.where(img_result_blue[:, :] == 0)
            blue_pixel = len(blue_pixel[0])
            

            img_mask_red = cv2.inRange(hsv, lower_red, upper_red)
            img_result_red = cv2.bitwise_and(img, img, mask=img_mask_red)

            red_pixel = np.where(img_result_red[:, :] == 0)
            red_pixel = len(red_pixel[0])
            
            if blue_pixel > red_pixel:
                print("red found")
            else:
                print("blue found")

            # blur_blue = cv2.blur(img_result_blue, (3, 3))

            # alphabet = pytesseract.image_to_string(blur_blue, config=custom_config)
            # alphabet = alphabet[0:1]
            # if alphabet == "A":
            #     count_region[0] += 1
            #     if count_region[0] == 3:
            #         print("blue_A")
            #         count_region = [0, 0, 0, 0, 0]
            #         break;
            # elif alphabet == "B":
            #     count_region[1] += 1
            #     if count_region[1] == 3:
            #         print("blue_B")
            #         count_region = [0, 0, 0, 0, 0]
            #         break;
            # elif alphabet == "C":
            #     count_region[2] += 1
            #     if count_region[2] == 3:
            #         print("blue_C")
            #         count_region = [0, 0, 0, 0, 0]
            #         break;
            # elif alphabet == "D":
            #     count_region[3] += 1
            #     if count_region[3] == 3:
            #         print("blue_D")
            #         count_region = [0, 0, 0, 0, 0]
            #         break;
            # else:
            #     count_region[4] += 1
            #     if count_region[4] == 20:
            #         print("not blue")
            #         color_check = 1
            #         count_region = [0, 0, 0, 0, 0]

            cv2.imshow('img_color_blue', blur_blue)
        elif color_check == 1:  # 빨간색일경우
            img_mask_red = cv2.inRange(hsv, lower_red, upper_red)
            img_result_red = cv2.bitwise_and(img, img, mask=img_mask_red)

            blur_red = cv2.blur(img_result_red, (3, 3))

            alphabet = pytesseract.image_to_string(blur_red, config=custom_config)
            alphabet = alphabet[0:1]
            if alphabet == "A":
                count_region[0] += 1
                if count_region[0] == 3:
                    print("red_A")
                    count_region = [0, 0, 0, 0, 0]
                    break;
            elif alphabet == "B":
                count_region[1] += 1
                if count_region[1] == 3:
                    print("red_B")
                    count_region = [0, 0, 0, 0, 0]
                    break;
            elif alphabet == "C":
                count_region[2] += 1
                if count_region[2] == 3:
                    print("red_C")
                    count_region = [0, 0, 0, 0, 0]
                    break;
            elif alphabet == "D":
                count_region[3] += 1
                if count_region[3] == 3:
                    print("red_D")
                    count_region = [0, 0, 0, 0, 0]
                    break;
            else:
                count_region[4] += 1
                if count_region[4] == 20:
                    print("not red")
                    color_check = 0
                    count_region = [0, 0, 0, 0, 0]

            cv2.imshow('img_color_red', blur_red)

            # cv2.waitKey(0)
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
    bearing = [0, 0, 0, 0]  # EWSN(동서남북)

    exit(1)