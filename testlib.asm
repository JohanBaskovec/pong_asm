extern  printf, fabs, exit

%define test_suite_failure 1
%define test_suite_success 0

%macro test_suite 0
    main:
        enter   0, 0
        xor     rax, rax
%endmacro

%macro end_test_suite 0
    mov     rax, [db_test_suite_result]
    leave
    ret
%endmacro

segment .data
dd_epsilon dq 0.001

ds_print_file_and_line dd `%s:%d: \0`
assert_double_eq_fail dd `assert_double_eq: expected %lf to be %lf.\n\0`

db_test_suite_result dq 0

ds_testlib_file_name dd __FILE__

; Assert that the doubles are equal. Print error message, set the global
; test suite result to 1 and return 1 from the current function if they are not
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
    jbe     %%end_success       ; if (xmm0 <= dd_epsilon) jump to %%end

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

    mov     qword [db_test_suite_result], test_suite_failure

    mov     rax, test_suite_failure
    add     rsp, 16
    ; leave the function that called the macro
    ; (when one of the asserts in a test failed, we don't want to
    ; execute other asserts in the test)
    leave
    ret
    jmp     %%leave

    %%end_success:
    add     rsp, 16
    %%leave:
%endmacro

; Run the tests
%macro run_tests 1
%endmacro
