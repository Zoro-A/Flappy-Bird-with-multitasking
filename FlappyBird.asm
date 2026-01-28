[org 0x0100]

jmp start
gameName:db 'Flappy Bird'
groupname:db 'Hawk Tuah'
name1:db 'Mahhee Ibn Ahmar Bukhari '
rollNumber1:db '23L-0990'
name2:db 'Muhammad Ali Mahoon'
rollNo2:db '23L-0531'
instructions: db 'Up key -> Goes Upward && ESC -> Pauses the Game' 
presstoplay: db 'press any key to start the game'

birdPosition:dw 1930
birdDirection:db'D'

upperpillarRow: dw 0
lowerpillarRow:dw 22
pillarWidth:dw 14		;The width of the pillar is in bytes of the screen 
pillarHeight:dw 8
firstPillarOffset:dw 50
secondPillarOffset:dw 96
thirdPillarOffset:dw 142

firstPillarHeight:dw 7
secondPillarHeight:dw 10
thirdPillarHeight:dw 4

firstLowerHeight:dw 10
secondLowerHeight:dw 7
thirdLowerHeight:dw 13

paused: dw 0
pauseScreenString:db 'Press Y to end the game or press N to resume',0 ;44
randomUpper:dw 13,5,9,4,10,7
randomLower:dw 4,12,9,13,7,10
count:dw 0
scoreString: db 'Score:'
score:dw 0
endGameString:db 'GAME IS OVER',0;12
oldisr:dd 0

collisonCheck:db 'N'

seconds:dw 0
isReleased:dw 0

pcb: times 32*16 dw 0 ; space for 32 PCBs
stack: times 32*256 dw 0 ; space for 32 512 byte stacks
nextpcb: dw 1 ; index of next free pcb
current: dw 0 ; index of current pcb
lineno: dw 0 ; line number for next thread
isEscapePressed:dw 0
sound_data:  dw 1193, 1064, 947, 843, 752, 670, 597, 0 ; Sample frequencies (0 ends the tune)

isNpressed:db 0
isYpressed:db 0
; isEscapePressed:dw 0
oldTimer:dd 0

delay1:
	mov cx,0xFFFF
	
	delay1_loop:
		loop delay1_loop
		
	mov cx,0xFFFF
	delay1_loop2:
		loop delay1_loop2
		
ret
delay:
    push cx
    push bx
    push ax

    mov cx, 01H  ; Reduced outer loop counter
    mov bx, 01H  ; Reduced inner loop counter

delay_loop:
    mov ax, 0
inner_delay_loop:
    dec ax
    jnz inner_delay_loop  ; Inner delay loop
    loop delay_loop       ; Outer delay loop

    pop ax
    pop bx
    pop cx
ret


myTask:          ; Clear ES
    pusha
    infinite_sound_loop:
        ; Set up sound for the current note
        mov al, 182
        out 43h, al
        mov bx, 1193180
        div bx
        out 42h, al
        mov al, ah
        out 42h, al
        in al, 61h
        or al, 00000011b
        out 61h, al

        ; Delay for a duration to keep the sound playing
        mov bx, 3
    delay_loop1:
        mov cx, 65535
    delay_loop2:
        dec cx
        jne delay_loop2
        dec bx
        jne delay_loop1

        ; Turn off sound briefly (optional, for a pause effect)
        in al, 61h
        and al, 11111100b
        out 61h, al
        ; Loop back to play sound continuously
        jmp infinite_sound_loop

	popa
ret
	

clrscreen:
    pusha
	push cs
	pop ds
    mov ax, 0xb800         ; Video memory segment
    mov es, ax
    xor di, di             ; Start at the beginning of video memory

	loop_clear:
		mov word [es:di], 0x0720 ; 0x07 (black background, grey text), 0x20 (space)
		add di, 2              ; Move to the next character cell
		cmp di, 4000           ; 4000 bytes = 80 columns * 25 rows * 2 bytes per cell
		jne loop_clear         ; Loop until all cells are cleared

		popa
ret


background:
	push ax
	push cs
	pop ds
	mov di,0
	mov ax,0xb800
	mov es,ax

	loop1:
	mov word[es:di],0x1720
	add di,2
	cmp di,4000
	jne loop1


	pop ax;
