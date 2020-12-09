# -*- coding: utf-8 -*-

import platform
import numpy as np
import argparse
import cv2
import serial
import time
import sys
from threading import Thread
import motion
import definition
import pytesseract

pytesseract.pytesseract.tesseract_cmd = '/usr/bin/tesseract'

serial_use = 1

serial_port = None
Read_RX = 0
receiving_exit = 1
threading_Time = 0.01

region = []
total_st = 0
ttf = "DEFAULT"
arrow = "DEFAULT"
count = 0
check = 0 #경기가 완전히 문열고 나와서 끝나면 1 그 외엔 0

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
# **************************************************
img = np.ndarray([])
def Camera(cap):
    global img

    while True:
        ret, img = cap.read()
        if not ret:
            break
        cv2.imshow("img", img)
        key = 0xFF & cv2.waitKey(1)
        if key == 27:  # ESC  Key
            self.cap.release()
            cv2.destroyAllWindows()
            break
#-------------------------------------------------------------------------------------------------------------setting---
def dist_front():
    y_left = 0
    y_right = 0
    while True:
        lower_yellow = (20, 80, 50)
        upper_yellow = (30, 255, 255)

        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        img_mask_yellow = cv2.inRange(hsv, lower_yellow, upper_yellow)
        img_result_yellow = cv2.bitwise_and(img, img, mask=img_mask_yellow)

        canny = cv2.Canny(img_result_yellow, 100, 255)

        for i in range(240):
            if canny[i, 145] == 255:
                y_left = i
                break

        for j in range(240):
            if canny[j, 175] == 255:
                y_right = j
                break

        print("y_left = ", y_left, ", y_right = ", y_right, "y_left - y_right = ", y_left - y_right)

        if abs(y_left- y_right) <= 3:
            print("끝!")
            return 0
        else:
            if y_left > y_right:
                print("왼쪽으로 Turn")
                dabinoid.Line_left_Turn()
                continue
            else:
                print("오른쪽으로 Turn")
                dabinoid.Line_right_Turn()
                continue

def findarrow():
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    _, img_th = cv2.threshold(gray, 53, 255, cv2.THRESH_BINARY)
    x_std = 0

    for y in range(240):
        for x in range(320):
            if img_th[y, x] == 0:
                x_std = x
                break
        if x_std != 0:
            break

    pixel_l = np.where(img_th[:50, :x_std - 1] == 0)
    pixel_l = len(pixel_l[0])

    pixel_r = np.where(img_th[:50, x_std + 1:] == 0)
    pixel_r = len(pixel_r[0])

    if pixel_l > pixel_r:
        print("왼쪽 화살표!")
        for i in range(2):
            dabinoid.left_Turn()
        return "LEFT"
    elif pixel_r > pixel_l:
        print("오른쪽 화살표!")
        for i in range(2):
            dabinoid.right_Turn()
        return "RIGHT"
    else:
        print("뭐여 left = ", pixel_l, ", right = ", pixel_r)

def find_citizen(ttf, dabinoid):
    st = 11
    while True:
        std = 600

        if st == 11:
            dabinoid.bin_front_head()
            pixel = definition.citizen_pixel(ttf, 0, img)
            print(pixel)
            if pixel == 101:
                print("citizen_pixel_Error!")
                return 100
            elif pixel >= std:
                return 0
            else:
                print("고개를 1-2로 변경~")
                st = 12
                continue
        elif st == 12:
            dabinoid.bin_left_head()
            pixel = definition.citizen_pixel(ttf, 0, img)
            if pixel >= std:
                dabinoid.Line_left_Turn()
                print("왼쪽으로 Turn")
                st = 11
                continue
            else:
                print("고개를 1-3으로 변경혀")
                st = 13
                continue
        elif st == 13:
            dabinoid.bin_right_head()
            pixel = definition.citizen_pixel(ttf, 0, img)
            if pixel >= std:
                dabinoid.Line_right_Turn()
                print("오른쪽으로 Turn")
                st = 11
                continue
            else:
                print("고개를 2-1로 변경!")
                st = 21
                continue
        elif st == 21:
            dabinoid.da_front_head()
            pixel = definition.citizen_pixel(ttf, 0, img)
            if pixel >= std:
                print("두발짝 직진")
                for i in range(2):
                    dabinoid.bin_Walk()
                st = 11
                continue
            else:
                print("고개를 2-2로 변경!")
                st = 22
                continue
        elif st == 22:
            dabinoid.da_left_head()
            pixel = definition.citizen_pixel(ttf, 0, img)
            if pixel >= std:
                print("왼쪽으로 Turn + 앞으로 걷기")
                dabinoid.Line_left_Turn()
                dabinoid.bin_Walk()
                st = 11
                continue
            else:
                print("고개를 2-3으로 변경!!")
                st = 23
                continue
        elif st == 23:
            dabinoid.da_right_head()
            pixel = definition.citizen_pixel(ttf, 0, img)
            if pixel >= std:
                dabinoid.Line_right_Turn()
                dabinoid.bin_Walk()
                print("오른쪽으로 Turn + 앞으로 걷기")
                st = 11
                continue
            else:
                return 100
        else:
            return 100

