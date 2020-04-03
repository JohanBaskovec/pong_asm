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
