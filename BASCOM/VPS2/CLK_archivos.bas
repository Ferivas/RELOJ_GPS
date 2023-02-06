'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'*  SD_Archivos.bas                                                        *
'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'*                                                                             *
'*  Variables, Subrutinas y Funciones                                          *
'* WATCHING SOLUCIONES TECNOLOGICAS                                            *
'* 25.06.2015                                                                  *
'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

$nocompile
$projecttime = 430


'*******************************************************************************
'Declaracion de subrutinas
'*******************************************************************************
Declare Sub Inivar()
Declare Sub Procser()
Declare Sub Gendig(byval Valdig As Byte , Byval Posdig As Byte)
'Declare Sub Gendigp(byval Valdig As Byte , Byval Posdig As Byte)

Declare Sub Menu()
Declare Sub Lee_enc()
Declare Sub Gentmptime()
Declare Sub Disptime()

'RTC
#if Modrtc = 1
Declare Sub Getdatetimeds3231()
Declare Sub Error(byval Genre As Byte)
Declare Sub Setdateds3231()
Declare Sub Settimeds3231()
Declare Sub Leer_rtc()
#endif


'*******************************************************************************
'Declaracion de variables
'*******************************************************************************
Dim Tmpb As Byte
Dim Tmpb2 As Byte
Dim Tmpl2 As Long
Dim Cntrtime As Byte

Dim Cmdtmp As String * 6
Dim Atsnd As String * 120
Dim Cmderr As Byte
Dim Tmpstr8 As String * 16
Dim Tmpstr52 As String * 52


'Matriz
Dim Dato8 As Byte
Dim Dato16 As Word
Dim Datocol As Byte
Dim Buffram(longbuf) As Byte
'Dim Tmptx As Byte
Dim Cntr_col As Byte
'Dim Kk As Byte
'Dim Ptrcol As Byte
Dim Ptrdig As Byte
Dim Ptrpos As Byte
Dim Tmptime As String * 10
Dim Tmpstr As String * 2

'Encoder
Dim Varenc As Byte
Dim Cntrenc As Byte
Dim Cntrencant As Byte
Dim Tmpstrmenu As String * 5
Dim Giroenc As Byte
Dim Tmpenc As Byte
Dim Indmenu As Byte
Dim Ptrmenu As Byte
Dim Finmenu As Bit
Dim Cntrd As Byte
Dim Hora As Byte
Dim Minu As Byte
Dim Segundo As Byte

'RTC
Dim Dow As Byte
Dim Actclk As Bit
Dim Newactclk As Bit
Dim Cntrseg As word
Dim Topseg As Word

'Variables TIMER0
Dim T0c As Byte
Dim Num_ventana As Byte
Dim Estado As Long
Dim Estado_led As Byte
Dim Iluminar As Bit

'TIMER1
Dim Tmpltime As Long
Dim Tmpsec As String * 10
Dim Newseg As Bit

Dim Horamin As Long
Dim Horamineep As Eram Long

Dim Topsegeep As Eram Word

dim cntrini as word
dim cntrinieep as eram word
'TIMER 2
Dim T0cntr As Word
Dim T0tout As Bit , T0ini As Bit
Dim T0rate As Word

'Variables SERIAL0
Dim Ser_ini As Bit , Sernew As Bit
Dim Numpar As Byte
Dim Cmdsplit(4) As String * 20
Dim Serdata As String * 120 , Serrx As Byte , Serproc As String * 120



'*******************************************************************************
'* END public part                                                             *
'*******************************************************************************


Goto Loaded_arch

'*******************************************************************************
' INTERRUPCIONES
'*******************************************************************************

'*******************************************************************************
' Subrutina interrupcion de puerto serial 1
'*******************************************************************************
At_ser1:
   Serrx = Udr

   Select Case Serrx
      Case "$":
         Ser_ini = 1
         Serdata = ""

      Case 13:
         If Ser_ini = 1 Then
            Ser_ini = 0
            Serdata = Serdata + Chr(0)
            Serproc = Serdata
            Sernew = 1
         End If

      Case Is > 31
         If Ser_ini = 1 Then
            Serdata = Serdata + Chr(serrx)
         End If

   End Select

