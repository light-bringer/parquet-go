//go:build !purego

#include "textflag.h"
#include "min_amd64.h"

// func minBool(data []bool) bool
TEXT ·minBool(SB), NOSPLIT, $-25
    MOVQ data_base+0(FP), AX
    MOVQ data_len+8(FP), CX

    CMPQ CX, $0
    JE false
    XORQ SI, SI

    CMPB ·hasAVX512MinBool(SB), $0
    JE loop

    CMPQ CX, $128
    JB loop

    MOVQ CX, DX
    SHRQ $7, DX
    SHLQ $7, DX

    MOVQ $0x0101010101010101, DI
    VPBROADCASTQ DI, Z0
    VPBROADCASTQ DI, Z1
loop128:
    VMOVDQU64 (AX)(SI*1), Z2
    VMOVDQU64 64(AX)(SI*1), Z3
    VPANDQ Z2, Z0, Z0
    VPANDQ Z3, Z1, Z1
    ADDQ $128, SI
    CMPQ SI, DX
    JNE loop128

    VPBROADCASTQ DI, Z2
    VPANDQ Z1, Z0, Z0
    VPCMPUB $0, Z0, Z2, K1
    VZEROUPPER

    KMOVQ K1, DI
    POPCNTQ DI, DI
    CMPQ DI, $64
    JNE false

    CMPQ SI, CX
    JE true
loop:
    MOVBQZX (AX)(SI*1), DX
    CMPQ DX, $0
    JE false
    INCQ SI
    CMPQ SI, CX
    JNE loop
true:
    MOVB $1, ret+24(FP)
    RET
false:
    MOVB $0, ret+24(FP)
    RET

// func minInt32(data []int32) int32
TEXT ·minInt32(SB), NOSPLIT, $-28
    MOVQ data_base+0(FP), AX
    MOVQ data_len+8(FP), CX
    XORQ BX, BX

    CMPQ CX, $0
    JE done
    XORQ SI, SI
    MOVLQZX (AX), BX

    CMPB ·hasAVX512(SB), $0
    JE loop

    CMPQ CX, $32
    JB loop

    MOVQ CX, DI
    SHRQ $5, DI
    SHLQ $5, DI
    VPBROADCASTD (AX), Z0
loop32:
    VMOVDQU32 (AX)(SI*4), Z1
    VMOVDQU32 64(AX)(SI*4), Z2
    VPMINSD Z1, Z0, Z0
    VPMINSD Z2, Z0, Z0
    ADDQ $32, SI
    CMPQ SI, DI
    JNE loop32

    VMOVDQU32 swap32+0(SB), Z1
    VPERMI2D Z0, Z0, Z1
    VPMINSD Y1, Y0, Y0

    VMOVDQU32 swap32+32(SB), Y1
    VPERMI2D Y0, Y0, Y1
    VPMINSD X1, X0, X0

    VMOVDQU32 swap32+48(SB), X1
    VPERMI2D X0, X0, X1
    VPMINSD X1, X0, X0
    VZEROUPPER

    MOVQ X0, DX
    MOVL DX, BX
    SHRQ $32, DX
    CMPL DX, BX
    CMOVLLT DX, BX

    CMPQ SI, CX
    JE done
loop:
    MOVLQZX (AX)(SI*4), DX
    CMPL DX, BX
    CMOVLLT DX, BX
    INCQ SI
    CMPQ SI, CX
    JNE loop
done:
    MOVL BX, ret+24(FP)
    RET

// func minInt64(data []int64) int64
TEXT ·minInt64(SB), NOSPLIT, $-32
    MOVQ data_base+0(FP), AX
    MOVQ data_len+8(FP), CX
    XORQ BX, BX

    CMPQ CX, $0
    JE done
    XORQ SI, SI
    MOVQ (AX), BX

    CMPB ·hasAVX512(SB), $0
    JE loop

    CMPQ CX, $32
    JB loop

    MOVQ CX, DI
    SHRQ $5, DI
    SHLQ $5, DI
    VPBROADCASTQ (AX), Z0
