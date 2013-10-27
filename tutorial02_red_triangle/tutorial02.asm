;; Define the externs for the functions that we'll use in this program. 
%include "GLEWN.INC"
%include "GLFW3N.INC"

;; Define the externs for the functions that we'll use in this program. 
extern _glfwInit 
extern _glfwWindowHint
extern _glfwCreateWindow
extern _glfwMakeContextCurrent
extern _glfwTerminate
extern _glfwSwapBuffers
extern _glfwGetKey
extern _glfwWindowShouldClose
extern _glfwPollEvents
extern _glClearColor@16
extern _glClear@4
extern _glewInit@0
extern __imp____glewBindVertexArray
extern __imp____glewGenVertexArrays
extern __imp____glewGenBuffers
extern __imp____glewBindBuffer
extern __imp____glewBufferData
extern __imp____glewEnableVertexAttribArray
extern __imp____glewVertexAttribPointer
extern __imp____glewLinkProgram
extern __imp____glewAttachShader
extern __imp____glewCreateProgram
extern __imp____glewCompileShader
extern __imp____glewShaderSource
extern __imp____glewCreateShader
extern __imp____glewUseProgram
extern _glDrawArrays@12
extern __imp____glewDisableVertexAttribArray
extern _ExitProcess@4

section .code use32 Class=CODE

;; In order to make this code as similar as possible to NeHe's OpenGL tutorial
;; we will first get all of the params of WinMain and call the WinMain function
;; if we were going for as small a program as possible this could be done all in
;; the WinMain function.
global _start
;; Entry point of program
_start: 
main:

  call _glfwInit
  sub dword eax,0
  jnz .InitSuccess
  ;;Say something usefull
  push dword -1
  jmp .exit
 .InitSuccess:
 
  push dword 4
  push dword GLFW_SAMPLES ;note renamed GLFW_FSAA_SAMPLES
  call _glfwWindowHint
  push dword 3
  push dword GLFW_CONTEXT_VERSION_MAJOR ;;note renamed GLFW_OPENGL_VERSION_MAJOR
  call _glfwWindowHint
  push dword 3
  push dword GLFW_CONTEXT_VERSION_MINOR ;;note renamed GLFW_OPENGL_VERSION_MINOR
  call _glfwWindowHint
  push dword GLFW_OPENGL_CORE_PROFILE
  push dword GLFW_OPENGL_PROFILE
  call _glfwWindowHint

  push dword 0 ;;Null
  push dword 0 ;;Null
  push dword Title
  push dword 768
  push dword 1024
  call _glfwCreateWindow
  add  dword esp,52 ;clean up the stack from all these std calls
  
  sub dword eax,0
  jnz .CreateWindowSuccess
  ;;Say something useful about window fail
  push dword -1
  jmp .terminate
 .CreateWindowSuccess:
 
  push eax ;;This is the window reference stick on top of stack as its used lots
  call _glfwMakeContextCurrent ;Added for GLFWV3

  call _glewInit@0
  sub dword eax,0
  jz .GlewInitSuccess  ;;GLEW_OKAY is 0
  ;;Say somethign useful about glew failing
  push dword -1
  jmp .terminate
 .GlewInitSuccess:
 
  push dword 0
  push dword [ZP4] 
  push dword 0
  push dword 0
  call _glClearColor@16 ;note this is a cdecl call
   
  push dword VertexArrayID
  push dword 1
  mov dword eax,[__imp____glewGenVertexArrays]
  call [eax]
  push dword [VertexArrayID]
  mov dword eax,[__imp____glewBindVertexArray]
  call [eax]
  
  call LoadShaders
  
  push dword Vertexbuffer
  push dword 1
  mov dword eax,[__imp____glewGenBuffers]
  call [eax]

  push dword [Vertexbuffer]
  push dword GL_ARRAY_BUFFER
  mov dword eax,[__imp____glewBindBuffer]
  call [eax]

  push dword GL_STATIC_DRAW
  push dword g_vertex_buffer_data
  push dword g_vertex_buffer_data_size
  push dword GL_ARRAY_BUFFER
  mov dword eax,[__imp____glewBufferData]
  call [eax]

 .buffloop:
 
  push dword GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
  call _glClear@4
  
  push dword [ProgramID]
  mov dword eax,[__imp____glewUseProgram]
  call [eax]
  
  mov dword eax,[__imp____glewEnableVertexAttribArray]
  push dword 0
  call [eax]
  
  push dword [Vertexbuffer]
  push dword GL_ARRAY_BUFFER
  mov dword eax,[__imp____glewBindBuffer]
  call [eax]

  push dword 0
  push dword 0
  push dword GL_FALSE
  push dword GL_FLOAT
  push dword 3
  push dword 0
  mov dword eax,[__imp____glewVertexAttribPointer]
  call [eax]

  push dword 3
  push dword 0
  push dword GL_TRIANGLES
  call _glDrawArrays@12

  push dword 0
  mov dword eax,[__imp____glewDisableVertexAttribArray]
  call [eax]

 
  call _glfwPollEvents
  call _glfwSwapBuffers ;as this is a std call and window is allready on stack
  ;we dont need to give it any other params.
  pop eax
  push dword GLFW_KEY_ESCAPE;;note renamed GLFW_KEY_ESC
  push eax
  call _glfwGetKey
  sub dword eax,0
  jnz .terminate
  pop eax
  mov [esp],eax
  call _glfwWindowShouldClose
  sub dword eax,0
  jnz .terminate
  jmp .buffloop
  
  push dword 1
 .terminate:
  call _glfwTerminate
 .exit:
  call _ExitProcess@4

