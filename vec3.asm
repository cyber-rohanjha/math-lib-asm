section .text
	global vec3_add
	global vec3_scale
	global vec3_dot

;vec3_add(rdi=&a, rsi=&b, rdx=&res)
vec3_add:
	movaps xmm0, [rdi]
	movaps xmm1, [rsi]
	addps xmm0, xmm1
	movaps [rdx], xmm0
	ret

;vec3_scale(rdi=&vec, xmm0=scalar, rsi=&res)
vec3_scale:
	shufps xmm0, xmm0, 0
	;shufps= Shuffle Packed Signles.
	;The immediate 0 copies lane O into all four lanes.
	; If xmm0 = {3.0, ?, ?, ?}, after this it becomes, {3.0, 3.0, 3.0, 3.0}
	;This is the standard for broadcasting a scalar to all lanes so we can use `mulps`
	movaps xmm1, [rdi]
	mulps xmm1, xmm0
	movaps [rsi], xmm1
	ret

;vec3_dot(rdi=&a, rsi=&b) -> eax=float bits
vec3_dot:
	movaps xmm0, [rdi]
	movaps xmm1, [rsi]
	mulps xmm0, xmm1
	haddps xmm0, xmm0
	;haddps = Horizontal Add packed Signles
	;Takes adjacent pairs within each source and adds them.
	;The result after first haddps is partially summed.
	haddps xmm0, xmm0
	;Second horizontal add finishes the reduction.
	;Lane O now holds the complete dot product.
	movd eax, xmm0
	ret
