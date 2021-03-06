%include "defines.asm"

; libc externs
extern  malloc, free, puts, exit, printf

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
extern  glClear, glClearColor,glPolygonMode,\
        glCreateProgram, glLinkProgram, glGetProgramiv, glUseProgram,\
        glDeleteProgram, glGetProgramInfoLog, glIsProgram,\
        glGenVertexArrays, glBindVertexArray,\
        glEnableVertexAttribArray, glVertexAttribPointer,\
        glGetAttribLocation, glDisableVertexAttribArray,\
        glCompileShader, glCreateShader, glShaderSource, glGetShaderiv,\
        glAttachShader, glIsShader, glGetShaderInfoLog, glDeleteShader,\
        glGenBuffers, glBindBuffers, glBufferData, glBindBuffer,\
        glDrawElements, glEnable,\
        glDebugMessageCallback, glGetUniformLocation, glUniformMatrix4fv,\
        glViewport

%include "SDL.asm"
%include "SDL_events.asm"
%include "SDL_scancode.asm"
%include "SDL_video.asm"
%include "SDL_render.asm"
%include "SDL_opengl.asm"
%include "glew.asm"
%include "maths.asm"

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
    `in vec3 LVertexPos2D;\n`,\
    `uniform mat4 model;\n`,\
    `uniform mat4 view;\n`,\
    `uniform mat4 projection;\n`,\
    `void main() {\n`,\
    `   gl_Position = projection * view * model * vec4(LVertexPos2D, 1.0f);\n`,\
    `}\0`

ds_fragment_shader_source db `#version 130\n`,\
    `out vec4 LFragment;\n`,\
    `void main() {\n`,\
    `   LFragment = vec4(1.0, 1.0, 1.0, 1.0);\n`,\
    `}\0`

df_one                              dd  1.0
df_zero                             dd  0.0

; 3D model of paddle
dfa_vertex_data dd  -0.5, -0.5, 0.0, \
                    0.5,  -0.5, 0.0,\
                    0.5,  0.5,  0.0,\
                    -0.5, 0.5,  0.0
duia_index_data dd 0, 1, 2, 3

; world space position
dfa_paddle_1_position dd 0.0, 0.0, 0.0

dfa_camera_position dd 0.0, 0.0, -6.0

di_screen_width dd 800
di_screen_height dd 600
df_screen_width dd 800.0
df_screen_height dd 600.0

ds_LVertexPos2D_var_name   dd "LVertexPos2D", 0
ds_model_var_name   dd "model", 0
ds_projection_var_name   dd "projection", 0
ds_view_var_name   dd "view", 0

db_wireframe db false

%define pi __float64__(3.141592653589793238462)

dfa_translate_vec dd 0.4, 0.5, 0.0

df_z_near dd 0.1
df_z_far dd 100.0

; GLfloat
df_fov dd 45.0

df_delta_time dd 0.0
df_last_frame dd 0.0

; keys pressed
db_up db false
db_down db false

df_movement_speed dd 0.1

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

; GLuint
dui_vao resd 1

; GLint
di_vertex_pos_2d_location resd 1

; GLint
di_shader_projection_variable_location resd 1

; GLint
di_shader_view_variable_location resd 1

; GLint
di_shader_model_variable_location resd 1

; GLfloat*
dfa_view_mat resd 16

; GLfloat*
dfa_projection_mat resd 16

; GLfloat*
dfa_model_mat resd 16

; float
df_screen_ratio resd 1

df_fov_rad resd 1

segment .text

global main

