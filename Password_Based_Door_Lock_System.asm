RS EQU P3.7
EN EQU P3.6
org 0000h
	JMP start
org 0100h
	start:
	CLR EN
	CLR RS
	MOV P1,#00h                       
	MOV R0,#30h						
	MOV R3,#00h
	MOV R4,#04h
	MOV R5,#00h
	
	
	MOV A,#38h                     //2 Lines and 5*7 Matrix        
	LCALL cmd_write
	MOV A,#0Fh					   //LCD ON ,cursor blinking ON ,cursor ON
	LCALL cmd_write
	MOV A,#01h                     //Clear Screen
	LCALL cmd_write
	MOV A,#80h 					   //Cursor on line 1 position 0 	
	LCALL cmd_write
	

//Display ENTER PASSWORD
		MOV dptr,#data_1
		MOV R2,#00h
next:	MOV A,R2
		MOVC A,@A+dptr
		CJNE A,#00h,down
		MOV A,#0C0h                     //2nd line position 0
		LCALL cmd_write	
		
		
		JMP s00 
		
down:	LCALL data_write_1
		INC R2
		JMP next
		
		
//Button press on hex keypad		
				
s00:CLR  	P3.0
	setb 	P3.1
	setb 	P3.2
	JB 	P2.0,s1
	JNB	P2.0,$			//y2g_added :wait till switch is released (+ve edge detection)
	MOV A,#'7'
	MOV @R0,A
	LJMP loop1


	

s1: 
	JB  P2.1,s2
	JNB	P2.1,$			//y2g_added :wait till switch is released (+ve edge detection)
	MOV A,#'8'
	MOV @R0,A
	LJMP loop1 

s2: 
JB  P2.2,s3
	JNB	P2.2,$			//y2g_added :wait till switch is released (+ve edge detection)
	MOV A,#'9'
	MOV @R0,A
	LJMP loop1
	
s3: setb  	P3.0
	clr 	P3.1
	setb 	P3.2	
	JB  P2.0,s4
	JNB	P2.0,$			//y2g_added :wait till switch is released (+ve edge detection)
	MOV A,#'4'
	MOV @R0,A
	LJMP loop1
		
s4: 
	JB  P2.1,s5
	JNB	P2.1,$			//y2g_added :wait till switch is released (+ve edge detection)
	MOV A,#'5'
	MOV @R0,A
	LJMP loop1
	
s5:
JB  P2.2,s6			    //y2g_edit : previously this line was		s5: JB P2.2,s00
	JNB	P2.2,$			//y2g_added :wait till switch is released (+ve edge detection)
	MOV A,#'6'
	MOV @R0,A
	LJMP loop1
	
s6: setb  P3.0
	setb  P3.1
	clr   P3.2	

	JB  P2.0,s7
	JNB	P2.0,$			//y2g_added :wait till switch is released (+ve edge detection)	
	MOV A,#'1'
	MOV @R0,A
	LJMP loop1
	
s7: JB  P2.1,s8
	JNB	P2.1,$			//y2g_added :wait till switch is released (+ve edge detection)
	MOV A,#'2'
	MOV @R0,A
	LJMP loop1
	
s8:	JB  P2.2,s00
	JNB	P2.2,$			//y2g_added :wait till switch is released (+ve edge detection)
	MOV A,#'3'
	MOV @R0,A
	LJMP loop1
		

loop1:	INC R0
		LCALL data_write
		DJNZ R4,level1
		LJMP check_passw
		level1:	LJMP s00                   //Directly jumping to label s00 caused target out of range error
	
	
	// checking entered password	

check_passw: MOV R1,#30h
			 MOV R3,#04h
			 MOV R5,#00h
			 MOV dptr,#data_2
repeat:		 CLR A
			 MOV A,R5
			 MOVC A,@A+dptr
			 XRL A,@R1
			 JNZ loop2
			 INC R1
			 INC R5
			 DJNZ R3,repeat
		     LJMP servo	
	



// Display Wrong Password
		
loop2: 	MOV A,#01h                     //Clear Screen
		LCALL cmd_write
		MOV dptr,#data_3   
		MOV R2,#00h
next1:	MOV A,R2
		MOVC A,@A+dptr
		CJNE A,#00h,down1
		
down1:	LCALL data_write_1
		INC R2
		JMP next1
		
	
	
		
org 0200h
cmd_write: MOV P1,A
		   CLR RS
		   SETB EN
		   LCALL delay
		   CLR EN
		   RET

org 0300h
data_write: MOV A,#'*'
			MOV P1,A
			SETB RS
			SETB EN
			LCALL delay
			CLR EN
			RET

org 0400h
delay:  	MOV R6,#20
up:			MOV R7,#250
			DJNZ R7,$
			DJNZ R6,up
			RET

		
org 0500h
servo:	
		MOV A,#01h                     //Clear Screen
		LCALL cmd_write
		MOV dptr,#data_4
		MOV R2,#00h
next2:	MOV A,R2
		MOVC A,@A+dptr
		CJNE A,#00h,down2
		MOV A,#0C0h                     //2nd line position 0
		LCALL cmd_write	
		
		
		CLR P2.4
		SETB P2.4
		LCALL delay_servo
		CLR P2.4
		JMP $	
 
		
down2:	LCALL data_write_1
		INC R2
		JMP next2
		
;		CLR P2.4
;		SETB P2.4
;		LCALL delay_servo
;		CLR P2.4
;		JMP $	

delay_servo: 
	MOV R4,#02
	up2: MOV R5,#08
	up1: MOV R2,#250
	up3:  MOV R3,#250    
	here: DJNZ R3,here
		  DJNZ R2,up3    
		  DJNZ R5,up1
		  DJNZ R4,up2
		  
org 0600h
data_write_1: MOV P1,A
			SETB RS
			SETB EN
			LCALL delay
			CLR EN
			RET	

org 0700h
	data_1: db "ENTER PASSWORD",00h
	data_2: db "8428"
	data_3: db "WRONG PASSWORD   ",00h
	data_4:	db "CORRECT PASSWORD",00h
end	