ret;

pauseScreen:
	pusha
		push cs
	pop ds
	push 0xb800
	pop es
	mov di,0
	
	mov cx,4000

_loop3:
		mov word[es:di],0xBF20
		add di,2
		loop _loop3
	
	mov ah,0x13
	mov al,0x1
	mov bh,0
	mov bl,0xc
	mov dx,0x0A80
	mov cx,37
	push cs
	pop es
	mov bp,pauseScreenString
	int 0x10	
	popa
	
ret

collisionDetecting:
    push bp
	mov bp,sp
	push ax
	push di
	push es
		push cs
	pop ds

    ; Get bird's position in video memory
   mov di,[bp+4]

    ; Set video memory segment
    mov ax, 0xb800
    mov es, ax

    ; Check for collision
    mov ax, [es:di]
    cmp ax, 0x1720         ; Check if it's blue sky
    je no_collision

    ; Collision detected, terminate the game
	jmp exit
   

no_collision:
    pop es
	pop di
	pop ax
	pop bp
    ret 2
	
endGameScreen:
	push 0xb800
	pop es
	mov di,0
		push cs
	pop ds
	
	mov cx,4000
		
	_loop1:
		mov word[es:di],0xBF20
		add di,2
		loop _loop1
		
	mov ah,0x13
	mov al,0x1
	mov bh,0
	mov bl,0xc
	mov dx,0x0470
	mov cx,12
	push cs
	pop es
	mov bp,endGameString
	int 0x10
	
	mov dx,0x0674
	mov cx,6
	mov bp,scoreString
	int 0x10
	
	push 1208
	mov ax,[score]
	push ax
	call printScore
	
ret
		
printstr:
		push bp
		mov bp, sp
		push es
		push ax
		push cx
		push si
		push di
			push cs
	pop ds

		mov ax, 0xb800
		mov es, ax				; point es to video base

		mov di, 3982			; point di to required location
		mov si, [bp+6]			; point si to string
		mov cx, [bp+4]			; load length of string in cx
		mov ah,0x6F		; load attribute in ah

	nextchar:	
		mov al, [si]			; load next char of string
		mov [es:di], ax			; show this char on screen
		add di, 2				; move to next screen location
		add si, 1				; move to next char in string
		call delay
		loop nextchar			; repeat the operation cx times

	pop di
	pop si
	pop cx
	pop ax
	pop es
	pop bp
ret 4

upperpillar:
	push bp
	mov bp,sp
		push cs
	pop ds
	mov ax,0xb800
	mov es,ax
	mov di,0
	add di,[firstPillarOffset]
	mov bx,di
	add bx,[pillarWidth]
	mov dx,[firstPillarHeight]
	mov ax,[bp+4]
	push di
	push bx
loopu:
	mov word[es:di],ax
	add di,2
	
	cmp di,bx
	jne loopu
	
pushing:
	pop bx
	pop di
	add bx,160
	add di,160
	
	push di
	push bx
	
	sub dx,1
	cmp dx,0
	jne loopu

pop bx
pop di


secondPillar:
	mov ax,0xb800
	mov es,ax
	mov di,0
	add di,[secondPillarOffset]
	mov bx,di
	add bx,[pillarWidth]
	mov dx,[secondPillarHeight]
	push di
	push bx
	mov ax,[bp+4]
loop2:
	mov word[es:di],ax
	add di,2
	
	cmp di,bx
	jne loop2
	
pushing2:
	pop bx
	pop di
	add bx,160
	add di,160
	
	push di
	push bx
	
	sub dx,1
	cmp dx,0
	jne loop2
	
pop bx
pop di


thirdPillar:
	mov ax,0xb800
	mov es,ax
	mov di,0
	add di,[thirdPillarOffset]
	mov bx,di
	add bx,[pillarWidth]
	mov dx,[thirdPillarHeight]
	push di
	push bx
	mov ax,[bp+4]
loop3:
	mov word[es:di],ax
	add di,2
	
	cmp di,bx
	jne loop3
	
pushing3:
	pop bx
	pop di
	add bx,160
	add di,160
	
	push di
	push bx
	
	sub dx,1
	cmp dx,0
	jne loop3
	
pop bx
pop di
pop bp

ret 2


