import serial;
from tkinter import *;
serial_commands = {"a" : 1, "d" : 2, "w" : 3, "s" : 4, "i" : 5, "k" : 6};
ser = serial.Serial();

def keyUp(e):
    global ser;
    if e.char in serial_commands.keys():
        print(e.char);
        ser.write(bytes([serial_commands[e.char]]));

def initialise():
    global ser;
    try:
        ser = serial.Serial('/dev/ttyUSB0');
        ser.baudrate = 115200;
    except Exception as e:
        raise Exception(e);

    root = Tk();
    root.bind("<KeyRelease>", keyUp);
    
    root.mainloop();

if __name__ == "__main__":
    initialise();
