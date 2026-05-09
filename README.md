# x86-64 Assembly Math Library

A low-level math library written in x86-64 NASM assembly, implementing Vec3 and Mat4x4 operations using SSE/SIMD instructions for efficient packed floating-point arithmetic.

---

## Motivation

This project is an exercise in understanding how math operations used in graphics, physics, and game engines actually work at the hardware level — no intrinsics, no compiler abstractions, just raw SSE instructions and registers.

---

## Files

### `vec3.asm`
Implements three Vec3 operations on 16-byte aligned, zero-padded 4-float vectors `{x, y, z, 0.0}`.

| Function | Signature | Description |
|---|---|---|
| `vec3_add` | `rdi=&a, rsi=&b, rdx=&res` | Adds two Vec3s using `addps` |
| `vec3_scale` | `rdi=&vec, xmm0=scalar, rsi=&res` | Scales a Vec3 by a scalar using `shufps` broadcast + `mulps` |
| `vec3_dot` | `rdi=&a, rsi=&b → eax` | Dot product via `mulps` + two `haddps` reductions, returns raw float bits in `eax` |

---

### `mat4.asm`
Implements 4x4 matrix multiplication in row-major order using SSE column extraction and dot products.

| Function | Signature | Description |
|---|---|---|
| `mat4_mul` | `rdi=&A, rsi=&B, rdx=&C` | Computes `C = A * B` by iterating over each row of A and column of B, computing the dot product for each element |

Column extraction is done manually using `movss` + `unpcklps` + `movlhps` since columns are not contiguous in row-major memory. Each dot product uses `mulps` + two `haddps` reductions. Callee-saved registers `r12`, `r13`, `r14`, `rbx` are preserved across the loop.

---

### `data.asm`
Contains all static data declarations — Vec3s, Mat4x4s, scalar values, and result buffers.

| Symbol | Type | Description |
|---|---|---|
| `vec3_a`, `vec3_b` | `dd` × 4 | Input Vec3s padded to 16 bytes |
| `vec3_res` | `dd` × 4 | Output buffer for Vec3 operations |
| `scalar_val` | `dd` | Scalar float used in `vec3_scale` |
| `mat4_scale` | `dd` × 16 | 4x4 scale matrix |
| `mat4_test` | `dd` × 16 | 4x4 test matrix |
| `mat4_res` | `dd` × 16 | Output buffer for matrix multiply |
| `dot_result` | `dd` | Stores the result of `vec3_dot` |

> **Note:** Every Vec3 and Mat4x4 symbol is preceded by `align 16` to satisfy `movaps` alignment requirements. Misaligned data will cause a segfault at runtime.

---

### `main.asm`
Entry point that wires all modules together and demonstrates each operation in sequence.

| Operation | Inputs | Expected Result |
|---|---|---|
| `vec3_add` | `vec3_a + vec3_b` | `(5.0, 7.0, 9.0, 0.0)` |
| `vec3_scale` | `vec3_res * 3.0` | `(15.0, 21.0, 27.0, 0.0)` |
| `vec3_dot` | `vec3_a · vec3_b` | `32.0` |
| `mat4_mul` | `mat4_scale * mat4_test` | Scaled matrix |

Uses `default rel` for correct RIP-relative addressing across object files.

---

## Output

This is a computational math library — no output is printed to the screen. All operations run silently and store their results in memory. To verify correctness, use GDB:

```bash
gdb ./mathlib
break *0x<address of mov $0x3c, %rax>   # break before exit syscall
run
x/4f &vec3_res      # Vec3 add + scale result
x/f  &dot_result    # Dot product result
x/16f &mat4_res     # Mat4 multiply result
```

To find the exit instruction address:
```bash
gdb ./mathlib
break _start
run
disassemble _start  # look for 'mov $0x3c, %rax'
```

---

## Build Instructions

```bash
nasm -f elf64 data.asm  -o data.o
nasm -f elf64 vec3.asm  -o vec3.o
nasm -f elf64 mat4.asm  -o mat4.o
nasm -f elf64 main.asm  -o main.o
ld data.o vec3.o mat4.o main.o -o mathlib
./mathlib
```

> Requires [NASM](https://www.nasm.us/) and a Linux x86-64 environment.

---

## Architecture Notes

- All functions follow the **System V AMD64 ABI** calling convention.
- Vec3 structs are padded to 128 bits `{x, y, z, 0.0}` to enable aligned `movaps` loads.
- Mat4x4 matrices are stored in **row-major** order. Element `M[i][j]` is at byte offset `(i*4 + j) * 4`.
- `default rel` is set in `main.asm` and `mat4.asm` for correct RIP-relative symbol resolution across object files.
- SSE instructions used: `movaps`, `movss`, `addps`, `mulps`, `shufps`, `haddps`, `unpcklps`, `movlhps`, `movd`.

