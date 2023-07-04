# RELOJ_GPS
Reloj GPS basado en matrices 8x8 y drivers A6282.
Se tiene un arreglo de 5 matrices 8x8 manejadas cada una por un driver A6282.
La resolución del display resultante es de 8x40 (8 filas por 40 columnnas). 
Los datos del display se guardan en un arreglo Buffram de 40 bytes

## MICROPYTHON DRIVER
Con Micropython se puede implementar un driver manejando los datos con una instancia del puerto SPI (la línea MOSI no se utiliza).
En este escenario se encontro que para manejar 4 matrices se necesitan 870us para actualizar los datos. Las interrupciones del timer se generan cada 2ms por lo que para un barrido de 8 columnas se tiene una frecuencia de refresco de f=1/(2*8ms)=62.5Hz. Con el osciloscopio se determina que las columas están encendidas 1.4ms, por lo que se tiene un tiempo de (1400-870)/1400=38% del tiempo útil con los datos. En la práctica el brillo es aceptable y no hay efecto de fantasma por la conmutación.
## CONEXION MATRIZ 16X16
Las matrices se arreglan en un formato de 16x16 como se inidica en la figura siguiente:

<img width="600" alt="Conexion Reverso" src="https://github.com/Ferivas/RELOJ_GPS/blob/master/DOCS/Matriz_16x16_reverso.jpg">

Con esta conexión la posición de las columnas para el arreglo bufferram en el programa de Micropython queda como se indica a continuación:

<img width="600" alt="Pos Columnas" src="https://github.com/Ferivas/RELOJ_GPS/blob/master/DOCS/Matriz_16x16_anverso.jpg">

En el programa de micropython las posiciones de los dígitos se asignan en una lista 

tblposdig=[10,2,23,16,25,31]

en donde el elemento 0 corresponde a la posición de las unidades de minuto, el elemento 1 a las decenas de minuto, el elemento 2 a las unidades de hora y el elemento 3 a las decenas de hora. 

El reloj por el frente

<img width="600" alt="Pos Columnas" src="https://github.com/Ferivas/RELOJ_GPS/blob/master/DOCS/Reloj_frente.jpg">

## BUGS RELOJ BASADO EN ESP32 CON TARJETA JLCPCB
### BUGS HARDWARE
Se debe desconectar la línea PWM que une a los dos drivers. Esta línea se debe manejar por separado. Cuando estaban unidos solo se enciende el segundo driver.
El corte esta indicado en la figura siguiente:

<img width="600" alt="Pos Columnas" src="https://github.com/Ferivas/RELOJ_GPS/blob/master/MatrizJLCPCB/SCH/Parche_PCB.jpg">


