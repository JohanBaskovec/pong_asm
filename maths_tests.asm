%include "maths.asm"

segment .data

dd_radians_to_degrees_t1_radians dq 1.0
dd_radians_to_degrees_t1_degrees dq 57.2957795

dd_radians_to_degrees_t2_radians dq 495.423
dd_radians_to_degrees_t2_degrees dq 28385.647

dd_radians_to_degrees_t3_radians dq 0.0
dd_radians_to_degrees_t3_degrees dq 0.0

dd_degrees_to_radians_t1_degrees dq 57.2957795
dd_degrees_to_radians_t1_radians dq 1.0

dd_degrees_to_radians_t2_degrees dq 28385.647
dd_degrees_to_radians_t2_radians dq 495.423

dd_degrees_to_radians_t3_degrees dq 0.0
dd_degrees_to_radians_t3_radians dq 0.0

segment .text

test_radians_to_degrees:
    enter   0, 0

    movq    xmm0, [dd_radians_to_degrees_t1_radians]
    radians_to_degrees
    movq    xmm1, [dd_radians_to_degrees_t1_degrees]
    assert_double_eq

    movq    xmm0, [dd_radians_to_degrees_t2_radians]
    radians_to_degrees
    movq    xmm1, [dd_radians_to_degrees_t2_degrees]
    assert_double_eq

    movq    xmm0, [dd_radians_to_degrees_t3_radians]
    radians_to_degrees
    movq    xmm1, [dd_radians_to_degrees_t3_degrees]
    assert_double_eq

    leave
    ret

test_degrees_to_radians:
    enter   0, 0

    movq    xmm0, [dd_degrees_to_radians_t1_degrees]
    degrees_to_radians
    movq    xmm1, [dd_degrees_to_radians_t1_radians]
    assert_double_eq

    movq    xmm0, [dd_degrees_to_radians_t2_degrees]
    degrees_to_radians
    movq    xmm1, [dd_degrees_to_radians_t2_radians]
    assert_double_eq

    movq    xmm0, [dd_degrees_to_radians_t3_degrees]
    degrees_to_radians
    movq    xmm1, [dd_degrees_to_radians_t3_radians]
    assert_double_eq

    leave
    ret

segment .data
dfa_mat4f_vec3_translate_t1_vec dd 0.4, 0.5, 0.6
dfa_mat4f_vec3_translate_t1_mat dd 1.0, 0.0, 0.0, 0.0,\
                                   0.0, 1.0, 0.0, 0.0,\
                                   0.0, 0.0, 1.0, 0.0,\
                                   0.4, 0.5, 0.6, 1.0\


segment .bss
dfa_mat4f_vec3_translate_mat resd 16

segment .text

test_mat4f_vec3_translate:
    enter   0, 0
    mov     rdi, dfa_mat4f_vec3_translate_mat
    call    mat4f_identity

    mov     rdi, dfa_mat4f_vec3_translate_mat
    mov     rsi, dfa_mat4f_vec3_translate_t1_vec
    call    mat4f_vec3_translate

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   0*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+0*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   1*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+1*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   2*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+2*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   3*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+3*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   4*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+4*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   5*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+5*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   6*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+6*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   7*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+7*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   8*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+8*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   9*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+9*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   10*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+10*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   11*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+11*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   12*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+12*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   13*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+13*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   14*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+14*float_size]
    assert_float_eq

    movss   xmm1, [dfa_mat4f_vec3_translate_mat+   15*float_size]
    movss   xmm0, [dfa_mat4f_vec3_translate_t1_mat+15*float_size]
    assert_float_eq

    leave
    ret
