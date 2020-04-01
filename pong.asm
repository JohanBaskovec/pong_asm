; SDL externs
extern SDL_Init, SDL_Quit
extern SDL_Log
extern SDL_GetError
extern SDL_CreateWindow, SDL_DestroyWindow, SDL_GL_SetAttribute, SDL_GL_SetSwapInterval, SDL_GL_CreateContext, SDL_GL_SwapWindow
extern SDL_PollEvent
extern SDL_RenderClear, SDL_RenderPresent, SDL_SetRenderDrawColor, SDL_CreateRenderer
; end SDL externs

; Glew externs
extern glewExperimental, glewInit

; OpenGL extern
extern glClear, glClearColor

%include "SDL.asm"
%include "SDL_events.asm"
%include "SDL_scancode.asm"
%include "SDL_video.asm"
%include "SDL_render.asm"
%include "SDL_opengl.asm"

segment .data
dba_log_sdl_init_error              db  `Unable to initialize SDL: %s\n\0`
dba_log_sdl_int_success             db  `SDL intialization successful.\n\0`
dba_window_title                    db  `Pong\n\0`
dba_log_sdl_createwindow_error      db  `SDL window creation failed: %s\n\0`
dba_log_quit_timestamp              db  `Program quit after %i ticks\n\0`
dba_log_sdl_create_renderer_error   db  `SDL renderer creation failed: %s\n\0`
dba_log_sdl_gl_create_context_error db  `SDL OpenGL context creation failed: %s\n\0`

df_one                              dd  1.0
df_zero                             dd  0.0

segment .bss
; last event from SDL
b_sdl_event     resb    SDL_Event_max_size

; address of the SDL_Window
b_window        resq    1

; SDL_GLContext, is an opaque pointer to an OpenGL context (void*)
b_gl_context    resq    1

segment .text

global main

main:
    enter   0,0
    xor     rax,rax

    mov     rdi, SDL_INIT_VIDEO
    call    SDL_Init
    cmp     rax,0
    jne     .SDL_Init_error

    mov     rdi, dba_log_sdl_int_success
    call    SDL_Log

    mov     rdi,SDL_GL_CONTEXT_MAJOR_VERSION
    mov     rsi,3
    call    SDL_GL_SetAttribute

    mov     rdi,SDL_GL_CONTEXT_MINOR_VERSION
    mov     rsi,0
    call    SDL_GL_SetAttribute

    mov     rdi,SDL_GL_CONTEXT_PROFILE_MASK
    mov     rsi,SDL_GL_CONTEXT_PROFILE_CORE
    call    SDL_GL_SetAttribute

    mov     rdi, dba_window_title       ; title
    mov     rsi, SDL_WINDOWPOS_CENTERED ; x
    mov     rdx, SDL_WINDOWPOS_CENTERED ; y
    mov     rcx, 100                    ; w
    mov     r8, 100                     ; h
    mov     r9, SDL_WINDOW_OPENGL       ; flags
    call    SDL_CreateWindow

    cmp     rax,0
    je      .SDL_CreateWindow_error
    mov     [b_window],rax

    mov     rdi, [b_window]   ; window
    call    SDL_GL_CreateContext
    cmp     rax,0
    je      .SDL_GL_CreateContext_error
    mov     [b_gl_context],rax

    mov     qword [glewExperimental], qword 1
    call    glewInit

    mov     rdi,1
    call    SDL_GL_SetSwapInterval

    .game_loop:
    movss   xmm0, [df_one]
    movss   xmm1, [df_zero]
    movss   xmm2, [df_zero]
    movss   xmm3, [df_one]
    call    glClearColor

    mov     rdi, GL_COLOR_BUFFER_BIT
    call    glClear

    mov     rdi, [b_window]
    call    SDL_GL_SwapWindow
    mov     rdi, b_sdl_event
    call    SDL_PollEvent
    cmp     rax,0
    je      .game_loop
    cmp     dword [b_sdl_event+SDL_Event.type],SDL_QUIT
    je      .quit_event
    cmp     dword [b_sdl_event+SDL_Event.type],SDL_KEYDOWN
    je      .key_down
    jmp     .game_loop
    .key_down:
    cmp     dword [b_sdl_event+SDL_KeyboardEvent.keysym+SDL_Keysym.scancode],SDL_SCANCODE_ESCAPE
    je      .quit_event
    jmp     .game_loop

    .quit_event:
    mov     rdi, dba_log_quit_timestamp
    mov     esi, [b_sdl_event+SDL_QuitEvent.timestamp]
    call    SDL_Log

    mov     rax,[b_window]
    call    SDL_DestroyWindow

    call    SDL_Quit
    xor     rax, rax
    jmp     .end

    .SDL_Init_error:
    mov     rdi, dba_log_sdl_init_error
    jmp     .SDL_LogError

    .SDL_CreateWindow_error:
    mov     rdi, dba_log_sdl_createwindow_error
    jmp     .SDL_LogError

    .SDL_CreateRenderer_error:
    mov     rdi, dba_log_sdl_create_renderer_error
    jmp     .SDL_LogError

    .SDL_GL_CreateContext_error:
    mov     rdi, dba_log_sdl_gl_create_context_error
    jmp     .SDL_LogError

    .SDL_LogError:
    call    SDL_GetError
    mov     rsi, rax
    call    SDL_Log
    mov     rax,1

    .end:
    leave
    ret