Return



'*******************************************************************************



'*******************************************************************************
' TIMER0
'*******************************************************************************
Int_timer0:
   'Timer0 = &H98                                            '600 Hz con 12MHz
   Timer0 = &HD0
   Incr T0c
   T0c = T0c Mod 200
   If T0c = 0 Then
      Toggle led1
   End If

   Set Oena                                                 ' Apago driver
   Incr Cntr_col
   Datocol = Lookup(cntr_col , Tbl_col)

   Dato8 = 0
   Dato16 = Makeint(datocol , Dato8)
   Shiftout Sdi , Clk , Dato16 , Opcion
   Shiftout Sdi , Clk , Dato16 , Opcion
   Shiftout Sdi , Clk , Dato16 , Opcion
   Shiftout Sdi , Clk , Dato16 , Opcion
   'Shiftout Sdi , Clk , Dato16 , Opcion
   Set Lena
   Reset Lena

   Dato8 = Buffram(cntr_col)
   Dato16 = Makeint(datocol , Dato8)
   Shiftout Sdi , Clk , Dato16 , Opcion

   Dato8 = Buffram(cntr_col + 8)
   Dato16 = Makeint(datocol , Dato8)
   Shiftout Sdi , Clk , Dato16 , Opcion

   Dato8 = Buffram(cntr_col + 16)
   Dato16 = Makeint(datocol , Dato8)
   Shiftout Sdi , Clk , Dato16 , Opcion

   Dato8 = Buffram(cntr_col + 24)
   Dato16 = Makeint(datocol , Dato8)
   Shiftout Sdi , Clk , Dato16 , Opcion

   'Dato8 = Buffram(cntr_col + 32)
   'Dato16 = Makeint(datocol , Dato8)
   'Shiftout Sdi , Clk , Dato16 , Opcion

   Set Lena
   Reset Lena
   Cntr_col = Cntr_col Mod 8
   nop
   nop
'   nop
'   nop
'   nop
   Reset Oena


Return


Int_timer1:
   'Timer1 = &HC2F7
   Timer1 = &HE3E0

   Tmpltime = Syssec()

   Incr Tmpltime

   Tmpsec = Time(tmpltime)
   Time$ = Tmpsec
   Tmpsec = Date(tmpltime)
   Date$ = Tmpsec

   Set Newseg
   Incr Cntrseg
   Cntrseg = Cntrseg Mod Topseg
   If Cntrseg = 0 Then
      Set Newactclk
   End If
Return


'*******************************************************************************
' TIMER2
'*******************************************************************************
Int_timer2:
   'Timer2 = &H64                                            '100.1603 Hz
   Timer2 = &HB8                                            '100 Hz CON 7.3728MHz
   If T0ini = 1 Then
      Incr T0cntr
      If T0cntr = T0rate Then
         Set T0tout
      End If
   Else
      T0cntr = 0
   End If

RETURN


Settime:
Return

Getdatetime:
Return

Setdate:
Return

Movizq:
   Decr Cntrenc
Return

Movder:
   Incr Cntrenc
Return



'*******************************************************************************
' SUBRUTINAS
'*******************************************************************************

'*******************************************************************************
' Inicialización de variables
'*******************************************************************************
Sub Inivar()
   Reset Led1
   Tmptime = "00:00:00"
   Call Disptime()
  ' Print #1 , "************ MAINSERLED M8 ************"
   Print #1 , Version(1)
   Print #1 , Version(2)
   Print #1 , Version(3)
   Estado_led = 1
   'Print #1 , "Nummatriz=" ; Nummatriz
   'Print #1 , "Longbuf=" ; Longbuf

'   For Tmpb = 1 To Longbuf
'      Buffram(tmpb) = 0
'   Next

