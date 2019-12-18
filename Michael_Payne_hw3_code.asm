TITLE Homework3     (Michael_Payne_hw3_code.asm)

; Author: Michael Payne
; Last Modified: 07/27/2019
; OSU email address: paynemi
; Course number/section: cs271
; Project Number:   3              Due Date: 07/28/2019
; Description:	This program sums up negative integers inputted by the user.  It first introduces the program title and my nanme.
; It then asks the user his/her name and then greets them (with their name).  After that, it tells the user to enter an integer in
; domain of [-100, -1].  Integers less than -100 produce an error message.  Integers greater than -1 move the program to the results stage.
; All of the negative numbers (number that ends input stage is discarded) are summed up, and then the sum is divided by the number
; of inputted integers to give an average.  The program rounds up to the nearest .001.  The program then says goodbye to the user.
; Also, the program uses the rdtsc instruction to keep track of how much time has elapsed from the beginning of the program to the end.
; It prints the results at the end after saying goodbye.

INCLUDE Irvine32.inc

.data
boobs			byte	"idiot",0
greeting1		BYTE	"Welcome to the integer adder by Michael Payne.",10
question1		BYTE	"What is your name: ", 0
hello			BYTE	"Hello, ",0
goodbye1		BYTE	"Thanks for using my program.",10
goodbye2		BYTE	"Goodbye, ",0
userName		BYTE	33 DUP(0)			; user name
period			BYTE	".",0
inst1			BYTE	"Please enter numbers in [-100, -1].", 10
inst2			BYTE	"Enter a non-negative number when you are finished to see results.", 0
numLine1		BYTE	": "
numLine2		BYTE	"Enter number: ",0
result1			BYTE	"You entered ",0
result2			BYTE	" negative number(s).", 10
result3			BYTE	"The sum of your numbers is ", 0
result4			BYTE	"The rounded average is -",0
programTime		BYTE	"The elapsed program time is: ",0
noIntegers		BYTE	"You entered zero integers.",0
errorNum		BYTE	"You cannot enter a number less than -100!", 0
numnum			DWORD	0					; count for number of integers user enters
tenten			DWORD	10					; need number 10 for calculation of digits after decimal point
numTotal		DWORD	?					; sum of all inputted integers
upperLimit		DWORD	0					; Used to check to see if number is negative or not
lowerLimit		DWORD	-100				; Inputted number cannot be less than -100
timeStamp		DWORD	?


