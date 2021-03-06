' File: GPS.spin

' Notes:
' GPS Tutorial http://www.kronosrobotics.com/Projects/GPS.shtml
' Teh GPS http://www.sparkfun.com/commerce/product_info.php?products_id=8234
' Teh LED Matrix http://www.sparkfun.com/commerce/product_info.php?products_id=760
' Teh Serial LCD Display http://www.sparkfun.com/commerce/product_info.php?products_id=8884
' Teh Compass http://www.sparkfun.com/commerce/product_info.php?products_id=418

CON
  '_clkmode = xtal1 + pll16x
  '_xinfreq = 5_000_000
  'led_mosi = 8
  'led_cs = 9
  'led_sclk = 10
  led_sclk_speed = 200_000'Hz
  led_enable_delay = 2_000 '= 0.5ms
  led_disable_delay = 100  '= 10ms
  'Orientation: The one has YS sign on it is up
  right = 0
  down  = 1
  left  = 2
  up    = 3  
  
OBJ
  Terminal : "FullDuplexSerial"

VAR
  byte Data[64]
  byte Character[128]
  byte CharacterNumber
  byte NewData[64]
  long Rotation
  byte Scroll
  byte ScrollDirection

  byte Forecolor
  byte Backcolor

  byte led_mosi
  byte led_cs
  byte led_sclk
  long stack[64]

'TODO LIST
'
' - Set COG UNIT
' - Set multiple units --> make terminal for mosi cs sclk variable
' - Remove transfer protocol to terminal
' - Remove some functions

PUB Start (mosi, cs, sclk) : success | cog
  'cogstop
  'success  := (cog := cognew(StartLED(mosi,cs,sclk),@stack)+1)
  StartLED(mosi, cs, sclk)  

PUB StartLED (mosi, cs, sclk)

  led_mosi := mosi
  led_cs   := cs
  led_sclk := sclk

  InitLED
  InsertData 'Remove me
  'InsertChar
  CharacterNumber := 0'33
  ClrScr
  'InsertText(string("TEsting123Z![\]^_`a"))
  repeat
    InsertData
    FontMasking
    RotateCharacter
    repeat 8
      DisplayLED '------------------------Consider moving to the back
      TransferCharacter
      'TransferRight 'Remove me
      'InsertData
      'FontMasking
      'RotateCharacter
      'Data := NewData    
      waitcnt (clkfreq/32 + cnt) 'delay 1s

PUB Rotate(RotateValue)
  Rotation := RotateValue

PRI ClrScr | i
  repeat i from 0 to 63
    Data[i] := Backcolor
    
PUB InsertText(stringptr) | i
  i := 0
  repeat strsize (stringptr)
    Character[i++] := byte[stringptr++]
  Character[i] := 0
  CharacterNumber := 0

PUB SetColor (Fore, Back)
  Forecolor := Fore
  Backcolor := Back   
  

PRI RotateCharacter | TempData[64] , i , ii, Temp1, Temp2
  if Rotation == 90
    repeat i from 0 to 7
      repeat ii from 0 to 7
        Temp1 := (i * 8) + ii
        Temp2 := ((7 - ii) * 8) + i
        TempData[Temp2] := NewData[Temp1]
            
  elseif Rotation == 180
    repeat i from 0 to 7
      repeat ii from 0 to 7
        Temp1 := (i * 8) + ii
        Temp2 := ((7 - i) * 8) + (7 - ii)
        TempData[Temp2] := NewData[Temp1]

  elseif Rotation == 270
    repeat i from 0 to 7
      repeat ii from 0 to 7
        Temp1 := (i * 8) + ii
        Temp2 := (ii * 8) + (7 - i)
        TempData[Temp2] := NewData[Temp1]

  else 'Rotation == 0
    repeat i from 0 to 63
      TempData[i] := NewData[i]

  repeat i from 0 to 63
    NewData[i] := TempData[i]
    
PUB ScrollEnable
  Scroll := 1
  
PUB ScrollDisable
  Scroll := 0