'   For Tmpb = 0 To 3
'       Call Gendig(tmpb , Tmpb)
'   Next

   Horamin = Horamineep

   Print #1 , "Last act CLK " ; Date(horamin) ; "," ; Time(horamin)
   'Tmplntp = Syssec(horamin)
   Tmpstr8 = Time(horamin)

   Time$ = Tmpstr8
   'Print #1 , "Ts:" ; Tmpstr8 ; " T:" ; Time$
   Tmpstr8 = Date(horamin)
   Date$ = Tmpstr8
   'Print #1 , "Ds:" ; Tmpstr8 ; " D:" ; Date$
   'Print #1 , "H:" ; Time$ ; " D:" ; Date$

   Topseg = Topsegeep
   Print #1 , "Topseg=" ; Topseg
   cntrini=cntrinieep
   incr cntrini
   Cntrinieep = Cntrini
   print #1, "CNTRINI=";CNTRINI
   Set Newseg

End Sub


'*******************************************************************************
' Genera digitos 6x8 en posicion determinada
'*******************************************************************************


Sub Gendig(byval Valdig As Byte , Byval Posdig As Byte)
   Local Kt As Byte
   Local Ptr As Byte
   Local Tmpb22 As Byte
   Local Tmpw2 As Word
   Ptrdig = Valdig * 6
   'Posdig = Posdig - 1
   Ptrpos = Lookup(posdig , Tbl_posdig)
   'Print #1 , "Ptrpos=" ; Ptrpos

   For Kt = 0 To 5
'      K = Kt - 1
      Tmpw2 = Ptrdig + Kt
      Tmpb22 = Lookup(tmpw2 , Tbl_dig)
      Ptr = Ptrpos + Kt
      Buffram(ptr) = Tmpb22
      'Print #1 , "B(" ; Ptr ; ")=" ; Bin(tmpb22)
   Next

End Sub


'*******************************************************************************
' Genera digitos 4x6 en posicion determinada
'*******************************************************************************


'Sub Gendigp(byval Valdig As Byte , Byval Posdig As Byte)
'   Local Kt As Byte
'   Local Ptr As Byte
'   Local Tmpb22 As Byte
'   Local Tmpw2 As Word
'   Ptrdig = Valdig * 4
'   Ptrpos = Lookup(posdig , Tbl_posdigp)

'   For Kt = 0 To 3
'      Tmpw2 = Ptrdig + Kt
'      Tmpb22 = Lookup(tmpw2 , Tbl_digp)
'      Ptr = Ptrpos + Kt
'      Buffram(ptr) = Tmpb22
'   Next

'End Sub


'*******************************************************************************
' ENCODER
'*******************************************************************************
Sub Menu()
   Print #1 , "INI Menu"
   Tmptime = Time$
   Tmpstr = Mid(tmptime , 1 , 2)
   Hora = Val(tmpstr)
   Tmpstr = Mid(tmptime , 4 , 2)
   Minu = Val(tmpstr)
   Tmpstr = Mid(tmptime , 7 , 2)
   Segundo = Val(tmpstr)
   Print #1 , Tmptime
   Print #1 , "H=" ; Hora ; ", M=" ; Minu ; ", S=" ; Segundo

   T0rate = 1000
   T0cntr = 0
   Set T0ini
   Reset T0tout
   Cls
   Cntrenc = 0
   'Ptrmenu = Numvar_masuno
   Ptrmenu = 0
   Tmpstrmenu = ""
   Indmenu = 0
   Giroenc = 0
   Do
      Call Lee_enc()

      If Giroenc = 2 Then
         T0cntr = 0
         Giroenc = 0
         Select Case Ptrmenu
            Case 0:
               Incr Hora
               Hora = Hora Mod 24
            Case 1:
               Incr Minu
               Minu = Minu Mod 60

            Case 2:
               Incr Segundo
               Segundo = Segundo Mod 60
         End Select
         Call Gentmptime()
         Set Newseg
         Cntrd = 0
      End If

      If Giroenc = 1 Then
         T0cntr = 0
         Giroenc = 0
         Select Case Ptrmenu
            Case 0:
               Decr Hora
               Hora = Hora Mod 24
            Case 1:
               Decr Minu
               Minu = Minu Mod 60

            Case 2:
               Decr Segundo
               Segundo = Segundo Mod 60
         End Select
         Call Gentmptime()
         Set Newseg
         Cntrd = 0
      End If

      If Newseg = 1 Then
         Reset Newseg
         Incr Cntrd
         If Cntrd.0 = 0 Then
            Select Case Ptrmenu
               Case 0:
                  Call Gendig(10 , 0)
                  Call Gendig(10 , 1)

               Case 1:
                  Call Gendig(10 , 2)
                  Call Gendig(10 , 3)

