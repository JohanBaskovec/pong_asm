;Application events
%define SDL_QUIT        0x100  ;User-requested quit
%define SDL_KEYDOWN     0x300  ;Key pressed
%define SDL_KEYUP       0x301  ;Key released

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

