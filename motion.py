import serial
import time

class Robot():

    def __init__(self, serial = None):
        self.serial = serial

    def TX_data(self, one_byte):
        self.serial.write(serial.to_bytes([one_byte]))

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