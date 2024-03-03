import machine
from machine import Pin,SPI
import time
import ntptime
import wifimgr


#Declaracion de pines y constantes
ntptime.host = "pool.ntp.org"


NUMMATRIZ=4
LONGBUF=NUMMATRIZ*8
datocero=0b00000000
buffram=[]
for i in range(LONGBUF+1):
    buffram.append(datocero)

VERSION_HW=2

#Config HW
if VERSION_HW==1:
    LEDPIN=5
    oe = 27
    data = 26;    # pin connected to the serial input of the MAX7219 (DIN)
    clk  = 25;    # pin for the clock of the serial link (CLK)    
    load = 33;    # pin for loading data (CS)
    miso=15 #notused
    
if VERSION_HW==2:
    LEDPIN=2
    oe = 27
    data = 14;    # pin connected to the serial input of the MAX7219 (DIN)
    clk = 12;    # pin for loading data (CS)
    load  = 13;    # pin for the clock of the serial link (CLK)
    miso=15 #notused

led=Pin(LEDPIN,Pin.OUT)

# Initialize the pins as outputs
oePin = machine.Pin(oe, machine.Pin.OUT)
dataPin = machine.Pin(data, machine.Pin.OUT)
loadPin = machine.Pin(load, machine.Pin.OUT)
clkPin  = machine.Pin(clk, machine.Pin.OUT)
misoPin = machine.Pin(miso, machine.Pin.OUT)
# Set them to level 0
dataPin.off()
loadPin.off()
clkPin.off()

#spi = machine.SPI(-1, sck = clkPin, mosi = dataPin, miso = misoPin)
spi = SPI(1, baudrate=3000000,  phase=0, sck=clkPin, mosi=dataPin, miso=misoPin)

flaginternet=False
columnas=[0b00000001,0b00000010,0b00000100,0b00001000,0b00010000,0b00100000,0b01000000,0b10000000]
#tblposdig=[1,9,19,27,25,31]
#tblposdig=[1,10,19,27,25,31]
tblposdig=[10,2,23,16,25,31]
coldata = bytearray(columnas)
datocolumna=bytearray(1)
ptrcol=0
def handleInterrupt(timer):
    global interruptCounter
    global datocolumna
    global ptrcol
    global datodat
    interruptCounter = False
    oePin.on()
    datocolumna=coldata[ptrcol]
    datodat=buffram[ptrcol]
#    ptrcol=ptrcol+1
#    ptrcol=ptrcol%8
    serialWrite(datocolumna,datocero)
    serialWrite(datocolumna,datocero)
    serialWrite(datocolumna,datocero)
    serialWrite(datocolumna,datocero)
    serialWrite(datocolumna,datodat)
#    if flaginternet:
    serialWrite(datocolumna,buffram[ptrcol+8])
    serialWrite(datocolumna,buffram[ptrcol+16])
    serialWrite(datocolumna,buffram[ptrcol+24])
#     else:
#         serialWrite(datocolumna,0b00000001)
#         serialWrite(datocolumna,0b00000010)
#         serialWrite(datocolumna,0b00000100)
    oePin.off()
    ptrcol=ptrcol+1
    ptrcol=ptrcol%8
    
    interruptCounter=True

interruptCounter = False
#totalInterruptsCounter = 0
timer = machine.Timer(1)
timer.init(period=2, mode=machine.Timer.PERIODIC, callback=handleInterrupt) #Ints cada 2 ms
tled=0
 
# Send a byte bit by bit to the MAX7219, most significant bit first
def serialShiftByte(data):
    # Set the clock to 0 in order to be able to make a rising edge later
    clkPin.off()
    # Shift the 8 bits of data
    spi.write(data)
# Write some data in a register of the MAX7219.
buffer = bytearray(2)
def serialWrite(address, data):
    # Set CS to 0 to create a rising edge later
    buffer[0] = address
    buffer[1] = data    
    loadPin.off()
    # Send the address of the register first
    spi.write(buffer)
    # then the data
    # make a rising edge on CS to load the transmitted data into the register
    loadPin.on()
    loadPin.off()
# Send a byte bit by bit to the MAX7219, most significant bit first

def gendig(valdig,posdig):
    ptrdig=valdig*6
    ptrpos=tblposdig[posdig]
    #print("Ptrpos>",ptrpos)
    for i in range(6):
        ptr=ptrdig+i
        datadig=TBLDIG[ptr]
        #ptr2=ptrpos+i-1
        ptr2=ptrpos+i
        buffram[ptr2]=datadig
    

