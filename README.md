# x86-64 Assembly Math Library

A low-level math library written in x86-64 NASM assembly, implementing Vec3 and Mat4x operations using SSE/SIMD instructions for efficient packed floating-point arithmetic.

---

## Motivation

This project is an exercise in understanding how math operations used in graphics, physics, and game engines actually work at the hardware level — no intrinsics, no compiler abstractions, just raw SSE instructions and registers.

---

## Current Files

### `vec3.asm`
Implements three Vec3 operations on 16-byte aligned, zero-padded 4-float vectors `{x, y, z, 0.0}`.

| Function | Signature | Description |
|---|---|---|
| `vec3_add` | `rdi=&a, rsi=&b, rdx=&res` | Adds two Vec3s using `addps` |
| `vec3_scale` | `rdi=&vec, xmm0=scalar, rsi=&res` | Scales a Vec3 by a scalar using `shufps` broadcast + `mulps` |
| `vec3_dot` | `rdi=&a, rsi=&b → eax` | Dot product via `mulps` + two `haddps` reductions, returns raw float bits in `eax` |

> **Note:** All Vec3 data must be 16-byte aligned and padded with `0.0` as the 4th lane for `movaps` compatibility.

---

## Upcoming Files

| File | Description |
|---|---|
| `data.asm` | All static data declarations — Vec3s, Mat4x4s, and result buffers with correct alignment |
| `mat4.asm` | 4x4 matrix multiplication using row-major dot products and SSE column extraction |
| `main.asm` | Entry point — wires all modules together and demonstrates each operation |

---

## Build Instructions

Once all files are added, the full library can be assembled and linked with:

```bash
nasm -f elf64 data.asm  -o data.o
nasm -f elf64 vec3.asm  -o vec3.o
nasm -f elf64 mat4.asm  -o mat4.o
nasm -f elf64 main.asm  -o main.o
ld data.o vec3.o mat4.o main.o -o mathlib
```

> Requires [NASM](https://www.nasm.us/) and a Linux x86-64 environment.

---

## Architecture Notes

- All functions follow the **System V AMD64 ABI** calling convention.
- Vec3 structs are padded to 128 bits `{x, y, z, 0.0}` to enable aligned `movaps` loads.
- Mat4x4 matrices are stored in **row-major** order. Element `M[i][j]` is at byte offset `(i*4 + j) * 4`.
- SSE instructions used: `movaps`, `addps`, `mulps`, `shufps`, `haddps`, `movss`, `unpcklps`, `movlhps`, `movd`.

