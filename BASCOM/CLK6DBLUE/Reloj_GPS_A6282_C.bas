'RELOJgps.bas - Programa para implementar RELOJgps
'
'
'                 WATCHING Soluciones Tecnológicas
'                    Fernando Vásquez
'                    Sandro Montesdeoca - 29.02.2012
'
'  RELOJgps: Manejo de driver Allegro A6276
'
'
'Configuración del microcontrolador


$regfile = "m644pdef.dat"
$crystal = 11059200
$baud = 4800
$baud1 = 4800
$hwstack = 200
$swstack = 200
$framesize = 200


Config Date = Dmy , Separator = /
Config Clock = Soft , Gosub = Sectic

Enable Interrupts
On Urxc Int_ser1
Enable Urxc

Enable Timer0

Config Timer0 = Timer , Prescale = 256                      'Ints cada 0.5seg con Timer1=7936 en int
On Timer0 Inttim0
Start Timer0

Config Adc = Single , Prescaler = Auto                      ', Reference = Internal
Start Adc

'DECLARACION DE FUNCIONES Y SUBRUTINAS
'******************************************************************************
Declare Sub Pintar(byval D_time1 As Byte , Byval D_time2 As Byte)
Declare Sub Gps_rx()

'DECLARACION DE VARIABLES
'******************************************************************************

Datos Alias Portb.0
Config Datos = Output
Clk Alias Portb.1
Config Clk = Output
Le Alias Portb.2
Config Le = Output
Oena Alias Portb.3
Config Oena = Output
Enc0 Alias Portc.0
Config Enc0 = Output
Enc1 Alias Portc.1
Config Enc1 = Output
Enc2 Alias Portc.2
Config Enc2 = Output



Dim Red As Byte
Dim Green As Byte

Dim Aux As Byte
Dim Contador As Byte
Dim Lsyssec As Long

Dim Strdate As String * 8
Dim Strtime As String * 8
Dim Hora As Byte
Dim Minuto As Byte
Dim Segundo As Byte
Dim S_dec As Byte
Dim S_uni As Byte
Dim M_dec As Byte
Dim M_uni As Byte
Dim H_dec As Byte
Dim H_uni As Byte
Dim Newsec As Bit
Dim Flag_hora As Bit
Dim Slot As Byte
Dim Inten_cuadro0 As Byte
Dim Inten_cuadro1 As Byte
Dim Inten_cuadro2 As Byte
Dim Intensidad As Byte

'VARIABLES PARA LA RECEPCION DE DATOS DEL GPS
Dim Mdcrx As Byte
Dim Mdcproc As String * 200
Dim Mdc_ini As Bit
Dim Mdcdata As String * 200
Dim Gpsnew As Bit
Dim Gpsdata As Bit
Dim Hora_gps As String * 6
Dim Time_gps As String * 8
Dim Igualar As Bit
Dim Tmpl As Long
Dim Puntos As Bit
Dim Sincronizado As Bit
Dim Header As String * 5
Dim Active As String * 1
Dim Tiempo_igualar As Long

'Variables para el ADC
Dim Valor_adc As Word
Dim Leer_adc As Bit
Dim Contar_seg_adc As Word
Dim Avg_adc As Single
Dim Trama_gprmc As String * 200

Const Tiempo_igualar1 = 86400                               '86400segundos de 24 horas



' Programa Principal
'*******************************************************************************

Print "************ Reloj GPS *************"
Print Version(1)
Print "**Watching Soluciones Tecnológicas**"

Reset Enc0
Reset Enc1
Reset Enc2


Slot = 0
Inten_cuadro0 = 3
Inten_cuadro1 = Inten_cuadro0 + 8
Inten_cuadro2 = Inten_cuadro0 + 16

Set Igualar

Inten_cuadro0 = 7
Do

   If Gpsnew = 1 Then
      Reset Gpsnew
      Call Gps_rx()

   End If

'   If Gpsnew = 1 Then
'      Header = Mid(mdcproc , 1 , 5 )
'      If Header = "GPRMC" Then
'         Trama_gprmc = Mdcproc
'         Active = Mid(trama_gprmc , 14 , 1 )
'         If Active = "V" Then
'            Set Igualar
'         End If

'      End If
'      Reset Gpsnew
'      If Igualar = 1 Then
'         Call Gps_rx()
'      End If
'   End If


   If Newsec = 1 Then
   'Segmento para obtener los digitos en el diplay.

      Reset Newsec
      Segundo = Makebcd(_sec)
      S_uni = Segundo And &H0F
      Swap Segundo
      S_dec = Segundo And &H0F
      Minuto = Makebcd(_min)
      M_uni = Minuto And &H0F
      Swap Minuto
      M_dec = Minuto And &H0F
      Hora = Makebcd(_hour)
      H_uni = Hora And &H0F
      Swap Hora
      H_dec = Hora And &H0F
      Incr Contar_seg_adc
      If Contar_seg_adc = 30 Then Set Leer_adc
      Valor_adc = Getadc(0)
      Avg_adc = Avg_adc + Valor_adc
    End If