loop32:
    VMOVDQU64 (AX)(SI*8), Z1
    VMOVDQU64 64(AX)(SI*8), Z2
    VMOVDQU64 128(AX)(SI*8), Z3
    VMOVDQU64 192(AX)(SI*8), Z4
    VPMINSQ Z1, Z2, Z5
    VPMINSQ Z3, Z4, Z6
    VPMINSQ Z5, Z6, Z1
    VPMINSQ Z1, Z0, Z0
    ADDQ $32, SI
    CMPQ SI, DI
    JNE loop32

    VMOVDQU32 swap32+0(SB), Z1
    VPERMI2D Z0, Z0, Z1
    VPMINSQ Y1, Y0, Y0

    VMOVDQU32 swap32+32(SB), Y1
    VPERMI2D Y0, Y0, Y1
    VPMINSQ X1, X0, X0

    VMOVDQU32 swap32+48(SB), X1
    VPERMI2D X0, X0, X1
    VPMINSQ X1, X0, X0
    VZEROUPPER

    MOVQ X0, BX
    CMPQ SI, CX
    JE done
loop:
    MOVQ (AX)(SI*8), DX
    CMPQ DX, BX
    CMOVQLT DX, BX
    INCQ SI
    CMPQ SI, CX
    JNE loop
done:
    MOVQ BX, ret+24(FP)
    RET

// func minUint32(data []int32) int32
TEXT ·minUint32(SB), NOSPLIT, $-28
    MOVQ data_base+0(FP), AX
    MOVQ data_len+8(FP), CX
    XORQ BX, BX

    CMPQ CX, $0
    JE done
    XORQ SI, SI
    MOVLQZX (AX), BX

    CMPB ·hasAVX512(SB), $0
    JE loop

    CMPQ CX, $32
    JB loop

    MOVQ CX, DI
    SHRQ $5, DI
    SHLQ $5, DI
    VPBROADCASTD (AX), Z0
loop32:
    VMOVDQU32 (AX)(SI*4), Z1
    VMOVDQU32 64(AX)(SI*4), Z2
    VPMINUD Z1, Z0, Z0
    VPMINUD Z2, Z0, Z0
    ADDQ $32, SI
    CMPQ SI, DI
    JNE loop32

    VMOVDQU32 swap32+0(SB), Z1
    VPERMI2D Z0, Z0, Z1
    VPMINUD Y1, Y0, Y0

    VMOVDQU32 swap32+32(SB), Y1
    VPERMI2D Y0, Y0, Y1
    VPMINUD X1, X0, X0

    VMOVDQU32 swap32+48(SB), X1
    VPERMI2D X0, X0, X1
    VPMINUD X1, X0, X0
    VZEROUPPER

    MOVQ X0, DX
    MOVL DX, BX
    SHRQ $32, DX
    CMPL DX, BX
    CMOVLCS DX, BX

    CMPQ SI, CX
    JE done
loop:
    MOVLQZX (AX)(SI*4), DX
    CMPL DX, BX
    CMOVLCS DX, BX
    INCQ SI
    CMPQ SI, CX
    JNE loop
done:
    MOVL BX, ret+24(FP)
    RET

// func minUint64(data []uint64) uint64
TEXT ·minUint64(SB), NOSPLIT, $-32
    MOVQ data_base+0(FP), AX
    MOVQ data_len+8(FP), CX
    XORQ BX, BX

    CMPQ CX, $0
    JE done
    XORQ SI, SI
    MOVQ (AX), BX

    CMPB ·hasAVX512(SB), $0
    JE loop

    CMPQ CX, $32
    JB loop

    MOVQ CX, DI
    SHRQ $5, DI
    SHLQ $5, DI
    VPBROADCASTQ (AX), Z0