lowerpillar:
	push bp
		push cs
	pop ds
	mov bp,sp
	mov ax,0xb800
	mov es,ax
	mov di,[lowerpillarRow]
	mov ax,80
	mul di
	shl ax,1
	mov di,ax
	add di,[firstPillarOffset]
	mov bx,di
	add bx,[pillarWidth]
	mov dx,[firstLowerHeight]
	push di
	push bx
	mov ax,[bp+4]
lowerLoop1:
	mov word[es:di],ax
	add di,2
	
	cmp di,bx
	jne lowerLoop1
	
pushingL1:
	 pop bx
	 pop di
	
	 sub bx,160
	 sub di,160
	
	 push di
	 push bx
	
	 sub dx,1
	 cmp dx,0
	 jne lowerLoop1

pop bx
pop di

secondLower:
	mov ax,0xb800
	mov es,ax
	mov bx,[lowerpillarRow]
	mov ax,80
	mul bx
	shl ax,1
	mov di,ax
	add di,[secondPillarOffset]
	mov bx,di
	add bx,[pillarWidth]
	mov dx,[secondLowerHeight]
	push di
	push bx
	mov ax,[bp+4]
lowerLoop2:
	mov word[es:di],ax
	add di,2
	
	cmp di,bx
	jnz lowerLoop2
	
pushingL2:
	 pop bx
	 pop di
	
	 sub bx,160
	 sub di,160
	
	 push di
	 push bx
	
	 sub dx,1
	 cmp dx,0
	 jne lowerLoop2

pop bx
pop di

thirdLower:
	mov ax,0xb800
	mov es,ax
	mov bx,[lowerpillarRow]
	mov ax,80
	mul bx
	shl ax,1
	mov di,ax
	add di,[thirdPillarOffset]
	mov bx,di
	add bx,[pillarWidth]
	mov dx,[thirdLowerHeight]
	push di
	push bx
	mov ax,[bp+4]
lowerLoop3:
	mov word[es:di],ax
	add di,2
	
	cmp di,bx
	jnz lowerLoop3
	
pushingL3:
	 pop bx
	 pop di
	
	 sub bx,160
	 sub di,160
	
	 push di
	 push bx
	
	 sub dx,1
	 cmp dx,0
	 jne lowerLoop3

pop bx
pop di
pop bp

ret 2
	
ground:
pusha
	push cs
	pop ds
	mov ax,0xb800
	mov es,ax
	mov bx,[lowerpillarRow]
	add bx,1
	mov ax,80
	mul bx
	shl ax,1
	mov di,ax
	
groundLoop:
	mov word[es:di],0x6720
	add di,2
	
	cmp di,4000
	
	jnz groundLoop
	popa
ret
	
scrollLeft:
	pusha
		push cs
	pop ds
	push 0x1720
	call upperpillar
	push 0x1720
	call lowerpillar
	sub word[firstPillarOffset],2
	sub word[secondPillarOffset],2
	sub word[thirdPillarOffset],2
	
	cmp word[firstPillarOffset],0
	jnz compare2
	
	cmp word[count],12
	jnz moveAsitis
	mov word[count],0
	
moveAsitis:	
	mov si,[count]
	mov bx,randomUpper
	mov ax,[bx+si]
	mov [firstPillarHeight],ax
	
	mov bx,randomLower
	mov ax,[bx+si]
	mov [firstLowerHeight],ax
	
	add si,2
	mov [count],si
	
	mov ax,150
	mov [firstPillarOffset],ax

compare2:	
	cmp word[secondPillarOffset],0
	jnz compare3
	
	
	mov si,[count]
	mov bx,randomUpper
	mov ax,[bx+si]
	mov [secondPillarHeight],ax
	
	mov bx,randomLower
	mov ax,[bx+si]
	mov [secondLowerHeight],ax
	
	add si,2
	mov [count],si
	mov ax,150
	mov [secondPillarOffset],ax
	
compare3:
	cmp word[thirdPillarOffset],0
	jnz draw
	
	
	mov si,[count]
	mov bx,randomUpper
	mov ax,[bx+si]
	mov [thirdPillarHeight],ax
	
	mov bx,randomLower
	mov ax,[bx+si]
	mov [thirdLowerHeight],ax
	
	add si,2
	mov [count],si
	mov ax,150
	mov [thirdPillarOffset],ax

