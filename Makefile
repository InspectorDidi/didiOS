default: run

build: didiOS.iso

run: didiOS.iso
	qemu-system-x86_64 -cdrom didiOS.iso

multiboot_header.o: multiboot_header.asm
	nasm -f elf64 multiboot_header.asm

boot.o: boot.asm
	nasm -f elf64 boot.asm

kernel.bin: multiboot_header.o boot.o linker.ld
	bin/x86_64-linux-ld --nmagic -o kernel.bin --script linker.ld multiboot_header.o boot.o

didiOS.iso: kernel.bin grub.cfg
	mkdir -p isofiles/boot/grub
	cp grub.cfg isofiles/boot/grub
	cp kernel.bin isofiles/boot
	grub-mkrescue -o didiOS.iso isofiles

clean:
	rm -f multiboot_header.o
	rm -f boot.o
	rm -f kernel.bin
	rm -rf isofiles
	rm -f didiOS.iso
