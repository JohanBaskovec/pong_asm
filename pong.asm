%define true 1
%define false 0
%define NULL 0

; libc externs
extern  malloc, free, puts, exit

; SDL externs
extern  SDL_Init, SDL_Quit,\
        SDL_Log,\
        SDL_GetError,\
        SDL_CreateWindow, SDL_DestroyWindow, SDL_GL_SetAttribute,\
        SDL_GL_SetSwapInterval, SDL_GL_CreateContext, SDL_GL_SwapWindow,\
        SDL_PollEvent,\
        SDL_RenderClear, SDL_RenderPresent, SDL_SetRenderDrawColor, lololol
; end SDL externs

; Glew externs
extern glewExperimental, glewInit

; OpenGL extern
extern  glClear, glClearColor,\
        \
        glCreateProgram, glLinkProgram, glGetProgramiv, glUseProgram,\
        glDeleteProgram, glGetProgramInfoLog, glIsProgram,\
        \
        glEnableVertexAttribArray, glVertexAttribPointer,\
        glGetAttribLocation, glDisableVertexAttribArray,\
        \
        glCompileShader, glCreateShader, glShaderSource, glGetShaderiv,\
        glAttachShader, glIsShader, glGetShaderInfoLog,\
        \
        glGenBuffers, glBindBuffers, glBufferData, glBindBuffer,\
        \
        glDrawElements,\
        \
        glEnable,\
        \
        glDebugMessageCallback

%include "SDL.asm"
%include "SDL_events.asm"
%include "SDL_scancode.asm"
%include "SDL_video.asm"
%include "SDL_render.asm"
%include "SDL_opengl.asm"
%include "glew.asm"

segment .data
ds_log_sdl_init_error db `Unable to initialize SDL: %s\n\0`
ds_log_sdl_int_success db `SDL intialization successful.\n\0`
ds_window_title db `Pong\0`
ds_log_sdl_createwindow_error db `SDL window creation failed: %s\n\0`
ds_log_quit_timestamp db  `Program quit after %i ticks\n\0`
ds_log_SDL_GL_CreateContext_error db \
    `SDL_GL_CreateContext error: %s\n\0`
ds_log_SDL_GL_SetSwapInterval_error db \
    `SDL_GL_SetSwapInterval error: %s\n\0`
ds_log_glCompileShader_error db \
    `glCompileShader failed, unable to compile shader %d\n\0`
ds_log_glCompileShader_success db \
    `glCompileShader successful, compiled shader %d\n\0`
ds_log_shader_info db `Shader info log: %s\n\0`
ds_log_shader_info_none db `No shader info available.\n\0`
ds_log_opengl_error db `GL CALLBACK: type = 0x%x, severity = 0x%x, message = %s\n\0`

ds_log_glLinkProgram_error db \
    `glLinkProgram failed, unable to link program %d\n\0`
ds_log_program_info db `Program info log: %s\n\0`
ds_log_program_info_none db `No program info available.\n\0`

ds_log_glGetAttribLocation_error db `No variable named %s in glsl program.\n\0`

ds_vertex_shader_source db `#version 130\n`,\
    `in vec2 LVertexPos2D;\n`,\
    `void main() {\n`,\
    `   gl_Position = vec4( LVertexPos2D.x, LVertexPos2D.y, 0, 1 );\n`,\
    `}\0`

ds_fragment_shader_source db `#version 130\n`,\
    `out vec4 LFragment;\n`,\
    `void main() {\n`,\
    `   LFragment = vec4(1.0, 1.0, 1.0, 1.0);\n`,\
    `}\0`

df_one                              dd  1.0
df_zero                             dd  0.0

dfa_vertex_data dd  -0.5, -0.5, 0.5, -0.5, 0.5, 0.5, -0.5, 0.5

duia_index_data dd 0, 1, 2, 3

ds_LVertexPos2D_var_name   dd "LVertexPos2D", 0

segment .bss
; SDL_Event
d_sdl_event         resb    SDL_Event_max_size