'               Case 2:
'                  Call Gendigp(10 , 0)
'                  Call Gendigp(10 , 1)

            End Select
         Else
            Select Case Ptrmenu
               Case 0:
                  Tmpstr = Mid(tmptime , 1 , 1)
                  Tmpb = Val(tmpstr)
                  Call Gendig(tmpb , 0)

                  Tmpstr = Mid(tmptime , 2 , 1)
                  Tmpb = Val(tmpstr)
                  Call Gendig(tmpb , 1)

               Case 1:
                  Tmpstr = Mid(tmptime , 4 , 1)
                  Tmpb = Val(tmpstr)
                  Call Gendig(tmpb , 2)

                  Tmpstr = Mid(tmptime , 5 , 1)
                  Tmpb = Val(tmpstr)
                  Call Gendig(tmpb , 3)
'               Case 2:
'                  Tmpstr = Mid(tmptime , 7 , 1)
'                  Tmpb = Val(tmpstr)
'                  Call Gendigp(tmpb , 0)

'                  Tmpstr = Mid(tmptime , 8 , 1)
'                  Tmpb = Val(tmpstr)
'                  Call Gendigp(tmpb , 1)
            End Select

         End If
      End If
      If Swenc = 0 Then
         Waitms 200
         If Swenc = 0 Then
            Call Gentmptime()
            Call Disptime()
            T0cntr = 0
            Incr Ptrmenu
            Ptrmenu = Ptrmenu Mod 3
            Print #1 , "PTR=" ; Ptrmenu
            If Ptrmenu = 2 Then
               Set Finmenu
               Time$ = Tmptime
               Horamin = Syssec()
               Horamineep = Horamin
            End If
         End If
      End If
   Loop Until Finmenu = 1 Or T0tout = 1
   Print #1 , "FIN Menu"
   Reset Finmenu
End Sub

Sub Lee_enc()
#if Vhw = 1
   Varenc = Encoder(pinc.1 , Pinc.2 , Movizq , Movder , 0)
#endif

#if Vhw = 2
   Varenc = Encoder(pinc.2 , Pinc.1 , Movizq , Movder , 0)
#endif
   Varenc = Encoder(pinb.4 , Pinb.3 , Movizq , Movder , 0)
   If Cntrenc <> Cntrencant Then
      Cntrencant = Cntrenc
      Tmpenc = Cntrenc Mod 4
      Tmpstrmenu = Tmpstrmenu + Str(tmpenc)
      'T0cntr = 0
      If Len(tmpstrmenu) = 4 Then
         If Tmpstrmenu = "0123" Or Tmpstrmenu = "1230" Or Tmpstrmenu = "2301" Or Tmpstrmenu = "3012" Then
            Giroenc = 1
         End If
         If Tmpstrmenu = "3210" Or Tmpstrmenu = "2103" Or Tmpstrmenu = "1032" Or Tmpstrmenu = "0321" Then
            Giroenc = 2
         End If
         Print #1 , "G=" ; Giroenc
         Tmpstrmenu = ""
      End If
   End If
End Sub

Sub Gentmptime()
   Tmptime = ""
   If Hora < 10 Then
      Tmptime = "0" + Str(hora)
   Else
      Tmptime = Str(hora)
   End If
   Tmptime = Tmptime + ":"
   If Minu < 10 Then
      Tmptime = Tmptime + "0" + Str(minu)
   Else
      Tmptime = Tmptime + Str(minu)
   End If
   Tmptime = Tmptime + ":"
   If Segundo < 10 Then
      Tmptime = Tmptime + "0" + Str(segundo)
   Else
      Tmptime = Tmptime + Str(segundo)
   End If
   Print #1 , "Tc=" ; Tmptime
End Sub

Sub Disptime()
   'Tmptime = Time$
   Incr Cntrtime

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

'   Tmpstr = Mid(tmptime , 7 , 1)
'   Tmpb = Val(tmpstr)
'   Call Gendigp(tmpb , 0)

