*-----------------------------------------------------------
* Title      : Main file for Save The Eevees game
* Written by : Abish Neelakanta
* Date       : 10/17/2022
* Description: Main file for the game 'Save The Eevees'. Includes the various files
* required to run the game. Has a menu loop in which the main menu screen is drawn
* and it waits for space bar to be pressed to start the game. When the game starts 
* draws a bitmap as the background by calling the drawbitmap subroutine. It then 
* initializes the required variables as well as the individual data memebers of 
* each of the scripts. The gameloop is responsible for essentially calling all of
* the update functions on all scripts to run the game. The premise of the game is
* that you control the paddle and must prevent the various eevee evolutions from
* falling off the screen by changing your paddle color to the appropriate color
* to bounce that particular form of eevee. If the eevee hits the padle and the 
* color does not match, the game ends and it also ends if eevee falls off the screen.
*-----------------------------------------------------------
    ORG    $1000
START:

ALL_REG  REG  D0-D7/A0-A2

GET_INPUT_TRAP_CODE         equ 19
SET_FILL_COLOR_TRAP_CODE    equ 81
FRAME_DELAY_TRAP_CODE       equ 23
SWAP_BUFFER_TRAP_CODE       equ 94
SET_DRAWING_MODE_TRAP_CODE  equ 92
CLEAR_SCREEN_TRAP_CODE      equ 11
SET_PEN_COLOR_TRAP_CODE     equ 80
LOAD_AUDIO_TRAP_CODE        equ 71
PLAY_AUDIO_TRAP_CODE        equ 76
  
CLEAR_SCREEN_MAGIC_VAL     equ $00FF
FRAME_DELAY                equ 0
DOUBLE_BUFFER_DRAWING_MODE equ 17
SINGLE_BUFFER_DRAWING_MODE equ 16
SCREEN_RIGHT               equ 640
SCREEN_BOTTOM              equ 460
BACKGROUND_HEIGHT          equ 480
BLACK_COLOR_CODE           equ $00000000
D_KEY_CODE                 equ 68
A_KEY_CODE                 equ 65
SPACE_KEY_CODE             equ $20
LOOPED_AUDIO_CODE          equ 1

PlayBGAudio:
        lea BgSoundPath,a1
        move.b #LOAD_AUDIO_TRAP_CODE,d0
        TRAP #15                            ;Loads audio into sound memory
        
        move.b #LOOPED_AUDIO_CODE,d2
        move.b #PLAY_AUDIO_TRAP_CODE,d0
        TRAP #15                            ;Plays audio sotred in memory in a loop

DrawSplashScreen:
        move.b #SINGLE_BUFFER_DRAWING_MODE,d1   
        move.b #SET_DRAWING_MODE_TRAP_CODE,d0
        TRAP #15                            ;Sets single buffer modefor the menu startup

        move.w #0,-(sp)
        move.w #0,-(sp)
        move.w #75,-(sp)
        move.w #100,-(sp)
        move.w #BACKGROUND_HEIGHT,-(sp)
        move.w #SCREEN_RIGHT,-(sp)
        lea SplashScreen,a3
        move.l a3,-(sp)
        jsr DrawBitmap                      ;Draws splashcreen
    
MainMenuLoop:
        move.l #SPACE_KEY_CODE,d1
        move.b #GET_INPUT_TRAP_CODE,d0
        TRAP #15
        
        cmp.w #$FF,d1
        beq InitializeGame
        
        bra MainMenuLoop

InitializeGame:
        move.w #0,ScoreUnits
        move.w #0,ScoreTens
        move.w #0,XVelocityMagnitude
        move.w #0,YVelocityMagnitude
        move.w #0,XVelocityDelta
        move.w #0,YVelocityDelta
        move.w #0,SpeedIncreaseCounter

DrawBG:        
        move.b #DOUBLE_BUFFER_DRAWING_MODE,d1   
        move.b #SET_DRAWING_MODE_TRAP_CODE,d0
        TRAP #15                                ;Sets double buffering mode
        
        move.w #0,-(sp)
        move.w #0,-(sp)
        move.w #0,-(sp)
        move.w #0,-(sp)
        move.w #BACKGROUND_HEIGHT,-(sp)
        move.w #SCREEN_RIGHT,-(sp)
        lea Background,a3
        move.l a3,-(sp)
        jsr DrawBitmap                      ;Draws background on startup
        

        jsr InitializePaddle
        jsr InitializeBall
        jsr SwapBuffers                     ;Initializes ball and paddle before starting the game loop
 
GameLoop:
     jsr UpdatePaddle
     jsr UpdateBall
     
     move.w ScoreUnits,-(sp)
     move.w #620,-(sp)
     jsr PrintScore
     
     move.w ScoreTens,-(sp)
     move.w #590,-(sp)
     jsr PrintScore
     
     jsr SwapBuffers
     
     bra GameLoop                           ;Calls the update function on all game entities within the game loop

ClearScreen:
    move.w #CLEAR_SCREEN_MAGIC_VAL,d1
    move.w #CLEAR_SCREEN_TRAP_CODE,d0
    TRAP #15
    rts                                     ;Clears screen when called
   
SwapBuffers:
    move.b #SWAP_BUFFER_TRAP_CODE,d0
    TRAP #15
    rts                                     ;Swaps the back and front buffer
    
EndGame:
    jsr ClearScreen
    move.w #90,-(sp)
    move.w #170,-(sp)
    move.w #0,-(sp)
    move.w #0,-(sp)
    move.w #300,-(sp)
    move.w #300,-(sp)
    lea GameOverScreen,a3
    move.l a3,-(sp)
    jsr DrawBitmap
    jsr SwapBuffers                   ;Draws game over screen when game ends

    bra MainMenuLoop
    
   
    INCLUDE 'paddle.X68'
    INCLUDE 'ball.X68'
    INCLUDE 'drawbitmap.X68'
    INCLUDE 'randomnumbergenerator.X68'
    INCLUDE 'sevensegment.X68'
    
                 
End:
    SIMHALT             

* Put variables and constants here
Background INCBIN "Forest.bmp"
GameOverScreen INCBIN "newgameover.bmp"
SplashScreen   INCBIN "splashscreen.bmp"
BgSoundPath  dc.b 'bgsound.wav',0

ScoreUnits dc.w 0
ScoreTens  dc.w 0

    END    START




















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
