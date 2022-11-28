*-----------------------------------------------------------
* Title      : Save The Eevees ball script
* Written by : Abish Neelakanta
* Date       : 10/02/2022
* Description: The ball script for Save The Eevees game. Handles
* ball movement, redrawing background behind the moving ball, ball
* collisions as well as varied trajectory changes upon paddle collision.
* Also handles eevee form changing every time the ball hits one of the wall.
* Responsible for ending the game if the ball falls below the screen or if 
* it colllides with the paddle and the color does not match. The ball uses
* fixed point math to accelerate, move and detect collisions.
*-----------------------------------------------------------
*d7 is used to store the left X position of the ball
*d6 is used to store top Y value of the ball
*d5 is used to store the ball x velocity
*a1 is used to store the ball y velocity
*d0-d4 are used to execute Trap codes and general purpose registers
*a0 is used to store the address of the x draw positions array
*a2 is used as an index to traverse the x draw positions array
*a3,a4,a5 are used to as general purpose address registers
*a6 is used to save of the register data of this script into a cache, so it can be retrieved every update

    ORG $3000

CACHE_MEMORY    equ $5000

BALL_WIDTH             equ 25
BALL_HEIGHT            equ 30
BALL_VELOCITY_X         equ 8
BALL_VELOCITY_Y         equ 6

SCREEN_LEFT_MAGIC_VAL   equ 5

InitializeBall:
    move.l #CACHE_MEMORY,a6                         ;Initializes a6 with the ball cache memory used to save registers off into
    
    move.l (sp)+,ReturnAddressBall
    
    move.w #100,d7
    move.w #50,d6                                   
    
    lea EeveeXDrawPositions,a0
    move.l #1,a2
    
    move.w #BALL_VELOCITY_X,d5
    move.w #BALL_VELOCITY_Y,a1
    
    asr.l #2,d5
    move.w d5,XVelocityMagnitude
    move.w #BALL_VELOCITY_X,d5
    
    move.l a1,d4
    asr.l #2,d4
    move.w d4,YVelocityMagnitude
    
    jsr MoveBall
    jsr DrawBall
    
    jmp BallReturn                                ;Initializes the ball with starting x and y positions as well starting x and y velocities
    
UpdateBall:
      movem.l (a6),ALL_REG                        ;Loads ball data from Cache Memory
      move.l (sp)+,ReturnAddressBall              ;Stores the return address the subroutine should return to
      
      jsr CheckCollisionsBall
      jsr RedrawBg
      jsr MoveBall                                ;Calling required subroutines to implement ball behavior 

BallReturn:      
      movem.l ALL_REG,(a6)
      move.l ReturnAddressBall,-(sp)    
      rts                                         ;Saves off registers to cache, loads return address to top of stack and returns out of stack

CheckCollisionsBall:
      cmp.w #(SCREEN_BOTTOM)<<2,d6
      bgt MissedCollision                         ;Branches to end game if ball goes below the bottom of the screen

      cmp.w #(SCREEN_RIGHT - BALL_WIDTH)<<2,d7
      bgt SetNegativeVelocityX                    ;Bounces the ball if it hits the right side of the screen
      
      cmp.w #(PADDLE_POSITION_Y - BALL_VELOCITY_Y - BALL_HEIGHT)<<2,d6
      bgt CheckPaddleCollision                      ;Checks if the ball collides with the paddle if it gets to the paddle y position
      
      move.w d7,d4
      sub.w XVelocityMagnitude,d4
      cmp.w #SCREEN_LEFT_MAGIC_VAL<<2,d4
      movem.l (a6),ALL_REG
      blt SetPositiveVelocityX                      ;Bounces the ball if it hits the left side of the screen
      
      move.w d6,d4
      sub.w  YVelocityMagnitude,d4
      cmp.w #BALL_VELOCITY_Y<<2,d4
      movem.l (a6),ALL_REG
      blt SetPositiveVelocityY                      ;Bounces the ball if it hits the top of the screen
      
      rts   
                  
