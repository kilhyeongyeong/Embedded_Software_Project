import serial
import time

class Robot():

    def __init__(self, serial = None):
        self.serial = serial

    def TX_data(self, one_byte):
        self.serial.write(serial.to_bytes([one_byte]))

    def east(self):
        self.TX_data(1)
        time.sleep(1.5)

    def west(self):
        self.TX_data(2)
        time.sleep(1.5)

    def south(self):
        self.TX_data(3)
        time.sleep(1.5)

    def north(self):
        self.TX_data(4)
        time.sleep(1.5)

    def default(self):
        self.TX_data(5)
        time.sleep(1.5)

    def bin_walk(self):
        self.TX_data(6)
        time.sleep(3)

    def doorman_jehyeon(self):
        self.TX_data(11)
        time.sleep(10)

    def start_head_right(self):
        self.TX_data(26)
        time.sleep(1)

    def start_turn_left(self):
        self.TX_data(24)
        time.sleep(2)

    def start_turn_right(self):
        self.TX_data(25)
        time.sleep(2)

    def arrow_head_up(self):
        self.TX_data(28)
        time.sleep(1)