draw:
	push 0x2720
	call upperpillar
	push 0x2720
	call lowerpillar
	popa
ret
printScore: 
		push bp
		mov bp, sp
			push cs
	pop ds
		push es
		push ax
		push bx
		push cx
		push dx
		push di

		mov ax, 0xb800
		mov es, ax			; point es to video base

		mov ax, [bp+4]		; load number in ax= 4529
		mov bx, 10			; use base 10 for division
		mov cx, 0			; initialize count of digits

	nextdigit:		
		mov dx, 0			; zero upper half of dividend
		div bx				; divide by 10 AX/BX --> Quotient --> AX, Remainder --> DX ..... 
		add dl, 0x30		; convert digit into ascii value
		push dx				; save ascii value on stack

		inc cx				; increment count of values
		cmp ax, 0			; is the quotient zero
		jnz nextdigit		; if no divide it again


		mov di, [bp+6]			; point di to top left column
	nextpos:	
		pop dx				; remove a digit from the stack
		mov dh, 0x6F		; use normal attribute
		mov [es:di], dx		; print char on screen
		add di, 2			; move to next screen location
		loop nextpos		; repeat for all digits on stack

pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 4

calculateScore:
	pusha
		push cs
	pop ds
	cmp word[firstPillarOffset],2
	jnz pillar2
	mov ax,[score]
	add ax,1
	mov [score],ax
	
pillar2:
	cmp word[secondPillarOffset],2
	jnz pillar3
	mov ax,[score]
	add ax,1
	mov [score],ax
	
pillar3:
	cmp word[thirdPillarOffset],2
	jnz end1
	mov ax,[score]
	add ax,1
	mov [score],ax
	
end1:
popa
	ret 
	
bird:

	push ax
	push di
	push es
	mov ah,0x14
	mov al,0xDB
	
	push 0xb800
	pop es
		push cs
	pop ds
	
	mov di,[birdPosition]
	mov word[es:di],ax
	pop es 
	pop di
	pop ax 
	ret
	
kbisr:
	push ax
	push es
	
	mov ax,0xb800
	mov es,ax
	
	in al,0x60
	cmp al,0x48
	
	jne nextcomp
	mov byte[birdDirection],'U'
	mov word[isReleased],0
	jmp nomatch
	
nextcomp:
	cmp al,0xc8
	jne nomatch
	
	mov word[birdDirection],'D'
	;jmp kbisr
	
nomatch:
	cmp al,0x01     ;escape key 
	je escape_pressed
	
	mov al,0x20
	out 0x20,al
	pop es
	pop ax
	iret
	;jmp far[cs:oldisr]
escape_pressed:
		mov word[isEscapePressed],1
		call clrscreen          ; Clear the screen

		; Display confirmation message
		mov ax, 0xb800          ; Set video memory segment
		mov es, ax
		mov di, 160 * 12 + 30   ; Position at row 12, column 30

		lea si, pauseScreenString
.print_message:
		lodsb
		cmp al, 0
		je wait_choice         ; End of message
		mov ah, 0x0F            ; Set text attribute (white on black)
		mov word [es:di], ax
		add di, 2
		jmp .print_message

wait_choice:
		in al, 0x60             ; Wait for another keypress
		cmp al, 0x15            ; Check for 'Y'
		jnz Ncheck 
		mov byte[isYpressed],1
		jmp khatam

Ncheck:		
		cmp al, 0x31            ; Check for 'N'
		jnz wait_choice
		mov byte[isNpressed],1
								; Loop if invalid key
khatam:
		mov al,0x20
		out 0x20,al
		pop es
		popa
		iret
		
