;; Define the externs for the functions that we'll use in this program. 
extern glfwInit 
extern glfwWindowHint
extern glfwCreateWindow
extern glfwTerminate
extern glfwSwapBuffers
extern glClearColor
extern _glewInit@0 

;; Import the Win32 API functions. 
import glfwInit glfw3.dll 
import glfwWindowHint glfw3.dll
import glfwCreateWindow glfw3.dll
import glfwSwapBuffers glfw3.dll
import glfwTerminate glfw3.dll
import glClearColor opengl32.dll
import _glewInit@0 glew32.dll

section .code use32 Class=CODE

;; In order to make this code as similar as possible to NeHe's OpenGL tutorial
;; we will first get all of the params of WinMain and call the WinMain function
;; if we were going for as small a program as possible this could be done all in
;; the WinMain function.

;; Entry point of program
..start: 

  call [glfwInit]
  push dword 4
  push dword 0x0002100D ;;note renamed GLFW_FSAA_SAMPLES
  call [glfwWindowHint]
  push dword 3
  push dword 0x00022002;;note renamed GLFW_OPENGL_VERSION_MAJOR
  call [glfwWindowHint]
  push dword 3
  push dword 0x00022003;;note renamed GLFW_OPENGL_VERSION_MINOR
  call [glfwWindowHint]
  push dword 0x00032001 ;;GLFW_OPENGL_CORE_PROFILE
  push dword 0x00022008 ;;GLFW_OPENGL_PROFILE
  call [glfwWindowHint]

  push dword 0 ;;Null
  push dword 0 ;;Null
  push dword Title
  push dword 768
  push dword 1024
  call [glfwCreateWindow]
  push dword eax
  call [_glewInit@0]
  push dword 0
  push dword [ZP4] ;;;NOOO
  push dword 0
  push dword 0
  call [glClearColor]
  nop
 buffloop:
  call [glfwSwapBuffers]
  jmp buffloop
  nop
  call [glfwTerminate]


section .data USE32
Title   db "NeHE's OpenGL Framework", 0 
ZP4 dd 0.4