[BITS 16]
[ORG 0]

BootEntry:
    jmp short BootStart
    nop

times 33 db 0               ; BPB space

; ---------------------------
; Interrupt handlers)
; ---------------------------
HandleInterrupt0:
    push ax
    push bx
    mov ah, 0Eh
    mov al, 'A'
    mov bx, 0x0007
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

BootDrive: db 0             ; store BIOS boot drive here

InitSegments:
    cli

    mov ax, 0x7C0
    mov ds, ax              ; DS = 7C0
    mov es, ax              ; ES = 7C0
    xor ax, ax
    mov ss, ax
    mov sp, 0x7000

    mov [BootDrive], dl     ; preserve boot drive

    ; Install interrupt handlers 
    xor ax, ax
    mov es, ax              ; ES=0 for IVT writes

    mov word [es:0x00], HandleInterrupt0
    mov word [es:0x02], 0x7C0
    mov word [es:0x04], HandleInterrupt1
    mov word [es:0x06], 0x7C0

    ; Restore ES for disk read destination
    mov ax, 0x7C0
    mov es, ax              ; ES = 7C0, so ES:BX point into boot segment

    sti

    ; ---------------------------
    ; Read sector 2 (CHS 0/0/2) into Buffer
    ; INT 13h AH=02h
    ; ES:BX = destination
    ; AL = sector count
    ; CH = cylinder, CL = sector (1-based), DH = head, DL = drive
    ; ---------------------------
ReadTry:
    mov ah, 0x02            ; read sectors
    mov al, 0x01            ; read 1 sector
    mov ch, 0x00            ; cylinder 0
    mov cl, 0x02            ; sector 2 (sector numbers start at 1)
    mov dh, 0x00            ; head 0
    mov dl, [BootDrive]     ; boot drive from BIOS
    mov bx, Buffer          ; offset within ES (7C0)
    int 0x13
    jnc ReadOk

    ; reset disk and show error
    mov ah, 0x00
    mov dl, [BootDrive]
    int 0x13

    mov si, ErrorMessage
    call PrintString
    jmp $

ReadOk:
    mov si, Buffer
    call PrintString
    jmp $

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

ErrorMessage:
    db 'Failed to load sector', 0

Buffer:
    times 128 db 0      

times 510 - ($ - $$) db 0
dw 0xAA55
