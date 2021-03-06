default: build

build: target/kernel.bin

run: target/didiOS.iso
	qemu-system-x86_64 -cdrom target/didiOS.iso

cargo:
	xargo build --release --target x86_64-unknown-didios-gnu

target/multiboot_header.o: src/asm/multiboot_header.asm
	mkdir -p target
	nasm -f elf64 src/asm/multiboot_header.asm -o target/multiboot_header.o

target/boot.o: src/asm/boot.asm
	mkdir -p target
	nasm -f elf64 src/asm/boot.asm -o target/boot.o

target/kernel.bin: target/multiboot_header.o target/boot.o src/asm/linker.ld cargo
	bin/x86_64-linux-ld --nmagic -o target/kernel.bin --script src/asm/linker.ld target/multiboot_header.o target/boot.o target/x86_64-unknown-didios-gnu/release/libdidios.a

target/didiOS.iso: target/kernel.bin src/asm/grub.cfg
	mkdir -p target/isofiles/boot/grub
	cp src/asm/grub.cfg target/isofiles/boot/grub
	cp target/kernel.bin target/isofiles/boot
	grub-mkrescue -o target/didiOS.iso target/isofiles

clean:
	cargo clean