PUB ScrollDir ( Direction )
  'if ((Direction <= 3) & (Direction >= 0))
    ScrollDirection := Direction
  

PRI InsertData | InsertCounter 'Remove me
  InsertCounter := 0
  '┌───────────────────────────────┐
  '│         8-bit Colour          │    
  '├───────────┬───────────┬───────┤
  '│    Red    │   Green   │ Blue  │
  '├───┬───┬───┼───┬───┬───┼───┬───┤
  '│ 7 │ 6 │ 5 │ 4 │ 3 │ 2 │ 1 │ 0 │
  '└───┴───┴───┴───┴───┴───┴───┴───┘
  ' Common Color:
  ' 00 Black    FF White
  ' E0 Red      FC Yellow(kinda orange-ish)
  ' 1C Green    E3 Magenta(Looks more like a pink)
  ' 03 Blue     1F Teal(Cyan/Light Blue)
  ' F0 Orange   43 Purple

  repeat 64  '8x8 = 64 bytes of color
'    NewData[InsertCounter++] := $07
'    NewData[InsertCounter++] := $27
'    NewData[InsertCounter++] := $3F
'    NewData[InsertCounter++] := $38'
'    NewData[InsertCounter++] := $C0
'    NewData[InsertCounter++] := $C4
'    NewData[InsertCounter++] := $C7
    NewData[InsertCounter++] := Forecolor

PRI InsertChar | InsertCounter
  'Insert character here
  InsertCounter := 0
  repeat 127
    Character[InsertCounter++] := InsertCounter + 32
  Character[InsertCounter++] := 0
  'Character := byte [string ("Test")]
  
PRI TransferRight | RightCounter, Temp 'Transfer byte right only, this is not transfer right char
  RightCounter := 127 'TODO: remove this funct
  Temp := Data[127]  
  repeat 127
    Data[RightCounter] := Data[RightCounter - 1]
    RightCounter--
  Data[0] := Temp

PRI TransferCharacter | i
  if Scroll == 1
    if rotation == 90
      if ScrollDirection == right
        ScrollDown
      elseif ScrollDirection == down
        ScrollLeft
      elseif ScrollDirection == left
        ScrollUp
      elseif ScrollDirection == up
        ScrollRight    
    elseif rotation == 180
      if ScrollDirection == right
        ScrollLeft
      elseif ScrollDirection == down
        ScrollUp
      elseif ScrollDirection == left
        ScrollRight
      elseif ScrollDirection == up
        ScrollDown    
    elseif rotation == 270
      if ScrollDirection == right
        ScrollUp
      elseif ScrollDirection == down
        ScrollRight
      elseif ScrollDirection == left
        ScrollDown
      elseif ScrollDirection == up
        ScrollLeft
    else
      if ScrollDirection == right
        ScrollRight
      elseif ScrollDirection == down
        ScrollDown
      elseif ScrollDirection == left
        ScrollLeft
      elseif ScrollDirection == up
        ScrollUp
  else
    repeat i from 0 to 63
      Data[i] := NewData[i]

PRI ScrollLeft | i,ii,Temp
  '@@@@@@@@ ########  -->  @@@@@@@@ .#######
  repeat i from 0 to 7
    repeat ii from 0 to 6
      Temp := 63 - ((i * 8) + ii)
      Data [Temp] := Data[Temp-1]
  '@@@@@@@@ .#######  -->  @@@@@@@. @#######
  repeat i from 0 to 7
    Temp := 56 - (i * 8)
    Data [Temp] := NewData [Temp + 7]
  '@@@@@@@.  -->  .@@@@@@@
  repeat i from 0 to 7
    repeat ii from 0 to 6
      Temp := 63 - ((i * 8) + ii)
      NewData [Temp] := NewData[Temp-1]

