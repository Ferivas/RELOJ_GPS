'Main.bas
'
'                 WATCHING Soluciones Tecnológicas
'                    Fernando Vásquez - 25.06.15
'
' Programa para almacenar los datos que se reciben por el puerto serial a una
' memoria SD
'


$version 0 , 1 , 41
$regfile = "m1284pdef.dat"
$crystal = 18432000
$baud = 9600


$hwstack = 120
$swstack = 120
$framesize = 120
$projecttime = 33


'Declaracion de constantes
Const Nummatriz = 2                                         'Una matriz esunmodulo P10 de 16x32
Const Longbuf = Nummatriz * 64
Const Longdat = Nummatriz * 32
Const Longdat_mas_uno = Longdat + 1
Const Longbuf_mas_uno = Longbuf + 1
Const Numtxser = Longbuf / 4
Const Numtxser_2 = Numtxser / 2



'Configuracion de entradas/salidas
Led1 Alias Portd.5                                          'LED ROJO
Config Led1 = Output

'PINES interfaz
Clk Alias Portc.4
Config Clk = Output
Lena Alias Portc.3
Config Lena = Output
Oena Alias Porta.5
Config Oena = Output
Sdi Alias Portc.5
Config Oena = Output

Set Clk
Reset Lena
Reset Oena
Reset Sdi

'Configuración de Interrupciones
'TIMER0
Config Timer0 = Timer , Prescale = 1024                     'Ints a 100Hz si Timer0=184
On Timer0 Int_timer0
Enable Timer0
Start Timer0

'TIMER2
Config Timer2 = Timer , Prescale = 128                      'Ints a 100Hz si Timer0=184
On Timer2 Int_timer2
Enable Timer2
Start Timer2

' Puerto serial 1
Open "com1:" For Binary As #1
On Urxc At_ser1
Enable Urxc

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

Loop