def adjust_citizen(ttf, dabinoid):
    while True:
        if ttf == "RED":
            top, bottom, left, right, pixel = definition.red(img)
        elif ttf == "BLUE":
            top, bottom, left, right, pixel = definition.blue(img)
        else:
            return 102

        if left != 0:
            print("왼쪽으로 걷기")
            dabinoid.bin_left_Walk()
            continue
        if right != 0:
            print("오른쪽으로 걷기")
            dabinoid.bin_right_Walk()
            continue

        if top == 0 or bottom == 0:
            if bottom == 0:
                if top < 470:
                    print("앞으로 한발짝!")
                    dabinoid.bin_Walk()
                    continue
                else:
                    print("살짝꿍 앞으로!")
                    dabinoid.bin_SWalk()
                    continue
            elif top == 0:
                if bottom >= 520:
                    print("뒤로 한발짝")
                    dabinoid.bin_backStep()
                    continue
                else:
                    print("집자!")
                    return 0
            else:
               return 102
        else:
            if bottom < 270 or top <380:
                while True:
                    if ttf == "RED":
                        lower_red = (130, 50, 50)
                        upper_red = (360, 255, 255)

                        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
                        img_mask_red = cv2.inRange(hsv, lower_red, upper_red)
                        img_result_red = cv2.bitwise_and(img, img, mask=img_mask_red)

                        bottom2 = np.where(img_result_red[239:, :] == 0)
                        bottom2 = 960 - len(bottom2[0])

                        left = np.where(img_result_red[:, 154:155] == 0)
                        left = 960 - len(left[0])

                        right = np.where(img_result_red[:, 164:165] == 0)
                        right = 960 - len(right[0])

                        _, _, left_l, right_r, _ = definition.red(img)

                        if left_l > 0:
                            dabinoid.bin_left_Walk()
                            continue
                        if right_r > 0:
                            dabinoid.bin_right_Walk()
                            continue
                        if bottom2 <= 510:
                            print("일직선 맞추기!!! 살짝꿍 앞으로 이동")
                            dabinoid.bin_SWalk()
                            continue
                        else:
                            if abs(left - right) < 4:
                                print("수평 맞춰줬음")
                                dabinoid.bin_backStep()
                                continue
                            else:
                                print("살짝꿍 앞으로 이동하면서 수평맞추기")
                                dabinoid.bin_SWalk()
                                continue
                    else:
                        lower_blue = (80, 100, 50)
                        upper_blue = (130, 255, 255)

                        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
                        img_mask_blue = cv2.inRange(hsv, lower_blue, upper_blue)
                        img_result_blue = cv2.bitwise_and(img, img, mask=img_mask_blue)

                        bottom2 = np.where(img_result_blue[239:, :] == 0)
                        bottom2 = 960 - len(bottom2[0])

                        left = np.where(img_result_blue[:, 154:155] == 0)
                        left = 960 - len(left[0])

                        right = np.where(img_result_blue[:, 164:165] == 0)
                        right = 960 - len(right[0])

                        _, _, left_l, right_r, _ = definition.blue(img)

                        if left_l > 0:
                            dabinoid.bin_left_Walk()
                            continue
                        if right_r > 0:
                            dabinoid.bin_right_Walk()
                            continue
                        if bottom2 <= 510:
                            print("일직선 맞추기!!! 살짝꿍 앞으로 이동")
                            dabinoid.bin_SWalk()
                            continue
                        else:
                            if abs(left - right) < 4:
                                print("수평 맞춰줬음")
                                dabinoid.bin_backStep()
                                dabinoid.bin_front_head()
                                break
                            else:
                                print("살짝꿍 앞으로 이동하면서 수평맞추기")
                                dabinoid.bin_SWalk()
                                continue
            else:
                print("return 0이당")
                return 0