'   Tmpstr = Mid(tmptime , 8 , 1)
'   Tmpb = Val(tmpstr)
'   Call Gendigp(tmpb , 1)

   If Cntrtime.0 = 1 Then                                   'aQUI SE GENERAN LOS DOS PUNTOS INTERMITENTES
      Buffram(16) = &H66
      Buffram(17) = &H66
   Else
      Buffram(16) = &H00
      Buffram(17) = &H00
   End If
End Sub

'*******************************************************************************
' Procesamiento de comandos
'*******************************************************************************
Sub Procser()
   Print #1 , "$" ; Serproc
   Tmpstr52 = Mid(serproc , 1 , 6)
   Numpar = Split(serproc , Cmdsplit(1) , ",")
   If Numpar > 0 Then
      For Tmpb = 1 To Numpar
         Print #1 , Tmpb ; ":" ; Cmdsplit(tmpb)
      Next
   End If

   If Len(cmdsplit(1)) = 6 Then
      Cmdtmp = Cmdsplit(1)
      Cmdtmp = Ucase(cmdtmp)
      Cmderr = 255
      Select Case Cmdtmp
'(
         Case "LEEVFW"
            Cmderr = 0
            Atsnd = "Version FW: Fecha <"
            Tmpstr52 = Version(1)
            Atsnd = Atsnd + Tmpstr52 + ">, Archivo <"
            Tmpstr52 = Version(3)
            Atsnd = Atsnd + Tmpstr52 + ">"


         Case "SETLED"
            If Numpar = 2 Then
               Tmpb = Val(cmdsplit(2))
               If Tmpb < 17 Then
                  Cmderr = 0
                  Atsnd = "Se configura setled a " + Str(tmpb)
                  Estado_led = Tmpb
               Else
                  Cmderr = 5
               End If

            Else
               Cmderr = 4
            End If


         Case "SETBUF"
            If Numpar = 3 Then
               Tmpb = Val(cmdsplit(2))
               If Tmpb > 0 And Tmpb < Longbuf_masuno Then
                  Cmderr = 0
                  Buffram(tmpb) = Hexval(cmdsplit(3))
                  Atsnd = "Se configuro Buffram(" + Str(tmpb) + ") a" + Hex(buffram(tmpb))
               Else
                  Cmderr = 4
               End If
            Else
               Cmderr = 5
            End If

         Case "LEEBUF"
            If Numpar = 1 Then
               Cmderr = 0
               For Tmpb = 1 To Longbuf
                  Print #1 , Tmpb ; "," ; Hex(buffram(tmpb))
               Next
               Atsnd = "Buffram"
            Elseif Numpar = 2 Then
               Cmderr = 0
               Tmpb = Val(cmdsplit(2))
               If Tmpb > 0 And Tmpb < Longbuf_masuno Then
                  Cmderr = 0
                  Buffram(tmpb) = Hexval(cmdsplit(3))
                  Atsnd = "Se configuro Buffram(" + Str(tmpb) + ") a" + Hex(buffram(tmpb))
                  Call Gendig(tmpb , Tmpb2)
               Else
                  Cmderr = 4
               End If
            Else
               Cmderr = 5
            End If

         Case "SETCER"
            Cmderr = 0
            Atsnd = "Buffram a cero"
            For Tmpb = 1 To Longbuf
               Buffram(tmpb) = 0
            Next

         case "SETDIG"
            If Numpar = 3 Then
               tmpb=val(cmdsplit(2))
               if tmpb<11 then
                  tmpb2=val(cmdsplit(3))
                  If Tmpb2 < 5 Then
                     cmderr=0
                     atsnd="Set digito "+str(tmpb)+ "en pos "+str(tmpb2)
                     Call Gendig(tmpb , Tmpb2)
                  Else
                    Cmderr = 6
                  End If
               Else
                  Cmderr = 4
               End If
            Else
               Cmderr = 5
            End If

'         Case "SETDIP"
'            If Numpar = 3 Then
'               tmpb=val(cmdsplit(2))
'               if tmpb<11 then
'                  tmpb2=val(cmdsplit(3))
'                  If Tmpb2 < 2 Then
'                     cmderr=0
'                     Atsnd = "Set digito p " + Str(tmpb) + "en pos " + Str(tmpb2)
'                     Call Gendigp(tmpb , Tmpb2)
'                  Else
'                    Cmderr = 6
'                  End If
'               Else
'                  Cmderr = 4
'               End If
'            Else
'               Cmderr = 5
'            End If

