all: sim/image

kernel:
	sdasz80 -o entry.s
	sdcc -mz80 --no-std-crt0 -c main.c
	sdcc -mz80 --no-std-crt0 --code-loc 0xc010 --data-loc 0x8000 -o main.ihx entry.rel main.rel
	srec_cat main.ihx -intel -offset -0xc000 -o main.bin -binary

boot:
	sdasz80 -o boot.s
	sdcc -mz80 --no-std-crt0 --code-loc 0 -o boot.ihx boot.rel
	srec_cat boot.ihx -intel -o boot.bin -binary

sim/image: boot kernel
	dd if=/dev/zero of=image bs=1k count=1024
	dd if=boot.bin of=image conv=notrunc
	dd if=main.bin of=image conv=notrunc bs=512 seek=3

simh:
	altairz80 simh.conf N8VEM_simh_z.rom

clean:
	-rm *.rel *.ihx *.asm *.sym *.lst *.map *.noi *.lk *.bin image