DrawBall:
    move.l (sp)+,a5                                 ;Saves off the local return address to a5
    movem.l ALL_REG,-(sp)                           ;Saves off the registers performing temporary manipulations
    
    asr.l #2,d6
    asr.l #2,d7
    
    move.w d6,-(sp) 
    move.w d7,-(sp)
    move.w #0,-(sp)
    move.w (a0),-(sp)
    move.w #BALL_HEIGHT,-(sp)
    move.w #BALL_WIDTH,-(sp)
    
    lea Eevee,a3
    move.l a3,-(sp)
    
    jsr DrawBitmap                                 ;Draws the ball (eevee) by pushing in the appropriate paramaters
    
    movem.l (sp)+,ALL_REG                           
    move.l a5,-(sp)                             
    rts                                            ;Reloads registers, reloads local return address and returns to the top of the stack
        
RedrawBg:
    cmp.w #0,d5 
    blt RedrawRight                                ;If ball XVelocity is positive, it redraws the background to the left of the ball as it moves, if it is negative, redraws to the right
    
RedrawLeft:
    movem.l ALL_REG,-(sp)
    
    asr.l #2,d7
    asr.l #2,d6
    
    move.w d6,-(sp)
    move.w d7,-(sp)
    move.w d6,-(sp)
    move.w d7,-(sp)
    move.w #(BALL_HEIGHT + 2),-(sp)
    move.w XVelocityMagnitude,d4
    add.w #2,d4
    move.w d4,-(sp)
    lea Background,a3
    move.l a3,-(sp)
    jsr DrawBitmap
    
    movem.l (sp)+,ALL_REG                           ;Redraws backround to the left of the ball when called
    jmp RedrawTopBottom
    
RedrawRight:
    movem.l ALL_REG,-(sp)
    
    asr.l #2,d7
    asr.l #2,d6
    
    move.w d6,-(sp)
    add.w #BALL_WIDTH,d7
    move.w d7,-(sp)
    move.w d6,-(sp)
    move.w d7,-(sp)
    move.w #(BALL_HEIGHT + 2),-(sp)
    move.w XVelocityMagnitude,d4
    add.w #2,d4
    move.w d4,-(sp)
    lea Background,a3
    move.l a3,-(sp)
    jsr DrawBitmap
    
    movem.l (sp)+,ALL_REG                 ;Redraws backround to the right of the ball when called

RedrawTopBottom:
    cmp.w #0,a1
    blt RedrawBottom                            ;If ball XYVelocity is positive, it redraws the background to the top of the ball as it moves, if it is negative, redraws to the bottom
    
RedrawTop:
    movem.l ALL_REG,-(sp)
    
    asr.l #2,d7
    asr.l #2,d6
    
    move.w d6,-(sp)
    move.w d7,-(sp)
    move.w d6,-(sp)
    move.w d7,-(sp)
    move.w YVelocityMagnitude,d4
    add.w #2,d4
    move.w d4,-(sp)
    move.w #(BALL_WIDTH + 2),-(sp)
    lea Background,a3
    move.l a3,-(sp)
    jsr DrawBitmap

    movem.l (sp)+,ALL_REG                      ;Redraws backround above ball when called
    rts
    
RedrawBottom:
    movem.l ALL_REG,-(sp)
    
    asr.l #2,d7
    asr.l #2,d6
    
    add.w #BALL_HEIGHT,d6
    move.w d6,-(sp)
    move.w d7,-(sp)
    move.w d6,-(sp)
    move.w d7,-(sp)
    move.w YVelocityMagnitude,d4
    add.w #2,d4
    move.w d4,-(sp)
    move.w #(BALL_WIDTH + 2),-(sp)
    lea Background,a3
    move.l a3,-(sp)
    jsr DrawBitmap

    movem.l (sp)+,ALL_REG               ;Redraws backround below ball when called
    rts
     
    
