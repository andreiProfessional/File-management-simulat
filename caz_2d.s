.data
	NR_BLOCURI: .long 1048576 # 1048576 # 64
	NR_LIN_COL: .long 1024 # 1024 # 8
	BITI_IN_BYTE: .long 8
	ID_NUL: .long 0
	COD_ADD: .long 1
	COD_GET: .long 2
	COD_DELETE: .long 3
	COD_DEFRAGMENTATION: .long 4

	memorie: .space 4194304 # 4194304 # 256
	fin: .asciz "%d"
	fout_long: .asciz "%d\n"
	fout_str: .asciz "%s\n"
	fout_long_id_intervale: .asciz "%d: ((%d, %d), (%d, %d))\n"
	fout_long_intervale: .asciz "((%d, %d), (%d, %d))\n"
	cod_indisponibil: .asciz "OPERATIE INDISPONIBILA!"

	i_init_memorie: .space 4
	nr_op: .space 4
	i_parc_op: .space 4
	op: .space 4
	nr_fis: .space 4
	i_parc_fis: .space 4
	id_fis: .space 4
	dim_fis: .space 4
	poz: .space 4
	lung: .space 4
.text
	init_memorie:
		pushl %ebp
		movl %esp, %ebp

		lea memorie, %edi
		movl $-1, i_init_memorie
		parc_init_memorie:
			incl i_init_memorie
			movl i_init_memorie, %ecx
			cmpl %ecx, NR_BLOCURI
			je ret_init_memorie

			movl ID_NUL, %eax
			movl %eax, (%edi, %ecx, 4)

			jmp parc_init_memorie

		ret_init_memorie:
			movl %esp, %ebp
			popl %ebp
			ret

	conv_spatiu:
		pushl %ebp
		movl %esp, %ebp

		movl 8(%ebp), %ebx
		movl 0(%ebx), %eax

		movl BITI_IN_BYTE, %ebx
		xorl %edx, %edx
		divl %ebx

		cmpl $0, %edx
		je ret_conv_spatiu

		incl %eax

		jmp ret_conv_spatiu

		ret_conv_spatiu:
			movl 8(%ebp), %ebx
			movl %eax, 0(%ebx)

			movl %esp, %ebp
			popl %ebp
			ret

	get_1D:
		pushl %ebp
		movl %esp, %ebp

		movl 16(%ebp), %ebx
		movl $0, 0(%ebx)

		sar_la_id_fis:
			movl 12(%ebp), %ecx
			movl 0(%ecx), %ecx
			cmpl %ecx, NR_BLOCURI
			je ret_get_1D

			movl 8(%ebp), %eax
			cmpl %eax, (%edi, %ecx, 4)
			je cautare_interval_id_fis

			incl %ecx
			movl 12(%ebp), %ebx
			movl %ecx, 0(%ebx)

			movl 16(%ebp), %ebx
			movl $0, 0(%ebx)

			jmp sar_la_id_fis

		cautare_interval_id_fis:
			movl 12(%ebp), %ebx
			movl 0(%ebx), %ecx
			movl 16(%ebp), %ebx
			addl 0(%ebx), %ecx
			cmpl %ecx, NR_BLOCURI
			je ret_get_1D
			
			movl 8(%ebp), %eax			
			cmpl %eax, (%edi, %ecx, 4)
			jne ret_get_1D

			movl 16(%ebp), %ebx
			movl 0(%ebx), %eax
			incl %eax
			movl %eax, 0(%ebx)

			jmp cautare_interval_id_fis

		ret_get_1D:
			movl %esp, %ebp
			popl %ebp
			ret

	delete_1D:
		pushl %ebp
		movl %esp, %ebp

		subl $4, %esp
		movl $-1, -4(%ebp)
		parc_memorie_delete_1D:
			movl -4(%ebp), %ecx
			incl %ecx
			cmpl %ecx, NR_BLOCURI
			je ret_delete_1D

			movl %ecx, -4(%ebp)

			movl 8(%ebp), %eax
			cmpl %eax, (%edi, %ecx, 4)
			jne parc_memorie_delete_1D

			movl ID_NUL, %eax
			movl %eax, (%edi, %ecx, 4)

			jmp parc_memorie_delete_1D

		ret_delete_1D:
			addl $4, %esp

			movl %esp, %ebp
			popl %ebp
			ret

	defragmentation_1D:
		pushl %ebp
		movl %esp, %ebp

		subl $8, %esp
		movl $0, -4(%ebp)
		movl $0, -8(%ebp)
		parc_memorie_defragmentation_1D:
			movl NR_BLOCURI, %eax
			cmpl %eax, -8(%ebp)
			je golire_reziduu_memorie

			movl ID_NUL, %eax
			# lea memorie, %edi
			movl -8(%ebp), %ecx
			cmpl %eax, (%edi, %ecx, 4)
			jne	mutare_inapoi_id

			jmp inc_contor_parc_memorie_defragmentation_1D

			mutare_inapoi_id:
				movl -8(%ebp), %ecx
				movl (%edi, %ecx, 4), %eax
				movl -4(%ebp), %ecx
				movl %eax, (%edi, %ecx, 4)
				incl %ecx
				movl %ecx, -4(%ebp)

				jmp inc_contor_parc_memorie_defragmentation_1D

			inc_contor_parc_memorie_defragmentation_1D:
				movl -8(%ebp), %ecx
				incl %ecx
				movl %ecx, -8(%ebp)

				jmp parc_memorie_defragmentation_1D

		golire_reziduu_memorie:
			movl -4(%ebp), %ecx
			cmpl %ecx, NR_BLOCURI
			je ret_defragmentation_1D

			movl ID_NUL, %eax
			movl %eax, (%edi, %ecx, 4)
			incl %ecx
			movl %ecx, -4(%ebp)

			jmp golire_reziduu_memorie

		ret_defragmentation_1D:
			addl $8, %esp

			movl %esp, %ebp
			popl %ebp
			ret

