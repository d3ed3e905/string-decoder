extern puts
extern printf
extern strlen
extern strstr

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./input0.dat", 0
inputlen: dd 2263

fmtstr:            db "Key: %d",0xa, 0
usage:             db "Usage: %s <task-no> (task-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:     db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

xor_strings:
	; TASK 1
	
	push ebp
	mov ebp, esp
	mov eax, dword [ebp+8]	; adresa input_string
	mov ebx, dword [ebp+12]	; adresa cheie
	
xor_one_byte:
	; realizeaza xor byte cu byte intre input_string si cheie
	; suprascrie input_string

	mov dl, byte [eax]
	test dl, dl
	je out
	mov cl, byte [ebx]
	xor dl, cl
	mov byte [eax], dl
	inc eax
	inc ebx
	jmp xor_one_byte

out:	
	leave
	ret

rolling_xor:
	; TASK 2

	push ebp
	mov ebp, esp
	mov eax, dword [ebp+8]	; adresa input_string
	
	push eax
	call strlen
	mov ecx, eax	; ecx contine lungimea sirului
	pop eax	; eax contine adresa sirului
	dec ecx

decrypt_one_byte:
	; realizeaza xor intre byte-ul n si byte-ul n-1
	; modifica byte-ul n

	mov dl, byte [eax+ecx]
	mov bl, byte [eax+ecx-1]
	xor dl, bl
	mov byte [eax+ecx], dl
	loop decrypt_one_byte
	
	leave
	ret
	
hex_to_bin:
	; primeste ca parametru adresa unui sir si realizeaza conersia hex to binar
	; adauga la final terminatorul de sir

	push ebp
	mov ebp, esp
	
	mov eax, dword [ebp+8]
	mov esi, eax
	xor ecx, ecx
	
conversion:
	xor dl, dl
	mov dl, byte [eax]
	test dl, dl
	je add_null	; adauga terminatorul de sir pe pozitia ecx
	xor bl, bl
	cmp dl, '9'
	ja is_hex_letter
	sub dl, 48
	jmp next_ch
	
is_hex_letter:
	sub dl, 87
	
next_ch:
	shl dl, 4
	mov bl, dl
	inc eax
	
	mov dl, byte [eax]
	cmp dl, '9'
	ja is_next_hex_letter
	sub dl, 48
	jmp continue
	
is_next_hex_letter:
	sub dl, 87
	
continue:
	add bl, dl
	mov byte [esi+ecx], bl
	inc eax
	inc ecx
	jmp conversion

add_null:
	mov byte [esi+ecx], 0
	leave
	ret

xor_hex_strings:
	; TASK 3

	push ebp
	mov ebp, esp

	; conversie binar->hexa pentru input_string
	mov eax, dword [ebp+8]	; adresa input_string
	push eax
	call hex_to_bin
	pop eax
	
	;conversie binar->hexa pentru cheie
	mov ebx, dword [ebp+12]	; adresa cheie
	push eax
	push ebx
	call hex_to_bin
	pop ebx
	pop eax
	
	; xor intre input_string si cheie, utilizand functia de la Task 1
	push ebx
	push eax
	call xor_strings
	add esp, 8
	
	leave
	ret
	
base32_to_bin:
	; realizeaza conversia din alfabetul base32 in binar
	; suprascrie sirul dat
	
	push ebp
	mov ebp, esp
	mov eax, dword [ebp+8]	; adresa sir
	mov esi, eax
	xor ecx, ecx
	
convert:
	xor dl, dl
	mov dl, byte [eax]
	test dl, dl	; parcurg pana la 0x00
	je out
	cmp dl, "="
	je is_equal
	cmp dl, 'A'
	jb is_number
	sub dl, 65
	jmp overwrite

is_equal:
	sub dl, 61
	jmp overwrite

is_number:
	sub dl, 24
	
overwrite:
	mov byte [esi+ecx], dl
	inc ecx
	inc eax
	jmp convert

base32decode:
	; TASK 4

	push ebp
	mov ebp, esp

	mov eax, dword [ebp+8]	; adresa input_string
	mov esi, eax
	push eax
	call strlen
	mov edi, eax	; lungimea sirului
	pop eax
	push edi
	xor edi, edi
	
	push eax
	call base32_to_bin
	pop eax
	xor ecx, ecx
	
