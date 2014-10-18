; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================
; definicion de rutinas de atencion de interrupciones

%include "imprimir.mac"

BITS 32

sched_tarea_offset:     dd 0x00
sched_tarea_selector:   dw 0x00
errorDiv: db "e r r o r   e n   d i v i s i o n",10,0

;; PIC
extern fin_intr_pic1

;; Sched
extern sched_proximo_indice

;extern printf
;;
;; Definición de MACROS
;; -------------------------------------------------------------------------- ;;
%macro ISR 1
global _isr%1 

_isr%1:
    ; xchg bx, bx
    mov eax, %1
    ; mov edi,0xb800
    ; mov byte [edi],71
    ; inc edi
    ; mov byte [edi],71
    ; inc edi
    ; mov byte [edi],71
    ; inc edi
    ; mov byte [edi],71
    ; inc edi
    ; mov byte [edi],71

    jmp $

%endmacro

;;
;; Datos
;; -------------------------------------------------------------------------- ;;
; Scheduler
isrnumero:           dd 0x00000000
isrClock:            db '|/-\'

;;
;; Rutina de atención de las EXCEPCIONES
;; -------------------------------------------------------------------------- ;;
ISR 0 ; _isr0
ISR 1 ; _isr0
ISR 2 ; _isr0
ISR 3 ; _isr0
ISR 4 ; _isr0
ISR 5 ; _isr0
ISR 6 ; _isr0
ISR 7 ; _isr0
ISR 8 ; _isr0
ISR 9 ; _isr0
ISR 10 ; _isr0
ISR 11 ; _isr0
ISR 12 ; _isr0
ISR 13 ; _isr0
ISR 14 ; _isr0
ISR 15 ; _isr0
ISR 16 ; _isr0
ISR 17 ; _isr0
ISR 18 ; _isr0
ISR 19 ; _isr0

; ISR 1
; ISR 2
; ISR 3
;;
;; Rutina de atención del RELOJ
;; -------------------------------------------------------------------------- ;;

;;
;; Rutina de atención del TECLADO
;; -------------------------------------------------------------------------- ;;

;;
;; Rutinas de atención de las SYSCALLS
;; -------------------------------------------------------------------------- ;;

%define IZQ 0xAAA
%define DER 0x441
%define ADE 0x83D
%define ATR 0x732


;; Funciones Auxiliares
;; -------------------------------------------------------------------------- ;;
proximo_reloj:
        pushad
        inc DWORD [isrnumero]
        mov ebx, [isrnumero]
        cmp ebx, 0x4
        jl .ok
                mov DWORD [isrnumero], 0x0
                mov ebx, 0
        .ok:
                add ebx, isrClock
                imprimir_texto_mp ebx, 1, 0x0f, 49, 79
                popad
        ret
        
        