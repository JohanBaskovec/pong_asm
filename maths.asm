%ifndef PONG_MATHS
%define PONG_MATHS

%include "defines.asm"

segment .data

dd_radians_to_degrees_ratio dq 57.2957795
dd_degrees_to_radians_ratio dq 0.0174532925
dd_1 dd 1.0
dd_0 dd 0.0

; inline double radians_to_degrees(double a)
%define radians_to_degrees mulsd   xmm0, [dd_radians_to_degrees_ratio]

; inline double degrees_to_radians(double a)
%define degrees_to_radians mulsd  xmm0, [dd_degrees_to_radians_ratio]

; initialize an identity matrix
; all matrices are column-major (to match OpenGL)
;void mat4f_identity(float *matrix)
mat4f_identity:
    enter 0, 0
    movss   xmm0, [dd_1]
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

%endif
