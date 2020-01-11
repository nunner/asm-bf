QEMU=qemu-system-i386

run:
	nasm bf.asm
	$(QEMU) -fda bf
	rm bf
