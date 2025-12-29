[BITS 16]
[ORG 0]

BootEntry:
    jmp short BootStart
    nop

times 33 db 0               ; BPB space

; ---------------------------
; Interrupt handlers
; ---------------------------

HandleInterrupt0:
    push ax
    push bx

    mov ah, 0Eh
    mov al, 'A'
    mov bx, 0x0007          ; page 0, white on black
    int 0x10

    pop bx
    pop ax
    iret

HandleInterrupt1:
    push ax
    push bx

    mov ah, 0Eh
    mov al, 'V'
    mov bx, 0x0007
    int 0x10

    pop bx
    pop ax
    iret


BootStart:
    jmp 0x7C0:InitSegments

InitSegments:
    cli                     ; No interrupts during setup

    mov ax, 0x7C0
    mov ds, ax
    mov es, ax

    xor ax, ax
    mov ss, ax
    mov sp, 0x7000          ; safer stack (below bootloader)

    ; ---------------------------
    ; Install interrupt handlers
    ; ---------------------------

    xor ax, ax
    mov es, ax              ; ES = 0 → IVT base

    ; INT 0
    mov word [es:0x00], HandleInterrupt0
    mov word [es:0x02], 0x7C0

    ; INT 1
    mov word [es:0x04], HandleInterrupt1
    mov word [es:0x06], 0x7C0

    sti                   

    ; Trigger INT 1
    int 1

    mov si, BootMessage
    call PrintString

IdleLoop:
    hlt
    jmp IdleLoop


PrintString:
    lodsb
    test al, al
    jz .done
    call PrintChar
    jmp PrintString
.done:
    ret

PrintChar:
    mov ah, 0Eh
    mov bx, 0x0007
    int 0x10
    ret

BootMessage:
    db 'Hello world!', 0

times 510 - ($ - $$) db 0
dw 0xAA55