')
            Case "SETCLK"
               If Numpar = 2 Then
                  Cmderr = 0
                  Tmpstr52 = Cmdsplit(2)
                  If Len(tmpstr52) = 12 Then
                     Tmpstr8 = Mid(tmpstr52 , 7 , 2) + "/" + Mid(tmpstr52 , 9 , 2) + "/" + Mid(tmpstr52 , 11 , 2)
                     'Print #1 , Tmpstr8
                     Time$ = Tmpstr8
                     'Print #1 , "T>" ; Time$
                     Tmpstr8 = Mid(tmpstr52 , 1 , 2) + ":" + Mid(tmpstr52 , 3 , 2) + ":" + Mid(tmpstr52 , 5 , 2)
                     'Print #1 , Tmpstr8
                     Date$ = Tmpstr8
                     'Print #1 , "D>" ; Date$
                     Tmpstr8 = ""
                     Atsnd = "WATCHING INFORMA. Se configuro reloj en " + Date$ + " a " + Time$
                     'Set Actclkok

#if Modrtc = 1
                     Dow = Dayofweek()
                     Call Setdateds3231()
                     Call Settimeds3231()
                     Call Getdatetimeds3231()
#endif
                     Horamin = Syssec()
                     Horamineep = Horamin
                     Set Actclk

'                     Tmpl2 = Syssec()
'                     Horamin = Tmpl2
'                     Horamineep = Horamin
                  Else
                     Cmderr = 1
                  End If
               Else
                  Cmderr = 5
               End If

            Case "SISCLK"
               Cmderr = 0
               Tmpstr52 = Date$
               Atsnd = "Hora actual " + Tmpstr52 + " a "  '+ Time(horamin)
               Tmpstr52 = Time$
               Atsnd = Atsnd + Tmpstr52


            Case "LEECLK"
               Cmderr = 0
               Tmpstr52 = Date(horamin)
               Atsnd = "Ultima ACT CLK en " + Tmpstr52 + " a "       '+ Time(horamin)
               Tmpstr52 = Time(horamin)
               Atsnd = Atsnd + Tmpstr52

            Case "ACTCLK"
               Cmderr = 0
               Atsnd = "Nueva act CLK"
               'set topsegeep
               Set Newactclk

            Case "SETTOP"
               If Numpar = 2 Then
                  Cmderr = 0
                  Topseg = Val(cmdsplit(2))
                  Topsegeep = Topseg
                  Atsnd = "Se config Topseg=" + Str(topseg)
               Else
                  Cmderr = 4
               End If

            Case "LEETOP"
               Cmderr = 0
               Atsnd = "Topseg=" + Str(topseg)

'(
            Case "SETINI"
               if numpar=2 then
                  cmderr=0
                  cntrini=val(cmdsplit(2))
                  cntrinieep=cntrini
                  atsnd="Se config. CNTRini="+str(cntrini)
               else
                  cmderr=4
               endif

            case "LEEINI"
               cmderr=0
               atsnd="CNTRini="+str(cntrini)
')

      Case Else
      Cmderr = 1

         End Select
   Else
       Cmderr = 2
   End If

   If Cmderr > 0 Then
      Atsnd = Lookupstr(cmderr , Tbl_err)
   End If

   Print #1 , Atsnd

End Sub


#if Modrtc = 1
'*****************************************************************************
'---------routines I2C for  RTC DS3231----------------------------------------

