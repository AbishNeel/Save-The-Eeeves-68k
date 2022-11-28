*-----------------------------------------------------------
* Title      : Seven Segment LED script for Save The Eevees Game
* Written by : Abish Neelakanta
* Date       : 09/29/2022
* Description: Displays the score in the form of a seven segment
* display. Does so by employing bitmasks and funtion tables. Score
* and X draw position (from the right) are supplied as parameters
* through the stack.
*-----------------------------------------------------------
* All registers are used as general purpose registers

SEGMENT_THICKNESS   equ 4

UpdateScore:
    move.l (sp)+,SSReturnAddress
    move.w (sp)+,d5

    add.w #1,ScoreUnits
    
    cmp.w #10,ScoreUnits
    bge ConvertScore

RedrawBgScore:    
    move.w #(StartY - SEGMENT_THICKNESS),-(sp)
    move.w d5,d4
    sub.w #Width,d4
    move.w d4,-(sp)
    move.w #StartY,-(sp)
    move.w d4,-(sp)
    move.w #((Height*2) + (2*SEGMENT_THICKNESS)),-(sp)
    move.w #(Width + SEGMENT_THICKNESS),-(sp)
    lea Background,a3
    move.l a3,-(sp)
    jsr DrawBitmap
    
    move.l SSReturnAddress,-(sp)
    rts                                               ;Redraws the background each time the score changes
    
ConvertScore:
    move.w #0,ScoreUnits
    add.w #1,ScoreTens
    jmp RedrawBgScoreTens

PrintScore:
    move.l (sp)+,SSReturnAddress
    move.w (sp)+,d6
    move.w (sp)+,d4
 
    move.w d4,d0                                    
    lea Bitmasks,a0                             ;Loads bitmasks
    lea DrawFunctions,a1                        ;Loads Drawfunction array        
    lea StartX,a3
    
    
    add.w d0,a0                                 ;Offsets bitmasks by the number to be drawn
    
    clr.l d7
         
SegmentLoop:  
       move.b (a0),d0
       and.b #$FF,d7
       lsr.l d7,d0
       and.b #01,d0
       
       move.l (a1)+,a2
       cmp.b #01,d0
       bne DrawReturn
       jsr (a2)                               ;Loops through each bit in the bitmask and draws the corresponding segment if it is set, skips if not set

DrawReturn:        
       add.b #1,d7
       cmp.b #7,d7
       blt SegmentLoop
  
       move.l SSReturnAddress,-(sp)
       rts                                    ;Loads return address and returns to the top of stack
       
              
DrawG: 
       move.w d6,d1
       sub.w #Width,d1
       move.w #(StartY + Height),d2
       move.w d6,d3
       move.w #(StartY + Height + SEGMENT_THICKNESS),d4
       
       move.b #DRAW_RECTANGLE_TRAP_CODE,d0
       TRAP #15
       rts                       ;Draws segment G
       
       
DrawF: 
       move.w d6,d1
       sub.w #Width,d1
       move.w #StartY,d2
       move.w d6,d3
       add.w #(SEGMENT_THICKNESS - Width ),d3
       move.w #(StartY + Height),d4
       
       move.b #DRAW_RECTANGLE_TRAP_CODE,d0
       TRAP #15
       rts                      ;Draws segment F
       
       
DrawE: 
       move.w d6,d1
       sub.w #Width,d1
       move.w #(StartY + Height),d2
       move.w d6,d3
       add.w #(SEGMENT_THICKNESS - Width ),d3
       move.w #(StartY + (2*Height)),d4
       
       move.b #DRAW_RECTANGLE_TRAP_CODE,d0
       TRAP #15
       rts                   ;Draws segment E
       
       
DrawD: 
       move.w d6,d1
       sub.w #Width,d1
       move.w #(StartY + (2*Height)),d2
       move.w d6,d3
       move.w #(StartY + (2*Height) + SEGMENT_THICKNESS),d4
       
       move.b #DRAW_RECTANGLE_TRAP_CODE,d0
       TRAP #15
       rts                  ;Draws segment D
       
       
DrawC: move.w d6,d1
       sub.w #SEGMENT_THICKNESS,d1
       move.w #(StartY + Height),d2
       move.w d6,d3
       move.w #(StartY + (2*Height)),d4
       
       move.b #DRAW_RECTANGLE_TRAP_CODE,d0
       TRAP #15
       rts                 ;Draws segment C
       
       
DrawB: move.w d6,d1
       sub.w #SEGMENT_THICKNESS,d1
       move.w #StartY,d2
       move.w d6,d3
       move.w #(StartY + Height),d4
       
       move.b #DRAW_RECTANGLE_TRAP_CODE,d0
       TRAP #15
       rts                 ;Draws segment B
       
       
DrawA:  move.w d6,d1
       sub.w #Width,d1
        move.w #StartY,d2
        move.w d6,d3
        move.w #(StartY + SEGMENT_THICKNESS),d4
         
        move.b #DRAW_RECTANGLE_TRAP_CODE,d0
        TRAP #15
        rts              ;Draws segment A
        
RedrawBgScoreTens:    
    move.w #(StartY - SEGMENT_THICKNESS),-(sp)
    move.w #590,d3
    sub.w #Width,d3
    move.w d3,-(sp)
    move.w #StartY,-(sp)
    move.w d3,-(sp)
    move.w #((Height*2) + (2*SEGMENT_THICKNESS)),-(sp)
    move.w #(Width + SEGMENT_THICKNESS),-(sp)
    lea Background,a3
    move.l a3,-(sp)
    jsr DrawBitmap
    
    jmp RedrawBgScore

Buffer: dcb.b 6,$FF

Bitmasks dc.b $7E,$30,$6D,$79,$33,$5B,$5F,$70,$7F,$7B               ;Holds bitmask for each number

DrawFunctions dc.l DrawG,DrawF,DrawE,DrawD,DrawC,DrawB,DrawA        ;Function Table

Height equ 20
Width  equ 20

StartX equ 620
StartY equ 20

SSReturnAddress  dc.l  $00000010 














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