to_8_bits:
	; grupez cate 8 biti => fiecare grup rezultat reprezinta un caracter ascii
	; In realizarea grupurilor iau in considerare ultimii 5 biti din fiecare
	; octet din sirul convertit
	; => se obtin 5 grupuri, adica 5 caractere ascii per 40 biti "prelucrati"
	
	cmp edi, dword [ebp-4]
	jae add_null2
	
	; grupul 1
	xor ebx, ebx
	xor edx, edx
	mov dl, byte [eax]
	mov bl, dl
	shl bl, 3
	inc eax
	mov dl, byte [eax]
	push edx
	shr dl, 2
	or bl, dl
	mov byte [esi+ecx], bl
	inc eax
	inc ecx
	
	; grupul 2
	xor ebx, ebx
	xor edx, edx
	pop ebx
	shl bl, 6
	mov dl, byte [eax]
	shl dl, 1
	or bl, dl
	inc eax
	mov dl, byte [eax]
	push edx
	shr dl, 4
	or bl, dl
	mov byte [esi+ecx], bl
	inc eax
	inc ecx
	
	; grupul 3
	xor ebx, ebx
	xor edx, edx
	pop ebx
	shl bl, 4
	mov dl, byte [eax]
	push edx
	shr dl, 1
	or bl, dl
	mov byte [esi+ecx], bl
	inc eax
	inc ecx
	
	; grupul 4
	xor ebx, ebx
	xor edx, edx
	pop ebx
	shl bl, 7
	mov dl, byte [eax]
	shl dl, 2
	or bl, dl
	inc eax
	mov dl, byte [eax]
	push edx
	shr dl, 3
	or bl, dl
	mov byte [esi+ecx], bl
	inc eax
	inc ecx
	
	; grupul 5
	xor ebx, ebx
	xor edx, edx
	pop ebx
	shl bl, 5
	mov dl, byte [eax]
	or bl, dl
	mov byte [esi+ecx], bl
	inc eax
	inc ecx
	
	inc edi
	jmp to_8_bits
	
add_null2:
	mov byte [esi+ecx], 0
	add esp, 4
	leave
	ret

xor_singlebyte_key:
	; xor intre cheie si input_string
	; modifica stringul dat

	push ebp
	mov ebp, esp
	mov eax, dword [ebp+8]	; adresa input_string
	mov ebx, dword [ebp+12]	; key
	
repeat_xor:
	mov dl, byte [eax]
	test dl, dl
	je out
	xor dl, bl
	mov byte [eax], dl
	inc eax
	jmp repeat_xor
	
contains_force:
	; testeaza daca sirul obtinut contine "force"
	push ebp
	mov ebp, esp
	mov eax, dword [ebp+8]
	
	; scriere string "force" pe stiva
	
	sub esp, 6
	lea ebx, [ebp-6]
	mov byte [ebx], 'f'
	mov byte [ebx+1], 'o'
	mov byte [ebx+2], 'r'
	mov byte [ebx+3], 'c'
	mov byte [ebx+4], 'e'
	mov byte [ebx+5], 0x00
	
	push ebx
	push eax
	call strstr
	add esp, 8
	
	add esp, 6
	leave
	ret

bruteforce_singlebyte_xor:
	; TASK 5

	push ebp
	mov ebp, esp

	mov ebx, dword [ebp+8]	; adresa input_string
	xor ecx, ecx	; cheia de test
	mov ecx, 1
	
repeat:
	; incrementare cheie pana se obtine string-ul ce contine 'force'
	; sau pana se depaseste valoarea maxima cuprinsa pe un octet
	cmp ecx, 256
	je out_repeat
	
	;xor intre cheie si input_string
	push ecx
	push ebx
	call xor_singlebyte_key
	pop ebx
	pop ecx
	
	; testare daca contine "force"
	push ecx
	push ebx
	call contains_force
	pop ebx
	pop ecx
	
	cmp eax, 0
	jne the_right_key	; contine "force"
	
	; nu contine "force" => revenire la sirul initial
	push ecx
	push ebx
	call xor_singlebyte_key
	pop ebx
	pop ecx
	inc ecx
	jmp repeat
	
the_right_key:
	; cheia se afla in eax
	mov eax, ecx
	
out_repeat:	
	leave
	ret

decode_vigenere:
	; TASK 6

	push ebp
	mov ebp, esp
	
	mov eax, dword [ebp+8]	; adresa input_string
	mov ebx, dword [ebp+12]	; adresa cheie
	
get_initial_string:
	; parcurgere simultana sir-cheie

	mov dl, byte [eax]
	test dl, dl
	je out
	cmp dl, 'a'
	jb next_pos
	cmp dl, 'z'
	ja next_pos
	mov cl, byte [ebx]
	test cl, cl
	jne exist_key_ch
	mov ebx, dword [ebp+12]	; repetare cheie
	mov cl, byte [ebx]
	
