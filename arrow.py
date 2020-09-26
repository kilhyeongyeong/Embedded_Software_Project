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

img = np.ndarray([])
# ----------------------------------------

def Camera(cap):
    global img

    while True:
        ret, img = cap.read()
        if not ret:
            break

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

    y_max=0
    while True:
        # 이미지 매치 템플릿 : 미리 넣어둔 이미지와 영상이미지와 비교해 가장 유사한 부분을 리턴
        left_img = cv2.imread("left.png", cv2.IMREAD_GRAYSCALE)
        right_img = cv2.imread("right.png", cv2.IMREAD_GRAYSCALE)

        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        left_result = cv2.matchTemplate(gray, left_img, cv2.TM_SQDIFF_NORMED)
        rignt_result = cv2.matchTemplate(gray, right_img, cv2.TM_SQDIFF_NORMED)

        L_minVal, L_maxVal, L_minLoc, L_maxLoc = cv2.minMaxLoc(left_result)
        L_x, L_y = L_minLoc
        L_h, L_w = left_img.shape

        R_minVal, R_maxVal, R_minLoc, R_maxLoc = cv2.minMaxLoc(rignt_result)
        R_x, R_y = R_minLoc
        R_h, R_w = right_img.shape

        # ROI : 위에서 얻은 부분을 자름
        L_roi = gray[L_y:L_y + L_h, L_x:L_x + L_w]
        R_roi = gray[R_y:R_y + R_h, R_x:R_x + R_w]

        # 검은색만 볼 수 있게끔 이진화
        _, L_thr = cv2.threshold(L_roi, 75, 255, cv2.THRESH_BINARY)
        _, R_thr = cv2.threshold(R_roi, 75, 255, cv2.THRESH_BINARY)

        cv2.imshow("L_dst", L_thr)
        cv2.imshow("R_dst", R_thr)

        # cv2.waitKey(0)
        key = 0xFF & cv2.waitKey(1)
        if key == 27:  # ESC  Key
            cap.release()
            cv2.destroyAllWindows()
            break

        # 만약 화살표 벽을 보고 있지 않으면 화면은 거의 흰색으로 리턴 될 거임.
        # 만약 화살표 벽을 보고 있다면 화살표가 잡혀 검은색의 픽셀 수 가 더 많게 될 것.
        L_black_pixel = np.where(L_thr[:, :] == 255)
        L_black_pixel = len(L_black_pixel[0])

        R_black_pixel = np.where(R_thr[:, :] == 255)
        R_black_pixel = len(R_black_pixel[0])

        print(L_black_pixel,",",R_black_pixel)

        if L_black_pixel >= 10000 and R_black_pixel >= 10000:  # 거의다 흰색인 경우:배경을 보고있는겨
            print("여긴 화살표가 아예 아냥...")
        else:
            _, thr = cv2.threshold(gray, 75, 255, cv2.THRESH_BINARY)
            cv2.imshow("thr", thr)
            for xx in range(320):
                for yy in range(240):
                    if thr[yy, xx] != 255:
                        if yy > y_max:
                            x = xx
                            y_max = yy

            print(x, ", ", y_max)
            for i in range(240):
                if (x - 25) <= 0:
                    if thr[i, 1] != 255:
                        y_left = i
                    if thr[i, x + 25] != 255:
                        y_right = i
                elif (x + 25) >= 319:
                    if thr[i, x - 25] != 255:
                        y_left = i
                    if thr[i, 319] != 255:
                        y_right = i
                else:
                    if thr[i, x - 25] != 255:
                        y_left = i
                    if thr[i, x + 25] != 255:
                        y_right = i

            print(y_left, ", ", y_right)
            if abs((y_max - y_left) - (y_max - y_right)) < 30:
                print("요기는 화살표의 꼬리다!")
            else:
                if (y_max - y_left) > (y_max - y_right):
                    print("요기는 오른쪽")
                else:
                    print("요기는 왼쪽")
            y_max = 0;
            x = 0;
            y_right = 0;
            y_left = 0

    # -----  remocon 16 Code  Exit ------
    while receiving_exit == 1:
        time.sleep(0.01)

    cap.release()
    cv2.destroyAllWindows()

    exit(1)
