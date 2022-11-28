*-----------------------------------------------------------
* Title      : Bitmap Subroutine 
* Written by : Abish Neelakanta
* Date       : 09/19/22
* Description: A subroutine written in 68k Assembly which reads 32-bit bitmap images
*              and draws it to the output screen. In addition to this, the subroutine
*              also accepts paramaters such as X and Y position(from top left) of the
*              original image to start drawing from, the height and width of the newly
*              drawn image. There are also a couple of parameters that specify the X and Y
*              location on theoutput window to start drawing the new image at. The subroutine
*              also handles edge cases such as either of the X or Y positions being out of
*              bounds, the new height or width being larger than the original image etc.
*              and prints out the appropriate error messages so the user can change their 
*              input accordingly.

*--------------------------Register Descriptions---------------------------------

* d7 is used to store original Width, multiplied by 4, to give us the number of pixels in each row of the image. It is later used to hold the value to shift the bmp pointer up by every pass of the Height loop
* d6 is used to denote the Y location at which pixel should be drawn, also functions as Height loop counter, counting down
* d5 is used to store the Width of the new image, also functions as the number of times the Width loop should run each time
* d4 is used to store the Height of the new image
* d3 is used to store the X location at which pixel should be drawn, also functions as Width loop counter, counting up
* d2,d1,d0 are used for trap codes as well general purpose registers


*------------------Input Section----------------------------

DrawBitmap:
        move.l (sp)+,a4                     
        move.l (sp)+,a0     ;Loads effective address of the bitmap header
        
        move.w $12(a0),d7  ;Original Width
        rol.w #8,d7        ;Converting from little to big endian
       
        move.w $16(a0),d6  ;Original Height
        rol.w #8,d6        ;Converting from little to big endian
        
        move.w (sp)+,d5   
        move.w (sp)+,d4     

        move.w (sp)+,d3
        move.w (sp)+,d2    ;Storing all of the paramaters into registers
        
        move.w (sp)+,a3
        move.w (sp)+,a2
        

*-----------------------Main Program Logic-------------------        
        
        mulu.w #$4,d7      ;Multiplying original width by 4 because each pixel's color is stored in 4 bytes. This is important to skip over the appropriate number of pixels according to the paramater
        move.w d4,-(sp)    ;Storing d4 in stack for later use
        

        move.w d6,-(sp)
        move.w d6,-(sp)     
        add.w d2,d4 
        sub.l d4,d6         
        move.w d6,d1       ;We are using d1 to store (Width - YStartPos - NewHeight) to get the value of pixels to skip over in the pixel data, as per the paramaters
        move.w (sp)+,d6    ;Reseting value of d6 
        sub.l  d1,d6       ;Holds correct Y position to start drawing at

        clr.l d1
        move.w (sp)+,d1
        sub.l d4,d1        ;(Original Height - NewHeight - YStartPos)

        move.b $0A(a0),d0
        add.w   d0,a0      ;Makes a0 point to start of the pixel array of the bmp
        
        move.l d7,-(sp)
        mulu.w d1,d7        ;This value is used to skip over all the pixels that need to be ignored at the start of the pixel array
        add.l  d7,a0        ;Makes a0 point to the correct pixel to start drawing from
        move.l (sp)+,d7     ;Resets d7 to original value
        
        mulu.w #$4,d3
        mulu.w #$4,d5
        sub.l  d3,d7        ;(OriginalWidth*4 - XStartPos*4 - NewWidth*4)
        sub.l  d5,d7        ;Stores the value by which the pixel array pointer should move up by, every pass of the Height loop 
        
        divu.w #$4,d5       ;Resets d5
        
        move.l d3,d4        ;Moves d3 to d4 because we will be using d3 as inner loop counter/X draw position
        
        move.w (sp)+,d6     ;Sets the value of d6 to hold the NewHeight, since we are drawing image from bottom to top
        
        move.w a3,d0
        add.w d0,d5
        move.w a2,d0
        add.w d0,d6         ;Offsets the draw points X and Y by the output screen X and Y paramaters
        
        
HeightLoop: add.w d4,a0         ; Skips over 'XStartPoint' number of pixels from the start of the row
            clr.l d3
            move.w a3,d0
            add.w d0,d3    ;Increments d3(the X draw location) by the outputscreen offset parameter
            

WidthLoop:  clr.l d1
            move.l (a0)+,d1     ;Reads the pixel pointed to by a0 which is stored in BBGGRRAA format
            lsr.l #8,d1         ; Zeros out the alpha in the pixel by right shifting by a byte
            
            cmp.l #$00FFDFDF,d1
            bgt SkipDraw
            
            move.b #80,d0 
            TRAP #15            ;We set the pen draw color here
            
            clr.l d1
            clr.l d2

            move.w d3,d1        
            move.w d6,d2        ;Specifying x and y coordinates to draw pixel at

            move.b #82,d0
            TRAP #15            ;Draws the pixel to output window
            
SkipDraw:   
            add.l #1,d3
            cmp.w d3,d5         ;Stops loop when d3 reaches d5, which is new width
            bgt WidthLoop       
 
            add.l d7,a0         ;Increments address pointer to point to the start of the next row
            
            sub.l #1,d6
            cmp.w a2,d6    ;Stops loop when d6 reaches 'OutputY'
            bgt HeightLoop
            
            move.l a4,-(sp)
            rts

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
