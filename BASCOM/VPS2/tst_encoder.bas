$regfile = "m168def.dat"
$crystal = 7372800
$baud = 9600


$hwstack = 116
$swstack = 116
$framesize = 116



Print "Encoder test"

Dim B As Byte

'we have dimmed a byte because we need to maintain the state of the encoder


Swenc Alias Pinb.5
Config Swenc = Input
Set Portb.5

Set Portb.3
Set Portb.4

'Portb = &B11                                               ' activate pull up registers

   Print Version(1)
   Print Version(2)
   Print  Version(3)


Do

  B = Encoder(pinb.3 , Pinb.4 , Links , Rechts , 1)

  '                                               ^--- 1 means wait for change which blocks programflow

  '                               ^--------^---------- labels which are called

  '              ^-------^---------------------------- port PINs

  Print B

Waitms 10

Loop

End



'so while you can choose PINB0 and PINB7,they must be both member of PINB

'this works on all PIN registers



Links:

Print "left rotation"

Return



Rechts:

Print "right rotation"

Return

End
