default rel

extern vec3_add
extern vec3_scale
extern vec3_dot
extern mat4_mul

extern vec3_a
extern vec3_b
extern vec3_res
extern scalar_val
extern mat4_scale
extern mat4_test
extern mat4_res
extern dot_result

section .text
	global _start

_start:
	; Vec3 Add: vec3_res = vec3_a + vec3_b = (5, 7, 9, 0)
	lea rdi, [vec3_a]
	lea rsi, [vec3_b]
	lea rdx, [vec3_res]
	call vec3_add

	; Vec3 Scale: vec3_res *= 3.0 = (15, 21, 27, 0)
	movss xmm0, [scalar_val]
	lea rdi, [vec3_res]
	lea rsi, [vec3_res]
	call vec3_scale

	; Vec3 Dot: dot_result = vec3_a . vec3_b = 32.0 (as float bits in eax)
	lea rdi, [vec3_a]
	lea rsi, [vec3_b]
	call vec3_dot
	lea rcx, [dot_result]
	mov [rcx], eax

	; Mat4 Mul: mat4_res = mat4_scale * mat4_test
	lea rdi, [mat4_scale]
	lea rsi, [mat4_test]
	lea rdx, [mat4_res]
	call mat4_mul

	; Exit
	mov rax, 60
	xor rdi, rdi
	syscall
