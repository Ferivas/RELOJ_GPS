'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'*  SD_Archivos.bas                                                        *
'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'*                                                                             *
'*  Variables, Subrutinas y Funciones                                          *
'* WATCHING SOLUCIONES TECNOLOGICAS                                            *
'* 25.06.2015                                                                  *
'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

$nocompile
$projecttime = 92


'*******************************************************************************
'Declaracion de subrutinas
'*******************************************************************************
Declare Sub Inivar()
Declare Sub Procser()


'*******************************************************************************
'Declaracion de variables
'*******************************************************************************
Dim Tmpb As Byte

Dim Cmdtmp As String * 6
Dim Atsnd As String * 200
Dim Cmderr As Byte
'Dim Tmpstr8 As String * 16
Dim Tmpstr52 As String * 52


'Matriz
Dim Dato8 As Byte
Dim Dato16 As Byte
Dim Datocol As Byte
Dim Buffram(longbuf) As Byte
Dim Tmptx As Byte
Dim Cntr_col As Byte
Dim Kk As Byte
Dim Ptrcol As Byte


'Variables TIMER0
Dim T0c As Byte
Dim Num_ventana As Byte
Dim Estado As Long
Dim Estado_led As Byte
Dim Iluminar As Bit

'TIMER 2

'Variables SERIAL0
Dim Ser_ini As Bit , Sernew As Bit
Dim Numpar As Byte
Dim Cmdsplit(8) As String * 20
Dim Serdata As String * 160 , Serrx As Byte , Serproc As String * 160



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
   Timer0 = &H4C                                            '100 Hz con 18.432MHz
   Incr T0c
   T0c = T0c Mod 8
   If T0c = 0 Then
      Num_ventana = Num_ventana Mod 32
      Estado = Lookup(estado_led , Tabla_estado)
      Iluminar = Estado.num_ventana
      Toggle Iluminar
      Led1 = Iluminar
      Incr Num_ventana
   End If

Return



'*******************************************************************************
' TIMER0
'*******************************************************************************
Int_timer2:                                                 ' Ints a 1000 Hz si
   Timer2 = &H70
   Set Oena                                                 ' Apago driver
   Incr Cntr_col
   Datocol = Lookup(cntr_col , Tbl_col)
   Ptrcol = Lookup(cntr_col , Tbl_ptrcol)
   For Kk = 1 To Nummatriz
      Tmptx = Lookup(ptrcol , Tbl_poscol)
      Dato8 = Buffram(tmptx)
      Dato16 = Makeint(datocol , Dato8)
      Shiftout Sdi , Clk , Dato16 , 1
      Incr Ptrcol
   Next

   Set Lena
   Reset Lena
   Cntr_col = Cntr_col Mod 8
   Reset Oena

Return



'*******************************************************************************
' SUBRUTINAS
'*******************************************************************************

'*******************************************************************************
' Inicialización de variables
'*******************************************************************************
Sub Inivar()
Reset Led1
Print #1 , "************ MAINSERLED M8 ************"
Print #1 , Version(1)
Print #1 , Version(2)
Print #1 , Version(3)
Estado_led = 1
Print #1 , "Nummatriz=" ; Nummatriz
Print #1 , "Longbuf=" ; Longbuf

For Tmpb = 1 To Longbuf
   Buffram(tmpb) = Tmpb

Next


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
                  Else
                     Cmderr = 4
                  End If
            Else
               Cmderr = 5
            End If


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
Data &B00000001
Data &B00000010
Data &B00000100
Data &B00001000
Data &B00010000
Data &B00100000
Data &B01000000
Data &B10000000

Tabla_estado:
Data &B00000000000000000000000000000000&                    'Estado 0
Data &B00000000000000000000000000000011&                    'Estado 1
Data &B00000000000000000000000000110011&                    'Estado 2
Data &B00000000000000000000001100110011&                    'Estado 3
Data &B00000000000000000011001100110011&                    'Estado 4
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


Tbl_ptrcol:
Data 0                                                      'DUMMY
Data 0
Data 5
Data 10
Data 15
Data 20
Data 25
Data 30
Data 35

Tbl_poscol:
'Data 0
Data 1                                                      '0
Data 9                                                      '1
Data 17                                                     '2
Data 25                                                     '3
Data 33                                                     '4
Data 2                                                      '6                                                      '5
Data 10
Data 18
Data 26
Data 34
Data 3
Data 11
Data 19
Data 27
Data 35
Data 4
Data 12
Data 20
Data 28
Data 36
Data 5
Data 13
Data 21
Data 29
Data 37
Data 6
Data 14
Data 22
Data 30
Data 38
Data 7
Data 15
Data 23
Data 31
Data 39
Data 8
Data 16
Data 24
Data 32
Data 40


Loaded_arch: