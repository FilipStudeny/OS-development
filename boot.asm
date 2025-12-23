[BITS 16]
[ORG 0]

BootEntry:
    jmp short BootStart     ; Jump over BPB / header
    nop

times 33 db 0               ; Reserved BPB space

BootStart:
    jmp 0x7C0:InitSegments  ; Far jump to fix CS

InitSegments:
    cli                     ; Disable interrupts during setup

    mov ax, 0x7C0
    mov ds, ax
    mov es, ax

    xor ax, ax
    mov ss, ax
    mov sp, 0x7C00           ; Initialize stack

    sti                     ; Enable interrupts (required for HLT)

    mov si, BootMessage
    call PrintString

IdleLoop:
    hlt                     ; Sleep until interrupt
    jmp IdleLoop

; PrintString: prints DS:SI string
PrintString:
    lodsb
    test al, al
    jz PrintDone
    call PrintChar
    jmp PrintString

PrintDone:
    ret

; PrintChar: prints character in AL
PrintChar:
    mov ah, 0x0E
    int 0x10
    ret

BootMessage:
    db 'Hello world!', 0

times 510 - ($ - $$) db 0
dw 0xAA55