def getntptime():
     print("Hora inicial:", time.localtime()) 
     ntptime.settime () # set the RTC's time using ntptime
     tval=ntptime.time()
     tval=tval-18000
     #tfloat=float(tval)
     tclk = time.localtime (tval)
     print(tclk)
     anio=str(tclk[0])
     if tclk[1]>9:
         mes=str(tclk[1])
     else:
         mes="0"+str(tclk[1])
     if tclk[2]>9:
         dia=str(tclk[2])
     else:
         dia="0"+str(tclk[2])
     if tclk[3]>9:
         hora=str(tclk[3])
     else:
         hora="0"+str(tclk[3])
     if tclk[4]>9:
         minu=str(tclk[4])
     else:
         minu="0"+str(tclk[4])
     if tclk[5]>9:
         seg=str(tclk[5])
     else:
         seg="0"+str(tclk[5])
         
     cmdclk=dia+mes+anio[2:]+hora+minu+seg
     print(cmdclk)

TBLDIG=[0B01111100,
0B11111110,
0B10000010,
0B10000010,
0B11111110,
0B01111100,


0B00000000,
0B10000100,
0B11111110,
0B11111110,
0B10000000,
0B00000000,


0B10000100,
0B11000010,
0B11100010,
0B10110010,
0B10011110,
0B10001100,


0B10000010,
0B10000010,
0B10010010,
0B10010010,
0B11111110,
0B01101100,


0B00111100,
0B00111100,
0B00100000,
0B11111110,
0B11111110,
0B00100000,


0B01011110,
0B11011110,
0B10010010,
0B10010010,
0B11110010,
0B01100010,


0B01111100,
0B11111110,
0B10010010,
0B10010010,
0B11110010,
0B01100000,


0B00000010,
0B11100010,
0B11110010,
0B00011010,
0B00001110,
0B00000110,


0B01101100,
0B11111110,
0B10010010,
0B10010010,
0B11111110,
0B01101100,


0B00001100,
0B10011110,
0B10010010,
0B10010010,
0B11111110,
0B01111100,


0B00000000,
0B00000000,
0B00000000,
0B00000000,
0B00000000,
0B00000000,
]

print("uPython Matrix")
ptrcol=0
datocero=0b00000000
datodat=0b001000100
print("Gen1")
gendig(4,0)
gendig(3,1)
gendig(2,2)
gendig(1,3)
tick=0
newdig=False
cntrdig=0
time.sleep(1)
gendig(10,0)
gendig(10,1)
gendig(10,2)
gendig(10,3)
buffram[30]=0b11000000


try:
    profiles = wifimgr.read_profiles()
    print(profiles)
except:
    print("Sin profiles todavia")

wlan = wifimgr.get_connection()

if wlan is None:
    print("Could not initialize the network connection.")
    while True:
        pass  # you shall not pass :D

flaginternet=True

try:
    getntptime()
except:
    print("Err NTP")
    
dhoraant=99
uhoraant=99
dminant=99
uminant=99
newd=False
newntp=False
while True:
  if interruptCounter:
    interruptCounter = False
    tled=tled+1
    tled=tled%1600
    if tled <100:
      led.value(1)
    else:
      led.value(0)
    tick=tick+1
    tick=tick%500
    if tick==0:
        newdig=True
  if newdig:
     newdig=False
     #print(time.localtime())
     cntrdig=cntrdig+1
     tc=cntrdig%2
     if tc==0:
         buffram[31]=0b00000000
         buffram[30]=0b00000000
     else:
         buffram[31]=0b01101100
         buffram[30]=0b01101100
     tclk=time.time()
     tclk=tclk-18000
     #tfloat=float(tclk)
     tval = time.localtime (tclk)     
     if tval[3]<10:
         dhora=0
         uhora=tval[3]
     else:
         horastr=str(tval[3])
         dhora=int(horastr[0])
         uhora=int(horastr[1])
         
     if tval[4]<10:
         dmin=0
         umin=tval[4]
     else:
         horastr=str(tval[4])
         dmin=int(horastr[0])
         umin=int(horastr[1])         

     if dhora!=dhoraant:
         dhoraant=dhora
         newd=True
     if uhora!=uhoraant:
         uhoraant=uhora
         newntp=True         
         newd=True

     if dmin!=dminant:
         dminant=dmin
         newd=True
     if umin!=uminant:
         uminant=umin
         newd=True
         #newntp=True         

     if newd:
         newd=False
         gendig(dhora,3)
         gendig(uhora,2)
         gendig(dmin,1)
         gendig(umin,0)
      
     if newntp:
        newntp=False
        gendig(10,0)
        gendig(10,1)
        gendig(10,2)
        gendig(10,3)        
        try:
            getntptime()
        except:
            print("Err NTP")
        newd=True
      
      
print("FIN tst Timer")      


