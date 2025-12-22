include $(DEVKITARM)/ds_rules

payload.bin: arm9.s
	$(CC) -nostartfiles -nostdlib -x assembler-with-cpp arm9.s -Ttext=0x021254C4 -o payload.elf
	$(OBJCOPY) -O binary payload.elf $@
	@rm -f payload.elf