loop32:
    VMOVDQU64 (AX)(SI*8), Z1
    VMOVDQU64 64(AX)(SI*8), Z2
    VMOVDQU64 128(AX)(SI*8), Z3
    VMOVDQU64 192(AX)(SI*8), Z4
    VPMINUQ Z1, Z2, Z5
    VPMINUQ Z3, Z4, Z6
    VPMINUQ Z5, Z6, Z1
    VPMINUQ Z1, Z0, Z0
    ADDQ $32, SI
    CMPQ SI, DI
    JNE loop32

    VMOVDQU32 swap32+0(SB), Z1
    VPERMI2D Z0, Z0, Z1
    VPMINUQ Y1, Y0, Y0

    VMOVDQU32 swap32+32(SB), Y1
    VPERMI2D Y0, Y0, Y1
    VPMINUQ X1, X0, X0

    VMOVDQU32 swap32+48(SB), X1
    VPERMI2D X0, X0, X1
    VPMINUQ X1, X0, X0
    VZEROUPPER

    MOVQ X0, BX
    CMPQ SI, CX
    JE done
loop:
    MOVQ (AX)(SI*8), DX
    CMPQ DX, BX
    CMOVQCS DX, BX
    INCQ SI
    CMPQ SI, CX
    JNE loop
done:
    MOVQ BX, ret+24(FP)
    RET

// func minFloat32(data []float32) float32
TEXT ·minFloat32(SB), NOSPLIT, $-28
    MOVQ data_base+0(FP), AX
    MOVQ data_len+8(FP), CX
    XORQ BX, BX

    CMPQ CX, $0
    JE done
    XORPS X0, X0
    XORPS X1, X1
    XORQ SI, SI
    MOVLQZX (AX), BX
    MOVQ BX, X0

    CMPB ·hasAVX512(SB), $0
    JE loop

    CMPQ CX, $64
    JB loop

    MOVQ CX, DI
    SHRQ $6, DI
    SHLQ $6, DI
    VPBROADCASTD (AX), Z0
loop64:
    VMOVDQU32 (AX)(SI*4), Z1
    VMOVDQU32 64(AX)(SI*4), Z2
    VMOVDQU32 128(AX)(SI*4), Z3
    VMOVDQU32 192(AX)(SI*4), Z4
    VMINPS Z1, Z2, Z5
    VMINPS Z3, Z4, Z6
    VMINPS Z5, Z6, Z1
    VMINPS Z1, Z0, Z0
    ADDQ $64, SI
    CMPQ SI, DI
    JNE loop64

    VMOVDQU32 swap32+0(SB), Z1
    VPERMI2D Z0, Z0, Z1
    VMINPS Y1, Y0, Y0

    VMOVDQU32 swap32+32(SB), Y1
    VPERMI2D Y0, Y0, Y1
    VMINPS X1, X0, X0

    VMOVDQU32 swap32+48(SB), X1
    VPERMI2D X0, X0, X1
    VMINPS X1, X0, X0
    VZEROUPPER

    MOVAPS X0, X1
    PSRLQ $32, X1
    MOVQ X0, BX
    MOVQ X1, DX
    UCOMISS X0, X1
    CMOVLCS DX, BX

    CMPQ SI, CX
    JE done
    MOVQ BX, X0
loop:
    MOVLQZX (AX)(SI*4), DX
    MOVQ DX, X1
    UCOMISS X0, X1
    CMOVLCS DX, BX
    MOVQ BX, X0
    INCQ SI
    CMPQ SI, CX
    JNE loop
done:
    MOVL BX, ret+24(FP)
    RET

// func minFloat64(data []float64) float64
TEXT ·minFloat64(SB), NOSPLIT, $-32
    MOVQ data_base+0(FP), AX
    MOVQ data_len+8(FP), CX
    XORQ BX, BX

    CMPQ CX, $0
    JE done
    XORPD X0, X0
    XORPD X1, X1
    XORQ SI, SI
    MOVQ (AX), BX
    MOVQ BX, X0

    CMPB ·hasAVX512(SB), $0
    JE loop

    CMPQ CX, $32
    JB loop

    MOVQ CX, DI
    SHRQ $5, DI
    SHLQ $5, DI
    VPBROADCASTQ (AX), Z0
