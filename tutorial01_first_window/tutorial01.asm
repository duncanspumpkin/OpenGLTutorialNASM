;; #vim asmsyntax=nasm
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
ExternImport glClearColor,          opengl32.dll,16
ExternImport ExitProcess,           kernel32.dll,4

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
  push dword __float32__(0.4) 
  push dword 0
  push dword 0
  callp glClearColor ;note this is a cdecl call
  
 .buffloop:
  callp glfwPollEvents
  callp glfwSwapBuffers ;as this is a std call and window is allready on stack
  ;we dont need to give it any other params.
  pop eax
  push dword GLFW_KEY_ESCAPE;;note renamed GLFW_KEY_ESC
  push eax
  callp glfwGetKey
  sub dword eax,0
  jnz .buffloopEnd

  pop eax
  mov [esp],eax
  callp glfwWindowShouldClose
  sub dword eax,0
  jnz .buffloopEnd
  
  callp glfwWaitEvents

  jmp .buffloop

 .buffloopEnd:
  push dword 1

 .terminate:
  callp glfwTerminate
 .exit:
  callp ExitProcess

section .data USE32
Title   db "Tutorial 01", 0 