import machine
from machine import Pin,SoftSPI,PWM
import time
import ntptime
import wifimgr
import ujson
import urequests as requests
from umqttsimple import MQTTClient
import ubinascii


#Declaracion de pines y constantes
ntptime.host = "pool.ntp.org"



VERSION_HW=2
FILECONFIG="configjson.txt"
EQUIPO="reloj"

#Config HW
if VERSION_HW==1:
    LEDPIN=5
    oe = 27
    data = 26;    # pin connected to the serial input of the MAX7219 (DIN)
    clk  = 25;    # pin for the clock of the serial link (CLK)    
    load = 33;    # pin for loading data (CS)
    miso=15 #notused
    PINSELBRK=18
    
if VERSION_HW==2:
    LEDPIN=2
    oe = 27
    data = 14;    # pin connected to the serial input of the MAX7219 (DIN)
    clk = 12;    # pin for loading data (CS)
    load  = 13;    # pin for the clock of the serial link (CLK)
    miso=15 #notused
    PINSELBRK=23

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

#Control brillo PWM
frequency = 5000
oecontrol = PWM(Pin(oe), frequency)
oecontrol.duty(800)

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
    oecontrol.duty(1023)
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
    oecontrol.duty(brillopwm)

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

try:
    print("Buscando conf inicial")
    with open(FILECONFIG,'r') as f:
        varconfig=ujson.load(f)
    print("Var file encontrado")
except:
    print("Inicializando conf inicial")
    varconfig={"equipo":EQUIPO,"tiempontp":3600,"huso":-18000,"chatid":"727498654",
               "botid":"1737167982:AAEfbJSqPZ9RB084GFqNEo_xBPcZRVERbLk","enamsg":True,"brillo":10,"cntrini":0}
    print("Guardando Var file")
    with open(FILECONFIG,'w') as f:
        ujson.dump(varconfig,f)
        
print(varconfig)
tiempontp=varconfig.get("tiempontp")
print("tiempontp=",tiempontp)
huso=varconfig.get("huso")
print("huso=",huso)
CHATID=varconfig.get("chatid")
BOTID=varconfig.get("botid")
ENAMSG=varconfig.get("enamsg")
brilloval=varconfig.get("brillo")
print("brillo=",brilloval)
cntrini=varconfig.get("cntrini")
print("cntrini=",cntrini)

brillopwm=round(-brilloval*1023/100+1023)
oecontrol.duty(brillopwm)

print("Telegram>",CHATID,BOTID,ENAMSG)
EQUIPO=varconfig.get("equipo")
print("Equipo>",EQUIPO)

def saveKey(dict, key,value):
    if key in dict.keys():
        #print("Key exist, ", end =" ")
        dict.update({key:value})
        #print("value updated =", value)
    else:
        print("No existe")    

last_message = 0
message_interval = 10
counter = 0
client_id = ubinascii.hexlify(machine.unique_id())
client_idstr=client_id.decode('utf-8')
print(client_id)
cntrini=cntrini+1
print("Cntrini=",cntrini)
try:
    saveKey(varconfig, "cntrini",cntrini)
    with open(FILECONFIG,'w') as f:
        ujson.dump(varconfig,f)
except:
    print("Err save cntrini")

# Defino pin para seleccionar el broker
botonbroker=Pin(PINSELBRK, Pin.IN,Pin.PULL_UP)

#MQTT
testbroker=True
cntrtest1=0
cntrtest2=0
while testbroker:
    if botonbroker.value()==1:
        time.sleep(0.2)
        if botonbroker.value()==1:
            cntrtest1=cntrtest1+1
            if cntrtest1>5:
                mqtt_server = "192.168.2.130"
                #mqtt_server="broker.emqx.io"
                testbroker=False
        else:
            cntrtest1=0
    if botonbroker.value()==0:
        time.sleep(0.2)
        if botonbroker.value()==0:
            cntrtest2=cntrtest2+1
            if cntrtest2>5:
                mqtt_server="broker.emqx.io"
                #mqtt_server = "192.168.2.130"
                testbroker=False

print("Broker>",mqtt_server)

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
reinicio=0
# digito1=gendig(10)
# digito2=gendig(10)
# digito3=gendig(10)
# digito4=gendig(10)
# serialWrite(digito1, digito2,digito3,digito4)

def sndmsgtelegram(msg,chatid,botid):
    urlbase="https://api.telegram.org"
    url=urlbase+'/bot'+botid+'/sendMessage?chat_id='+chatid+'&disable_web_page_preview=1&parse_mode=Markdown&text='+msg
    try:
        response = requests.get(url)
        if response.status_code == 200:
            results = response.json()
            print(results)
        else:
            print("Error code %s" % response.status_code)
    except:
        print("Error snd Telegram")

def sub_cb(topic, msg):
  global newmqttcmd, mqttcmd, mqtttopic
  print((topic, msg))
  newmqttcmd=True
  mqttcmd=msg
  mqtttopic=topic