'*****************************************************************************
Sub Getdatetimeds3231()
  I2cstart                                                  ' Generate start code
  If Err = 0 Then
     I2cwbyte Ds3231w                                       ' send address
     I2cwbyte 0                                             ' start address in 1307
     I2cstart                                               ' Generate start code
     If Err = 0 Then
        I2cwbyte Ds3231r                                    ' send address
        I2crbyte _sec , Ack
        I2crbyte _min , Ack       ' MINUTES
        I2crbyte _hour , Ack       ' Hours
        I2crbyte Dow , Ack                                        ' Day of Week
        I2crbyte _day , Ack                                       ' Day of Month
        I2crbyte _month , Ack       ' Month of Year
        I2crbyte _year , Nack       ' Year
        I2cstop
        If Err <> 0 Then
         Call Error(15)
        Else
           _sec = Makedec(_sec) : _min = Makedec(_min) : _hour = Makedec(_hour)
           _day = Makedec(_day) : _month = Makedec(_month) : _year = Makedec(_year)
        End If
     Else
      Print #1 , "No se encontro DS3231 en Getdatetime 2"
     End If
  Else
   Print #1 , "No se encontro DS3231 en Getdatetime 1"
  End If
End Sub
'-----------------------
Sub Setdateds3231()
  I2cstart                                                  ' Generate start code
  If Err = 0 Then
     _day = Makebcd(_day) : _month = Makebcd(_month) : _year = Makebcd(_year)
     I2cwbyte Ds3231w                                       ' send address
     I2cwbyte 3                                                ' starting address in 1307
     I2cwbyte Dow
     I2cwbyte _day                                             ' Send Data to day
     I2cwbyte _month       ' Month
     I2cwbyte _year       ' Year
     I2cstop
     If Err <> 0 Then call Error(15)
  Else
   Print #1 , "No se encontro DS3231 en Setdate"
  End If
end sub
'-----------------------
Sub Settimeds3231()
  I2cstart                                                  ' Generate start code
  If Err = 0 Then
     _sec = Makebcd(_sec) : _min = Makebcd(_min) : _hour = Makebcd(_hour)
     I2cwbyte Ds3231w                                       ' send address
     I2cwbyte 0                                                ' starting address in 1307
     I2cwbyte _sec                                             ' Send Data to SECONDS
     I2cwbyte _min                                             ' MINUTES
     I2cwbyte _hour                                         ' Hours
     I2cstop
     If Err <> 0 Then call Error(15)
  Else
   Print #1 , "No se encontro DS3231 en Settime"
  End If
 end sub
 '----------------------

 '********définition des erreurs***********************************************
Sub Error(byval genre As Byte )
Local Mes_error As String * 20
Select Case Genre
   Case 1
   Mes_error = " Reset  "
   Case 2
   Mes_error = " DFH "
   Case 3
   Mes_error = "set params  "
   Case 4
   Mes_error = "start "
  Case 5
   Mes_error = "Hardstop "
   Case 6
   Mes_error = "Status "
   Case 7
   Mes_error = "Getposition "
   Case 8
   Mes_error = "pas de module"
   Case 9
   Mes_error = "9xx"
   Case 10
   Mes_error = "10xx"
   Case 11
   Mes_error = "11xx"
   Case 12
   Mes_error = "12xx"
   Case 13
   Mes_error = "13xx"
   Case 14
   Mes_error = "ecriture clock"
   Case 15
   Mes_error = "lecture clock"
   Case Else
    Mes_error = "Autre erreur"
End Select
'Cls
Print #1 , "error=" ; Mes_error                             '; Adr_ax
'If Strerr <> "" Then
'   Locate 2 , 1 : Lcd Strerr
'End If
'Stop

End Sub


Sub Leer_rtc()
   Tmpb = 0
   Tmpb2 = 0
   Do
      Incr Tmpb
      Print #1 , "Leo RTC " ; Tmpb
      Call Getdatetimeds3231()
      If Err = 0 Then
         Print #1 , "RTC H=" ; Time$ ; ",F=" ; Date$
         Tmpb2 = 1
      Else
         I2cinit
      End If
      Wait 1

   Loop Until Tmpb = 10 Or Tmpb2 = 1
End Sub

#endif
'*******************************************************************************
'TABLA DE DATOS
'*******************************************************************************

Tbl_err:
   Data "OK"                                                   '0
   Data "Comando no reconocido"                                '1
   Data "Longitud comando no valida"                           '2
   Data "Numero de usuario no valido"                          '3
   Data "Numero de parametros invalido"                        '4
   Data "Error longitud parametro 1"                           '5
   Data "Error longitud parametro 2"                           '6
   Data "Parametro no valido"                                  '7
   Data "ERROR8"                                               '8
   Data "ERROR SD. Intente de nuevo"                           '9