initpcb: 	
		push bp
		mov bp, sp
		push ax
		push bx
		push cx
		push si
		
		mov bx, [nextpcb] ; read next available pcb index
		cmp bx, 32 ; are all PCBs used
		je exit2 ; yes, exit
		
		mov cl, 5
		shl bx, cl ; multiply by 32 for pcb start ix2^5 
		
		mov ax, [bp+8] ; read segment parameter
		mov [pcb+bx+18], ax ; save in pcb space for cs
		mov ax,[bp+6] ; read offset parameter
		mov [pcb+bx+16], ax ; save in pcb space for ip
		mov [pcb+bx+22], ds ; set stack to our segment
		
		mov si, [nextpcb] ; read this pcb index
		mov cl, 9
		shl si, cl ; multiply by 512...ix2^9 (512)
		add si, 256*2+stack ; end of stack for this thread
		mov ax, [bp+4] ; read parameter for subroutine
		sub si, 2 ; decrement thread stack pointer
		mov [si], ax ; pushing param on thread stack
		sub si, 2 ; space for return address
		mov [pcb+bx+14], si ; save si in pcb space for sp
		
		mov word [pcb+bx+26], 0x0200 ; initialize thread flags
		mov ax, [pcb+28] ; read next of 0th thread in ax
		mov [pcb+bx+28], ax ; set as next of new thread
		
		mov ax, [nextpcb] ; read new thread index
		mov [pcb+28], ax ; set as next of 0th thread
		
		inc word [nextpcb] ; this pcb is now used
		
		exit2: 
		pop si
		pop cx
		pop bx
		pop ax
		pop bp
	ret 6

timer_music:
			push ds
			push bx
			push cs
			pop ds ; initialize ds to data segment
			
			mov bx, [current] ; read index of current in bx
			shl bx, 1
			shl bx, 1
			shl bx, 1
			shl bx, 1
			shl bx, 1 ; multiply by 32 for pcb start
			
			mov [pcb+bx+0], ax ; save ax in current pcb
			mov [pcb+bx+4], cx ; save cx in current pcb
			mov [pcb+bx+6], dx ; save dx in current pcb
			mov [pcb+bx+8], si ; save si in current pcb
			mov [pcb+bx+10], di ; save di in current pcb
			mov [pcb+bx+12], bp ; save bp in current pcb
			mov [pcb+bx+24], es ; save es in current pcb
			pop ax ; read original bx from stack
			mov [pcb+bx+2], ax ; save bx in current pcb
			pop ax ; read original ds from stack
			mov [pcb+bx+20], ax ; save ds in current pcb
			pop ax ; read original ip from stack
			mov [pcb+bx+16], ax ; save ip in current pcb
			pop ax ; read original cs from stack
			mov [pcb+bx+18], ax ; save cs in current pcb
			pop ax ; read original flags from stack
			mov [pcb+bx+26], ax ; save cs in current pcb
			mov [pcb+bx+22], ss ; save ss in current pcb
			mov [pcb+bx+14], sp ; save sp in current pcb
			
			mov bx, [pcb+bx+28] ; read next pcb of this pcb
			mov [current], bx ; update current to new pcb
			mov cl, 5
			shl bx, cl ; multiply by 32 for pcb start
			
			mov cx, [pcb+bx+4] ; read cx of new process
			mov dx, [pcb+bx+6] ; read dx of new process
			mov si, [pcb+bx+8] ; read si of new process
			mov di, [pcb+bx+10] ; read diof new process
			mov bp, [pcb+bx+12] ; read bp of new process
			mov es, [pcb+bx+24] ; read es of new process
			mov ss, [pcb+bx+22] ; read ss of new process
			mov sp, [pcb+bx+14] ; read sp of new process
			push word [pcb+bx+26] ; push flags of new process
			push word [pcb+bx+18] ; push cs of new process
			push word [pcb+bx+16] ; push ip of new process
			push word [pcb+bx+20] ; push ds of new process
			
			mov al, 0x20
			out 0x20, al ; send EOI to PIC
			
			mov ax, [pcb+bx+0] ; read ax of new process
			mov bx, [pcb+bx+2] ; read bx of new process
			pop ds ; read ds of new process
			
			iret ; return to new process

	
IntroScreen:
pusha
	push  es
	push 0xb800
	pop es
	mov di,0
		push cs
	pop ds
	mov cx,4000
	
