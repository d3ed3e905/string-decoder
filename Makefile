tema2: decoder.asm
	nasm -f elf32 -o decoder.o $<
	gcc -m32 -o $@ decoder.o

clean:
	rm -f decoder decoder.o
