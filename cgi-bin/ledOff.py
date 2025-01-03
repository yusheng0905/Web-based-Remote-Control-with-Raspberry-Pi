import time
from grovepi import *

# Connect the Grove LED to digital port D4
led = 4

cnt = 0

pinMode(led,"OUTPUT")
# time.sleep(1)

while (cnt==0):
    try:
        digitalWrite(led,0)
        cnt += 1
    except IOError:
        print ("Error")