.code
main PROC
; segment 1 - Introducing Program and Greeting User - This segment starts the timer for program execution time by generating a timestamp
; with the rdtsc instruction.  Later on, this timestamp is used to calculate how long it took for the program to execute.
; This segment also lists the program title and my name.  It then gets the user name, greets the user with his/her name and then
; jumps to inputStart where program instructions are printed and user input is taken and printed
	rdtsc									; getting timestamp of beginning of program 
	mov			timeStamp, eax				; saving timestamp so that elapsed time can be calculated at end of program
	mov			edx, offset greeting1
	call		writestring
	mov			edx, OFFSET userName    	; using readstring to store user's input of name
	mov			ecx, 32						; specifying size of 32 bytes
	call		ReadString
	mov			edx, offset hello			; printing greeting to user (with user's name)
	call		writestring
	mov			edx, offset userName
	call		writestring
	mov			edx, offset period
	call		writestring					
	jmp			inputStart					; jumping to inputStart (need to skip errorMSG)

; segment 2 - Program instructions and User Num Input - This segment instructs the user to enter an integer that falls within the domain
; of [-100, -1].  It then takes input from the user.  If the user enters an integer less than -100, the program jumps back to errorMSG,
; and instructs the user to enter an integer greater than or equal to -100.  If the user enters an integer within the stated domain, the program
; adds it to numTotal, and increments numnum (which keeps track of how many correctly inputted integers there are; this is used to 
; print the numbers for the input lines, and to later produce an average).  The procedure numberLine is used to print inputLines.
; If the user inputs an integer greater than -1, the program moves on to segment 3.  If the user inputs an integer greater than -1 while numnum
; equals 0 (meaning the user hasn't inputted any negative integers), the program jumps to zeroIntegers, which prints a special message before ending
; the program
; errorMSG is skipped initially, but the program jumps to it if the user enters an integer less than -100.  It prints an error message
; and then decrements numnum, so the input lines are still correctly numbered and the number of correctly entered negative integers
; remains accurate
errorMSG:
	mov			edx, offset errorNum		; printing error message
	call		writestring
	dec			numnum						; decrementing numnum so integer count remains accurate
; inputStart prints instructions for the user, and clears out eax, so that numTotal can be properly added to later on
inputStart:
	call		crlf
	mov			edx, offset inst1			; printing instructions about user inputs
	call		writestring
	call		crlf
	xor			eax, eax					; clearing eax so numTotal stays accurate
; printLine is a loop that handles everything related to the user's integer inputs.  It first adds correct inputs to numTotal (which
; is 0 during the first iteration of the loop).  It then calls the procedure numberLine (which is explained in detail later), which
; prints out an input line (with the number of the line displayed. the number only increments if the inputted number is greater than 
; -101).  Inputs generated in numberLine are checked against the lowerLimit (-100) and upperLimit (0).  Inputs less than lowerLimit cause
; the program to jump up to errorMSG.  Inputs less than upperLimit restart the loop.  If the user enters a non-negative integer, the loop
; ends, numnum is decremented (to throw out the non-negative integer essentially), and the program moves onto the next segment.
; Also, the value of numnum is compared to 0.  If it equals zero, the program jumps to zeroInteger where a special message is printed
; and the program ends (no point in running through all of stuff in segment 3 if the user hasn't entered any negative integers)
printLine:
	add			numTotal, eax				; adding correctly inputted integer to numTotal
	call		numberLine					; calling procedure numberLine to print out numbered input lines
	call		readint						; reading user input
	cmp			eax, lowerLimit				; comparing inputted integer to -100
	jl			errorMSG					; if less than -100, jump to errorMSG to scold user
	cmp			eax, upperLimit				; comparing inputted integer to 0
	jl			printLine					; if less than 0, restart loop. 
	dec			numnum						; once user has inputted positive integer, program moves on and decrements numnum
	cmp			numnum,0					; making sure the user has inputted at least 1 negative integer
	je			zeroIntegers				; if not, jump to zeroIntegers

; segment 3 - Calculating and Printing Results - Segment 3 calls printResults, which takes the negative integers that the user inputted
; and prints out the sum and then the average of the integers (description of the procedure will give a more detailed explanation of how
; this works exactly).  The program then jumps to next segment to say goodbye to user and print program execution time
	call		printResults				; calling printResults procedure that processes inputted negative integers
	jmp			farewell					; once finished with that, jump to farewell to say goodbye to user and print program execution time
; zeroIntegers handles special case where user inputs a non-negative integer without having first inputted any negative integers.
; It lets the user know that they haven't entered anything to process or calculate and then moves onto next segment of program.
zeroIntegers:
	mov			edx, offset noIntegers		; printing message about no negative integers
	call		writestring

; segment 4 - Saying Goodbye - This segment thanks the user for using my program and then says goodbye (with their name)
farewell:
	call		crlf
	mov			edx, offset goodbye1		; saying goodbye and thanking user
	call		writestring
	mov			edx, offset userName
	call		writestring
	mov			edx, offset period
	call		writestring

; segment 5 - Printing Program Execution Time - this segment prints the program execution time.  It generates a new timestamp and then
; subtracts the timestamp (the part of the number stored in eax) from it.  It prints the result (which is the number of elapsed ticks)
	call		crlf
	mov			edx, offset programTime		; starting to print elapsed execution time
	call		writestring
	rdtsc									; getting a new timestamp
	sub			eax,timeStamp               ; subtracting old timestamp from that
	call		writedec					; finish printing elapsed execution time

	exit	; exit to operating system
main ENDP

; NumberLine is a procedure that prints out input lines for the user.  It increments numnum and then uses the number stored in numnnum
; to number each input line (numnum is essentially only incremented when the user inputs an integer greater than -101).  
numberLine	PROC
	inc			numnum						; incrementing numnum to keep track of correctly inputted integers
	mov			eax, numnum					; printing number stored in numnum (no line break between this and following printed string)
	call		writedec
	mov			edx, offset numline1		; printing "Enter Number: "
	call		writestring
	ret										; return to main
numberLine	ENDP

; The printResults procedure prints out the number of correctly inputted negative integers and the sum of those integers.  It also gets the 
; absolute value of the sum of the negative integers, because when I was generating the average of the inputted integers, I needed
; to use the resulting remainder generated from div to produce the 3 digits after the decimal (in order to print a floating point
; number).  idiv was too awkward to use, so I decided to work with non-signed numbers and then simply insert a '-' character
; in front of my average.  Once it gets the absolute value of sumTotal, it divides the sum by the number in numnum to get the
; non decimal digits (the stuff to the left of the decimal point) of the average.  It then calls division loop, which handles the work
; of generating the three digits to the right of the decimal point
printResults	PROC
	mov			edx, offset result1			; printing number of inputted negative integers
	call		writestring
	mov			eax, numnum
	call		writedec
	mov			edx, offset result2			; printing sum of inputted negative integers
	call		writestring
	mov			eax, numTotal
	call		writeint
	call		crlf
	mov			edx, offset result4			; starting process of printing average of inputted negative integers
	call		writestring
	xor			edx, edx					; clearing edx for division
	imul		eax, -1						; getting absolute value of summed integers
	div			numnum						; dividing sum of integers by numnum to get average
	call		writedec					; printing digits to left of decimal point
	xchg		ebx, edx					; moving remainder to ebx so decimal point can be printed
	mov			edx, offset period			; printing decimal point
	call		writestring
	call		divisionLoop				; calling divisionLoop so 3 digits to right of decimal point can be calculated
	ret										; return to main
printResults	ENDP

; divisionLoop uses the remainder to calculate 3 numbers to right of decimal point.  The remainder is multiplied by 10 and then 
; divided by numnum.  The result is then printed 2 more times.  
divisionLoop	PROC
	xchg		ebx, edx					; moving remainder to edx, so it can be later be moved to eax for div
	mov			ecx, 3						; initializing counter for loop
; division multiplies the remainder by 10 and then divides that by numnum to generate the first digit to the right of the decimal point.
; it generates the remaining 2 digits by taking the remainders (from each division) and again multiplying them by 10 and, again, dividing 
; by numnum.  I ultimately realized that I could have just multiplied the remainder by 1000 and divided by numnum to get the 3 digits I needed,
; but there were certain situations where that wouldn't work properly (specifically if there was no remainder), and I didn't want to code the conditionals
; to deal with that after producing this functional code
division:			
	xchg		eax, edx					; swapping eax and edx because we're more concerned with remainder
	xor			edx, edx					; clearing edx for division
	mul			tenten						; multiplying remainder by 10
	div			numnum						; dividing by original divisor
	call		writedec					; printing digit
	loop		division					; restarting loop (run through loop 3 times in total)
	ret										; return to printResults
divisionLoop	ENDP

END main
