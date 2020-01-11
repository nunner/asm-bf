[org 0x7c00]
[bits 16]

start equ 0x1000
prog equ 0x2000

mov bx, start
mov si, prog

; input loop

loop:
	call input
	call store
	call print
	cmp al, 0x0d
	je init
	cmp al, 0x08
	jne loop
	dec si
	jmp loop

; get input

input:
	push bx;
	mov ah, 0x00
	mov bh, 0
	int 16h
	pop bx
	ret

; store input at memory region

store:
	mov ah, 0
	mov [si], ax
	inc si
	ret

print:
	push bx
	mov ah, 0x0e
	int 10h
	pop bx
	ret

newline:
	pusha

	mov bh, 0
	mov ah, 0x03
	int 0x10

	inc dh
	mov dl, 0
	mov ah, 0x02
	int 0x10
	
	popa
	ret

init:
	call newline
	call newline
	mov si, prog
	mov bx, start - 1
	jmp parse
	
parse:
	cmp si, 0x3000
	je end

	inc si
	mov ax, [si]

	cmp al, '>'
	je right

	cmp al, '<'
	je left
	
	cmp al, '+'
	je inc

	cmp al, '-'
	je dec

	cmp al, '.'
	je write

	cmp al, '['
	je loop_enter
	
	cmp al, ']'
	je loop_return

	jmp parse 

end:
	jmp $

; Brainfuck functions

; move right, if at limit -> jump back to start
right:
	cmp bx, start 
	jne cright
	mov bx, prog 
	
	cright:
	inc bx
	jmp parse

; move left, if at start -> jump to limit
left:
	cmp bx, start 
	jne cleft
	mov bx, prog 
	
	cleft:
	dec bx
	jmp parse 

inc:
	mov ax, [bx]
	inc ax
	mov [bx], ax
	jmp parse

dec:
	mov ax, [bx]
	dec ax
	mov [bx], ax
	jmp parse 

write:
	mov ax, [bx]
	mov ah, 0
	call print	
	jmp parse 

loop_enter:
	cmp byte [bx], 0
	jne lec
	pop si
	jmp parse
	
	lec:
	add esp, 4
	push si

loop_return:
	cmp byte [bx], 0
	jne lrc
	add esp, 4

	lrc:
	mov ax, si
	pop si
	push ax
	jmp parse 

times 510 - ($ - $$) db 0
dw 0xaa55
