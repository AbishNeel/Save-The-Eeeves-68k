 *-----------------------------------------------------------
* Title      : Paddle script for Save The Eevees game
* Written by : Abish Neelakanta
* Date       : 10/04/2022
* Description: Paddle script which is responsble for enabling the user
* inputs to control paddle behavior(A to move left, D to move right, space
* to change color). It halso handles redrawing background behind the paddle
* as well as paddle collisions with walls, clamping it between the screen width. 
*-----------------------------------------------------------
* d7 is used to store the paddle left position
* d6 is used as a counter to loop through the color array
* d0 - d4 are used for manipulating Trap codes
* a0 is used to store the starting address of the color array

    ORG $2000
    
DRAW_RECTANGLE_TRAP_CODE    equ 87
    

PADDLE_WIDTH               equ 100
PADDLE_HEIGHT              equ 15
PADDLE_VELOCITY            equ 6
PADDLE_POSITION_Y          equ 460
    
InitializePaddle:
        move.l (sp)+,ReturnAddressPaddle

        move.w #220,d7   
        lea Colors,a0
        move.w #1,d6
        
        move.l (a0),d1
        move.b #SET_FILL_COLOR_TRAP_CODE,d0
        TRAP #15                                ;Initializes the fill color of the paddle with the starting position of the Color Array

        jsr DrawPaddle
        
        jmp Return
        
UpdatePaddle:
        move.l (sp)+,ReturnAddressPaddle
        movem.l (sp)+,ALL_REG                       ;Saves the return address UpdatePaddle has to return to and loads the registers with paddle specific data

GetInput: 
          move.l #(SPACE_KEY_CODE<<16 + A_KEY_CODE<<8 + D_KEY_CODE),d1
          move.b #GET_INPUT_TRAP_CODE,d0
          TRAP #15                                  ;Polls for input, (keys A,D and space)
            
InputSpace:     
          cmp.l #$FF0000,d1
          bge ChangeColor                           ;Changes paddle color when space is pressed
          blt ResetSpaceInput                       ;If space is not pressed, it resets the flag to accept space input

InputD:          
          cmp.w #$00FF,d1
          beq MoveRight                             ;Moves Right if D is pressed
InputA:
          cmp.w #$FF00,d1
          beq MoveLeft                              ;Moves left if A is pressed

Return:   
          movem.l ALL_REG,-(sp)
          move.l ReturnAddressPaddle,-(sp)
          rts                                       ;Saves off the registers onto the stack and loads the return address onto to the top of stack before returning 

DrawPaddle: 
          move.l #BLACK_COLOR_CODE,d1
          move.b #SET_PEN_COLOR_TRAP_CODE,d0
          TRAP #15
          move.w d7,d1
          move.w #PADDLE_POSITION_Y,d2

          move.w d1,d3
          add.w #PADDLE_WIDTH,d3

          move.w d2,d4
          add.w #PADDLE_HEIGHT,d4
          
          move.b #DRAW_RECTANGLE_TRAP_CODE,d0
          TRAP #15
          
          rts                               ;Draws the paddle each time it moves and each time it changes color

MoveRight:
          cmp.w #(SCREEN_RIGHT - PADDLE_WIDTH),d7
          bgt Return
          add.w #PADDLE_VELOCITY,d7                ;Moves the paddle right and redraws the background to the right of it
            
          movem.l ALL_REG,-(sp)
          move.w #(PADDLE_POSITION_Y-1),-(sp)
          sub.w #PADDLE_VELOCITY,d7
          move.w d7,-(sp)
          move.w #(PADDLE_POSITION_Y-1),-(sp)
          move.w d7,-(sp)
          move.w #(PADDLE_HEIGHT+2),-(sp)
          move.w #(PADDLE_VELOCITY+1),-(sp)
          lea Background,a3
          move.l a3,-(sp)
          jsr DrawBitmap
          movem.l (sp)+,ALL_REG                     
          
          jsr DrawPaddle                                
          
          jmp InputA                        
          
          
MoveLeft:
          cmp.w #PADDLE_VELOCITY,d7
          blt Return
          sub.w #PADDLE_VELOCITY,d7             ;Moves the paddle left and redraws the background to the left of it
          
          
          movem.l ALL_REG,-(sp)
          move.w #(PADDLE_POSITION_Y - 1),-(sp)
          add.w #PADDLE_WIDTH,d7
          move.w d7,-(sp)
          move.w #(PADDLE_POSITION_Y - 1),-(sp)
          move.w d7,-(sp)
          move.w #(PADDLE_HEIGHT + 2),-(sp)
          move.w #(PADDLE_VELOCITY + 1),-(sp)
          lea Background,a3
          move.l a3,-(sp)
          jsr DrawBitmap
          movem.l (sp)+,ALL_REG

          jsr DrawPaddle 

          jmp Return 
          
ChangeColor:
          movem.l ALL_REG,-(sp)
          
          cmp.b #1,Get_Space_Input
          bne Return
          
          jsr getRandomByteIntoD6
          move.w d6,RandomNumber
          
          movem.l (sp)+,ALL_REG
          
          move.w RandomNumber,d6
          and.l #3,d6
          cmp.w #3,d6
          blt SetNewColor   
          move.w #2,d6     ;Gets color randomly and clamps it between 0-2 

SetNewColor:
          asl.l #2,d6

          lea Colors,a0
          add.l d6,a0
          move.l (a0),d1
          move.b #SET_FILL_COLOR_TRAP_CODE,d0
          TRAP #15                            ;Sets fill color to the new color
          
          move.b #0,Get_Space_Input
          asr.l #2,d6
          add.w #1,d6                         ;Sets up d6 to hold the right color index which is used for collisions 
          jsr DrawPaddle
          jmp InputD
          
          
ResetSpaceInput:
          move.b #1,Get_Space_Input
          jmp InputD                          ;Sets SpaceInput flag which prevents multiple color changes when space is held down


* Put variables and constants here

Colors     dc.l $00FF0000, $0000FFFF, $000000FF
Get_Space_Input  dc.b 1
ReturnAddressPaddle   dc.l $00000000
RandomNumber  dc.w 0











































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
