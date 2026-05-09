default rel
section .text
	global mat4_mul

;mat4_mul(rdi=&A, rsi=&B, rdx=&C) : C = A*B, row-major
; Computes each element C[i][j] = dot(row_i(A), col_j(B))
mat4_mul:
	push r12
	push r13
	push r14
	push rbx

	mov r12, rdi	;A
	mov r13, rsi	;B
	mov r14, rdx	;C

	xor rbx, rbx	;row index = 0

.row_loop:
	cmp rbx, 4
	je .done

	; Load row i of A into xmm4
	; Row i starts at byte offset i*16
	mov rax, rbx
	shl rax, 4		; rax = i * 16
	movaps xmm4, [r12 + rax]

	xor rcx, rcx	; col index j = 0

.col_loop:
	cmp rcx, 4
	je .next_row

	; Extract col j of B manually (stride = 16 bytes per row)
	; col j elements: B[0][j], B[1][j], B[2][j], B[3][j]
	; byte offsets:	  j*4		16+j*4	32+J*4		48+j*4
	mov rax, rcx
	shl rax, 2		; rax = j * 4

	movss xmm0, [r13 + rax]			;B[0][j]
	movss xmm1, [r13 + rax + 16]	;B[1][j]
	movss xmm2, [r13 + rax + 32]	;B[2][j]
	movss xmm3, [r13 + rax + 48]	;B[3][j]

	; Pack into one register for example: xmm0= { B[0][j], B[1][j], B[2][j], B[3][j] }
	unpcklps xmm0, xmm1			;xmm0 = { B[0][j], B[1][j], ?, ?}
	unpcklps xmm2, xmm3			;xmm2 = { B[2][j], B[3][j], ?, ?}
	movlhps xmm0, xmm2			;xmm0= { B[0][j], B[1][j], B[2][j], B[3][j] }

	; Dot product: row_i(A) . col_j(B)
	movaps xmm5, xmm4
	mulps xmm5, xmm0
	haddps xmm5, xmm5
	haddps xmm5, xmm5		;xmm5[0] = dot result

	; Store to C[i][j]: byte offset = (i*4 + j) * 4
	mov rax, rbx
	shl rax, 2			;i*4
	add rax, rcx		;i*4 + j
	shl rax, 2			;(i*4 + j) * 4
	movss [r14 + rax], xmm5

	inc rcx
	jmp .col_loop

.next_row:
	inc rbx
	jmp .row_loop

.done:
	pop rbx
	pop r14
	pop r13
	pop r12
	ret
