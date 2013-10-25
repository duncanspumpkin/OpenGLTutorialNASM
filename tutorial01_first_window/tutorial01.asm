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
extern _glewInit@0
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
  
 .buffloop:
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

section .data USE32
Title   db "Tutorial 01", 0 
ZP4 dd 0.4
