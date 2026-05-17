# Digital Clock DEC Project

## Demo
[![Watch the demo](https://img.youtube.com/vi/vMbcKwL5xt4/0.jpg)](https://www.youtube.com/playlist?list=PL8TAmlTnt1M9XmpB4Xc3X9jTW3SgLloRu)

> Click the thumbnail above to watch the full demo playlist

## Features:
- Display current time in HH:MM:SS format on seven-segment displays
- Synchronous reset to set time back to 00:00:00 for each mode
- Alarm functionality to set a specific time and trigger an alert when the current time matches the alarm time
- Stopwatch functionality to measure elapsed time (up to 10 mins) with a hold switch enabling to hold the specific value while the clock is still counting
- Timer functionality to trigger an alert to measure time interval
- Different set of modes for clock (00), alarm (01), stopwatch (10) and timer (11)
- Dynamic Light effect for alert at alarm and countdown trigger
- Toggle between time format (HH:MM, SS) and (MM:SS, CS) as per mode

## Technical Implementation
- 100MHz master clock divided down to 1Hz using custom clock divider
- Multiplexed 4-digit 7-segment display with optimized refresh rate 
  to eliminate display artifacts
- Synchronous switch sampling naturally filters mechanical bounce
- Johnson ring counter for dynamic LED alert effects
- FSM based mode switching (Clock/Alarm/Stopwatch/Timer)

## Tools Used
- Vivado Design Suite
- Basys 3 FPGA Board (Artix-7)
- Verilog HDL

## Controls:

### General

Switch (V17) - Synchronous Reset: Set time to default (00:00:00) for each mode

Switch (W16) - Load: Pauses the time and enables the user to change the time for each mode

Switch (T1) - mode[0]: Ones place for mode selection

Switch (R2) - mode[1]: Tens place for mode selection

Up Button (T18) - Increases the value by 1

Left Button (W19) - Cycles between HH:MM:SS (if load is on)

Right Button (T17) - Cycles between HH:MM:SS (if load is on)

Down Button (U17) - Decreases the value by 1

### Clock

Center Button (U18) - Shows SS

### Alarm

Center Button (U18) - Shows SS

LED (W18) - led[0]: Turns on when the alarm is equal to the clock (as per the Johnson ring)

LED (U15) - led[1]: Turns on when the alarm is equal to the clock (as per the Johnson ring)

LED (U14) - led[2]: Turns on when the alarm is equal to the clock (as per the Johnson ring)

LED (V14) - led[3]: Turns on when the alarm is equal to the clock (as per the Johnson ring)

LED (V13) - led[4]: Turns on when the alarm is equal to the clock (as per the Johnson ring)

LED (V3) - led[5]: Turns on when the alarm is equal to the clock (as per the Johnson ring)

LED (W3) - led[6]: Turns on when the alarm is equal to the clock (as per the Johnson ring)

LED (U3) - led[7]: Turns on when the alarm is equal to the clock (as per the Johnson ring)

### Stopwatch

Center Button (U18) - Shows CS

Switch (V16) - hold: Holds the value when the switch is high

### Timer

Center Button (U18) - Shows SS

LED (W18) - led[0]: Turns on when the timer hits zero (as per the Johnson ring)

LED (U15) - led[1]: Turns on when the timer hits zero (as per the Johnson ring)

LED (U14) - led[2]: Turns on when the timer hits zero (as per the Johnson ring)

LED (V14) - led[3]: Turns on when the timer hits zero (as per the Johnson ring)

LED (V13) - led[4]: Turns on when the timer hits zero (as per the Johnson ring)

LED (V3) - led[5]: Turns on when the timer hits zero (as per the Johnson ring)

LED (W3) - led[6]: Turns on when the timer hits zero (as per the Johnson ring)

LED (U3) - led[7]: Turns on when the timer hits zero (as per the Johnson ring)
