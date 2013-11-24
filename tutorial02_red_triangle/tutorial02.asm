;; Define the externs for the functions that we'll use in this program. 
%include "GLEWN.INC"
%include "GLFW3N.INC"
%include "MULTILINK.INC"

;; Define the externs for the functions that we'll use in this program. 
ExternImport glfwInit,              glfw3.dll,-
ExternImport glfwWindowHint,        glfw3.dll,-
ExternImport glfwCreateWindow,      glfw3.dll,-
ExternImport glfwMakeContextCurrent,glfw3.dll,-
ExternImport glfwTerminate,         glfw3.dll,-
ExternImport glfwSwapBuffers,       glfw3.dll,-
ExternImport glfwGetKey,            glfw3.dll,-
ExternImport glfwWindowShouldClose, glfw3.dll,-
ExternImport glfwWaitEvents,        glfw3.dll,-
ExternImport glfwPollEvents,        glfw3.dll,-
ExternImport glfwWaitEvents,        glfw3.dll,-
ExternImport ExitProcess,           kernel32.dll,4
ExternImport glClear,               opengl32.dll,4
ExternImport glClearColor,          opengl32.dll,16
ExternImport glDrawArrays,          opengl32.dll,12

GlewExternImport BindVertexArray
GlewExternImport GenVertexArrays
GlewExternImport BindVertexArray
GlewExternImport GenVertexArrays
GlewExternImport GenBuffers
GlewExternImport BindBuffer
GlewExternImport BufferData
GlewExternImport EnableVertexAttribArray
GlewExternImport VertexAttribPointer
GlewExternImport LinkProgram
GlewExternImport AttachShader
GlewExternImport CreateProgram
GlewExternImport CompileShader
GlewExternImport ShaderSource
GlewExternImport CreateShader
GlewExternImport UseProgram
GlewExternImport DisableVertexAttribArray

extern _glewInit@0 
%ifidn __OUTPUT_FORMAT__, obj  ;There is always one difficult one
 import _glewInit@0 glew32.dll
 %define __CALL__glewInit [_glewInit@0]
%elif
 %define __CALL__glewInit _glewInit@0
%endif



section .code use32 Class=CODE

;; Entry point of program
%ifidn __OUTPUT_FORMAT__, obj
 ..start:
%elif 
 global _WinMain@16
 _WinMain@16:
 global _start
 _start:
%endif

main:

  callp glfwInit
  sub dword eax,0
  jnz .InitSuccess
  ;;Say something usefull
  push dword -1
  jmp .exit
 .InitSuccess:
 
  push dword 4
  push dword GLFW_SAMPLES ;note renamed GLFW_FSAA_SAMPLES
  callp glfwWindowHint
  push dword 3
  push dword GLFW_CONTEXT_VERSION_MAJOR ;;note renamed GLFW_OPENGL_VERSION_MAJOR
  callp glfwWindowHint
  push dword 3
  push dword GLFW_CONTEXT_VERSION_MINOR ;;note renamed GLFW_OPENGL_VERSION_MINOR
  callp glfwWindowHint
  push dword GLFW_OPENGL_CORE_PROFILE
  push dword GLFW_OPENGL_PROFILE
  callp glfwWindowHint

  push dword 0 ;;Null
  push dword 0 ;;Null
  push dword Title
  push dword 768
  push dword 1024
  callp glfwCreateWindow
  add  dword esp,52 ;clean up the stack from all these std calls
  
  sub dword eax,0
  jnz .CreateWindowSuccess
  ;;Say something useful about window fail
  push dword -1
  jmp .terminate
 .CreateWindowSuccess:
 
  push eax ;;This is the window reference stick on top of stack as its used lots
  callp glfwMakeContextCurrent ;Added for GLFWV3

  callp glewInit
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
  callp glClearColor ;note this is a cdecl call
   
  push dword VertexArrayID
  push dword 1
  callglew GenVertexArrays

  push dword [VertexArrayID]
  callglew BindVertexArray
  
  call LoadShaders
  
  push dword Vertexbuffer
  push dword 1
  callglew GenBuffers

  push dword [Vertexbuffer]
  push dword GL_ARRAY_BUFFER
  callglew BindBuffer

  push dword GL_STATIC_DRAW
  push dword g_vertex_buffer_data
  push dword g_vertex_buffer_data_size
  push dword GL_ARRAY_BUFFER
  callglew BufferData

 .buffloop:
 
  push dword GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
  callp glClear
  
  push dword [ProgramID]
  callglew UseProgram
  
  push dword 0
  callglew EnableVertexAttribArray

  push dword [Vertexbuffer]
  push dword GL_ARRAY_BUFFER
  callglew BindBuffer


  push dword 0
  push dword 0
  push dword GL_FALSE
  push dword GL_FLOAT
  push dword 3
  push dword 0
  callglew VertexAttribPointer


  push dword 3
  push dword 0
  push dword GL_TRIANGLES
  callp glDrawArrays

  push dword 0
  callglew DisableVertexAttribArray
 
  callp glfwPollEvents
  callp glfwSwapBuffers ;as this is a std call and window is allready on stack
  ;we dont need to give it any other params.
  pop eax
  push dword GLFW_KEY_ESCAPE;;note renamed GLFW_KEY_ESC
  push eax
  callp glfwGetKey
  sub dword eax,0
  jnz .terminate
  pop eax
  mov [esp],eax
  callp glfwWindowShouldClose
  sub dword eax,0
  jnz .terminate
  
  callp glfwWaitEvents

  jmp .buffloop
  
  push dword 1
 .terminate:
  callp glfwTerminate
 .exit:
  callp ExitProcess

LoadShaders:
  push dword GL_VERTEX_SHADER
  callglew CreateShader
  mov [VertexShaderID],eax
  
  push dword GL_FRAGMENT_SHADER
  callglew CreateShader
  mov [FragmentShaderID],eax
  
  push dword 0
  push dword SimpleVertexShaderPoint
  push dword 1
  push dword [VertexShaderID]
  callglew ShaderSource

  
  push dword [VertexShaderID]
  callglew CompileShader
  
  push dword 0
  push dword SimpleFragmentShaderPoint
  push dword 1
  push dword [FragmentShaderID]
  callglew ShaderSource
  
  push dword [FragmentShaderID]
  callglew CompileShader
  
  callglew CreateProgram
  mov dword [ProgramID],eax
  
  push dword [VertexShaderID]
  push dword [ProgramID]
  callglew AttachShader

  
  push dword [FragmentShaderID]
  push dword [ProgramID]
  callglew AttachShader

  
  push dword [ProgramID]
  callglew LinkProgram
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