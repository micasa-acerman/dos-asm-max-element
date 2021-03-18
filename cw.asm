sdata segment para public 'data'
 MSG_START db 'Input ditits: $'
 MSG_RESULT db 10,13,'Result: '
 M_RES db 8 dup('$')
 RESULT dw -32768
 BUF_MAX db 200
 BUF_LEN db ?
 BUF 	 db 203 dup(0);
 TEMP    db '655 542',0
sdata ends

stk segment stack
	db 256 dup(?)
stk ends
code segment para public 'code'
ASSUME cs:code,ds:sdata,ss:stk,es:sdata
start:
	; Init
	mov ax,sdata
	mov ds,ax
	mov es,ax
	
	
	; Message
	mov ah,9
	mov dx,offset MSG_START
	int 21h
	
	; Input
	mov ah,0ah
	mov dx,offset BUF_MAX
	int 21h
	
	; Основной блок
	mov si,offset BUF
read_next:
	; Read char
	call strtoint
	
	mov bx,Result
	cmp ax,bx
	jl check
	mov Result,ax
check:
	mov al, [si]
	cmp al,13
	je finish
	test al,al
	jz finish
	jmp read_next

finish:
	; Output result
	mov ax,Result
	mov di,offset M_RES
	call inttostr
	
	mov dx,offset MSG_RESULT
	mov ah,9
	int 21h
	
	; Finish
	mov ah,1
	int 21h
	
	mov ax,4c00h
	int 21h
	; Procedurs
	
	; Int to str:
	;  - ax = digit
	;  - es:di = buf out
inttostr proc
	push cx
	push dx
	push bx
	
	cmp ax,0
	jnl @@m0
	push ax
	mov al,'-'
	STOSb
	pop ax
	neg ax
@@m0:
	mov bx,10
	xor cx,cx
@@m1:
	xor dx,dx
	div bx
	push dx
	inc cx
	test ax,ax
	jne @@m1
@@m2:
	pop ax
	add al,'0'
	STOSb
	LOOP @@m2
	pop bx
	pop dx
	pop cx
	ret
inttostr endp
	
	; String to int
	;  - ds:si = string
	;  - ax = output number
strtoint proc
	mov dl,ds:si
	cmp dl,'-'
	jne @s1
	push 1
	jmp @s2
@s1:
	push 0
	jmp @s2
@s2:
	xor dx,dx
@lp1:
	xor ax,ax
	lodsb
	test al,al
	jz @ex
	cmp al,' '
	je @ex
	cmp al,'9'
	jnbe @lp1
	cmp al,'0'
	jb @lp1
	sub ax,'0'
	shl dx,1
	add ax,dx
	shl dx,2
	add dx, ax
	jmp @lp1
@ex: 
	pop ax
	test ax,ax
	jz @s3
	neg dx
@s3:
	mov ax,dx
	ret
strtoint endp
	code ends
	end start