LoadShaders:
  push dword GL_VERTEX_SHADER
  mov dword eax,[__imp____glewCreateShader]
  call [eax]
  mov [VertexShaderID],eax
  
  push dword GL_FRAGMENT_SHADER
  mov dword eax,[__imp____glewCreateShader]
  call [eax]
  mov [FragmentShaderID],eax
  
  push dword 0
  push dword SimpleVertexShaderPoint
  push dword 1
  push dword [VertexShaderID]
  mov dword eax,[__imp____glewShaderSource]
  call [eax]
  
  push dword [VertexShaderID]
  mov dword eax,[__imp____glewCompileShader]
  call [eax]
  
  push dword 0
  push dword SimpleFragmentShaderPoint
  push dword 1
  push dword [FragmentShaderID]
  mov dword eax,[__imp____glewShaderSource]
  call [eax]
  
  push dword [FragmentShaderID]
  mov dword eax,[__imp____glewCompileShader]
  call [eax]
  
  mov dword eax,[__imp____glewCreateProgram]
  call [eax]
  mov dword [ProgramID],eax
  
  push dword [VertexShaderID]
  push dword [ProgramID]
  mov dword eax,[__imp____glewAttachShader]
  call [eax]
  
  push dword [FragmentShaderID]
  push dword [ProgramID]
  mov dword eax,[__imp____glewAttachShader]
  call [eax]
  
  push dword [ProgramID]
  mov dword eax,[__imp____glewLinkProgram]
  call [eax]
  mov dword eax,[ProgramID]
  
  ret
section .data USE32
Title   db "Tutorial 02", 0 
ZP4 dd 0.4
g_vertex_buffer_data:
dd -1.0,-1.0, 0.0
dd  1.0,-1.0, 0.0
dd  0.0, 1.0, 0.0
g_vertex_buffer_data_size equ $-g_vertex_buffer_data

SimpleVertexShaderPoint dd SimpleVertexShader
SimpleVertexShader:
incbin "SimpleVertexShader.vertexshader"
db 0
SimpleVertexShader_size equ $-SimpleVertexShader

SimpleFragmentShaderPoint dd SimpleFragmentShader
SimpleFragmentShader:
incbin "SimpleFragmentShader.fragmentshader"
db 0
SimpleFragmentShader_size equ $-SimpleFragmentShader

section .bss USE32
VertexArrayID resd 1
Vertexbuffer resd 1

VertexShaderID resd 1
FragmentShaderID resd 1
ProgramID resd 1