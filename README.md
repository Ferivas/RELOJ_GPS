# RELOJ_GPS
Reloj GPS basado en matrices 8x8 y drivers A6282.
Se tiene un arreglo de 5 matrices 8x8 manejadas cada una por un driver A6282.
La resolución del display resultante es de 8x40 (8 filas por 40 columnnas). 
Los datos del display se guardan en un arreglo Buffram de 40 bytes

## MICROPYTHON DRIVER
Con Micropython se puede implementar un driver manejando los datos con una instancia del puerto SPI (la línea MOSI no se utiliza).
En este escenario se encontro que para manejar 4 matrices se necesitan 870us para actualizar los datos. Las interrupciones del timer se generan cada 2ms por lo que para un barrido de 8 columnas se tiene una frecuencia de refresco de f=1/(2*8ms)=62.5Hz. Con el osciloscopio se determina que las columas están encendidas 1.4ms, por lo que se tiene un tiempo de (1400-870)/1400=38% del tiempo útil con los datos. En la práctica el brillo es aceptable y no hay efecto de fantasma por la conmutación.