def find_region(color):
    std = 14000

    if color == "GREEN":
        dabinoid.da_front_head()
        green_pixel = definition.green(0,img)
        print(green_pixel)

        if green_pixel >= std:
            return 1
        else:
            dabinoid.da_left_head()
            green_pixel = definition.green(0, img)
            if green_pixel >= std:
                return 2
            else:
                dabinoid.da_right_head()
                green_pixel = definition.green(0, img)
                if green_pixel >= std:
                    return 3
                else:
                    return 103
    elif color == "BLACK":
        return 0
    else:
        return 103

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

    # 로봇 인스턴스 생성-----------------------------
    dabinoid = motion.Robot(serial_port)
    definition = definition.Def(dabinoid, serial_port)
    # ---------camera-setting---------------
    c_W = 320
    c_H = 240
    FPS = 90

    # 라즈베리파이의 카메라 연결
    cap = cv2.VideoCapture(0)
    cap.set(3, c_W)
    cap.set(4, c_H)
    # ---------------------------------------
    camera = Thread(target=Camera, args=(cap,))
    camera.daemon = True
    camera.start()
    time.sleep(1)

    dabinoid.default()
    while True:
        if check == 1:
            print("finish!!!!!Yeah~!!")
            break
        print(total_st)
        #-----------------------------------------------------------------------------------------------------------st=0
        if total_st == 0:
            while True:
                dabinoid.start_head()
                gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
                gray = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)[1]
                ret = definition.EWSN(gray)
                if ret == 0:
                    total_st = 1
                    dabinoid.Door_Open()
                    break
                else:
                    print("다시다시!")
                    continue
        #-----------------------------------------------------------------------------------------------------------st=1
        elif total_st == 1:
            dabinoid.bin_front_head()
            while True:
                std = 25
                if definition.canny(0, img) >= std:
                    if definition.canny(1,img) >= std:
                        if definition.canny(2,img) >= std:
                            ret = dist_front()
                            if ret == 0:
                                for i in range(2):
                                    dabinoid.min_Walk()
                                total_st = 2
                                break
                            else:
                                print("에러당")
                                continue
                        else:
                            print("오른쪽으로 Turn")
                            dabinoid.Line_right_Turn()
                            continue
                    else:
                        if definition.canny(2, img) >= std:
                            print("왼쪽으로 Turn")
                            dabinoid.Line_left_Turn()
                            continue
                        else:
                            print("Error!")
                            break
                else:
                    print("backstep!")
                    dabinoid.bin_backStep()
                    continue
        #st=2-------------------------------------------------------------------------------------------------------st=2
        elif total_st == 2:
            dabinoid.min_front_head()
            while True:
                std = 4000
                if definition.black(0, img) >= std:
                    if definition.black(1, img) >= 10000:
                        if definition.black(2,img) >= 10000:
                            arrow = findarrow()
                            total_st = 3
                            break
                        else:
                            print("왼쪽으로 이동!")
                            dabinoid.min_left_Walk()
                            continue
                    else:
                        if definition.black(2, img) >= std:
                            print("오른쪽으로 이동!")
                            dabinoid.min_right_Walk()
                            continue
                        else:
                            print("에러당 에러1")
                else:
                    dabinoid.min_left_head()
                    if definition.black(0, img) >= std:
                        print("왼쪽으로 두걸음")
                        for i in range(2):
                            dabinoid.min_left_Walk()
                        continue
                    else:
                        dabinoid.min_right_head()
                        if definition.black(0, img) >= std:
                            print("오른쪽으로 두걸음!")
                            for i in range(2):
                                dabinoid.min_right_Walk()
                            continue
                        else:
                            print("Error!_arrow!2")
        #st=3 ------------------------------------------------------------------------------------------------------st=3
        elif total_st == 3:
            print("arrow = ", arrow)
            st = 11
            dabinoid.bin_front_head()
            while True:
                left, right, top, top_l, top_r, bottom, bottom_l, bottom_r, pixel, total = definition.yellow(img)
                if st == 11:
                    if pixel > 24800:
                        if pixel > 28500:  # ----수정
                            if count >= 2:
                                print("finish! 경기장 나가기!")
                                total_st = 6
                                break
                            else:
                                print("삼거리 직진!!")
                                if count >= 2:
                                    print("나가기!")
                                    check = 1
                                    break
                                else:
                                    for i in range(4):
                                        dabinoid.bin_Walk()
                                    continue
                        else:
                            print("1-1직진!")
                            for i in range(4):
                                dabinoid.bin_Walk()
                            continue
                    else:
                        if top > 0:
                            print("살짝꿍 앞으로 걷기")
                            dabinoid.bin_Walk()
                            continue
                        else:
                            if bottom_l > 0 and bottom_r == 0:  # bottom_l = yellow[239:, :89], bottom_r = yellow[239:, 190:]
                                if bottom_l >= 380:
                                    print("미션 확인")
                                    dabinoid.mission_front_head()
                                    _, _, _, _, red = definition.red(img)
                                    _, _, _, _, blue = definition.blue(img)
                                    if red >= 6000:
                                        ttf = "RED"
                                        total_st = 4
                                        break
                                    elif blue >= 6000:
                                        ttf = "BLUE"
                                        total_st = 4
                                        break
                                    else:
                                        if arrow == "LEFT":
                                            print("직각, 왼쪽으로 Turn")
                                            dabinoid.Line_left_Turn()
                                            continue
                                        else:
                                            print("직각, 오른쪽으로 Turn")
                                            dabinoid.Line_right_Turn()
                                            continue
                                else:
                                    if right > 0:
                                        print("미션 확인")
                                        dabinoid.mission_front_head()
                                        _, _, _, _, red = definition.red(img)
                                        _, _, _, _, blue = definition.blue(img)
                                        if red >= 6000:
                                            ttf = "RED"
                                            total_st = 4
                                            break
                                        elif blue >= 6000:
                                            ttf = "BLUE"
                                            total_st = 4
                                            break
                                        else:
                                            if arrow == "LEFT":
                                                print("직각, 왼쪽으로 Turn")
                                                dabinoid.Line_left_Turn()
                                                continue
                                            else:
                                                print("직각, 오른쪽으로 Turn")
                                                dabinoid.Line_right_Turn()
                                                continue
                                    else:
                                        print("왼쪽으로 걷기")
                                        dabinoid.bin_left_Walk()
                                        continue
                            elif bottom_r > 0 and bottom_l == 0:
                                if bottom_r >= 380:
                                    print("미션 확인")
                                    dabinoid.mission_front_head()
                                    _, _, _, _, red = definition.red(img)
                                    _, _, _, _, blue = definition.blue(img)
                                    if red >= 6000:
                                        ttf = "RED"
                                        total_st = 4
                                        break
                                    elif blue >= 6000:
                                        ttf = "BLUE"
                                        total_st = 4
                                        break
                                    else:
                                        if arrow == "LEFT":
                                            print("직각, 왼쪽으로 Turn")
                                            dabinoid.Line_left_Turn()
                                            continue
                                        else:
                                            print("직각, 오른쪽으로 Turn")
                                            dabinoid.Line_right_Turn()
                                            continue
                                else:
                                    if left > 0 :
                                        print("미션 확인")
                                        dabinoid.mission_front_head()
                                        _, _, _, _, red = definition.red(img)
                                        _, _, _, _, blue = definition.blue(img)
                                        if red >= 6000:
                                            ttf = "RED"
                                            total_st = 4
                                            break
                                        elif blue >= 6000:
                                            ttf = "BLUE"
                                            total_st = 4
                                            break
                                        else:
                                            if arrow == "LEFT":
                                                print("직각, 왼쪽으로 Turn")
                                                dabinoid.Line_left_Turn()
                                                continue
                                            else:
                                                print("직각, 오른쪽으로 Turn")
                                                dabinoid.Line_right_Turn()
                                                continue
                                    else:
                                        print("오른쪽으로 걷기")
                                        dabinoid.bin_right_Walk()
                                        continue
                            elif bottom_r == 0 and bottom_l == 0:
                                if bottom == 0:  # bottom 전체에 노란색 픽셀이 없는 경우 = (미션 후)직각 or 가로로 일직선!
                                    if pixel == 0 and left == 0 and right == 0:
                                        st = 12
                                        continue
                                    else:
                                        if arrow == "LEFT":
                                            print("왼쪽으로 Turn")
                                            dabinoid.Line_left_Turn()
                                            continue
                                        else:
                                            print("오른쪽으로 Turn")
                                            dabinoid.Line_right_Turn()
                                            continue
                                else:  # bottom 가운데만 노란색 픽셀이 있는경우, 직각 or 대각선
                                    if left > 0 and right == 0:
                                        if top_l > 0:  # 왼쪽 대각선
                                            print("대각선, 왼쪽으로 Turn")
                                            dabinoid.Line_left_Turn()
                                            continue
                                        else:  # 왼쪽 직각
                                            dabinoid.mission_front_head()
                                            _, _, _, _, red = definition.red(img)
                                            _, _, _, _, blue = definition.blue(img)
                                            if red >= 6000:
                                                ttf = "RED"
                                                total_st = 4
                                                break
                                            elif blue >= 6000:
                                                ttf = "BLUE"
                                                total_st = 4
                                                break
                                            else:
                                                if arrow == "LEFT":
                                                    print("직각, 왼쪽으로 Turn")
                                                    dabinoid.Line_left_Turn()
                                                    continue
                                                else:
                                                    print("직각, 오른쪽으로 Turn")
                                                    dabinoid.Line_right_Turn()
                                                    continue
                                    elif right > 0 and left == 0:
                                        if top_r > 0:  # 오른쪽 대각선
                                            print("대각선, 오른쪽으로 Turn")
                                            dabinoid.Line_right_Turn()
                                            continue
                                        else:  # 오른쪽 직각
                                            dabinoid.mission_front_head()
                                            _, _, _, _, red = definition.red(img)
                                            _, _, _, _, blue = definition.blue(img)
                                            if red >= 6000:
                                                ttf = "RED"
                                                total_st = 4
                                                break
                                            elif blue >= 6000:
                                                ttf = "BLUE"
                                                total_st = 4
                                                break
                                            else:
                                                if arrow == "LEFT":
                                                    print("직각, 왼쪽으로 Turn")
                                                    dabinoid.Line_left_Turn()
                                                    continue
                                                else:
                                                    print("직각, 오른쪽으로 Turn")
                                                    dabinoid.Line_right_Turn()
                                                    continue
                                    elif right > 0 and left > 0:  # V자 대각선
                                        if arrow == "LEFT":
                                            print("왼쪽으로 Turn")
                                            dabinoid.Line_left_Turn()
                                            continue
                                        else:
                                            print("오른쪽으로 Turn")
                                            dabinoid.Line_right_Turn()
                                            continue
                                    else:
                                        print("여긴 안나와야 하는데....")
                            else:  # bottom_r > 0 and bottom_l > 0
                                if arrow == "LEFT":
                                    print("왼쪽으로 Turn")
                                    dabinoid.Line_left_Turn()
                                    continue
                                else:
                                    print("오른족으로 Turn")
                                    dabinoid.Line_right_Turn()
                                    continue
                elif st == 12:
                    dabinoid.bin_left_head()
                    _, _, _, _, _, _, _, _, pixel, _ = definition.yellow(img)
                    if pixel > 0:
                        print("1_2 왼쪽으로 이동!!")
                        for i in range(2):
                            dabinoid.bin_left_Walk()
                        st = 11
                        continue
                    else:
                        st = 13
                        continue
                elif st == 13:
                    dabinoid.bin_right_head()
                    _, _, _, _, _, _, _, _, pixel, _ = definition.yellow(img)
                    if pixel > 0:
                        print("1-3 오른쪽으로 이동!!")
                        for i in range(2):
                            dabinoid.bin_right_Walk()
                        st = 11
                        continue
                    else:
                        st = 21
                        continue
                elif st == 21:
                    dabinoid.da_front_head()
                    _, _, _, _, _, _, _, _, pixel, _ = definition.yellow(img)
                    if pixel > 0:
                        print("2-1 앞으로 이동!")
                        for i in range(2):
                            dabinoid.bin_Walk()
                        st = 11
                        continue
                    else:
                        st = 22
                        continue
                elif st == 22:
                    dabinoid.da_left_head()
                    _, _, _, _, _, _, _, _, pixel, _ = definition.yellow(img)
                    if pixel > 0:
                        print("2-2 왼쪽으로 이동!")
                        dabinoid.bin_left_Walk()
                        dabinoid.bin_Walk()
                        st = 11
                        continue
                    else:
                        st = 23
                        continue
                else:
                    dabinoid.da_right_head()
                    _, _, _, _, _, _, _, _, pixel, _ = definition.yellow(img)
                    if pixel > 0:
                        print("2-3 오른쪽으로 이동!")
                        dabinoid.bin_right_Walk()
                        dabinoid.bin_Walk()
                        st = 11
                        continue
                    else:
                        print("미션 확인")
                        dabinoid.mission_front_head()
                        _, _, _, _, red = definition.red(img)
                        _, _, _, _, blue = definition.blue(img)
                        if red >= 6000:
                            print("빨간색")
                            ttf = "RED"
                            total_st = 4
                            break
                        elif blue >= 6000:
                            print("파란색")
                            ttf = "BLUE"
                            total_st = 4
                            break
                        else:
                            if arrow == "LEFT":
                                print("왼쪽으로 Turn")
                                dabinoid.Line_left_Turn()
                                continue
                            else:
                                print("오른족으로 Turn")
                                dabinoid.Line_right_Turn()
                                continue

        # st=4 -----------------------------------------------------------------------------------------------------st=4
        elif total_st == 4:
            print("ttf = ", ttf)
            while True:
                if ttf == "RED":
                    _, _, left, right, pixel = definition.red(img)
                else:
                    _, _, left, right, pixel = definition.blue(img)

                if left > 0:
                    dabinoid.min_left_Walk()
                    continue
                if right >0 :
                    dabinoid.min_right_Walk()
                    continue
                if pixel >= 15000:
                    break
                else:
                    dabinoid.min_Walk()

            dabinoid.min_front_head()
            count_region = [0,0,0,0]
            while True:
                alphabet = pytesseract.image_to_string(img, lang='eng',
                                                       config='--psm 10 -c preserve_interword_spaces=1')
                if alphabet.find("A") >= 0:
                    count_region[0] += 1
                    if count_region[0] == 2:
                        print("A!!!")
                        count_region = [0, 0, 0, 0]
                        region.append("A")
                        break
                elif alphabet.find("B") >= 0:
                    count_region[1] += 1
                    if count_region[1] == 2:
                        print("B!!!")
                        region.append("B")
                        count_region = [0, 0, 0, 0]
                        break
                elif alphabet.find("C") >= 0 or alphabet.find("c") >= 0:
                    count_region[2] += 1
                    if count_region[2] == 2:
                        print("C!!!")
                        region.append("C")
                        count_region = [0, 0, 0, 0]
                        break
                elif alphabet.find("D") >= 0:
                    count_region[3] += 1
                    if count_region[3] == 2:
                        print("D!!!")
                        region.append("D")
                        count_region = [0, 0, 0, 0]
                        break
                else:
                    continue
            total_st = 5
            continue
        #st=5 ------------------------------------------------------------------------------------------------------st=5
        elif total_st == 5:
            seq = 0
            turn = "DEFAULT"
            st = 0
            color = ""
            while True:
                print("st = ",st)
                if st == 0:
                    std = 300
                    if arrow == "LEFT":
                        dabinoid.left_Turn()
                        dabinoid.da_front_head()
                        print("왼쪽으로 Turn")
                    else:
                        dabinoid.right_Turn()
                        dabinoid.da_front_head()
                        print("오른쪽으로 Turn")

                    green_pixel = definition.green(0,img)
                    if green_pixel >= std:
                        print("미션 구역 색상은 녹생이넹~")
                        color = "GREEN"
                    else:
                        print("미션 구역 색상은 검정이여!")
                        color = "BLACK"
                    st = 1
                    continue
                elif st == 1:
                    if color == "GREEN":
                        ret = find_citizen(ttf, dabinoid)
                        if ret == 100:
                            if seq == 0:
                                dabinoid.left_Turn()
                                seq += 1
                                st = 1
                                continue
                            elif seq == 1:
                                for i in range(2):
                                    dabinoid.right_Turn()
                                seq += 1
                                st = 1
                                continue
                            else:
                                print("Find_citizen_Error!")
                                break
                        else:
                            st = 2
                            continue
                    elif color == "BLACK":
                        for i in range(7):
                            dabinoid.min_Walk()
                        ret = find_citizen(ttf, dabinoid)
                        if ret == 100:
                            print("시민이 없떵")
                            if seq == 0:
                                dabinoid.left_Turn()
                                seq += 1
                                st = 1
                                continue
                            elif seq == 1:
                                for i in range(2):
                                    dabinoid.right_Turn()
                                seq += 1
                                st = 1
                                continue
                            else:
                                print("Find_citizen_Error!")
                                break
                        else:
                            st = 2
                            continue
                    else:
                        print("main_st1_Black_Error!")
                        break
                elif st == 2:
                    ret = adjust_citizen(ttf, dabinoid)
                    if ret == 102:
                        print("adjust_citizen_Error!")
                        break
                    else:
                        st = 3
                        continue
                elif st == 3:
                    ret = find_region(color)
                    if ret == 103:
                        print("find_region_Error!")
                        break
                    elif ret == 1:
                        print("집기")
                        turn = "DD"
                        dabinoid.citizen_up()
                        st = 4
                        continue
                    elif ret == 2:
                        print("집기 + 집은 채로 왼쪽으로 Turn")
                        turn = "LL"
                        dabinoid.citizen_up()
                        dabinoid.citizen_left_Turn()
                        dabinoid.citizen_left_Turn()
                        st = 4
                        continue
                    elif ret == 3:
                        print("집기 + 집은 채로 오른쪽으로 Turn")
                        turn = "RR"
                        dabinoid.citizen_up()
                        dabinoid.citizen_right_Turn()
                        dabinoid.citizen_right_Turn()
                        st = 4
                        continue
                    elif ret == 0:
                        print("집기 + 집은 채로 180도 Turn")
                        dabinoid.citizen_up()
                        for i in range(5):
                            dabinoid.citizen_left_Turn()
                        st = 4
                        continue
                    else:
                        print("main_st3_Error!")
                        break
                elif st == 4:
                    if color == "GREEN":
                        while True:
                            total = definition.green(1,img)
                            left = definition.green(2, img)
                            right = definition.green(3, img)
                            if total == 124800:
                                dabinoid.citizen_down()
                                if turn == "LL":
                                    dabinoid.mission_left_turn()
                                    print("왼쪽이오", turn)
                                elif turn == "RR":
                                    dabinoid.mission_right_turn()
                                    print("오른쪽이궁!!", turn)
                                elif turn == "DD":
                                    dabinoid.mission_front_turn()
                                    print("180도요!!",  turn)
                                else:
                                    print("Error!_LL_RR_DD")
                                for i in range(3):
                                    dabinoid.bin_Walk()
                                count = count + 1
                                break
                            else:
                                if abs(left - right) < 18000:
                                    print("한발짝 직진")
                                    dabinoid.citizen_walk()
                                    continue
                                else:
                                    if left > right:
                                        print("왼쪽으로 Turn")
                                        dabinoid.citizen_left_Turn()
                                        continue
                                    else:
                                        print("오른쪽으로 Turn")
                                        dabinoid.citizen_right_Turn()
                                        continue
                    elif color == "BLACK":
                        while True:
                            total = definition.black(6, img)
                            left = definition.black(7, img)
                            right = definition.black(8, img)

                            if total == 0:
                                dabinoid.citizen_left_Turn()
                                dabinoid.citizen_down()
                                dabinoid.right_Turn()
                                count = count + 1
                                break
                            else:
                                print("한발짝 직진")
                                continue
                    else:
                        print("main_st4_error")
                        break
                    print("mission_Finish!!")
                    total_st = 3
                    break
                else:
                    print("main_st_Error")
                    break
        elif total_st == 6:
            print("요기까지!")
            break

    # -----  remocon 16 Code  Exit ------
    while receiving_exit == 1:
        time.sleep(0.01)

    cap.release()
    cv2.destroyAllWindows()

    exit(1)








