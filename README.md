I was required to connect the external sensors/connections to the IO ports of the
PIC16F887 µcontroller and then write the embedded software (firmware) needed to
have the following main functions:

1. Display Heart rate
2. Display Body Temperature
3. Communicate to the PC using UART with the patient status every 10 seconds
4. Flash an LED with the heart pulses
5. Short Beeps are sounded with the heart pulses using the buzzer
6. A soft on/off button to turn on/off the monitoring system by Software
7. A display toggle button to toggle between 3 display modes
a. Both Temperature and pulse rate are displayed
b. Temperature only is displayed
c. Pulse rate is only displayed


The specifications of the µcontroller and its connected devices/buttons is as follows:
● PIC16F887 µcontroller is used and is powered by 5V also connected to a 4MHZ
crystal
● Display is an alphanumeric LCD display having SPI interface
● PC connection is UART connection having built-in 12V/-12V level shifters (no
need to connect external level shifter)
● The Temperature sensor is a linear analog sensor giving a voltage between 1
and 3 for temperatures between 0 and 50℃
● The pulse rate sensor is a digital sensor which gives a digital pulse of width 1ms
for each heart beat
● Buttons are normally open buttons
● LED is a normal red LED with a voltage drop of 2V
● Buzzer is a 5V buzzer which sounds when a 5V is connected to its inpu
