section .data
	align 16

	global vec3_a
	global vec3_b
	global vec3_res
	global scalar_val
	global mat4_scale
	global mat4_test
	global mat4_res
	global dot_result

	; Vec3s padded to 16 bytes (4th lane = 0.0) for movaps alignment
	align 16
	vec3_a:		dd 1.0, 2.0, 3.0, 0.0
	align 16
	vec3_b:		dd 4.0, 5.0, 6.0, 0.0
	align 16
	vec3_res:	times 4 dd 0.0
	
	scalar_val:	dd 3.0
	
	align 16
	mat4_scale: dd 2.0, 0.0, 0.0, 0.0
				dd 0.0, 2.0, 0.0, 0.0
				dd 0.0, 0.0, 2.0, 0.0
				dd 0.0, 0.0, 0.0, 1.0
	
	align 16
	mat4_test: dd 1.0, 1.0, 1.0, 0.0
			   dd 1.0, 1.0, 1.0, 0.0
			   dd 1.0, 1.0, 1.0, 0.0
			   dd 0.0, 0.0, 0.0, 1.0
	
	align 16
	mat4_res:	times 16 dd 0.0

section .bss
	dot_result: resd 1
