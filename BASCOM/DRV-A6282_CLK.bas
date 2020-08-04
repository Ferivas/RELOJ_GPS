'Main.bas
'
'                 WATCHING Soluciones Tecnológicas
'                    Fernando Vásquez - 25.06.15
'
' Programa para almacenar los datos que se reciben por el puerto serial a una
' memoria SD
'


$version 0 , 1 , 140
$regfile = "m328pbdef.dat"
$crystal = 18432000
$baud = 9600


$hwstack = 152
$swstack = 152
$framesize = 152
$projecttime = 91


'Declaracion de constantes
Const Nummatriz = 5                                         'Una matriz esunmodulo P10 de 16x32
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
Led1 Alias Portc.4                                          'LED ROJO
Config Led1 = Output

'PINES interfaz
Clk Alias Portc.3
Config Clk = Output
Lena Alias Portc.0
Config Lena = Output
Oena Alias Portc.1
Config Oena = Output
Sdi Alias Portc.2
Config sdi = Output

Set Clk
Reset Lena
Reset Oena
Reset Sdi

'Configuración de Interrupciones
'TIMER0
Config Timer0 = Timer , Prescale = 1024                     'Ints a 100Hz
On Timer0 Int_timer0
Enable Timer0
Start Timer0

'TIMER1
Config Timer1 = Timer , Prescale = 1024                     'Ints a 1 Hz
On Timer1 Int_timer1
Enable Timer1
Start Timer1

'TIMER2
Config Timer2 = Timer , Prescale = 256                      'Ints a 480Hz
On Timer2 Int_timer2
'Enable Timer2
'Start Timer2

' Puerto serial 1
Open "com1:" For Binary As #1
On Urxc At_ser1
Enable Urxc

'***Date/Time***
Dim Dummy As Byte
Config Date = Dmy , Separator = /
Config Clock = User

Config Sda = Portb.5
Config Scl = Portb.4
Config I2cdelay = 10
I2cinit

Enable Interrupts


'*******************************************************************************
'* Archivos incluidos
'*******************************************************************************
$include "DRV-A6282_clk_archivos.bas"



'Programa principal

Call Inivar()

print #1, "Ver CLK"
estado_led=3
'Call Getdatetimeds3231()

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

Enable Timer2
Start Timer2


Do

   If Sernew = 1 Then                                       'DATOS SERIAL 1
      Reset Sernew
      Print #1 , "SER1=" ; Serproc
      Call Procser()
   End If

   If Newseg = 1 Then
      Reset Newseg
      Tmptime = Time$

      Tmpstr = Mid(tmptime , 1 , 1)
      Tmpb = Val(tmpstr)
      Call Gendig(tmpb , 0)

      Tmpstr = Mid(tmptime , 2 , 1)
      Tmpb = Val(tmpstr)
      Call Gendig(tmpb , 1)

      Tmpstr = Mid(tmptime , 4 , 1)
      Tmpb = Val(tmpstr)
      Call Gendig(tmpb , 2)

      Tmpstr = Mid(tmptime , 5 , 1)
      Tmpb = Val(tmpstr)
      Call Gendig(tmpb , 3)

      Tmpstr = Mid(tmptime , 7 , 1)
      Tmpb = Val(tmpstr)
      Call Gendigp(tmpb , 0)

      Tmpstr = Mid(tmptime , 8 , 1)
      Tmpb = Val(tmpstr)
      Call Gendigp(tmpb , 1)

      Buffram(15)=&h66
      'Print #1 , Time$
   End If

   If Newactclk = 1 Then
      Reset Newactclk
      Call Leer_rtc()

   End If
Loop