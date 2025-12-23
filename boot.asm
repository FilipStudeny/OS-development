[BITS 16]
[ORG 0]

jmp 0x7C0:start     ; Set CS

start:
    cli             ; Disable interrupts during setup

    mov ax, 0x7C0
    mov ds, ax
    mov es, ax

    xor ax, ax
    mov ss, ax
    mov sp, 0x7C00  ; Stack grows downward from here

    sti             ; Enable interrupts (REQUIRED for HLT)

    mov si, message
    call print

End:
    hlt             ; Sleep until next interrupt
    jmp End         ; Resume sleep again

; Print null-terminated string
print:
    lodsb
    test al, al
    jz .done
    call printCharacter
    jmp print

.done:
    ret

printCharacter:
    mov ah, 0x0E
    int 0x10
    ret

message:
    db 'Hello world!', 0

times 510 - ($ - $$) db 0
dw 0xAA55
