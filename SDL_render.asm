%define SDL_RENDERER_SOFTWARE  0x00000001         
%define SDL_RENDERER_ACCELERATED  0x00000002      
%define SDL_RENDERER_PRESENTVSYNC  0x00000004     
%define SDL_RENDERER_TARGETTEXTURE  0x00000008     

struc SDL_RendererInfo
    .name                   resq    1   ; pointer to char array
    .flags                  resd    1
    .num_texture_formats    resd    1
    .texture_formats        resd    16
    .max_texture_width      resd    1
    .max_texture_height     resd    1
endstruc
