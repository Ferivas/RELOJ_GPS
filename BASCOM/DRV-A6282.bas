'Main.bas
'
'                 WATCHING Soluciones Tecnológicas
'                    Fernando Vásquez - 25.06.15
'
' Programa para almacenar los datos que se reciben por el puerto serial a una
' memoria SD
'


$version 0 , 1 , 119
$regfile = "m328pbdef.dat"
$crystal = 18432000
$baud = 9600


$hwstack = 120
$swstack = 120
$framesize = 120
$projecttime = 65


'Declaracion de constantes
Const Nummatriz = 5                                         'Una matriz esunmodulo P10 de 16x32
Const Longbuf = Nummatriz * 8
Const Longbuf_masuno = Longbuf + 1
Const Msb_l = 0
Const Msb_h = 1
Const Lsb_l = 2
Const Lsb_h = 3

Const Opcion = Lsb_h

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
Config Timer2 = Timer , Prescale = 128                      'Ints a 1000Hz
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

Enable Interrupts


'*******************************************************************************
'* Archivos incluidos
'*******************************************************************************
$include "DRV-A6282_archivos.bas"



'Programa principal

Call Inivar()


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

Loop