extern  printf, fabs, exit

segment .data
dd_epsilon dq 0.001

ds_print_file_and_line dd `%s:%d: \0`
assert_double_eq_fail dd `assert_double_eq: expected %lf to be %lf.\n\0`

ds_testlib_file_name dd __FILE__

; Assert that the doubles are equal. Print error message and exit if
; they are not.
; void assert_double_eq(double expected, double value)
%macro assert_double_eq 0
    ;if (fabs(value - expected) > dd_epsilon) {
    ;   printf(...);
    ;   exit(1);
    ;}
    sub     rsp, 16
    movq    [rsp], xmm0
    movq    [rsp+8], xmm1

    subsd   xmm0, xmm1
    call    fabs
    ucomisd xmm0, [dd_epsilon]  ; xmm0 > dd_epsilon
    jbe     %%end               ; if (xmm0 <= dd_epsilon) jump to %%end

    mov     rdi, ds_print_file_and_line
    mov     rsi, ds_testlib_file_name
    mov     rdx, __LINE__
    xor     rax,rax
    call    printf

    movq    xmm0, [rsp]
    movq    xmm1, [rsp+8]

    mov     rdi, assert_double_eq_fail
    mov     rax, 2
    call    printf

    mov     rdi, 1
    add     rsp, 16
    call    exit

    %%end:
    add     rsp, 16
%endmacro
