OpenGLTutorialNASM
==================

OpenGL-Tutorial.org tutorials remade in NASM.

I have used the latest versions of GLEW v1.10.0 and GLFW v3.2 this has required making a few changes to the original tutorials. Both librarys were used with the precompiled binarys.

To compile I have used NASM 2.07 with the following options: 
```
nasm.exe -fwin32
```
To link I have used Microsoft Incremental Linker with the following options: 
```
link.exe /subsystem:windows /verbose /nodefaultlib /entry:start kernel32.lib opengl32.lib glfw3dll.lib glew32.lib
```
Note that I use glfw3dll.lib and not glfw3.lib as the second one is used for static linking.
