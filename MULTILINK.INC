;; #vim asmsyntax=nasm
%macro GlewExternImport 1
 %ifidn __OUTPUT_FORMAT__, win32
  %ifdef GLEW_STATIC
   %define __CALL__%1 ___glew%1
  %elif
   %define __CALL__%1 __imp____glew%1
  %endif
 %elifidn __OUTPUT_FORMAT__, obj
  %define __CALL__%1 __glew%1
  import __glew%1 glew32.dll
 %endif

 extern __CALL__%1 
%endmacro

%macro callglew 1
%ifdef GLEW_STATIC
 call [__CALL__%1]
%elif
mov dword eax,[__CALL__%1]
call [eax]
%endif
%endmacro

%macro ExternImport 3
%ifidn __OUTPUT_FORMAT__, win32
 %ifidn %3,-
  %define __CALL__%1 _%1
 %elif
  %define __CALL__%1 _%1@%3
 %endif
 extern __CALL__%1
%elifidn __OUTPUT_FORMAT__, obj
 import %1 %2
 extern %1
 %define __CALL__%1 [%1]
%endif
%endmacro

%macro callp 1
call __CALL__%1
%endmacro