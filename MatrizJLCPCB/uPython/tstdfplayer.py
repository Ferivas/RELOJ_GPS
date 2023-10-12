import time
from dfplayer import DFPlayer
df=DFPlayer(uart_id=1,tx_pin_id=17,rx_pin_id=16)
#wait some time till the DFPlayer is ready
print("Ini")
time.sleep(0.2)
#change the volume (0-30). The DFPlayer doesn't remember these settings
print("Set vol a 25")
df.volume(15)
time.sleep(0.2)
#play file ./01/001.mp3
print("Play file")
df.play(1,10)