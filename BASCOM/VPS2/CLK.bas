'Main.bas
'
'                 WATCHING Soluciones Tecnológicas
'                    Fernando Vásquez - 25.06.15
'
' Programa para almacenar los datos que se reciben por el puerto serial a una
' memoria SD
'


$version 0 , 1 , 269
'$regfile = "m328pdef.dat"
$regfile = "m168def.dat"
$crystal = 7372800
$baud = 9600


$hwstack = 96
$swstack = 96
$framesize = 96
$projecttime = 238


'Declaracion de constantes
Const Modrtc = 1
Const Vhw = 3                                               '1 version Arduino Nano, 2 version IBUTTON , PS2SERIAL

Const Nummatriz = 4                                         'Una matriz esunmodulo P10 de 16x32
Const Longbuf = Nummatriz * 8
Const Longbuf_masuno = Longbuf + 1
Const Msb_l = 0
Const Msb_h = 1
Const Lsb_l = 2
Const Lsb_h = 3

Const Opcion = Lsb_h

'RTC
Const Ds3231r = &B11010001                                  'DS3231 is very similar to DS1307 but it include a precise crystal
Const Ds3231w = &B11010000

'Configuracion de entradas/salidas
#if Vhw = 1
Led1 Alias Portb.5                                          'LED ROJO
Config Led1 = Output
#endif


#if Vhw = 2
Led1 Alias Portc.3                                          'LED ROJO
Config Led1 = Output
#endif

#if Vhw = 3
Led1 Alias Portb.0                                          'LED ROJO
Config Led1 = Output
#endif



'PINES interfaz
#if Vhw = 1
Oena Alias Portd.5
Config Oena = Output
Sdi Alias Portd.4
Config sdi = Output
Clk Alias Portd.3
Config Clk = Output
Lena Alias Portd.2
Config Lena = Output
#endif


#if Vhw = 2
Oena Alias Portc.0
Config Oena = Output
Sdi Alias Portb.3
Config Sdi = Output
Clk Alias Portb.4
Config Clk = Output
Lena Alias Portb.5
Config Lena = Output
#endif

#if Vhw = 3
Oena Alias Portc.0
Config Oena = Output
Sdi Alias Portc.1
Config Sdi = Output
Clk Alias Portc.2
Config Clk = Output
Lena Alias Portc.3
Config Lena = Output
#endif

Set Clk
Reset Lena
Reset Oena
Reset Sdi

'Encoder
#if Vhw = 1
Swenc Alias Pinc.0
Config Swenc = Input
Set Portc.0

Set Portc.1
Set Portc.2
#endif

#if Vhw = 2
Swenc Alias Pind.5
Config Swenc = Input
Set Portd.5

Set Portc.1
Set Portc.2
#endif

#if Vhw = 3
Swenc Alias Pinb.5
Config Swenc = Input
Set Portb.5

Set Portb.3
Set Portb.4
#endif


'Configuración de Interrupciones
'TIMER0
Config Timer0 = Timer , Prescale = 256                      'Ints a 100Hz
On Timer0 Int_timer0
Enable Timer0
Start Timer0

'TIMER1
Config Timer1 = Timer , Prescale = 1024                     'Ints a 1 Hz
On Timer1 Int_timer1
Enable Timer1
Start Timer1

'TIMER2
Config Timer2 = Timer , Prescale = 1024                      'Ints a 480Hz
On Timer2 Int_timer2
Enable Timer2
Start Timer2

' Puerto serial 1
Open "com1:" For Binary As #1
On Urxc At_ser1
Enable Urxc

'***Date/Time***
Dim Dummy As Byte
Config Date = Dmy , Separator = /

Config Clock = User
#if Modrtc = 1
Config Sda = PortC.4
Config Scl = Portc.5
Config I2cdelay = 10
I2cinit
#endif

Enable Interrupts


'*******************************************************************************
'* Archivos incluidos
'*******************************************************************************
$include "CLK_archivos.bas"



'Programa principal

Call Inivar()

#if Modrtc = 1
print #1, "Ver CLK"
estado_led=3
Call Leer_rtc()


If Err = 0 Then
   Print #1 , "RTC Hora=" ; Time$ ; ",Fecha=" ; Date$
   Tmpl2 = Syssec()
   If Tmpl2 > 598798055 Then
      Print #1 , "Hora valida, no es necesario ACTCLK"
      Estado_led = 1
      Set Actclk
   End If
Else
   Print # 1 , "ERROR CLK"
   Estado_led = 3
   Tmpb = 0
   Do
      If Sernew = 1 Then                                    'DATOS SERIAL 1
         Reset Sernew
         Print #1 , "SER1=" ; Serproc
         Call Procser()
      End If
      If Newseg = 1 Then
         Reset Newseg
         Incr Tmpb
         Tmpb = Tmpb Mod 10
         If Tmpb = 0 Then
            Print #1 , "Ingrese la hora manualmente"
         End If
      End If
   Loop Until Actclk = 1
   Estado_led = 1
End If
#endif
Print #1 , "INI"
'Enable Timer0
'Start Timer0


Do

   If Sernew = 1 Then                                       'DATOS SERIAL 1
      Reset Sernew
      Print #1 , "SER1=" ; Serproc
      Call Procser()
   End If

   If Swenc = 0 Then
      Waitms 100
      If Swenc = 0 Then
         Print #1 , "SW"
         Call Menu()
      End If
   End If

   If Newseg = 1 Then
      Reset Newseg
      Tmptime = Time$
      Call Disptime()
   End If

#if Modrtc = 1
   If Newactclk = 1 Then
      Reset Newactclk
      Call Leer_rtc()
   End If
#endif
Loop