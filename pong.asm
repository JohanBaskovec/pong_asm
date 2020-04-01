; SDL externs
; SDL.h
extern SDL_Init, SDL_Quit

; SDL_log.h
extern SDL_Log

; SDL_error.h
extern SDL_GetError

; SDL_video.h
extern SDL_CreateWindow, SDL_DestroyWindow

; SDL_event.h
extern SDL_PollEvent

; SDL_render.h
extern SDL_RenderClear, SDL_RenderPresent, SDL_SetRenderDrawColor, SDL_CreateRenderer
; end SDL externs

; SDL defines
; SDL.h
%define SDL_INIT_TIMER          0x00000001
%define SDL_INIT_AUDIO          0x00000010
%define SDL_INIT_VIDEO          0x00000020  ;/**< SDL_INIT_VIDEO implies SDL_INIT_EVENTS */
%define SDL_INIT_JOYSTICK       0x00000200  ;/**< SDL_INIT_JOYSTICK implies SDL_INIT_EVENTS */
%define SDL_INIT_HAPTIC         0x00001000
%define SDL_INIT_GAMECONTROLLER 0x00002000  ;/**< SDL_INIT_GAMECONTROLLER implies SDL_INIT_JOYSTICK */
%define SDL_INIT_EVENTS         0x00004000
%define SDL_INIT_NOPARACHUTE    0x00100000  ;/**< compatibility; this flag is ignored. */

%include "SDL_events.asm"
%include "SDL_scancode.asm"
%include "SDL_video.asm"
%include "SDL_render.asm"

; end SDL defines

struc SDL_Event
    .type   resd  1 ; Uint32 type
endstruc

struc SDL_QuitEvent
    .type       resd    1
    .timestamp  resd    1
endstruc

struc SDL_WindowEvent
    .type       resd  1
    .timestamp  resd  1
    .windowID   resd  1
    .event      resb  1
    .padding1   resb  1
    .padding2   resb  1
    .padding3   resb  1
    .data1      resd  1
    .data2      resd  1
endstruc

struc SDL_Keysym
    ; SDL makes sure that the enums are the size of ints
    ; (in SDL_stdinc.h, line 320)
    .scancode   resd    1 ; enum SDL_Scancode in C
    .sym        resd    1 ; enum SDL_Keycode in C
    .mod        resw    1
    .unused     resd    1
endstruc

struc SDL_KeyboardEvent
    .type       resd  1
    .timestamp  resd  1
    .windowID   resd  1
    .state      resb  1
    .repeat     resb  1
    .padding2   resb  1
    .padding3   resb  1
    .keysym     resb  SDL_Keysym_size
endstruc

; SDL_Event is an union whose size is 56 bytes
; because of its member `Uint8 padding[56];`
%define SDL_Event_max_size 56


segment .data
dba_log_sdl_init_error              db  `Unable to initialize SDL: %s\n\0`
dba_log_sdl_int_success             db  `SDL intialization successful.\n\0`
dba_window_title                    db  `Pong\n\0`
dba_log_sdl_createwindow_error      db  `SDL window creation failed.\n\0`
dba_log_quit_timestamp              db  `Program quit after %i ticks\n\0`
dba_log_sdl_create_renderer_error   db  `SDL renderer creation failed.\n\0`

segment .bss
; last event from SDL
b_sdl_event     resb    SDL_Event_max_size

; address of the SDL_Window
b_window        resq    1

; address of the SDL_Renderer
b_renderer      resq    1

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
    mov     rsi, -1         ; index
    mov     rdx, SDL_RENDERER_ACCELERATED ; flags
    call    SDL_CreateRenderer
    cmp     rax,0
    je      .SDL_CreateRenderer_error
    mov     [b_renderer], rax

    mov     rdi, [b_renderer]
    mov     rsi, 255
    mov     rdx, 0
    mov     rcx, 0
    mov     r8, 255
    call    SDL_SetRenderDrawColor

    .game_loop:
    mov     rdi, [b_renderer]
    call    SDL_RenderClear
    mov     rdi, [b_renderer]
    call    SDL_RenderPresent
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

    .SDL_LogError:
    call    SDL_GetError
    mov     rsi, rax
    call    SDL_Log
    mov     rax,1

    .end:
    leave
    ret