MoveBall:    
    add.w d5,d7
    add.w a1,d6                       ;Moves ball by adding X and Y velocities
    
    jsr DrawBall
    
    rts
 
 
SetNegativeVelocityX:
    move.w #0,a3
    sub.w d5,a3
    move.w a3,d5
    jsr SetNewSprite                 ;Called when ball hits the right side of the screen
    rts
    
SetPositiveVelocityX:
    move.w #0,a3
    sub.w d5,a3
    move.w a3,d5
    jsr SetNewSprite                ;Called when the ball hits the left side of the screen
    rts
    
SetPositiveVelocityY:
    move.w #0,a3
    sub.w a1,a3
    move.w a3,a1
    jsr SetNewSprite
    jsr IncreaseVelocity           ;Called if the ball collides with the 
    rts
    
CheckPaddleCollision:
    movem.l ALL_REG,(a6)
    move.l (sp)+,a5

    move.w a2,a6
    asr.l #2,d7
    move.w d7,a3 
    add.w #BALL_WIDTH,a3
    movem.l (sp)+,ALL_REG
    movem.l ALL_REG,-(sp)
    move.w a6,a2
    move.l #CACHE_MEMORY,a6
    cmp.w d7,a3
    bgt CheckLength               ;Checks if the right side of the ball's position is greater than the left side of the paddle's position

DontCollide:
    movem.l (a6),ALL_REG
    move.l a5,-(sp)
    rts                             ;Doesn't perform the collision an returns out of the function

Collide:
    move.l d7,-(sp)
    movem.l (a6),ALL_REG
    move.l (sp)+,d7                 
    
    sub.w #PADDLE_WIDTH,d7
    add.w #BALL_WIDTH,a3
    add.w #20,d7
    cmp.w a3,d7
    bgt PaddleLeftCollision
    
    add.w #20,d7
    cmp.w a3,d7
    bgt PaddleMidLeftCollision
    
    add.w #20,d7
    cmp.w a3,d7
    bgt PaddleMidCollision
    
    add.w #20,d7
    cmp.w a3,d7
    bgt PaddleMidLeftCollision
    
    add.w #20,d7
    cmp.w a3,d7
    bgt PaddleLeftCollision         ;Checks which part of the paddle the ball collides with 
    
PaddleCollideReturn:
    move.w d5,-(sp)
    movem.l (a6),ALL_REG
    move.w (sp)+,d5
    move.l a5,-(sp)
    move.w #-BALL_VELOCITY_Y,a1
    move.w #BALL_VELOCITY_Y,d4
    add.w YVelocityDelta,d4
    asr.l #2,d4
    move.w d4,YVelocityMagnitude       
    
    movem.l ALL_REG,(a6)
    move.w #620,-(sp)
    jsr UpdateScore
    movem.l (a6),ALL_REG            ;Performed after at the end of all collision calculations, flips the Y velocity, restores registers and local return address before returning to top of stack
    
    rts
    
PaddleLeftCollision:
    cmp.w #0,d5
    bgt SetPositiveX2
    
    move.l -XVelocityDelta,d5
    asr.l #1,d5
    muls.w #3,d5
    sub.w #(BALL_VELOCITY_X*3/2),d5
    move.l d5,-(sp)
    move.l #0,a4
    sub.w d5,a4
    move.l a4,d5
    asr.l #2,d5
    move.w d5,XVelocityMagnitude
    move.l (sp)+,d5
    jmp PaddleCollideReturn   ;Multiplies the X velocity by 1.5 when the ball collides with the middle part of the paddle, without changing the sign
    
SetPositiveX2:
    move.w XVelocityDelta,d5
    asr.l #1,d5
    mulu.w #3,d5
    add.w #(BALL_VELOCITY_X*3/2),d5
    move.l d5,-(sp)
    asr.l #2,d5
    move.w d5,XVelocityMagnitude
    move.l (sp)+,d5
    jmp PaddleCollideReturn
    