PRI ScrollUp | i,ii,Temp
  '@@@@@@@@ ########  -->  @@@@@@@@ .#######
  repeat i from 0 to 6
    repeat ii from 0 to 7
      Temp := (i * 8) + ii
      Data [Temp] := Data[Temp+8]
  '@@@@@@@@ .#######  -->  @@@@@@@. @#######
  repeat i from 0 to 7
    Temp := 56 + i
    Data [Temp] := NewData [i]
  '@@@@@@@.  -->  .@@@@@@@
  repeat i from 0 to 6
    repeat ii from 0 to 7
      Temp := (i * 8) + ii
      NewData [Temp] := NewData[Temp+8]

PRI ScrollRight | i,ii,Temp 'FIXME
  '@@@@@@@@ ########  -->  @@@@@@@@ .#######
  repeat i from 0 to 7
    repeat ii from 0 to 6
      Temp := (i * 8) + ii
      Data [Temp] := Data[Temp+1]
  '@@@@@@@@ .#######  -->  @@@@@@@. @#######
  repeat i from 0 to 7
    Temp := (i * 8) + 7
    Data [Temp] := NewData [Temp - 7]
  '@@@@@@@.  -->  .@@@@@@@
  repeat i from 0 to 7
    repeat ii from 0 to 6
      Temp := (i * 8) + ii
      NewData [Temp] := NewData[Temp+1]

PRI ScrollDown | i,ii,Temp
  '@@@@@@@@ ########  -->  @@@@@@@@ .#######
  repeat i from 0 to 6
    repeat ii from 0 to 7
      Temp := 63 - ((i * 8) + ii)
      Data [Temp] := Data[Temp-8]
  '@@@@@@@@ .#######  -->  @@@@@@@. @#######
  repeat i from 0 to 7
    Temp := i
    Data [Temp] := NewData [Temp+56]
  '@@@@@@@.  -->  .@@@@@@@
  repeat i from 0 to 6
    repeat ii from 0 to 7
      Temp := 63 - ((i * 8) + ii)
      NewData [Temp] := NewData[Temp-8]

     

PRI FontMasking | OffsetChar, Temp1, OffsetBit, DataNo, Temp2
  OffsetChar := (Character [CharacterNumber++] - 32) * 8
  'if CharacterNumber == 128
  if Character [CharacterNumber] == $00 
     CharacterNumber := 0
  DataNo := 0
  repeat 8
    Temp1 := byte[@fonttab][OffsetChar++]
    'OffsetBit := 0
    'SendToTerminal(Temp1) '----------test point
    repeat OffsetBit from 0 to 7
      Temp2 := (Temp1 << OffsetBit) & $80
      if Temp2 == 0
        NewData[DataNo] := Backcolor '--------------------------------------BG color
      DataNo++
      'SendToTerminal(Data[DataNo++]) '----------test point
  
    
PRI InitLED 'Initialization of LED unit and enabling
  dira[led_cs]~~   'Out - Enable
  dira[led_mosi]~~ 'Out - Data
  dira[led_sclk]~~ 'Out - Clk
  outa[led_sclk]~
  DisableLED
  'ScrollEnable
  'ScrollDisable
  'ScrollDir (down)
  'Rotate ( 0 )
  Backcolor := Backcolor & $FF
  Forecolor := Forecolor & $FF
'  EnableLED    


PRI DisplayLED | LED_counter
  LED_counter := 0
  EnableLED
  waitcnt(clkfreq/led_enable_delay + cnt)
  repeat 64  '------------Change me: 64=single, 128=double
             'Note: putting data in more than 1 unit can cause delays
    'SendToTerminal(Data[LED_counter]) '----------test point
    SendLED(Data[LED_counter++])
  DisableLED
  waitcnt(clkfreq/led_disable_delay + cnt)    

PRI EnableLED
  outa[led_cs]~ 'active low
  
PRI DisableLED
  outa[led_cs]~~  
  
PRI SendLED ( ByteData ) | i,Temp
  outa[led_sclk]~
  'ByteData <<=1
  repeat i from 0 to 7
    Temp := ((ByteData << i) & $80) >> 7
    outa[led_mosi] := Temp
    waitcnt(clkfreq/(led_sclk_speed)+cnt)
    outa[led_sclk]~~      
    waitcnt(clkfreq/(led_sclk_speed)+cnt)
    outa[led_sclk]~      
  