exist_key_ch:	
	cmp dl, cl
	jb switch_dif	
	sub dl, cl
	add dl, 97
	jmp continue_get_initial_str
	
switch_dif:
	sub cl, dl
	xor dl, dl
	mov dl, 26
	sub dl, cl
	add dl, 97
	
continue_get_initial_str:
	mov byte [eax], dl
	inc eax
	inc ebx	
	
	jmp get_initial_string

next_pos:
	; caracterul nu se aflain intervalul 'a'-'z'
	inc eax
	jmp get_initial_string
	
main:
	push ebp
	mov ebp, esp
	sub esp, 2300

	; test argc
	mov eax, [ebp + 8]
	cmp eax, 2
	jne exit_bad_arg

	; get task no
	mov ebx, [ebp + 12]
	mov eax, [ebx + 4]
	xor ebx, ebx
	mov bl, [eax]
	sub ebx, '0'
	push ebx

	; verify if task no is in range
	cmp ebx, 1
	jb exit_bad_arg
	cmp ebx, 6
	ja exit_bad_arg

	; create the filename
	lea ecx, [filename + 7]
	add bl, '0'
	mov byte [ecx], bl

	; fd = open("./input{i}.dat", O_RDONLY):
	mov eax, 5
	mov ebx, filename
	xor ecx, ecx
	xor edx, edx
	int 0x80
	cmp eax, 0
	jl exit_no_input

	; read(fd, ebp - 2300, inputlen):
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80
	cmp eax, 0
	jl exit_cannot_read

	; close(fd):
	mov eax, 6
	int 0x80

	; all input{i}.dat contents are now in ecx (address on stack)
	pop eax
	cmp eax, 1
	je task1
	cmp eax, 2
	je task2
	cmp eax, 3
	je task3
	cmp eax, 4
	je task4
	cmp eax, 5
	je task5
	cmp eax, 6
	je task6
	jmp task_done

task1:
	; TASK 1: Simple XOR between two byte streams
	
	; find the address for the string and the key
	push ecx
	call strlen
	pop ecx

	add eax, ecx
	inc eax
	
	; call the xor_strings function
	push eax		   ; eax = address of key string
	push ecx                   ; ecx = address of input string 
	call xor_strings
	pop ecx
	add esp, 4	

	push ecx
	call puts                   ; print resulting string
	add esp, 4

	jmp task_done

task2:
	; TASK 2: Rolling XOR

	; call the rolling_xor function
	push ecx	; ecx = address of input string
	call rolling_xor
	pop ecx

	push ecx
	call puts	; print resulting string
	add esp, 4

	jmp task_done

task3:
	; TASK 3: XORing strings represented as hex strings

	; find the addresses of both strings
	push ecx
	call strlen
	pop ecx
	add eax, ecx
	inc eax
	
	; call the xor_hex_strings function
	push eax		   ; eax = address of key string
	push ecx                   ; ecx = address of input string 
	call xor_hex_strings
	pop ecx
	add esp, 4	

	push ecx                     ; print resulting string
	call puts
	add esp, 4

	jmp task_done

task4:
	; TASK 4: decoding a base32-encoded string

	; call the base32decode function
	push ecx	; ecx = address of input string
	call base32decode
	pop ecx
	
	push ecx
	call puts                    ; print resulting string
	pop ecx
	
	jmp task_done

task5:
	; TASK 5: Find the single-byte key used in a XOR encoding

	; call the bruteforce_singlebyte_xor function
	
	push ecx	; ecx = address of input string
	call bruteforce_singlebyte_xor
	pop ecx
	
	push eax
	push ecx                    ; print resulting string
	call puts
	pop ecx
	pop eax

	push eax                    ; eax = key value
	push fmtstr
	call printf                 ; print key value
	add esp, 8

	jmp task_done

task6:
	; TASK 6: decode Vignere cipher

	; find the addresses for the input string and key
	; call the decode_vigenere function
	push ecx
	call strlen
	pop ecx

	add eax, ecx
	inc eax

	push eax	; eax = adresa cheie
	push ecx                   ;ecx = address of input string 
	call decode_vigenere
	pop ecx
	add esp, 4

	push ecx
	call puts
	add esp, 4

task_done:
	xor eax, eax
	jmp exit

exit_bad_arg:
	mov ebx, [ebp + 12]
	mov ecx , [ebx]
	push ecx
	push usage
	call printf
	add esp, 8
	jmp exit

exit_no_input:
	push filename
	push error_no_file
	call printf
	add esp, 8
	jmp exit

exit_cannot_read:
	push filename
	push error_cannot_read
	call printf
	add esp, 8
	jmp exit

exit:
	mov esp, ebp
	pop ebp
	ret