PaddleMidLeftCollision:
    cmp.w #0,d5
    bgt SetPositiveX
    
    move.l -XVelocityDelta,d5
    sub.w #BALL_VELOCITY_X,d5
    move.l d5,-(sp)
    move.l #0,a4
    sub.w d5,a4
    move.l a4,d5
    asr.l #2,d5
    move.w d5,XVelocityMagnitude
    move.l (sp)+,d5
    jmp PaddleCollideReturn     ;Keeps the X velocity the same when the ball collides with the middle left/right part of the paddle, without changing the sign
    
SetPositiveX:
    move.w XVelocityDelta,d5
    add.w #BALL_VELOCITY_X,d5
    move.l d5,-(sp)
    asr.l #2,d5
    move.w d5,XVelocityMagnitude
    move.l (sp)+,d5
    jmp PaddleCollideReturn     
    
PaddleMidCollision:
    cmp.w #0,d5
    bgt SetPositiveHalfX
    
    move.l -XVelocityDelta,d5
    asr.l #1,d5
    sub.w #(BALL_VELOCITY_X/2),d5
    move.l d5,-(sp)
    move.l #0,a4
    sub.w d5,a4
    move.l a4,d5
    asr.l #2,d5
    move.w d5,XVelocityMagnitude
    move.l (sp)+,d5
    jmp PaddleCollideReturn      ;Halves the X velocity when the ball collides with the middle part of the paddle, without changing the sign
    
SetPositiveHalfX:
    move.w XVelocityDelta,d5
    asr.l #1,d5
    add.w #(BALL_VELOCITY_X/2),d5
    move.l d5,-(sp)
    asr.l #2,d5
    move.w d5,XVelocityMagnitude
    move.l (sp)+,d5
    jmp PaddleCollideReturn    

CheckLength:
    add.w #PADDLE_WIDTH,d7
    sub.w #BALL_WIDTH,a3
    cmp.w d7,a3
    blt CheckColor          ;Checks if the left side of the ball's position is greater than the right side of the paddle's position
   
    
DontCollideAgain:
    movem.l (a6),ALL_REG
    move.l a5,-(sp)
    rts                     ;Doesn't perform collision
    
CheckColor:
    cmp.w a2,d6
    beq Collide
    jsr MissedCollision     ;Checks if the paddle color matches the current eevee form
    
DontCollideLastTime:
    movem.l (a6),ALL_REG
    move.l a5,-(sp)
    rts                    ;Doesn't perform collision
    
    
IncreaseVelocity:
    cmp.w #3,SpeedIncreaseCounter
    bge DontIncrease
    
    add.w #2,XVelocityDelta
    add.w #4,YVelocityDelta
    add.w #1,SpeedIncreaseCounter
    rts                     ;Increases ball velocity each time it bounces of the top of the screen
    
DontIncrease:
    rts                     ;Doesn't increase velocity after a certain point
    
    
    
SetNewSprite:
    add.w #1,a2
    cmp.w #4,a2
    blt GetNextSprite       ;Gets new eevee sprite from the array to swap to each time the ball collides with a wall (not paddle)
    
ResetIndex:
    move.l #1,a2
    sub.w #6,a0

GetNextSprite:    
    add.w #2,a0
    rts
    
MissedCollision:
    jsr EndGame

* Put variables and constants here
eevee   INCBIN 'eevee.bmp'

EeveeXDrawPositions dc.w 200, 110, 30
ReturnAddressBall   dc.l $00000000

XVelocityMagnitude  dc.w 0
YVelocityMagnitude  dc.w 0

XVelocityDelta      dc.w 0
YVelocityDelta      dc.w 0

SpeedIncreaseCounter  dc.w  0


































































































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
