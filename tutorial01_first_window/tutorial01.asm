;; Define the externs for the functions that we'll use in this program. 
%include "GLEWN.INC"
%include "GLFW3N.INC"

%macro GlewExternWrapper 1
%ifdef GLEW_STATIC_DLL
extern __%1
%elifdef GLEW_SHARED_DLL
extern __imp____%1
%elifdef GLEW_IMPORT_DLL
import __%1 glew32.dll
extern __%1
%endif
%endmacro

%macro callglew 1
%ifdef GLEW_STATIC_DLL
call %1
%elifdef GLEW_SHARED_DLL
mov dword eax,[__imp____%1]
call [eax]
%elifdef GLEW_IMPORT_DLL
mov dword eax,[__%1]
call [eax]
%endif
%endmacro

%macro ExternImport 2-3
%ifidn __OUTPUT_FORMAT__, win32
 %ifidn %3,-
  %define __CALL__%1 _%1
 %elif
  %define __CALL__%1 _%1@%3
 %endif
 extern __CALL__%1
%elifidn __OUTPUT_FORMAT__, obj
 extern %1
 import %1 %2
 %define __CALL__%1 [%1]
%endif
%endmacro

%macro callp 1
call __CALL__%1
%endmacro

GlewExternWrapper glewBindVertexArray

;; Define the externs for the functions that we'll use in this program. 
ExternImport glfwInit, glfw3.dll,-
ExternImport glfwWindowHint,glfw3.dll,-
ExternImport glfwCreateWindow,glfw3.dll,-
ExternImport glfwMakeContextCurrent,glfw3.dll,-
ExternImport glfwTerminate,glfw3.dll,-
ExternImport glfwSwapBuffers,glfw3.dll,-
ExternImport glfwGetKey,glfw3.dll,-
ExternImport glfwWindowShouldClose,glfw3.dll,-
ExternImport glfwPollEvents,glfw3.dll,-
ExternImport glClearColor,opengl32.dll,16

extern _glewInit@0 
%ifidn __OUTPUT_FORMAT__, obj  ;There is always one difficult one
 import _glewInit@0 glew32.dll
 %define __CALL__glewInit [_glewInit@0]
%elif
 %define __CALL__glewInit _glewInit@0
%endif

ExternImport ExitProcess,kernel32.dll,4

section .code use32 Class=CODE

;; In order to make this code as similar as possible to NeHe's OpenGL tutorial
;; we will first get all of the params of WinMain and call the WinMain function
;; if we were going for as small a program as possible this could be done all in
;; the WinMain function.
global _start
;; Entry point of program
%ifidn __OUTPUT_FORMAT__, obj
..start: 
%elif 
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

  callglew glewBindVertexArray
 .GlewInitSuccess:
 
  push dword 0
  push dword [ZP4] 
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
  jnz .terminate
  pop eax
  mov [esp],eax
  callp glfwWindowShouldClose
  sub dword eax,0
  jnz .terminate
  jmp .buffloop
  
  push dword 1
 .terminate:
  callp glfwTerminate
 .exit:
  callp ExitProcess

section .data USE32
Title   db "Tutorial 01", 0 
ZP4 dd 0.4