def restart_and_reconnect():
  print('Failed to connect to MQTT broker. Reconnecting...')
  time.sleep(5)


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
while True:
    cntrtb=0
    cmderr=0
    cmdtb=False
    print("Var usadas para MQTT")
    tmpstr=EQUIPO+'/'+client_idstr+'/ackresp'
    print(tmpstr)
    topic_ack = bytes(tmpstr, 'utf-8')
    tmpstr=EQUIPO+'/'+client_idstr+'/cmdresp'
    print(tmpstr)
    topic_pub = bytes(tmpstr, 'utf-8')
    tstbroker=True
    while tstbroker:
        try:
          #client = connect_and_subscribe()
          client = MQTTClient(client_id, mqtt_server, port=1883, keepalive=30)
          client.set_callback(sub_cb)
          client.connect()
          tstbroker=False
        except OSError as e:
          print(e)
          restart_and_reconnect()
    newmqttcmd=False
    
    topicname=["cmdrx","config","ackresp","onoff","tiempontp",
               "huso","brillo"]
    topiclist=[]
    ptr=0
    for i in topicname:
        tmpstr=EQUIPO+'/'+client_idstr+'/'+i
        topictmp=bytes(tmpstr, 'utf-8')
        topiclist.append(topictmp)
        print(tmpstr,",",topiclist[ptr])
        client.subscribe(topiclist[ptr])
        print('Connected to %s MQTT broker, subscribed to %s topic' % (mqtt_server, topiclist[ptr]))
        ptr=ptr+1
    
    print(topiclist)
    
    if reinicio==0:
        atsnd=EQUIPO + " ID "+client_idstr+ " inicia operacion en broker "+mqtt_server+", tiempontp="+str(tiempontp)+", huso="+str(huso)+", brillo="+str(brilloval)+ ", cntrini="+str(cntrini)
    if reinicio==1:
        atsnd=EQUIPO + " ID "+client_idstr+ " REINICIO en broker "+mqtt_server+", tiempontp="+str(tiempontp)+", huso="+str(huso)+", brillo="+str(brilloval)+ ", cntrini="+str(cntrini)
    print(atsnd)
    
    try:
        if ENAMSG:
            sndmsgtelegram(atsnd,CHATID,BOTID)
        else:
            print("No msg")
    except:
        print("ERR snd Telegram")

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
    brokerok=True
    while brokerok:
        try:
            client.check_msg()
            if newmqttcmd:
              newmqttcmd=False
              if mqtttopic == topiclist[4]:
                print('ESPcmdtiempontp>',mqttcmd)
                comando=mqttcmd.decode('utf-8')
                print("Cmd>",comando)
                try:
                    tiempoval=int(comando)
                    tiempontp=tiempoval*3600
                    print("tiempontp=",tiempontp, "seg")
                    saveKey(varconfig, "tiempontp",tiempontp)
                    with open(FILECONFIG,'w') as f:
                        ujson.dump(varconfig,f)
                    
                except:
                    print("err tiempontp")

              if mqtttopic == topiclist[5]:
                print('ESPcmdhuso>',mqttcmd)
                comando=mqttcmd.decode('utf-8')
                print("Cmd>",comando)
                try:
                    husof=float(comando)*3600
                    huso=int(husof)
                    print("Huso=",huso)
                    saveKey(varconfig, "huso",huso)
                    with open(FILECONFIG,'w') as f:
                        ujson.dump(varconfig,f)

                except:
                    print("err huso")
                
                
              if mqtttopic == topiclist[6]:
                print('ESPcmdbrillo>',mqttcmd)
                brillostr=mqttcmd.decode('utf-8')
                print("Cmd>",brillostr)
                brilloval=int(brillostr)
                brillopwm=round(-brilloval*1023/100+1023)
                print(brillopwm)
                oecontrol.duty(brillopwm)
                try:
                    print("Save brillo")
                    saveKey(varconfig, "brillo",brilloval)
                    with open(FILECONFIG,'w') as f:
                        ujson.dump(varconfig,f)

                except:
                    print("err savekey")
                

        
            if newdig:
             newdig=False
             #print(time.time())
             if tiempontp!=0:
                 tntp=time.time()%tiempontp
                 if tntp==0:
                     print("nuevo NTP")
                     newntp=True
             cntrdig=cntrdig+1
             tc=cntrdig%2
             tclk=time.time()
             tclk=tclk+huso
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
                 #newntp=True         
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

             if (time.time() - last_message) > message_interval:
                msg = client_idstr+","+str(counter)
                client.publish(topic_pub, msg)
                #client.publish(topiclist[1], msg)
                last_message = time.time()
                counter += 1 

        except OSError as e:
            print("Uy>",e)
            restart_and_reconnect()
            brokerok=False                
                
        