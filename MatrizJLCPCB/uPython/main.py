import machine
from machine import Pin,SoftSPI
import time
import ntptime
import wifimgr


#Declaracion de pines y constantes
ntptime.host = "pool.ntp.org"



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
oePin.off()

spi = SoftSPI(sck = clkPin, mosi = dataPin, miso = misoPin)
spi.init(baudrate=100000)

flaginternet=False

ptrcol=0
tled=0
tick=0
def handleInterrupt(timer):
    global tled
    global tick
    global newdig
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

   

#totalInterruptsCounter = 0
timer = machine.Timer(1)
timer.init(period=2, mode=machine.Timer.PERIODIC, callback=handleInterrupt) #Ints cada 2 ms
tled=0
 

# Write some data in a register of the MAX7219.
buffer = bytearray(2)
def serialWrite(dig1, dig2,dig3,dig4):
    # Set CS to 0 to create a rising edge later
    oePin.on()
    buffer[0] = dig1
    buffer[1] = dig2
    spi.write(buffer)
    loadPin.on()
    loadPin.off()
    buffer[0] = dig3
    buffer[1] = dig4
    spi.write(buffer)
    loadPin.on()
    loadPin.off()
    oePin.off()

def gendig(valdig):
    datadig=TBLDIG[valdig]
    return datadig

def getntptime():
     print("Hora ini:", time.localtime()) 
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

TBLDIG=[0B00111111,
0B00110000,
0B01101101,
0B01111001,
0B01110010,
0B01011011,
0B01011111,
0B00110001,
0B01111111,
0B01110011,
0B00000000,
]

print("uPython Matrix JLCPCB")
ptrcol=0
print("Gen1")
digito1=gendig(4)
digito2=gendig(3)
digito3=gendig(2)
digito4=gendig(1)
serialWrite(digito1, digito2,digito3,digito4)
tick=0
newdig=False
cntrdig=0
time.sleep(1)
# digito1=gendig(10)
# digito2=gendig(10)
# digito3=gendig(10)
# digito4=gendig(10)
# serialWrite(digito1, digito2,digito3,digito4)


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
cntrt=0
while True:
  if newdig:
     newdig=False
     #print(time.localtime())
     cntrdig=cntrdig+1
     tc=cntrdig%2
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

     newd=True
     if newd:
         newd=False
         #print(dhora,uhora,dmin,umin)
         digito1=gendig(dhora)
         digito2=gendig(uhora)
         if tc==0:
             digito2=digito2 & 0b01111111
         else:
             digito2=digito2 | 0b10000000
         digito3=gendig(dmin)
         digito4=gendig(umin)
         serialWrite(digito3, digito4,digito1,digito2)
      
     if newntp:
        newntp=False
        gendig(10)
        gendig(10)
        gendig(10)
        gendig(10)
        serialWrite(digito3, digito4,digito1,digito2)
        try:
            getntptime()
        except:
            print("Err NTP")
        newd=True
      
      
print("FIN tst Timer")      