_loop2:
	mov word[es:di],0xBF20
	add di,2
	loop _loop2
	mov ah,0x13
	mov al,0x1
	mov bh,0
	mov bl,0xc
	mov dx,0x0470
	mov cx,11
	push cs
	pop es
	mov bp,gameName
	int 0x10
	
	mov dx,0x0671
	mov cx,9
	mov bp,groupname
	int 0x10
	
	mov dx,0x086a
	mov cx,24
	mov bp,name1
	int 0x10
	
	mov dx,0x0a71
	mov cx,8
	mov bp,rollNumber1
	int 0x10
	
	mov dx,0x0c6c
	mov cx,19
	mov bp,name2
	int 0x10
	
	mov dx,0x0e71
	mov cx,8
	mov bp,rollNo2
	int 0x10
	
	mov dx,0x105f
	mov cx,47
	mov bp,instructions
	int 0x10
	
	
	
	pop es
	popa
ret

updateBird:
pusha
	push cs
	pop ds
	mov dx,[birdPosition]
	cmp byte[birdDirection],'U'
	jne continue
	mov di,dx
	sub dx,160
	push dx
	call collisionDetecting
			mov cx,1
	_kbisr_loop2:
		loop _kbisr_loop2
		
	mov word[es:di],0x1720
	mov [birdPosition],dx
	call bird
here:
popa
ret
continue:
	mov di,dx
	add dx,160
	push dx
	call collisionDetecting
	
		mov cx,1
	_kbisr_loop:
		loop _kbisr_loop
	mov word[es:di],0x1720
		
	mov [birdPosition],dx
	call bird
jmp here



mainScreen:
pusha
	push cs
	pop ds
	call background
	push 0x2720
	call upperpillar
	push 0x2720
	call lowerpillar
	call ground
	call bird
	popa
ret

animation:
	call scrollLeft
	call delay
	call updateBird
	

	call calculateScore
	push 3996
	push word[score]
	call printScore
	
	cmp byte[isEscapePressed],1
	jnz animation
	
	cmp byte[isNpressed],1
	jnz next
	call mainScreen
	mov byte[isNpressed],0
	
	next:
	cmp byte[isYpressed],1
	je exit
	jmp animation
ret


start:
	mov ax,1003h
	mov bx,0
	int 10h
;saving old isr so that we can come back to it
	call IntroScreen
	mov ah,0
	int 0x16
	call mainScreen
	mov ah,0x13
	mov al,0x1
	mov bh,0
	mov bl,0xc
	mov dx,0x0a68
	mov cx,31
	push cs
	pop es
	mov bp,presstoplay
	int 0x10
	
	mov ah,0
	int 0x16

	xor ax,ax
	mov es,ax
	mov ax,[es:9*4]
	mov [oldisr],ax
	mov ax,[es:9*4+2]
	mov [oldisr+2],ax
	
	cli
	mov word[es:9*4],kbisr
	mov word[es:9*4+2],cs
	sti
	
	xor ax,ax
	mov es,ax
	mov ax,[es:8*4]
	mov [oldTimer],ax
	mov ax,[es:9*4+2]
	mov [oldTimer+2],ax
	
	cli
	mov word[es:8*4],timer_music
	mov [es:8*4+2],cs
	sti
	
	call mainScreen
	mov ax,scoreString
	push ax
	push 6
	call printstr
	
	
	push cs ; use current code segment
	mov ax, animation
	push ax ; use mytask as offset
	push word [lineno] ; thread parameter
	call initpcb ; register the thread
	inc word [lineno] ; update line number
	
	push cs
	mov ax,myTask
	push ax
	push word 0
	call initpcb
	jmp $ ; wait for next keypress

exit:
    mov al, 11111101b    ; Clear bit 1 (Speaker Gate)
    in  al, 61h          ; Read current state of port 61h
    and al, 11111100b    ; Clear speaker bits
    out 61h, al          ; Write back to port 61h

    ; Reset Timer Channel 2 of the PIT
    mov al, 10110110b    ; Control word: Select Channel 2, Latch Command
    out 43h, al          ; Send control word to PIT command register
    mov al, 0            ; Send initial count low byte
    out 42h, al          ; Write to Channel 2 data port
    mov al, 0            ; Send initial count high byte
	out 42h,al
	call endGameScreen
	mov ax,[oldisr]
	mov bx,[oldisr+2]
	
	push 0
	pop es
	
	mov [es:9*4],ax
	mov [es:9*4+2],bx
	
	mov ax,[oldTimer]
	mov bx,[oldTimer+2]
	
	push 0
	pop es
	mov [es:8*4],ax
	mov [es:8*4+2],bx
	
mov ax,0x4c00
int 0x21