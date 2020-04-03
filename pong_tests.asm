extern printf

segment .data

%include "testlib.asm"

segment .text
global main

%include "maths_tests.asm"

; main
test_suite
    call    test_radians_to_degrees
    call    test_degrees_to_radians
    call    test_mat4f_vec3_translate
end_test_suite