main:
    enter   0,0
    ; here the stack is 16-bytes aligned (rsp ends with 0)

    movss   xmm0, [df_screen_width]
    divss   xmm0, [df_screen_height]
    movss   [df_screen_ratio], xmm0

    movss   xmm0, [df_fov]
    degrees_to_radiansf
    movss   [df_fov_rad], xmm0

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
    mov     ecx, [di_screen_width]      ; w
    mov     r8d, [di_screen_height]     ; h
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

    mov     rdi, GL_DEPTH_TEST
    call    glEnable

    mov     edi, 0
    mov     esi, 0
    mov     edx, [di_screen_width]
    mov     ecx, [di_screen_height]
    call    glViewport

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

    mov     rdi, [dui_fragment_shader]
    call    glDeleteShader

    mov     rdi, [dui_vertex_shader]
    call    glDeleteShader

    ;void glUseProgram(GLuint program);
    mov     edi, [dui_program_id]
    call    glUseProgram

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

    ;GLint glGetUniformLocation(GLuint program, const GLchar *name);
    mov     edi, [dui_program_id]
    mov     rsi, ds_model_var_name
    call    glGetUniformLocation
    mov     [di_shader_model_variable_location], eax

    mov     edi, [dui_program_id]
    mov     rsi, ds_view_var_name
    call    glGetUniformLocation
    mov     [di_shader_view_variable_location], eax

    mov     edi, [dui_program_id]
    mov     rsi, ds_projection_var_name
    call    glGetUniformLocation
    mov     [di_shader_projection_variable_location], eax

    ;void glGenVertexArrays(GLsizei n, GLuint *arrays);
    mov     edi, 1
    mov     rsi, dui_vao
    call    glGenVertexArrays

    ;void glGenBuffers(GLsizei n, GLuint * buffers);
    mov     edi, 1
    mov     rsi, dui_vbo
    call    glGenBuffers

    ; The VAO stores the vertex attribute configurations
    mov     edi, [dui_vao]
    call    glBindVertexArray

    ;void glBindBuffer(GLenum target, GLuint buffer);
    mov     edi, GL_ARRAY_BUFFER
    mov     esi, [dui_vbo]
    call    glBindBuffer

    ;void glBufferData(GLenum target,
    ;                  GLsizeiptr size,
    ;                  const void * data,
    ;                  GLenum usage);
    mov     edi, GL_ARRAY_BUFFER
    mov     rsi, 3 * 4 * GLfloat_size
    mov     rdx, dfa_vertex_data
    mov     ecx, GL_STATIC_DRAW
    call    glBufferData

    ;void glVertexAttribPointer(GLuint index, GLint size, GLenum type,
    ;                           GLboolean normalized, GLsizei stride,
    ;                           const void * pointer);
    mov     edi, [di_vertex_pos_2d_location]
    mov     esi, 3
    mov     edx, GL_FLOAT
    mov     ecx, GL_FALSE
    mov     r8d, 3 * GLfloat_size
    mov     r9, NULL
    call    glVertexAttribPointer

    ;void glEnableVertexAttribArray(GLuint index);
    mov     edi, [di_vertex_pos_2d_location]
    call    glEnableVertexAttribArray

    ;void glGenBuffers(GLsizei n, GLuint * buffers);
    mov     edi, 1
    mov     rsi, dui_ibo
    call    glGenBuffers

    ;void glBindBuffer(GLenum target, GLuint buffer);
    mov     edi, GL_ELEMENT_ARRAY_BUFFER
    mov     esi, [dui_ibo]
    call    glBindBuffer

    ;void glBufferData(GLenum target,
    ;                  GLsizeiptr size,
    ;                  const void * data,
    ;                  GLenum usage);
    mov     edi, GL_ELEMENT_ARRAY_BUFFER
    mov     rsi, 4 * GLuint_size
    mov     rdx, duia_index_data
    mov     ecx, GL_STATIC_DRAW
    call    glBufferData

    ;Unbind the VAO, not needed anymore
    mov     edi, 0
    call    glBindVertexArray

    .game_loop:
    ;void glClearColor(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
    movss   xmm0, [df_one]
    movss   xmm1, [df_zero]
    movss   xmm2, [df_zero]
    movss   xmm3, [df_one]
    call    glClearColor

    ;void glClear(GLbitfield mask);
    mov     rdi, GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
    call    glClear

    ;void glUseProgram(GLuint program);
    mov     edi, [dui_program_id]
    call    glUseProgram

    ; create and set the view matrix
    mov     rdi, dfa_view_mat
    call    mat4f_identity

    mov     rdi, dfa_view_mat
    mov     rsi, dfa_camera_position
    call    mat4f_vec3_translate

    mov     edi, [di_shader_view_variable_location]
    mov     esi, 1
    mov     edx, false
    mov     rcx, dfa_view_mat
    call    glUniformMatrix4fv

    ; projection matrix
    mov     rdi, dfa_projection_mat
    movss   xmm0, [df_fov_rad]
    movss   xmm1, [df_screen_ratio]
    movss   xmm2, [df_z_near]
    movss   xmm3, [df_z_far]
    call    mat4f_perspective

    mov     edi, [di_shader_projection_variable_location]
    mov     esi, 1
    mov     edx, false
    mov     rcx, dfa_projection_mat
    call    glUniformMatrix4fv

    mov     edi, [dui_vao]
    call    glBindVertexArray

    ; model matrix (the position of the paddle in the world)
    mov     rdi, dfa_model_mat
    call    mat4f_identity

    mov     rdi, dfa_model_mat
    mov     rsi, dfa_paddle_1_position
    call    mat4f_vec3_translate

    mov     edi, [di_shader_model_variable_location]
    mov     esi, 1
    mov     edx, false
    mov     rcx, dfa_model_mat
    call    glUniformMatrix4fv

    ;void glDrawElements(GLenum mode, GLsizei count, GLenum type,
    ;                    const void * indices)
    mov     edi, GL_TRIANGLE_FAN
    mov     esi, 4
    mov     edx, GL_UNSIGNED_INT
    mov     rcx, NULL
    call    glDrawElements

    mov     rdi, NULL
    call    glUseProgram
    mov     rdi, [dp_window]
    call    SDL_GL_SwapWindow

    cmp     byte [db_up], byte true
    jne      .check_move_down
    movss   xmm0, [df_movement_speed]
    movss   xmm1, [dfa_paddle_1_position+1*float_size]
    addss   xmm0, xmm1
    movss   [dfa_paddle_1_position+1*float_size], xmm0
    .check_move_down:
    cmp     byte [db_down], byte true
    jne     .poll_events
    movss   xmm0, [dfa_paddle_1_position+1*float_size]
    movss   xmm1, [df_movement_speed]
    subss   xmm0, xmm1
    movss   [dfa_paddle_1_position+1*float_size], xmm0


    .poll_events:
    mov     rdi, d_sdl_event
    call    SDL_PollEvent
    cmp     rax,0
    je      .game_loop
    cmp     dword [d_sdl_event+SDL_Event.type],SDL_QUIT
    je      .quit_event
    cmp     dword [d_sdl_event+SDL_Event.type],SDL_KEYDOWN
    je      .key_down
    cmp     dword [d_sdl_event+SDL_Event.type],SDL_KEYUP
    je      .key_up
    jmp     .game_loop
    .key_down:
    mov     edi, dword [d_sdl_event+SDL_KeyboardEvent.keysym+SDL_Keysym.scancode]
    cmp     edi, SDL_SCANCODE_ESCAPE
    je      .quit_event
    cmp     edi, SDL_SCANCODE_O
    je      .pressed_o
    cmp     edi, SDL_SCANCODE_W
    je      .pressed_w
    cmp     edi, SDL_SCANCODE_S
    je      .pressed_s
    jmp     .game_loop
    .pressed_w:
    mov     byte [db_up], byte true
    jmp     .game_loop
    .pressed_s:
    mov     byte [db_down], byte true
    jmp     .game_loop
    .pressed_o:
    cmp     byte [db_wireframe], byte false
    jmp     .game_loop
    je .switch_to_wireframe
    mov     rdi, GL_FRONT_AND_BACK
    mov     rsi, GL_FILL
    call    glPolygonMode
    mov     byte [db_wireframe], byte false
    jmp     .game_loop
    .switch_to_wireframe:
    mov     rdi, GL_FRONT_AND_BACK
    mov     rsi, GL_LINE
    call    glPolygonMode
    mov     byte [db_wireframe], byte true
    jmp     .game_loop
    .key_up:
    mov     edi, dword [d_sdl_event+SDL_KeyboardEvent.keysym+SDL_Keysym.scancode]
    cmp     edi, SDL_SCANCODE_W
    je      .released_w
    cmp     edi, SDL_SCANCODE_S
    je      .released_s
    jmp     .game_loop
    .released_w:
    mov     byte [db_up], byte false
    jmp     .game_loop
    .released_s:
    mov     byte [db_down], byte false
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
