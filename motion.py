import serial
import time

class Robot():

    def __init__(self, serial = None):
        self.serial = serial

    def TX_data(self, one_byte):
        self.serial.write(serial.to_bytes([one_byte]))

    def default(self):
        self.TX_data(5)
        time.sleep(3)
#--------------------------------------------------------------
    def east(self):
        self.TX_data(1)
        time.sleep(3)

    def west(self):
        self.TX_data(2)
        time.sleep(3)

    def south(self):
        self.TX_data(3)
        time.sleep(3)

    def north(self):
        self.TX_data(4)
        time.sleep(3)
#---------------------------------------------------------------
    def Door_Open(self):
        self.TX_data(10)
        time.sleep(13)

# --Go front---------------------------------------------------
    def min_Walk(self):
        self.TX_data(26)
        time.sleep(3)

    def da_Walk(self):
        self.TX_data(39)
        time.sleep(3)

    def bin_Walk(self):
        self.TX_data(40)
        time.sleep(3)

    def SWalk(self):
        self.TX_data(16)
        time.sleep(5.5)

    def bin_SWalk(self):
        self.TX_data(34)
        time.sleep(3)
# --Go left, right----------------------------------------------------
    def min_left_Walk(self):
        self.TX_data(14)
        time.sleep(3)

    def da_left_Walk(self):
        self.TX_data(35)
        time.sleep(3)

    def bin_left_Walk(self):
        self.TX_data(36)
        time.sleep(3)

    def min_right_Walk(self):
        self.TX_data(13)
        time.sleep(3)

    def da_right_Walk(self):
        self.TX_data(37)
        time.sleep(3)

    def bin_right_Walk(self):
        self.TX_data(38)
        time.sleep(3)
# --backstep-------------------------------------
    def min_backStep(self):
        self.TX_data()
        time.sleep(4)

    def da_backStep(self):
        self.TX_data()
        time.sleep(4)

    def bin_backStep(self):
        self.TX_data(46)
        time.sleep(4)
# --head------------------------------------
    def start_head(self):
        self.TX_data(57)
        time.sleep(1)

    def min_front_head(self):
        self.TX_data(43)
        time.sleep(2)

    def da_front_head(self):
        self.TX_data(18)
        time.sleep(2)

    def bin_front_head(self):
        self.TX_data(23)
        time.sleep(2)

    def min_left_head(self):
        self.TX_data(41)
        time.sleep(2)

    def da_left_head(self):
        self.TX_data(15)
        time.sleep(2)

    def bin_left_head(self):
        self.TX_data(17)
        time.sleep(2)

    def min_right_head(self):
        self.TX_data(42)
        time.sleep(2)

    def da_right_head(self):
        self.TX_data(20)
        time.sleep(2)

    def bin_right_head(self):
        self.TX_data(27)
        time.sleep(2)
# -- Turn -------------------------------
    def Line_right_Turn(self):
        self.TX_data(30)
        time.sleep(3)

    def Line_left_Turn(self):
        self.TX_data(28)
        time.sleep(3)

    def right_Turn(self):
        self.TX_data(31)
        time.sleep(3)

    def left_Turn(self):
        self.TX_data(21)
        time.sleep(3)

# -- mission ----------------------------
    def citizen_down(self):
        self.TX_data(9)
        time.sleep(7.5)

    def citizen_up(self):
        self.TX_data(7)
        time.sleep(10)

    def citizen_walk(self):
        self.TX_data(8)
        time.sleep(3)

    def citizen_left_Turn(self):
        self.TX_data(49)
        time.sleep(3)

    def citizen_right_Turn(self):
        self.TX_data(50)
        time.sleep(3)

    def mission_front_head(self):
        self.TX_data(62)
        time.sleep(2)

    def mission_left_turn(self):
        self.TX_data(63)
        time.sleep(3)

    def mission_right_turn(self):
        self.TX_data(65)
        time.sleep(3)

    def mission_front_turn(self):
        self.TX_data(64)
        time.sleep(4)