; SDL_Window*
dp_window           resq    1

; SDL_GLContext (void*)
dp_gl_context       resq    1

; GLuint
dui_program_id      resd    1

; GLuint
dui_vertex_shader   resd    1

; GLuint
dui_fragment_shader   resd    1

; char **
dsa_vertex_shader_sources resq 1

; char **
dsa_fragment_shader_sources resq 1

; Glint
di_program_success resd    1

; GLuint
dui_vbo resd 1

; GLuint
dui_ibo resd 1

; GLint
di_vertex_pos_2d_location resd 1


segment .text

global main

main:
    enter   0,0
    ; here the stack is 16-bytes aligned (rsp ends with 0)

    ; int SDL_Init(Uint32 flags)
    mov     edi, SDL_INIT_VIDEO
    call    SDL_Init
    cmp     eax, 0
    jne     .SDL_Init_error

    ; void SDL_Log(const char* fmt, ...)
    mov     rdi, ds_log_sdl_int_success
    xor     rax, rax
    call    SDL_Log

    ; int SDL_GL_SetAttribute(SDL_GLattr attr, int value)
    ; SDL_GLattr is an enum
    mov     edi, SDL_GL_CONTEXT_MAJOR_VERSION
    mov     esi, 3
    call    SDL_GL_SetAttribute

    mov     edi, SDL_GL_CONTEXT_MINOR_VERSION
    mov     esi, 0
    call    SDL_GL_SetAttribute

    mov     edi, SDL_GL_CONTEXT_PROFILE_MASK
    mov     esi, SDL_GL_CONTEXT_PROFILE_CORE
    call    SDL_GL_SetAttribute

    ; SDL_Window* SDL_CreateWindow(const char* title,
    ;                              int         x,
    ;                              int         y,
    ;                              int         w,
    ;                              int         h,
    ;                              Uint32      flags)
    mov     rdi, ds_window_title        ; title
    mov     esi, SDL_WINDOWPOS_CENTERED ; x
    mov     edx, SDL_WINDOWPOS_CENTERED ; y
    mov     ecx, 600                    ; w
    mov     r8d, 600                    ; h
    mov     r9d, SDL_WINDOW_OPENGL      ; flags
    call    SDL_CreateWindow

    cmp     rax, 0
    je      .SDL_CreateWindow_error
    mov     [dp_window], rax

    ; SDL_GLContext SDL_GL_CreateContext(SDL_Window* window)
    mov     rdi, [dp_window]
    call    SDL_GL_CreateContext
    cmp     rax, 0
    je      .SDL_GL_CreateContext_error
    mov     [dp_gl_context], rax

    ;GLboolean glewExperimental, global declared in glew.h
    ;GLboolean = unsigned char
    mov     byte [glewExperimental], byte true
    call    glewInit

    ;void glEnable(GLenum cap);
    mov     rdi, GL_DEBUG_OUTPUT
    call    glEnable

    ;void glDebugMessageCallback(DEBUGPROC callback, const void * userParam);
    mov     rdi, opengl_error_callback
    mov     rsi, NULL
    call    glDebugMessageCallback

    ;int SDL_GL_SetSwapInterval(int interval)
    mov     edi, 1
    call    SDL_GL_SetSwapInterval

    cmp     eax, -1
    je      .SDL_GL_SetSwapInterval_error

    ;GLuint glCreateProgram(void);
    call    glCreateProgram
    mov     [dui_program_id], eax

    mov     qword [dsa_vertex_shader_sources], qword ds_vertex_shader_source

    mov     qword [dsa_fragment_shader_sources], qword ds_fragment_shader_source

    mov     edi, GL_VERTEX_SHADER
    mov     rsi, dsa_vertex_shader_sources
    mov     edx, [dui_program_id]
    call    create_shader
    mov     [dui_vertex_shader],eax

    mov     edi, GL_FRAGMENT_SHADER
    mov     rsi, dsa_fragment_shader_sources
    mov     edx, [dui_program_id]
    call    create_shader
    mov     [dui_fragment_shader],eax

    ;void glLinkProgram(GLuint program);
    mov     edi, [dui_program_id]
    call    glLinkProgram

    ;void glGetProgramiv(GLuint program,
    ;                    GLenum pname,
    ;                    GLint *params);
    mov     edi, [dui_program_id]
    mov     esi, GL_LINK_STATUS
    mov     rdx, di_program_success
    call    glGetProgramiv

    cmp     qword [di_program_success], qword false
    je      .glLinkProgramError

    ;GLint glGetAttribLocation(GLuint program,
    ;                          const GLchar *name);
    mov     edi, [dui_program_id]
    mov     rsi, ds_LVertexPos2D_var_name
    call    glGetAttribLocation

    cmp     eax, -1
    mov     rsi, ds_LVertexPos2D_var_name
    je      .invalid_program_variable
    mov     [di_vertex_pos_2d_location], eax

    ;void glGenBuffers(GLsizei n, GLuint * buffers);
    mov     edi, 1
    mov     rsi, dui_vbo
    call    glGenBuffers

    ;void glBindBuffer(GLenum target, GLuint buffer);
    mov     edi, GL_ARRAY_BUFFER
    mov     esi, [dui_vbo]
    call    glBindBuffer

    ;void glBufferData(GLenum target,
    ;                  GLsizeiptr size,
    ;                  const void * data,
    ;                  GLenum usage);
    mov     edi, GL_ARRAY_BUFFER
    mov     rsi, 2 * 4 * GLfloat_size
    mov     rdx, dfa_vertex_data
    mov     ecx, GL_STATIC_DRAW
    call    glBufferData

    ;void glGenBuffers(GLsizei n, GLuint * buffers);
    mov     edi, 1
    mov     rsi, dui_ibo
    call    glGenBuffers

    ;void glBindBuffer(GLenum target, GLuint buffer);
    mov     edi, GL_ARRAY_BUFFER
    mov     esi, [dui_ibo]
    call    glBindBuffer

    ;void glBufferData(GLenum target,
    ;                  GLsizeiptr size,
    ;                  const void * data,
    ;                  GLenum usage);
    mov     edi, GL_ARRAY_BUFFER
    mov     rsi, 4 * GLuint_size
    mov     rdx, duia_index_data
    mov     ecx, GL_STATIC_DRAW
    call    glBufferData

    .game_loop:
    ;void glClearColor(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
    movss   xmm0, [df_one]
    movss   xmm1, [df_zero]
    movss   xmm2, [df_zero]
    movss   xmm3, [df_one]
    call    glClearColor

    ;void glClear(GLbitfield mask);
    mov     rdi, GL_COLOR_BUFFER_BIT
    call    glClear

    ;void glUseProgram(GLuint program);
    mov     edi, [dui_program_id]
    call    glUseProgram

    ;void glEnableVertexAttribArray(GLuint index);
    mov     edi, [di_vertex_pos_2d_location]
    call    glEnableVertexAttribArray

    mov     edi, GL_ARRAY_BUFFER
    mov     esi, [dui_vbo]
    call    glBindBuffer

    ;void glVertexAttribPointer(GLuint index, GLint size, GLenum type,
    ;                           GLboolean normalized, GLsizei stride,
    ;                           const void * pointer);
    mov     edi, [di_vertex_pos_2d_location]
    mov     esi, 2
    mov     edx, GL_FLOAT
    mov     ecx, GL_FALSE
    mov     r8d, 2 * GLfloat_size
    mov     r9, NULL
    call    glVertexAttribPointer

    mov     edi, GL_ELEMENT_ARRAY_BUFFER
    mov     esi, [dui_ibo]
    call    glBindBuffer

    ;void glDrawElements(GLenum mode, GLsizei count, GLenum type,
    ;                    const void * indices)
    mov     edi, GL_TRIANGLE_FAN
    mov     esi, 4
    mov     edx, GL_UNSIGNED_INT
    mov     rcx, NULL
    call    glDrawElements

    mov     edi, [di_vertex_pos_2d_location]
    call    glDisableVertexAttribArray

    mov     rdi, NULL
    call    glUseProgram

    mov     rdi, [dp_window]
    call    SDL_GL_SwapWindow

    mov     rdi, d_sdl_event
    call    SDL_PollEvent
    cmp     rax,0
    je      .game_loop
    cmp     dword [d_sdl_event+SDL_Event.type],SDL_QUIT
    je      .quit_event
    cmp     dword [d_sdl_event+SDL_Event.type],SDL_KEYDOWN
    je      .key_down
    jmp     .game_loop
    .key_down:
    cmp     dword [d_sdl_event+SDL_KeyboardEvent.keysym+SDL_Keysym.scancode],SDL_SCANCODE_ESCAPE
    je      .quit_event

    jmp     .game_loop

    .quit_event:
    mov     rdi, ds_log_quit_timestamp
    mov     esi, [d_sdl_event+SDL_QuitEvent.timestamp]
    xor     rax, rax
    call    SDL_Log

    mov     rax,[dp_window]
    call    SDL_DestroyWindow

    call    SDL_Quit
    xor     rax, rax
    jmp     .end

    .SDL_Init_error:
    mov     rdi, ds_log_sdl_init_error
    jmp     .SDL_LogError

    .SDL_CreateWindow_error:
    mov     rdi, ds_log_sdl_createwindow_error
    jmp     .SDL_LogError

    .SDL_GL_CreateContext_error:
    mov     rdi, ds_log_SDL_GL_CreateContext_error
    jmp     .SDL_LogError

    .SDL_GL_SetSwapInterval_error:
    mov     rdi, ds_log_SDL_GL_SetSwapInterval_error
    jmp     .SDL_LogError

    .SDL_LogError:
    call    SDL_GetError
    mov     rsi, rax
    call    SDL_Log
    mov     rax,1

    .glLinkProgramError:
    mov     rdi, ds_log_glLinkProgram_error
    mov     esi, [dui_program_id]
    xor     rax, rax
    call    SDL_Log
    mov     edi, [dui_program_id]
    call    print_program_log
    mov     edi, 1
    call    exit

    .invalid_program_variable:
    mov     rdi, ds_log_glGetAttribLocation_error
    call    SDL_Log
    mov     edi, 1
    call    exit

    .end:
    xor     rax,rax
    leave
    ret

;void print_shader_log(GLuint shader)
print_shader_log:
    .ui_info_length     equ 16
    .ui_info_max_length equ 20

    enter   16, 0
    push    r12
    push    r13

    mov     r12d, edi

    ;GLboolean glIsShader(GLuint shader);
    call    glIsShader
    cmp     al, 0
    je      .end

    ;void glGetShaderiv(GLuint shader, GLenum pname, GLint *params);
    mov     edi, r12d
    mov     esi, GL_INFO_LOG_LENGTH
    lea     rdx, [rsp+.ui_info_max_length]
    call    glGetShaderiv

    cmp     [rsp+.ui_info_max_length], dword 0
    je      .no_log

    ;void* malloc(size_t size)
    mov     edi, dword [rsp+.ui_info_max_length]
    call    malloc
    mov     r13, rax
    ; todo: error check malloc

    ;void glGetShaderInfoLog(GLuint shader,
    ;                        GLsizei maxLength,
    ;                        GLsizei *length,
    ;                        GLchar *infoLog);
    mov     edi, r12d
    mov     esi, [rsp+.ui_info_max_length]
    lea     rdx, [rsp+.ui_info_length]
    mov     rcx, r13
    call    glGetShaderInfoLog

    mov     rdi, ds_log_shader_info
    mov     rsi, r13
    xor     rax, rax
    call    SDL_Log

    ;void free(void* ptr)
    mov     rdi, r13
    call    free

    jmp     .end

    .no_log:
    mov     rdi, ds_log_shader_info_none
    xor     rax, rax
    call    SDL_Log

    .end:
    pop     r13
    pop     r12
    leave
    ret

;Create a shader, compile it and attach it to a program.
;GLuint
;create_shader(GLenum shaderType, char **source, GLuint program)
create_shader:
    compiled    equ 32

    enter   16, 0 ; 32
    push    r12   ; 24
    push    r13   ; 16
    push    r14   ; 8
    push    r15   ; 0

    mov     r12d, edi
    mov     r13,  rsi
    mov     r14d, edx

    ;GLuint glCreateShader(GLenum shaderType);
    call    glCreateShader
    mov     r15d, eax

    ;void glShaderSource(GLuint shader,
    ;                    GLsizei count,
    ;                    const GLchar **string,
    ;                    const GLint *length);
    mov     edi, r15d
    mov     esi, 1
    mov     rdx, r13
    mov     rcx, NULL
    call    glShaderSource

    ;void glCompileShader(GLuint shader);
    mov     edi, r15d
    call    glCompileShader

    ;void glGetShaderiv(GLuint shader,
    ;                   GLenum pname,
    ;                   GLint *params);
    mov     edi, r15d
    mov     esi, GL_COMPILE_STATUS
    lea     rdx, [rsp+compiled]
    cmp     qword [rsp+compiled], false
    call    glGetShaderiv
    je      .glCompileShaderError

    mov     rdi, ds_log_glCompileShader_success
    mov     esi, r15d
    xor     eax, eax
    call    SDL_Log

    ;void glAttachShader(GLuint program, GLuint shader);
    mov     edi, r14d
    mov     esi, r15d
    call    glAttachShader
    jmp     .end

    .glCompileShaderError:
    mov     rdi, ds_log_glCompileShader_error
    mov     esi, r15d
    xor     rax, rax
    call    SDL_Log

    mov     edi, r15d
    call    print_shader_log
    mov     rdi, 1
    call    exit

    .end:
    mov     eax, r15d
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    leave
    ret
;From https://www.khronos.org/opengl/wiki/OpenGL_Error
;void
;opengl_error_callback(GLenum source,
;                      GLenum type,
;                      GLuint id,
;                      GLenum severity,
;                      GLsizei length,
;                      const GLchar* message,
;                      const void* userParam)
opengl_error_callback:
    enter   0, 0
    xor     rax, rax
    mov     rdi, ds_log_opengl_error
    mov     rsi, rsi
    mov     rdx, rcx
    mov     rcx, r9
    call    SDL_Log
    leave
    ret

;void print_program_log(GLuint program)
print_program_log:
    .ui_info_length     equ 16
    .ui_info_max_length equ 20

    enter   16, 0
    push    r12
    push    r13

    mov     r12d, edi

    ;GLboolean glIsProgram(GLuint program);
    call    glIsProgram
    cmp     al, 0
    je      .end

    ;void glGetProgramiv(GLuint program, GLenum pname, GLint *params);
    mov     edi, r12d
    mov     esi, GL_INFO_LOG_LENGTH
    lea     rdx, [rsp+.ui_info_max_length]
    call    glGetProgramiv

    cmp     [rsp+.ui_info_max_length], dword 0
    je      .no_log

    ;void* malloc(size_t size)
    mov     edi, dword [rsp+.ui_info_max_length]
    call    malloc
    mov     r13, rax
    ; todo: error check malloc

    ;void glGetProgramInfoLog(GLuint program,
    ;                         GLsizei maxLength,
    ;                         GLsizei *length,
    ;                         GLchar *infoLog);
    mov     edi, r12d
    mov     esi, [rsp+.ui_info_max_length]
    lea     rdx, [rsp+.ui_info_length]
    mov     rcx, r13
    call    glGetProgramInfoLog

    mov     rdi, ds_log_program_info
    mov     rsi, r13
    xor     rax, rax
    call    SDL_Log

    ;void free(void* ptr)
    mov     rdi, r13
    call    free

    jmp     .end

    .no_log:
    mov     rdi, ds_log_program_info_none
    xor     rax, rax
    call    SDL_Log

    .end:
    pop     r13
    pop     r12
    leave
    ret
