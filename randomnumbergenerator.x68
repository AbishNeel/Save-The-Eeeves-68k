

GET_TIME_COMMAND        equ     8



getRandomByteIntoD6
        move.l  RANDOMVAL,d0
       	moveq	#$AF-$100,d1
       	moveq	#18,d2
Ninc0	
	add.l	d0,d0
	bcc	Ninc1
	eor.b	d1,d0
Ninc1
	dbf	d2,Ninc0
	
	move.l	d0,RANDOMVAL
	clr.l	d6
	move.b	d0,d6
	
        rts


RANDOMVAL       ds.l    1
TEMPRANDOMLONG  ds.l    1









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
