import serial
import time
import cv2
import pytesseract
import numpy as np

pytesseract.pytesseract.tesseract_cmd = '/usr/bin/tesseract'

# 1. EWSN(16)     2. canny(53)    3. black(83)    4. yellow(110)    5. red(138)     6. blue(163)
# 7. green        8.

class Def():
    def __init__(self, dabinoid, serial = None ):
        self._serial = serial
        self._dabinoid = dabinoid

    def EWSN(self, gray):
        bearing = [0, 0, 0, 0]  # EWSN(동서남북)
        while True:
            alphabet = pytesseract.image_to_string(gray, lang='eng', config='--psm 10 -c preserve_interword_spaces=1')
            print(alphabet)

            if alphabet.find("E") >= 0 or alphabet.find("e") >= 0:
                bearing[0] += 1
                if bearing[0] == 3:
                    self._dabinoid.east()
                    bearing = [0, 0, 0, 0]
                    print("finish_E")
                    return 0
            elif alphabet.find("W") >= 0 or alphabet.find("w") >= 0:
                bearing[1] += 1
                if bearing[1] == 3:
                    self._dabinoid.west()
                    bearing = [0, 0, 0, 0]
                    print("finish_W")
                    return 0
            elif alphabet.find("S") >= 0 or alphabet.find("s") >= 0:
                bearing[2] += 1
                if bearing[2] == 3:
                    self._dabinoid.south()
                    bearing = [0, 0, 0, 0]
                    print("finish_S")
                    return 0
            elif alphabet.find("N") >= 0 or alphabet.find("n") >= 0:
                bearing[3] += 1
                if bearing[3] == 3:
                    self._dabinoid.north()
                    bearing = [0, 0, 0, 0]
                    print("finish_N")
                    return 0
            else:
                return 100

    def canny(self, num, img):
        lower_yellow = (20, 80, 50)
        upper_yellow = (30, 255, 255)

        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        img_mask_yellow = cv2.inRange(hsv, lower_yellow, upper_yellow)
        img_result_yellow = cv2.bitwise_and(img, img, mask=img_mask_yellow)

        canny = cv2.Canny(img_result_yellow, 100, 255)

        if num == 0:
            pixel = np.where(canny[:, :] == 255)
            pixel = len(pixel[0])
        elif num == 1:
            pixel = np.where(canny[:, :160] == 255)
            pixel = len(pixel[0])
        elif num == 2:
            pixel = np.where(canny[:, 161:] == 255)
            pixel = len(pixel[0])
        else:
            return "err"

        return pixel

    def black(self, num, img):
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        _, img_th = cv2.threshold(gray, 53, 255, cv2.THRESH_BINARY)

        if num == 0:
            pixel = np.where(img_th[:, :] == 0)
            pixel = len(pixel[0])
        elif num == 1:
            pixel = np.where(img_th[:, :159] == 0)
            pixel = len(pixel[0])
        elif num == 2:
            pixel = np.where(img_th[:, 160:] == 0)
            pixel = len(pixel[0])
        elif num == 3:
            pixel = np.where(img_th[190:, :] == 0)
            pixel = len(pixel[0])
        elif num == 4:
            pixel = np.where(img_th[:50, :149] == 0)
            pixel = len(pixel[0])
        elif num == 5:
            pixel = np.where(img_th[:50, 150:] == 0)
            pixel = len(pixel[0])
        elif num == 6:
            pixel = np.where(img_th[110:, :] == 0)
            pixel = len(pixel[0])
        elif num == 7:
            pixel = np.where(img_th[110:, :159] == 0)
            pixel = len(pixel[0])
        elif num == 8:
            pixel = np.where(img_th[110:, 160:] == 0)
            pixel = len(pixel[0])
        else:
            return 90

        return pixel

    def yellow(self, img):
        lower_yellow = (20, 80, 50)
        upper_yellow = (30, 255, 255)

        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        img_mask_yellow = cv2.inRange(hsv, lower_yellow, upper_yellow)
        img_result_yellow = cv2.bitwise_and(img, img, mask=img_mask_yellow)

        yellow_pixel = np.where(img_result_yellow[:, 90:199] == 0)
        yellow_pixel = 78480 - len(yellow_pixel[0])

        top = np.where(img_result_yellow[:79, 90:199] == 0)
        top = 25833 - len(top[0])

        top_r = np.where(img_result_yellow[:79, 200:] == 0)
        top_r = 28440 - len(top_r[0])

        top_l = np.where(img_result_yellow[:79, :89] == 0)
        top_l = 21093 - len(top_l[0])

        left = np.where(img_result_yellow[:, :89] == 0)
        left = 64080 - len(left[0])

        right = np.where(img_result_yellow[:, 200:] == 0)
        right = 86400 - len(right[0])

        bottom = np.where(img_result_yellow[239:, 90:199] == 0)
        bottom = 327 - len(bottom[0])

        bottom_l = np.where(img_result_yellow[239:, :89] == 0)
        bottom_l = 267 - len(bottom_l[0])

        bottom_r = np.where(img_result_yellow[239:, 200:] == 0)
        bottom_r = 360 - len(bottom_r[0])

        total = np.where(img_result_yellow[:, :] == 0)
        total = 230400 - len(total[0])



        return left, right, top, top_l, top_r, bottom, bottom_l, bottom_r, yellow_pixel, total


    def red(self, img):
        lower_red = (130, 50, 50)
        upper_red = (360, 255, 255)

        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        img_mask_red = cv2.inRange(hsv, lower_red, upper_red)
        img_result_red = cv2.bitwise_and(img, img, mask=img_mask_red)

        top = np.where(img_result_red[49:50, :] == 0)
        top = 960 - len(top[0])

        bottom = np.where(img_result_red[199:200, :] == 0)
        bottom = 960 - len(bottom[0])

        left = np.where(img_result_red[:, 1:2] == 0)
        left = 720 - len(left[0])

        right = np.where(img_result_red[:, 319:320] == 0)
        right = 720 - len(right[0])

        red_pixel = np.where(img_result_red[:, :] == 0)
        red_pixel = 230400 - len(red_pixel[0])

        return top, bottom, left, right, red_pixel

    def blue(self, img):
        lower_blue = (80, 100, 50)
        upper_blue = (130, 255, 255)

        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        img_mask_blue = cv2.inRange(hsv, lower_blue, upper_blue)
        img_result_blue = cv2.bitwise_and(img, img, mask=img_mask_blue)

        top = np.where(img_result_blue[49:50, :] == 0)
        top = 960 - len(top[0])

        bottom = np.where(img_result_blue[199:200, :] == 0)
        bottom = 960 - len(bottom[0])

        left = np.where(img_result_blue[:, 1:2] == 0)
        left = 720 - len(left[0])

        right = np.where(img_result_blue[:, 319:320] == 0)
        right = 720 - len(right[0])

        blue_pixel = np.where(img_result_blue[:, :] == 0)
        blue_pixel = 230400 - len(blue_pixel[0])

        return top, bottom, left, right, blue_pixel

    def green(self, num, img):
        lower_green = (45, 65, 50)
        upper_green = (90, 255, 255)

        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        img_mask_green = cv2.inRange(hsv, lower_green, upper_green)
        img_result_green = cv2.bitwise_and(img, img, mask=img_mask_green)

        if num==0:
            green_pixel = np.where(img_result_green[:, :] == 0)
            green_pixel = 230400-len(green_pixel[0])
        elif num == 1:
            green_pixel = np.where(img_result_green[110:, :] == 0)
            green_pixel = 124800 - len(green_pixel[0])
        elif num == 2:
            green_pixel = np.where(img_result_green[110:, :159] == 0)
            green_pixel = 62010 - len(green_pixel[0])
        elif num == 3:
            green_pixel = np.where(img_result_green[110:, 160:] == 0)
            green_pixel = 62400 - len(green_pixel[0])
        else:
            return 105

        return green_pixel

    def citizen_pixel(self, ttf, num, img):
        lower_blue = (80, 100, 80)
        upper_blue = (130, 255, 255)

        lower_red = (130, 50, 100)
        upper_red = (360, 255, 255)

        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

        img_mask_red = cv2.inRange(hsv, lower_red, upper_red)
        img_result_red = cv2.bitwise_and(img, img, mask=img_mask_red)

        img_mask_blue = cv2.inRange(hsv, lower_blue, upper_blue)
        img_result_blue = cv2.bitwise_and(img, img, mask=img_mask_blue)

        x_std = 160
        y_std = 120

        if num == 0:
            if ttf == "RED":
                red_pixel = np.where(img_result_red[:, :] == 0)
                red_pixel = 230400 - len(red_pixel[0])
                return red_pixel
            elif ttf == "BLUE":
                blue_pixel = np.where(img_result_blue[:, :] == 0)
                blue_pixel = 230400 - len(blue_pixel[0])
                return blue_pixel
            else:
                return 101
        elif num == 1:
            if ttf == "RED":
                if ttf == 0:
                    red_pixel = np.where(img_result_red[:, :x_std] == 0)
                    red_pixel = 115200 - len(red_pixel[0])
                    return red_pixel
                elif ttf == "BLUE":
                    blue_pixel = np.where(img_result_blue[:, :x_std] == 0)
                    blue_pixel = 115200 - len(blue_pixel[0])
                    return blue_pixel
                else:
                    return 101
        elif num == 2:
            if ttf == "RED":
                red_pixel = np.where(img_result_red[:, x_std + 1:] == 0)
                red_pixel = 114480 - len(red_pixel[0])
                return red_pixel
            elif ttf == "BLUE":
                blue_pixel = np.where(img_result_blue[:, x_std + 1:] == 0)
                blue_pixel = 114480 - len(blue_pixel[0])
                return blue_pixel
            else:
                return 101
        elif num == 3:
            if ttf == "RED":
                red_pixel = np.where(img_result_red[:y_std, :] == 0)
                red_pixel = 115200 - len(red_pixel[0])
                return red_pixel
            elif ttf == "BLUE":
                blue_pixel = np.where(img_result_blue[:y_std, :] == 0)
                blue_pixel = 115200 - len(blue_pixel[0])
                return blue_pixel
            else:
                return 101
        elif num == 4:
            if ttf == "RED":
                red_pixel = np.where(img_result_red[y_std + 1:, :] == 0)
                red_pixel = 114240 - len(red_pixel[0])
                return red_pixel
            elif ttf == "BLUE":
                blue_pixel = np.where(img_result_blue[y_std + 1:, :] == 0)
                blue_pixel = 114240 - len(blue_pixel[0])
                return blue_pixel
            else:
                return 101
        else:
            return 101