PRI SendToTerminal (DataSendTerminal) 
  Terminal.start (31, 30, 0, 115200)
  Terminal.hex(DataSendTerminal,2)
  Terminal.str(string(" "))

DAT 'Taken from http://obex.parallax.com/objects/205/
              'font definition pixels are mirror image, due to the way waitvid works.
              'Atari 8 bit international font used here
              'There are 128 chars defined in this table.  256 are possible.
fonttab
'-----------------------------------------------
'---WARNING: All the codes here are inverted.---
'-----------------------------------------------
           byte byte %00000000   ' '  char 32 --> 0x20       
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
                      
           byte byte %00000000   '!' char 33 --> 0x21       
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00000000             
                      
           byte byte %00000000   '"'       
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000   '#'         
           byte byte %01100110             
           byte byte %11111111             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %11111111             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00011000   '$'       
           byte byte %01111100             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %00111110             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   '%'       
           byte byte %01100110             
           byte byte %00110110             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %01100110             
           byte byte %01100010             
           byte byte %00000000             
                       
           byte byte %00111000   '&'       
           byte byte %01101100             
           byte byte %00111000             
           byte byte %00011100             
           byte byte %11110110             
           byte byte %01100110             
           byte byte %11011100             
           byte byte %00000000             
                       
           byte byte %00000000   '''       
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000   '('       
           byte byte %01110000             
           byte byte %00111000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00111000             
           byte byte %01110000             
           byte byte %00000000             
                      
           byte byte %00000000   ')'       
           byte byte %00001110             
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011100             
           byte byte %00001110             
           byte byte %00000000             
                       
           byte byte %00000000   '*'       
           byte byte %01100110             
           byte byte %00111100             
           byte byte %11111111             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000   '+'       
           byte byte %00011000             
           byte byte %00011000             
           byte byte %01111110             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000   ','       
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00001100             
                       
           byte byte %00000000   '-'       
           byte byte %00000000             
           byte byte %00000000             
           byte byte %01111110             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000   '.'       
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   '/'       
           byte byte %01100000             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %00000110             
           byte byte %00000010             
           byte byte %00000000             
                       
           byte byte %00000000   '0'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01110110             
           byte byte %01101110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   '1'       
           byte byte %00011000             
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000   '2'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000   '3'       
           byte byte %01111110             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00110000             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   '4'       
           byte byte %00110000             
           byte byte %00111000             
           byte byte %00111100             
           byte byte %00110110             
           byte byte %01111110             
           byte byte %00110000             
           byte byte %00000000             
                       
           byte byte %00000000   '5'       
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111110             
           byte byte %01100000             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   '6'       
           byte byte %00111100             
           byte byte %00000110             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   '7'       
           byte byte %01111110             
           byte byte %01100000             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %00001100             
           byte byte %00000000             
                       
           byte byte %00000000   '8'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   '9'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %01100000             
           byte byte %00110000             
           byte byte %00011100             
           byte byte %00000000             
                       
           byte byte %00000000   ':'       
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   ';'       
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00001100             
                       
           byte byte %01100000   '<'       
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00110000             
           byte byte %01100000             
           byte byte %00000000             
                       
           byte byte %00000000   '='       
           byte byte %00000000             
           byte byte %01111110             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %01111110             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000110   '>'       
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %00000110             
           byte byte %00000000             
                       
           byte byte %00000000   '?'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   '@'         
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01110110             
           byte byte %01110110             
           byte byte %00000110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00000000   'A'       
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'B'       
           byte byte %00111110             
           byte byte %01100110             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111110             
           byte byte %00000000             
                       
           byte byte %00000000   'C'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'D'       
           byte byte %00011110             
           byte byte %00110110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00110110             
           byte byte %00011110             
           byte byte %00000000             
                       
           byte byte %00000000   'E'       
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000   'F'       
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000000             
                       
           byte byte %00000000   'G'       
           byte byte %01111100             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %01110110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00000000   'H'       
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'I'       
           byte byte %01111110             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000   'J'       
           byte byte %01100000             
           byte byte %01100000             
           byte byte %01100000             
           byte byte %01100000             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'K'       
           byte byte %01100110             
           byte byte %00110110             
           byte byte %00011110             
           byte byte %00011110             
           byte byte %00110110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'L'       
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000   'M'       
           byte byte %11000110             
           byte byte %11101110             
           byte byte %11111110             
           byte byte %11010110             
           byte byte %11000110             
           byte byte %11000110             
           byte byte %00000000             
                       
           byte byte %00000000   'N'       
           byte byte %01100110             
           byte byte %01101110             
           byte byte %01111110             
           byte byte %01111110             
           byte byte %01110110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'O'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'P'       
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000000             
                       
           byte byte %00000000   'Q'       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00110110             
           byte byte %01101100             
           byte byte %00000000             
                       
           byte byte %00000000   'R'       
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111110             
           byte byte %00110110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'S'       
           byte byte %00111100             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %01100000             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'T'       
           byte byte %01111110             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   'U'       
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000   'V'       
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   'W'       
           byte byte %11000110             
           byte byte %11000110             
           byte byte %11010110             
           byte byte %11111110             
           byte byte %11101110             
           byte byte %11000110             
           byte byte %00000000             
                       
           byte byte %00000000   'X'       
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'Y'       
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   'Z'       
           byte byte %01111110             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %00000110             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000   '['       
           byte byte %01111000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %01111000             
           byte byte %00000000             
                       
           byte byte %00000000   '\'       
           byte byte %00000010             
           byte byte %00000110             
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00110000             
           byte byte %01100000             
           byte byte %00000000             
                       
           byte byte %00000000   ']'       
           byte byte %00011110             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011110             
           byte byte %00000000             
                       
           byte byte %00000000   '^'       
           byte byte %00010000             
           byte byte %00111000             
           byte byte %01101100             
           byte byte %11000110             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000   '_'       
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %11111111             
           byte byte %00000000
                        
           byte byte %00000100   '`'       
           byte byte %00001000             
           byte byte %00010000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000   'a'       
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00000000   'b'       
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111110             
           byte byte %00000000             
                       
           byte byte %00000000   'c'       
           byte byte %00000000             
           byte byte %00111100             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'd'       
           byte byte %01100000             
           byte byte %01100000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00000000   'e'       
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'f'       
           byte byte %01110000             
           byte byte %00011000             
           byte byte %01111100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   'g'       
           byte byte %00000000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %01100000             
           byte byte %00111110             
                       
           byte byte %00000000   'h'       
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'i'       
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'j'       
           byte byte %01100000             
           byte byte %00000000             
           byte byte %01100000             
           byte byte %01100000             
           byte byte %01100000             
           byte byte %01100000             
           byte byte %00111100             
                       
           byte byte %00000000   'k'       
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00110110             
           byte byte %00011110             
           byte byte %00110110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'l'       
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'm'       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %11111110             
           byte byte %11111110             
           byte byte %11010110             
           byte byte %11000110             
           byte byte %00000000             
                       
           byte byte %00000000   'n'       
           byte byte %00000000             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'o'       
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000   'p'       
           byte byte %00000000             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111110             
           byte byte %00000110             
           byte byte %00000110             
                       
           byte byte %00000000   'q'       
           byte byte %00000000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %01100000             
           byte byte %01100000             
                       
           byte byte %00000000   'r'       
           byte byte %00000000             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00000000             
                       
           byte byte %00000000   's'       
           byte byte %00000000             
           byte byte %01111100             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %00111110             
           byte byte %00000000             
                       
           byte byte %00000000   't'       
           byte byte %00011000             
           byte byte %01111110             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %01110000             
           byte byte %00000000             
                       
           byte byte %00000000   'u'       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00000000   'v'       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000   'w'       
           byte byte %00000000             
           byte byte %11000110             
           byte byte %11010110             
           byte byte %11111110             
           byte byte %01111100             
           byte byte %01101100             
           byte byte %00000000             
                       
           byte byte %00000000   'x'       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00000000   'y'       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00110000             
           byte byte %00011110             
                       
           byte byte %00000000   'z'       
           byte byte %00000000             
           byte byte %01111110             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00100000   '{'             
           byte byte %00010000             
           byte byte %00010000             
           byte byte %00001000             
           byte byte %00010000             
           byte byte %00010000             
           byte byte %00100000             
           byte byte %00000000             
                       
           byte byte %00011000   '|'       
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             

           byte byte %00001000   '}'             
           byte byte %00010000             
           byte byte %00010000             
           byte byte %00100000             
           byte byte %00010000             
           byte byte %00010000             
           byte byte %00001000             
           byte byte %00000000             

           byte byte %00000000   '~'             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %01001100             
           byte byte %00110010             
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00000000

           byte byte %11111111   'Full'             
           byte byte %11111111             
           byte byte %11111111             
           byte byte %11111111             
           byte byte %11111111             
           byte byte %11111111             
           byte byte %11111111             
           byte byte %11111111             
                        



'--------------- non-traditional charset                       
           byte byte %00000000             
           byte byte %01111110             
           byte byte %00011110             
           byte byte %00111110             
           byte byte %01110110             
           byte byte %01100110             
           byte byte %01100000             
           byte byte %00000000             
                       
           byte byte %00010000             
           byte byte %00011000             
           byte byte %00011100             
           byte byte %00011110             
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00010000             
           byte byte %00000000             
                       
           byte byte %00001000             
           byte byte %00011000             
           byte byte %00111000             
           byte byte %01111000             
           byte byte %00111000             
           byte byte %00011000             
           byte byte %00001000             
           byte byte %00000000

'------------moved from letter a                        
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %01101100             
           byte byte %00110110             
           byte byte %00000000             
           byte byte %01101110             
           byte byte %01101110             
           byte byte %01111110             
           byte byte %01110110             
           byte byte %00000000             
                       
           byte byte %00110000             
           byte byte %00011000             
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111110             
           byte byte %00000110             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %00000110             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %00011000             
           byte byte %00001100             
                       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00111000             
           byte byte %00001100             
           byte byte %00001100             
           byte byte %00011110             
           byte byte %00001100             
           byte byte %00001100             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %01101100             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %01100110             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00000000             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %01100110             
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %00000000             
                       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00111000             
           byte byte %01100000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00111100             
           byte byte %01100110             
           byte byte %00000000             
           byte byte %00011100             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %01101100             
           byte byte %00110110             
           byte byte %00000000             
           byte byte %00111110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00111100             
           byte byte %11000011             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %00000110             
           byte byte %00111100             
           byte byte %00000000             
                       
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100000             
           byte byte %01111100             
           byte byte %01100110             
           byte byte %01111100             
           byte byte %00000000             
                       
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %01100110             
           byte byte %00000000             
                       
           byte byte %00011110             
           byte byte %00000110             
           byte byte %00011110             
           byte byte %00000110             
           byte byte %01111110             
           byte byte %00011000             
           byte byte %01111000             
           byte byte %00000000             
                       
           byte byte %00000000 'Arrow Up'             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01111110             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000 'Arrow Down'             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %01111110             
           byte byte %00111100             
           byte byte %00011000             
           byte byte %00000000             
                       
           byte byte %00000000 'Arrow Left'             
           byte byte %00011000             
           byte byte %00001100             
           byte byte %01111110             
           byte byte %00001100             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00000000 'Arrow Right'             
           byte byte %00011000             
           byte byte %00110000             
           byte byte %01111110             
           byte byte %00110000             
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00000000             
                       
           byte byte %00011000             
           byte byte %00000000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00011000             
           byte byte %00000000             
'------------------- moved
           byte byte %01100110             
           byte byte %01100110             
           byte byte %00011000             
           byte byte %00111100             
           byte byte %01100110             
           byte byte %01111110             
           byte byte %01100110             
           byte byte %00000000             