Tbl_col:
   Data &B00000000                                             'Dummy para usar tabla desde pos 1
   Data &B10000000
   Data &B01000000
   Data &B00100000
   Data &B00010000
   Data &B00001000
   Data &B00000100
   Data &B00000010
   Data &B00000001


Tabla_estado:
   Data &B00000000000000000000000000000000&                    'Estado 0
   Data &B00000000000000000000000000000011&                    'Estado 1
   Data &B00000000000000000000000000110011&                    'Estado 2
   Data &B00000000000000000000001100110011&                    'Estado 3
   Data &B00000000000000000011001100110011&                 'Estado 4
   Data &B00000000000000110011001100110011&                    'Estado 5
   Data &B00000000000011001100000000110011&                    'Estado 6
   Data &B00001111111111110000111111111111&                    'Estado 7
   Data &B01010101010101010101010101010101&                    'Estado 8
   Data &B00110011001100110011001100110011&                    'Estado 9
   Data &B01110111011101110111011101110111&                    'Estado 10
   Data &B11111111111111000000000000001100&                    'Estado 11
   Data &B11111111111111000000000011001100&                    'Estado 12
   Data &B11111111111111000000110011001100&                    'Estado 13
   Data &B11111111111111001100110011001100&                    'Estado 14
   Data &B11111111111111000000000000001100&                    'Estado 15
   Data &B11111111111111111111111111110000&                    'Estado 16


Tbl_posdig:
Data 1
Data 9
Data 19
Data 27
Data 25
Data 31

Tbl_posdigp:
Data 32
Data 37
Data 17


Tbl_dig:
Data &B01111110                                             '0
Data &B11111111
Data &B10000001
Data &B10000001
Data &B11111111
Data &B01111110


Data &B00100000                                             '1
Data &B01000001
Data &B11111111
Data &B11111111
Data &B00000001
Data &B00000000


Data &B10001111                                             '2
Data &B10011111
Data &B10010001
Data &B10010001
Data &B11110001
Data &B01100001


Data &B10000001                                             '3
Data &B10010001
Data &B10010001
Data &B10010001
Data &B11111111
Data &B01101110


Data &B11110000                                             '4
Data &B11111000
Data &B00001000
Data &B00001000
Data &B11111111
Data &B11111111


Data &B11110001                                             '5
Data &B11110001
Data &B10010001
Data &B10010001
Data &B10011111
Data &B10001110


Data &B01111110                                             '6
Data &B11111111
Data &B10010001
Data &B10010001
Data &B10011111
Data &B00001110


Data &B10000111                                             '7
Data &B10001111
Data &B10011000
Data &B10110000
Data &B11100000
Data &B11000000

Data &B01101110                                             '8
Data &B11111111
Data &B10010001
Data &B10010001
Data &B11111111
Data &B01101110


Data &B01100000                                             '9
Data &B11110001
Data &B10010001
Data &B10010001
Data &B11111111
Data &B01111110


Data &B00000000
Data &B00000000
Data &B00000000
Data &B00000000
Data &B00000000
Data &B00000000

Tbl_digp:
Data &B00011110                                             '0
Data &B00100001
Data &B00100001
Data &B00011110


Data &B00000000                                             '1
Data &B00010001
Data &B00111111
Data &B00000001


Data &B00100111                                             '2
Data &B00101001
Data &B00101001
Data &B00010001


Data &B00100001                                             '3
Data &B00101001
Data &B00101001
Data &B00010110


Data &B00111000                                             '4
Data &B00000100
Data &B00000100
Data &B00111111


Data &B00111001                                             '5
Data &B00101001
Data &B00101001
Data &B00100110


Data &B00011110                                             '6
Data &B00101001
Data &B00101001
Data &B00000110


Data        &B00100011
Data        &B00100100
Data        &B00101000
Data &B00110000


Data        &B00010110
Data        &B00101001
Data        &B00101001
Data        &B00010110


Data        &B00011000
Data        &B00100101
Data        &B00100101
Data        &B00011110


Data        &B00000000
Data        &B00000000
Data &B00000000
Data &B00000000

Loaded_arch: