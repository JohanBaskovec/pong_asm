%ifndef PONG_MATHS
%define PONG_MATHS

%include "defines.asm"

extern  tanf, printf

segment .data

dd_radians_to_degrees_ratio dq 57.2957795
dd_degrees_to_radians_ratio dq 0.0174532925
df_radians_to_degrees_ratio dd 57.2957795
df_degrees_to_radians_ratio dd 0.0174532925

df_2 dd     2.0
df_1 dd     1.0
df_0 dd     0.0
df_m1 dd    -1.0

ds_log_rad    dd `rad: %f\n\0`
ds_log_float    dd `float: %f\n\0`
ds_log_xmm4    dd `xmm4: %f\n\0`

; inline double radians_to_degrees(double a)
%define radians_to_degrees mulsd   xmm0, [dd_radians_to_degrees_ratio]

; inline double degrees_to_radians(double a)
%define degrees_to_radians mulsd  xmm0, [dd_degrees_to_radians_ratio]

; inline double radians_to_degrees(float a)
%define radians_to_degreesf mulss   xmm0, [df_radians_to_degrees_ratio]

; inline double degrees_to_radians(float a)
%define degrees_to_radiansf mulss  xmm0, [df_degrees_to_radians_ratio]

; initialize an identity matrix
; all matrices are column-major (to match OpenGL)
;void mat4f_identity(float *matrix)
mat4f_identity:
    enter 0, 0
    movss   xmm0, [df_1]
    xorps   xmm1, xmm1

    ; 1st column
    movss   [rdi+0 *float_size], xmm0
    movss   [rdi+1 *float_size], xmm1
    movss   [rdi+2 *float_size], xmm1
    movss   [rdi+3 *float_size], xmm1

    ; 2nd column
    movss   [rdi+4 *float_size], xmm1
    movss   [rdi+5 *float_size], xmm0
    movss   [rdi+6 *float_size], xmm1
    movss   [rdi+7 *float_size], xmm1

    ; 3rd column
    movss   [rdi+8 *float_size], xmm1
    movss   [rdi+9 *float_size], xmm1
    movss   [rdi+10*float_size], xmm0
    movss   [rdi+11*float_size], xmm1

    ; 4th column
    movss   [rdi+12*float_size], xmm1
    movss   [rdi+13*float_size], xmm1
    movss   [rdi+14*float_size], xmm1
    movss   [rdi+15*float_size], xmm0
    leave
    ret

; translate a matrix by a vector
mat4f_vec3_translate:
    enter 0, 0

    movss   xmm0, [rdi+12*float_size]
    addss   xmm0, [rsi+0*float_size]
    movss   [rdi+12*float_size], xmm0

    movss   xmm0, [rdi+13*float_size]
    addss   xmm0, [rsi+1*float_size]
    movss   [rdi+13*float_size], xmm0

    movss   xmm0, [rdi+14*float_size]
    addss   xmm0, [rsi+2*float_size]
    movss   [rdi+14*float_size], xmm0

    leave
    ret

; initialize a perspective matrix
; void mat4f_perspective(float *mat, float fovy, float aspect,
;                        float z_near, float z_far)
mat4f_perspective:
    enter   32, 0
    mov     [rsp], rdi
    movss   [rsp+8], xmm0
    movss   [rsp+12], xmm1
    movss   [rsp+16], xmm2
    movss   [rsp+20], xmm3

    ;movss   xmm4, xmm0
	;cvtss2sd	xmm0, xmm0
    ;mov     rax, 1
    ;mov     rdi, ds_log_rad
    ;call    printf
    ;movss   xmm0, xmm4

    ; xmm4 = tanf(fovy / 2.0)
    movss   xmm5, [df_2]
    divss   xmm0, xmm5
    ;movss   xmm4, xmm0

	;cvtss2sd	xmm0, xmm0
    ;mov     rax, 1
    ;mov     rdi, ds_log_float
    ;call    printf

    ;movss   xmm0, xmm4
    call    tanf
    movss   xmm4, xmm0

	;cvtss2sd	xmm0, xmm0
    ;mov     rax, 1
    ;mov     rdi, ds_log_xmm4
    ;call    printf

    movss   xmm0, [rsp+8]
    movss   xmm1, [rsp+12]
    movss   xmm2, [rsp+16]
    movss   xmm3, [rsp+20]

    movss   xmm12, [df_0]
    movss   xmm13, [df_m1]

    ;xmm10 = z_far - z_near
    movss   xmm10, xmm3
    subss   xmm10, xmm2

    ; xmm6 = 1.0 / (aspect * xmm4)
    movss   xmm7, xmm4
    mulss   xmm7, xmm1
    movss   xmm6, [df_1]
    divss   xmm6, xmm7

    ; xmm7 = 1.0 / xmm4
    movss   xmm7, [df_1]
    divss   xmm7, xmm4

    ; xmm8 = -(z_far + z_near) / (z_far - z_near)
    movss   xmm8, xmm3
    addss   xmm8, xmm2
    divss   xmm8, xmm10
    ; invert sign
    movd    eax,  xmm8
    xor     eax, 2147483648
    movd    xmm8, eax

    ; xmm9 = -(2.0 * z_far * z_near) / (z_far - z_near)
    movss   xmm9, [df_2]
    mulss   xmm9, xmm3
    mulss   xmm9, xmm2
    divss   xmm9, xmm10
    ; invert sign
    movd    eax,  xmm9
    xor     eax, 2147483648
    movd    xmm9, eax

    ; 1st column
    mov     rdi, [rsp]
    movss   [rdi+0 *float_size], xmm6
    movss   [rdi+1 *float_size], xmm12
    movss   [rdi+2 *float_size], xmm12
    movss   [rdi+3 *float_size], xmm12

    ; 2nd column
    movss   [rdi+4 *float_size], xmm12
    movss   [rdi+5 *float_size], xmm7
    movss   [rdi+6 *float_size], xmm12
    movss   [rdi+7 *float_size], xmm12

    ; 3rd column
    movss   [rdi+8 *float_size], xmm12
    movss   [rdi+9 *float_size], xmm12
    movss   [rdi+10*float_size], xmm8
    movss   [rdi+11*float_size], xmm13

    ; 4th column
    movss   [rdi+12*float_size], xmm12
    movss   [rdi+13*float_size], xmm12
    movss   [rdi+14*float_size], xmm9
    movss   [rdi+15*float_size], xmm12

    leave
    ret

%endif

