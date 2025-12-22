[BITS 16]              ; 16-bit real mode
[ORG 0x7c00]           ; BIOS loads boot sector here

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

PrintText:
    mov ah, 0x13       ; BIOS: write string
    mov al, 1          ; update cursor
    mov bx, 0x000A     ; page 0, light green text
    xor dx, dx         ; row 0, column 0
    mov bp, Message    ; address of string
    mov cx, MessageLen ; string length
    int 0x10

End:
    hlt
    jmp End            ; infinite loop

Message:
    db "Hello"

MessageLen equ $ - Message


times (0x1BE - ($ - $$)) db 0

; Partition table entry (16 bytes)

    db 80h             ; bootable partition
    db 0, 2, 0         ; starting CHS
    db 0F0h            ; partition type (placeholder)
    db 0FFh, 0FFh, 0FFh ; ending CHS
    dd 1               ; starting LBA
    dd (20*16*63 - 1)  ; number of sectors

times (16*3) db 0      ; remaining partition entries

; -------------------------------------------------
; Boot signature
; -------------------------------------------------

    db 0x55
    db 0xAA
