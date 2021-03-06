{{
===================================================
│                   Servo Input                   │
===================================================                  

   ┌──────────────────────────────────────────┐
   │ Copyright (c) 2008 David C. Gregory      │               
   │     See end of file for terms of use.    │               
   └──────────────────────────────────────────┘

 This Object uses one of a cog's counters to continuously
 poll a R/C servo control signal and store the pulse
 width  in microseconds, the same format as used by Servo32

   R/C Receiver             Propeller
  ┌────────────┐   10k    ┌──────────┐ 
  │ Ch1 - Sgn  │ ──── │    P4    │
  │ Ch2 - Sgn  │ ──── │    P5    │
  │ Ch3 - Sgn  │ ──── │    P6    │
  │ Ch4 - Sgn  │ ──── │    P7    │
  │       Pos  │ ─ +5V   │          │
  │       Gnd  │ ──┬─── │   Vss    │     
  └────────────┘    │     └──────────┘
                    │
                    └─ GND
                    
Arguments for the Start method can be declared like this:

  DAT
    pins        LONG 4, 5, 6, 7
    pulseWidths LONG 1, 1, 1, 1

And then Start would be called like this:

  servoInput.start(@pins,4,@pulseWidths)

See ServoInput_DEMO.spin for an example.

Important!
  This Object assumed that the servo control pulses are
  delivered sequentially on the input pins.  I.e., a pulse
  is delivered to the first pin, then to the next and so on.
  It will not work properly if this is not the case.  
    
}}

VAR
  long  Stack[20]                      'Stack space for new cog
  byte  Cog                            'Hold ID of cog in use, if any   
 
PUB Start(address,numPins,out): Success
{{Start new servo input process.  Return True if successful.}}
  Stop
  Success := (Cog   := cognew(Measure(address,numPins,out), @Stack) + 1)

PUB Stop
{{Stop toggling process, if any.}}
  if Cog
    cogstop(Cog~ - 1)
 
PUB Active: YesNo
{{Return TRUE if process is active, FALSE otherwise.}}
  YesNo := Cog > 0
      
PUB Measure (pinsIn,numPins,pulsesOut) | each
{{Continuously acquire pulse width on the pins at address pinsIn,
     and store as microseconds at the address pulsesOut }}
  ctra[30..26] := %11010        ' Set mode to "APIN=1"
  frqa := 1                     ' Increment phsa by 1 for each clock tick

  repeat 
    repeat each from 0 to (numPins-1)
      ctra[5..0] := LONG[pinsIn][each]                           ' Set APIN = to each pin in turn   
      waitpeq(|< LONG[pinsIn][each], |< LONG[pinsIn][each], 0)   ' Wait for pulse to start
      waitpne(|< LONG[pinsIn][each], |< LONG[pinsIn][each], 0)   ' Wait for pulse to stop             
      LONG[pulsesOut][each] := phsa /(clkfreq/1_000_000)         ' Calculate Width, in microseconds
      phsa := 0                                                  ' Reset the counter
 
{{
    ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    │                                                   TERMS OF USE: MIT License                                                  │                                                            
    ├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
    │Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
    │files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
    │modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
    │is furnished to do so, subject to the following conditions:                                                                   │
    │                                                                                                                              │
    │The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
    │                                                                                                                              │
    │THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
    │WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
    │COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
    │ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
    └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}       