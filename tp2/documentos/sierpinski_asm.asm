global sierpinski_asm

section .data

offset: dd 3.0, 2.0, 1.0, 0.0
dq255:  dd 255.0,255.0,255.0,255.0

section .text

; void sierpinski_c    (
;     unsigned char *src, RDI 
;     unsigned char *dst, RSI 
;     int cols,           RDX 
;     int filas,          RCX
;     int src_row_size,   R9
;     int dst_row_size)}  R8

sierpinski_asm:
    push rbp
    mov rbp, rsp
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15 

    xor r15, r15 ; x
    xor r14, r14 ; y
    pxor xmm15, xmm15
.loop_y:
    cmp r14d, ecx
    je .endloop_y        ; y = filas

.loop_x:
    cmp r15d,edx    ; x = cols
    je .endloop_x

    xor rax, rax 
    mov rax, r15          ; rax = x
    cvtsi2ss xmm1,rax     ; xmm1 = (float) rax
    shufps xmm1, xmm1, 0h ; replico 4 veces rax en xmm1
    movups xmm2,[offset]  ; 
    addps xmm1, xmm2      ; le sumo el offset de x en los pixels (3,2,1,0)
    mov rax, r14          ; rax = y
    cvtsi2ss xmm2, rax    ; xmm2 = (float) rax
    shufps xmm2, xmm2, 0h ; replico 4 veces rax en xmm2


    ; esto puede optimizarse haciendo 255/filas y 255/cols una única vez
    ; en lugar de hacerlo en cada iteración
    movups xmm0,[dq255]
    mulps xmm1,xmm0 ; x*255
    mulps xmm2,xmm0 ; y*255

    ; int i = (int) ( floor((x*255.0)/filas) );
    ; int j = (int) ( floor((y*255.0)/cols) );

    cvtsi2ss xmm3, rdx     ; xmm3 = cols  
    shufps xmm3, xmm3, 0h  ; replico 4 veces cols en xmm3

    cvtsi2ss xmm4, rcx     ; xmm4 = filas
    shufps xmm4, xmm4, 0h  ; replico 4 veces filas en xmm4

    divps xmm1, xmm3       ; xmm1 = x*255/cols
    divps xmm2, xmm4       ; xmm2 = y*255/filas

    cvttps2dq xmm1,xmm1 ; convierte a int truncando, o sea ((int) floor(n))
    cvttps2dq xmm2,xmm2

    pxor xmm1,xmm2 ; hago el xor entre los 4 Is y los 4 Js empaquetados

    movups xmm0,[dq255]
    cvtdq2ps xmm1,xmm1 ; los convierto a float otra vez
    divps xmm1,xmm0    ; y los divido por 255.0 

    ; ahora en xmm1 tengo los 4 coefiecientes 
    ; que corresponden a los próximos cuatro PIXELS
    ; que vamos a procesar!

    movups xmm15,xmm1  ; me hago una copia de los coeficientes porque pintó.
    ; float s = (i xor j) / 255.0;

    xor rax,rax
    mov r12d,r14d ; r12 = y
    mov r13d,r15d ; r13 = x
    imul r12d,r9d ; y * row_size_src
    imul r13d,4   ; x * 4 (esto puede ser un shift left)
    mov eax,r12d  ; 
    add eax,r13d  ; rax = y*row_size_src + x*4 

    
    movdqu xmm0,[rdi+rax] ; agarró 16 bytes del source!
    movdqu xmm1,xmm0      ; y me hago una copia

    pxor xmm2,xmm2

    punpcklbw xmm0,xmm2 ; parte baja 
    movdqu xmm6,xmm0    ; copio la parte baja
    punpcklwd xmm0,xmm2 ; baja de la baja 0 
    punpckhbw xmm6,xmm2 ; alta de la baja 1

    punpckhbw xmm1,xmm2 ; alta           
    movdqu xmm7,xmm1    ; copio la parte alta
    punpckhwd xmm1,xmm2 ; alta de alta    3
    punpcklwd xmm7,xmm2 ; baja de la alta 2

    cvtdq2ps xmm0,xmm0
    cvtdq2ps xmm6,xmm6
    cvtdq2ps xmm1,xmm1
    cvtdq2ps xmm7,xmm7

    movdqu xmm14,xmm15
    shufps xmm15,xmm15, 0x00 ; 00 00 00 00
    mulps xmm1,xmm15

    movdqu xmm15,xmm14
    shufps xmm15,xmm15, 0x55 ; 01 01 01 01 
    mulps xmm7,xmm15       
    
    movdqu xmm15,xmm14
    shufps xmm15,xmm15, 0xAA ; 10 10 10 10
    mulps xmm6,xmm15
    
    movdqu xmm15,xmm14
    shufps xmm15,xmm15, 0xFF ; 11 11 11 11
    mulps xmm0,xmm15

    ; Convierto los pixels (floats) a ints empaquetados!
    cvttps2dq xmm1,xmm1
    cvttps2dq xmm0,xmm0
    cvttps2dq xmm6,xmm6
    cvttps2dq xmm7,xmm7

    ;De ints a shorts
    packusdw xmm0,xmm6
    packusdw xmm7,xmm1

    ; Y de shorts a chars :D
    packuswb xmm0,xmm7

    ; por qué necesitamos unsigned saturation? Marco señal.

    xor rax,rax
    mov r12d,r14d ; r12 = y
    mov r13d,r15d ; r13 = x
    imul r12d,r8d ; y * row_size_dest
    imul r13d,4   ; x * 4
    mov eax,r12d  ; 
    add eax,r13d  ; rax = y*row_size_dest + x*4 

    movdqa [rsi+rax],xmm0

    add r15,4 ; avanzo 4 sobre x
    jmp .loop_x
.endloop_x:
    inc r14     ; y++
    xor r15,r15 ; reinicio x
    jmp .loop_y
.endloop_y:

    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop rbp
    ret