loop32:
    VMOVDQU64 (AX)(SI*8), Z1
    VMOVDQU64 64(AX)(SI*8), Z2
    VMOVDQU64 128(AX)(SI*8), Z3
    VMOVDQU64 192(AX)(SI*8), Z4
    VMINPD Z1, Z2, Z5
    VMINPD Z3, Z4, Z6
    VMINPD Z5, Z6, Z1
    VMINPD Z1, Z0, Z0
    ADDQ $32, SI
    CMPQ SI, DI
    JNE loop32

    VMOVDQU64 swap32+0(SB), Z1
    VPERMI2D Z0, Z0, Z1
    VMINPD Y1, Y0, Y0

    VMOVDQU64 swap32+32(SB), Y1
    VPERMI2D Y0, Y0, Y1
    VMINPD X1, X0, X0

    VMOVDQU64 swap32+48(SB), X1
    VPERMI2D X0, X0, X1
    VMINPD X1, X0, X0
    VZEROUPPER

    MOVQ X0, BX
    CMPQ SI, CX
    JE done
loop:
    MOVQ (AX)(SI*8), DX
    MOVQ DX, X1
    UCOMISD X0, X1
    CMOVQCS DX, BX
    MOVQ BX, X0
    INCQ SI
    CMPQ SI, CX
    JNE loop
done:
    MOVQ BX, ret+24(FP)
    RET

// func minBE128(data []byte) []byte
TEXT ·minBE128(SB), NOSPLIT, $-48
    MOVQ data_base+0(FP), AX
    MOVQ data_len+8(FP), CX
    CMPQ CX, $0
    JE null

    MOVQ CX, DX // len
    MOVQ AX, BX // min
    ADDQ AX, CX // end

    CMPQ DX, $256
    JB loop

    CMPB ·hasAVX512MinMaxBE128(SB), $0
    JE loop

    // Z19 holds a vector of the count by which we increment the vectors of
    // swap at each loop iteration.
    MOVQ $16, DI
    VPBROADCASTQ DI, Z19

    // Z31 holds the shuffle mask used to convert 128 bits elements from big to
    // little endian so we can apply vectorized comparison instructions.
    VMOVDQU64 bswap128(SB), Z31

    // These vectors hold four lanes of minimum values found in the input.
    VBROADCASTI64X2 (AX), Z0
    VPSHUFB Z31, Z0, Z0
    VMOVDQU64 Z0, Z5
    VMOVDQU64 Z0, Z10
    VMOVDQU64 Z0, Z15

    // These vectors hold four lanes of swap of minimum values.
    //
    // We initialize them at zero because we broadcast the first value of the
    // input in the vectors that track the minimums of each lane; in other
    // words, we assume the minimum value is at the first offset and work our
    // way up from there.
    VPXORQ Z2, Z2, Z2
    VPXORQ Z7, Z7, Z7
    VPXORQ Z12, Z12, Z12
    VPXORQ Z17, Z17, Z17

    // These vectors are used to compute the swap of minimum values held
    // in [Z1, Z5, Z10, Z15]. Each vector holds a contiguous sequence of
    // swap; for example, Z3 is initialized with [0, 1, 2, 3]. At each
    // loop iteration, the swap are incremented by the number of elements
    // consumed from the input (4x4=16).
    VMOVDQU64 indexes128(SB), Z3
    VPXORQ Z8, Z8, Z8
    VPXORQ Z13, Z13, Z13
    VPXORQ Z18, Z18, Z18
    MOVQ $4, DI
    VPBROADCASTQ DI, Z1
    VPADDQ Z1, Z3, Z8
    VPADDQ Z1, Z8, Z13
    VPADDQ Z1, Z13, Z18

    vpminu128mask(DI)
    SHRQ $8, DX
    SHLQ $8, DX
    ADDQ AX, DX