'    If Leer_adc = 1 Then
'      Print "$" ; Trama_gprmc
'      Reset Leer_adc
'      Avg_adc = Avg_adc / Contar_seg_adc
'      Select Case Avg_adc
'         Case Is > 1006
'            Inten_cuadro0 = 1
'         Case Is > 990
'            Inten_cuadro0 = 2
'         Case Is > 974
'            Inten_cuadro0 = 3
'         Case Is > 958
'            Inten_cuadro0 = 4
'         Case Is > 942
'            Inten_cuadro0 = 5
'         Case Is > 926
'            Inten_cuadro0 = 6
'         Case Is < 926
'            Inten_cuadro0 = 7
'      End Select
'      Avg_adc = 0
'      Contar_seg_adc = 0
'      Inten_cuadro0 = 7

'      Inten_cuadro1 = Inten_cuadro0 + 8
'      Inten_cuadro2 = Inten_cuadro0 + 16
'    End If

Loop

' Subrutina de atencion a la interrupción del TIMER0
'*******************************************************************************
Inttim0:
   Timer0 = &HFC
   Select Case Slot
      Case 0
         Set Enc0
         Call Pintar(m_dec , M_uni)
      Case Inten_cuadro0
         Set Oena
         Reset Enc0
      Case 8
         Set Enc1
         Call Pintar(h_dec , H_uni)
      Case Inten_cuadro1
         Set Oena
         Reset Enc1
      Case 16
         Set Enc2
         Call Pintar(s_uni , S_dec )
      Case Inten_cuadro2
         Set Oena
         Reset Enc2
      Case 24
         Slot = 255
         Reset Enc0
         Reset Enc1
         Reset Enc2
   End Select

   Incr Slot
Return

' Subrutina de atencion a la interrupción del TIMER2
'*******************************************************************************
Sectic:
   Set Newsec
   Lsyssec = Syssec()
   Tmpl = Lsyssec Mod Tiempo_igualar
   If Tmpl = 0 Then
      Set Igualar
      Reset Sincronizado
   End If
   If Sincronizado = 0 Then
      Toggle Puntos
   Else
      Set Puntos
   End If
Return

' Subrutina para Pintar los digitos del reloj: Entrada Digito1=D_time1, Digito2=D_time1
'**************************************************************************************

Sub Pintar(byval D_time1 As Byte , Byval D_time2 As Byte)
   Set Oena
   If Enc1 = 1 Then
      If Puntos = 1 Then
         Red = Lookup(d_time1 , Dec_hora1)
      Else
         Red = Lookup(d_time1 , Dec_hora0)
      End If
   Else
      Red = Lookup(d_time1 , Digitos)
   End If
   Shiftout Datos , Clk , Red , 0
   Green = Lookup(d_time2 , Digitos)
   Shiftout Datos , Clk , Green , 0
   Set Le
   Reset Le
   Reset Oena
End Sub


'Subrutina de atencion a la interrupcion serial
'*******************************************************************************
Int_ser1:
   Mdcrx = Udr
   Select Case Mdcrx
      Case "$":
         Mdc_ini = 1
         Mdcdata = ""
         Set Gpsdata
      Case 13:
         If Mdc_ini = 1 Then
            Mdc_ini = 0
            Mdcdata = Mdcdata + Chr(0)
            Mdcproc = Mdcdata
            Mdcdata = ""
            Set Gpsnew
         End If
      Case Is > 31
         If Mdc_ini = 1 Then
            Mdcdata = Mdcdata + Chr(mdcrx)
         End If
   End Select

Return

'Subrutina para sincronizar la hora con la señal GPS
'*******************************************************************************
Sub Gps_rx()
   If Mid(mdcproc , 1 , 5) = "GPRMC" Then
      Hora_gps = Mid(mdcproc , 7 , 6)
      Time_gps = Mid(hora_gps , 1 , 2) + ":" + Mid(hora_gps , 3 , 2) + ":" + Mid(hora_gps , 5 , 2)
      Time$ = Time_gps
      Lsyssec = Syssec() - 18000
      Time$ = Time(lsyssec)
      Set Sincronizado
      Reset Igualar
   End If
End Sub
'*******************************************************************************

'TABLAS DE DATOS
'*******************************************************************************

Digitos:
Data &H3F , &H06 , &H5B , &H4F , &H66 , &H6D , &H7D , &H07 , &H7F , &H67

Dec_hora1:
Data &H20 , &H26 , &H7B

Dec_hora0:
Data &H0 , &H6 , &H5B