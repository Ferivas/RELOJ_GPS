import machine
from machine import Pin,SPI


#Declaracion de pines y constantes
led=Pin(2,Pin.OUT)
oe = 21
data = 19;    # pin connected to the serial input of the MAX7219 (DIN)
clk = 18;    # pin for the clock of the serial link (CLK)
le = 5;    # pin for loading data (CS)
miso = 15;    # pin for input from the SPI bus (not used here)

oePin = machine.Pin(oe, machine.Pin.OUT)
dataPin = machine.Pin(data, machine.Pin.OUT)
clkPin  = machine.Pin(clk, machine.Pin.OUT)
lePin = machine.Pin(le, machine.Pin.OUT)

def handleInterrupt(timer):
  global interruptCounter
  interruptCounter=True

interruptCounter = False
totalInterruptsCounter = 0
timer = machine.Timer(1)  
tled=0

#Config HW
spi = SPI(baudrate=1600000, polarity=1, phase=0, sck=Pin(clk), mosi=Pin(data), miso=Pin(miso))
spi.init(baudrate=1600000) # set the baudrate
timer.init(period=1, mode=machine.Timer.PERIODIC, callback=handleInterrupt) #Ints cada 1 ms

# Set them to level 0
dataPin.off()
lePin.off()
clkPin.off()


# Send a byte bit by bit to the MAX7219, most significant bit first
def serialShiftByte(data):
    # Set the clock to 0 in order to be able to make a rising edge later
    clkPin.off()
    spi.write(data)


print("Ini tst Timer")
columnas=[0b00000001,0b00000010,0b00000100,0b00001000,0b00010000,0b00100000,0b01000000,0b10000000]
coldata = bytearray(columnas)
print(coldata)
bufdata=bytearray(1)
ptrcol=0
while True:
  if interruptCounter:
    interruptCounter = False
    totalInterruptsCounter = totalInterruptsCounter+1
    tled=tled+1
    tled=tled%1600
    if tled <100:
      led.value(1)
    else:
      led.value(0)

    oePin.on()
    bufdata=coldata[ptrcol]
    ptrcol=ptrcol+1
    ptrcol=ptrcol%8
    spi.write(bin(bufdata)) 
    spi.write(b'\x00') #Apago las columnas
    lePin.on()
    lePin.off()
#     spi.write(bin(bufdata)) 
#     spi.write(bin(bufdata)) #Apago las columnas
    lePin.on()
    lePin.off()
    oePin.off()        


        
    #spi.write(bufdata)
    # make a rising edge on CS to load the transmitted data into the register
    lePin.on()
    lePin.off()      
    #print("Int: "+ str(totalInterruptsCounter))

print("FIN tst Timer")      


