ASM      = boot.asm
BIN      = boot.bin
IMG      = boot.img
MSG      = message.txt

NASM     = nasm
QEMU     = qemu-system-x86_64

.PHONY: all build run clean rebuild

all: build

build: $(IMG)

# Assemble boot sector (MUST be 512 bytes)
$(BIN): $(ASM)
	$(NASM) -f bin $(ASM) -o $(BIN)
	@if [ $$(stat -c%s $(BIN)) -ne 512 ]; then \
		echo "Error: $(BIN) must be exactly 512 bytes"; \
		exit 1; \
	fi

# Create disk image and append message.txt after boot sector
$(IMG): $(BIN) $(MSG)
	dd if=/dev/zero of=$(IMG) bs=512 count=4
	dd if=$(BIN) of=$(IMG) bs=512 count=1 conv=notrunc
	dd if=$(MSG) of=$(IMG) bs=512 seek=1 conv=notrunc

run: $(IMG)
	$(QEMU) \
		-drive format=raw,file=$(IMG) \
		-boot order=c \
		-no-reboot

rebuild: clean all

clean:
	rm -f $(BIN) $(IMG)
