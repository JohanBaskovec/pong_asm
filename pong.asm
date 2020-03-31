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

; SDL_video.h

%define SDL_WINDOW_FULLSCREEN  0x00000001         ;/**< fullscreen window */
%define SDL_WINDOW_OPENGL  0x00000002             ;/**< window usable with OpenGL context */
%define SDL_WINDOW_SHOWN  0x00000004              ;/**< window is visible */
%define SDL_WINDOW_HIDDEN  0x00000008             ;/**< window is not visible */
%define SDL_WINDOW_BORDERLESS  0x00000010         ;/**< no window decoration */
%define SDL_WINDOW_RESIZABLE  0x00000020          ;/**< window can be resized */
%define SDL_WINDOW_MINIMIZED  0x00000040          ;/**< window is minimized */
%define SDL_WINDOW_MAXIMIZED  0x00000080          ;/**< window is maximized */
%define SDL_WINDOW_INPUT_GRABBED  0x00000100      ;/**< window has grabbed input focus */
%define SDL_WINDOW_INPUT_FOCUS  0x00000200        ;/**< window has input focus */
%define SDL_WINDOW_MOUSE_FOCUS  0x00000400        ;/**< window has mouse focus */
%define SDL_WINDOW_FULLSCREEN_DESKTOP  SDL_WINDOW_FULLSCREEN|0x00001000
%define SDL_WINDOW_FOREIGN  0x00000800            ;/**< window not created by SDL */
%define SDL_WINDOW_ALLOW_HIGHDPI  0x00002000      ;/**< window should be created in high-DPI mode if supported.
                                                  ;On macOS NSHighResolutionCapable must be set true in the
                                                  ;application's Info.plist for this to have any effect. */
%define SDL_WINDOW_MOUSE_CAPTURE  0x00004000      ;/**< window has mouse captured (unrelated to INPUT_GRABBED) */
%define SDL_WINDOW_ALWAYS_ON_TOP  0x00008000      ;/**< window should always be above others */
%define SDL_WINDOW_SKIP_TASKBAR   0x00010000      ;/**< window should not be added to the taskbar */
%define SDL_WINDOW_UTILITY        0x00020000      ;/**< window should be treated as a utility window */
%define SDL_WINDOW_TOOLTIP        0x00040000      ;/**< window should be treated as a tooltip */
%define SDL_WINDOW_POPUP_MENU     0x00080000      ;/**< window should be treated as a popup menu */
%define SDL_WINDOW_VULKAN         0x10000000       ;/**< window usable for Vulkan surface */

%define SDL_WINDOWPOS_CENTERED_MASK    0x2FFF0000
%define SDL_WINDOWPOS_CENTERED_DISPLAY(X)  (SDL_WINDOWPOS_CENTERED_MASK|(X))
%define SDL_WINDOWPOS_CENTERED         SDL_WINDOWPOS_CENTERED_DISPLAY(0)
%define SDL_WINDOWPOS_ISCENTERED(X)    (((X)&0xFFFF0000) == SDL_WINDOWPOS_CENTERED_MASK)

; SDL_event.h
%define SDL_QUIT           0x100 ; /**< User-requested quit */

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

; SDL_Event is an union whose size is 56 bytes
; because of its member `Uint8 padding[56];`
%define SDL_Event_max_size 56


segment .data
dba_log_sdl_init_error          db  `Unable to initialize SDL: %s\n\0`
dba_log_sdl_int_success         db  `SDL intialization successful.\n\0`
dba_window_title                db  `Pong\n\0`
dba_log_sdl_createwindow_error  db  `SDL window creation failed.\n\0`
dba_log_quit_timestamp          db  `Program quit after %i ticks\n\0`

segment .bss
b_sdl_event     resb    SDL_Event_max_size


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
    mov     r9, 0                       ; flags
    call    SDL_CreateWindow

    cmp     rax,0
    je      .SDL_CreateWindow_error
    mov     r12,rax

    .game_loop:
    mov     rdi, b_sdl_event
    call    SDL_PollEvent
    cmp     rax,0
    je      .game_loop
    cmp     dword [b_sdl_event+SDL_Event.type],SDL_QUIT
    je      .quit_event
    jmp     .game_loop

    .quit_event:
    mov     rdi, dba_log_quit_timestamp
    mov     esi, [b_sdl_event+SDL_QuitEvent.timestamp]
    call    SDL_Log

    mov     rax,r12
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

    .SDL_LogError:
    call    SDL_GetError
    mov     rsi, rax
    mov     rax,1

    .end:
    leave
    ret