.global main
main:
	call init_memorie

	pushl $nr_op
	pushl $fin
	call scanf
	popl %ebx
	popl %ebx

	movl $0, i_parc_op
	parc_op:
		movl i_parc_op, %ecx
		cmpl %ecx, nr_op
		je exit

		incl i_parc_op

		pushl $op
		pushl $fin
		call scanf
		popl %ebx
		popl %ebx
		
		movl op, %eax
		
		cmpl %eax, COD_ADD
		je operare_add

		cmpl %eax, COD_GET
		je operare_get

		cmpl %eax, COD_DELETE
		je operare_delete

		cmpl %eax, COD_DEFRAGMENTATION
		je operare_defragmentation

		jmp operare_indisponibil
	
	operare_add:
		pushl $nr_fis
		pushl $fin
		call scanf
		popl %ebx
		popl %ebx

		movl $0, i_parc_fis
		parc_fis:
			movl i_parc_fis, %ecx
			cmpl %ecx, nr_fis
			je parc_op

			incl i_parc_fis

			pushl $id_fis
			pushl $fin
			call scanf
			popl %ebx
			popl %ebx

			pushl $dim_fis
			pushl $fin
			call scanf
			popl %ebx
			# popl %ebx

			# pushl $dim_fis
			call conv_spatiu
			popl %ebx
			
			movl NR_LIN_COL, %eax
			cmpl %eax, dim_fis
			jg gasire_fisier_prea_mare

			movl $0, poz
			movl $1, lung
			parc_memorie_operare_add:
				movl poz, %ecx
				cmpl %ecx, NR_BLOCURI
				je gasire_fisier_prea_mare

				movl poz, %ecx
				movl (%edi, %ecx, 4), %eax
				cmpl %eax, ID_NUL
				jne salt_urm_secventa

				pushl $lung
				pushl $poz
				pushl ID_NUL
				call get_1D
				popl %ebx
				popl %ebx
				popl %ebx

				movl poz, %eax
				movl NR_LIN_COL, %ebx
				xorl %edx, %edx
				divl %ebx
				movl NR_LIN_COL, %eax
				subl %edx, %eax

				cmpl %eax, lung
				jle caz_lung_minim

				jmp caz_alpha_minim

				caz_lung_minim: # TODO
					movl lung, %eax
					cmpl %eax, dim_fis
					jle afisare_interval_add

					jmp salt_urm_secventa

				caz_alpha_minim: # TODO
					cmpl %eax, dim_fis
					jle afisare_interval_add

					addl %eax, poz
					subl %eax, lung

					movl lung, %eax
					cmpl %eax, dim_fis
					jle afisare_interval_add

					jmp salt_urm_secventa

				afisare_interval_add:
					decl dim_fis

					movl poz, %eax
					addl dim_fis, %eax
					movl NR_LIN_COL, %ebx
					xorl %edx, %edx
					divl %ebx
					pushl %edx
					pushl %eax
					movl poz, %eax
					movl NR_LIN_COL, %ebx
					xorl %edx, %edx
					divl %ebx
					pushl %edx
					pushl %eax
					pushl id_fis
					pushl $fout_long_id_intervale
					call printf
					popl %ebx
					popl %ebx
					popl %ebx
					popl %ebx
					popl %ebx
					popl %ebx

					pushl $0
					call fflush
					popl %ebx

					jmp umplere_memorie_add

				umplere_memorie_add:
					cmpl $0, dim_fis
					jl parc_fis

					movl poz, %ecx
					addl dim_fis, %ecx
					movl id_fis, %eax
					movl %eax, (%edi, %ecx, 4)
					decl dim_fis

					jmp umplere_memorie_add

				salt_urm_secventa:
					movl lung, %eax
					addl %eax, poz
					movl $1, lung

					jmp parc_memorie_operare_add

			gasire_fisier_prea_mare:
				pushl $0
				pushl $0
				pushl $0
				pushl $0
				pushl id_fis
				pushl $fout_long_id_intervale
				call printf
				popl %ebx
				popl %ebx
				popl %ebx
				popl %ebx
				popl %ebx
				popl %ebx

				pushl $0
				call fflush
				popl %ebx

				jmp parc_fis

	operare_get:
		pushl $id_fis
		pushl $fin
		call scanf
		popl %ebx
		popl %ebx

		movl $0, lung
		pushl $lung
		movl $0, poz
		pushl $poz
		pushl id_fis
		call get_1D
		popl %ebx
		popl %ebx
		popl %ebx

		movl lung, %eax
		cmpl $0, %eax
		je caz_nu_exista_id_fis

		jmp afisare_interval_get

		caz_nu_exista_id_fis:
			movl $0, poz
			movl $1, lung

			jmp afisare_interval_get

		afisare_interval_get:
			movl poz, %eax
			addl lung, %eax
			decl %eax
			movl NR_LIN_COL, %ebx
			xorl %edx, %edx
			divl %ebx
			pushl %edx
			pushl %eax
			movl poz, %eax
			movl NR_LIN_COL, %ebx
			xorl %edx, %edx
			divl %ebx
			pushl %edx
			pushl %eax
			pushl $fout_long_intervale
			call printf
			popl %ebx
			popl %ebx
			popl %ebx
			popl %ebx
			popl %ebx

			pushl $0
			call fflush
			popl %ebx

		jmp parc_op

	operare_delete:
		pushl $id_fis
		pushl $fin
		call scanf
		popl %ebx
		popl %ebx

		pushl id_fis
		call delete_1D
		popl %ebx

		jmp afisare_memorie

	operare_defragmentation:
		call defragmentation_2D

		jmp afisare_memorie

	operare_indisponibil:
		pushl $cod_indisponibil
		pushl $fout_str
		call printf
		popl %ebx
		popl %ebx

		pushl $0
		call fflush
		popl %ebx

		jmp parc_op

	afisare_memorie:
		movl $0, poz
		movl $0, lung
		parcurgere_memorie_afisare:
			movl poz, %eax
			cmpl %eax, NR_BLOCURI
			je parc_op

			pushl $lung
			pushl $poz
			movl poz, %ecx
			pushl (%edi, %ecx, 4)
			call get_1D
			popl %ebx
			popl %ebx
			popl %ebx

			movl ID_NUL, %eax
			movl poz, %ecx
			cmpl %eax, (%edi, %ecx, 4)
			jne afisare_fisier

			movl lung, %eax
			addl %eax, poz

			jmp parcurgere_memorie_afisare

		afisare_fisier:
			movl poz, %eax
			addl lung, %eax
			decl %eax
			movl NR_LIN_COL, %ebx
			xorl %edx, %edx
			divl %ebx
			pushl %edx
			pushl %eax

			movl poz, %eax
			movl NR_LIN_COL, %ebx
			xorl %edx, %edx
			divl %ebx
			pushl %edx
			pushl %eax

			movl poz, %ecx
			pushl (%edi, %ecx, 4)

			pushl $fout_long_id_intervale
			call printf
			popl %ebx
			popl %ebx
			popl %ebx
			popl %ebx
			popl %ebx
			popl %ebx

			pushl $0
			call fflush
			popl %ebx

			movl lung, %eax
			addl %eax, poz

			jmp parcurgere_memorie_afisare

exit:
	pushl $0
    call fflush
    popl %eax

	movl $1, %eax
	xorl %ebx, %ebx
	int $0x80