loop16:
    // Compute 4x4 minimum values in vector registers, along with their swap
    // in the input array.
    VMOVDQU64 (AX), Z1
    VMOVDQU64 64(AX), Z6
    VMOVDQU64 128(AX), Z11
    VMOVDQU64 192(AX), Z16
    VPSHUFB Z31, Z1, Z1
    VPSHUFB Z31, Z6, Z6
    VPSHUFB Z31, Z11, Z11
    VPSHUFB Z31, Z16, Z16
    vpminu128(Z1, Z3, Z0, Z2, K1, K2, R8, R9, R10, DI)
    vpminu128(Z6, Z8, Z5, Z7, K3, K4, R11, R12, R13, DI)
    vpminu128(Z11, Z13, Z10, Z12, K1, K2, R8, R9, R10, DI)
    vpminu128(Z16, Z18, Z15, Z17, K3, K4, R11, R12, R13, DI)
    VPADDQ Z19, Z3, Z3
    VPADDQ Z19, Z8, Z8
    VPADDQ Z19, Z13, Z13
    VPADDQ Z19, Z18, Z18
    ADDQ $256, AX
    CMPQ AX, DX
    JB loop16

    // After the loop completed, we need to merge the lanes that each contain
    // 4 minimum values (so 16 total candidate at this stage). The results are
    // reduced into 4 candidates in Z0, with their swap in Z2.
    vpminu128(Z10, Z12, Z0, Z2, K1, K2, R8, R9, R10, DI)
    vpminu128(Z15, Z17, Z5, Z7, K3, K4, R11, R12, R13, DI)
    vpminu128(Z5, Z7, Z0, Z2, K1, K2, R8, R9, R10, DI)

    // Further reduce the results by swapping the upper and lower parts of the
    // vector registers, and comparing them to determine which values are the
    // smallest. We compare 2x2 values at this step, then 2x1 values at the next
    // to find the index of the minimum.
    VMOVDQU64 swap64+0(SB), Z1
    VMOVDQU64 swap64+0(SB), Z3
    VPERMI2Q Z0, Z0, Z1
    VPERMI2Q Z2, Z2, Z3
    vpminu128(Y1, Y3, Y0, Y2, K1, K2, R8, R9, R10, DI)

    VMOVDQU64 swap64+32(SB), Y1
    VMOVDQU64 swap64+32(SB), Y3
    VPERMI2Q Y0, Y0, Y1
    VPERMI2Q Y2, Y2, Y3
    vpminu128(X1, X3, X0, X2, K1, K2, R8, R9, R10, DI)
    VZEROUPPER

    // Extract the index of the minimum value computed in the lower 64 bits of
    // X2 and position the BX pointer at the index of the minimum value.
    MOVQ X2, DX
    SHLQ $4, DX
    ADDQ DX, BX
    CMPQ AX, CX
    JE done

    // Unless the input was aligned on 256 bytes, we need to perform a few more
    // iterations on the remaining elements.
    //
    // This loop is also take if the CPU has no support for AVX-512.
loop:
    MOVBEQQ (AX), R8
    MOVBEQQ (BX), R9
    CMPQ R8, R9
    JB less
    JA next
    MOVBEQQ 8(AX), R8
    MOVBEQQ 8(BX), R9
    CMPQ R8, R9
    JAE next
less:
    MOVQ AX, BX
next:
    ADDQ $16, AX
    CMPQ AX, CX
    JB loop
done:
    MOVQ BX, ret+24(FP)
    MOVQ $16, ret+32(FP)
    MOVQ $16, ret+40(FP)
    RET
null:
    XORQ BX, BX
    MOVQ BX, min+24(FP)
    MOVQ BX, min+32(FP)
    MOVQ BX, min+40(FP)
    RET
