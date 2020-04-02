extern printf

segment .data

dd_radians_to_degrees_t1_radians dq 1.0
dd_radians_to_degrees_t1_degrees dq 57.2957795

dd_radians_to_degrees_t2_radians dq 495.423
dd_radians_to_degrees_t2_degrees dq 28385.647

dd_radians_to_degrees_t3_radians dq 0.0
dd_radians_to_degrees_t3_degrees dq 0.0

%include "testlib.asm"

segment .text
global main

%include "maths.asm"

main:
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

    xor     rax, rax
    leave
    ret
