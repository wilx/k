P486
JUMPS
MODEL TPASCAL

CODESEG

Max PROC PASCAL FAR a : DWORD, b : DWORD
	mov eax, a
        cmp eax, b
        jl @bmax        ;kdyz a je mensi tak ...
        shld eax, edx, 16
        shr eax, 16
        ret
@bmax:  mov eax, b
        shld eax, edx, 16
        shr eax, 16
	ret
Max ENDP

Min PROC PASCAL FAR a : DWORD, b : DWORD
	mov eax, a
        cmp eax, b
        jg @bmin        ;kdyz a je vetsi tak ...
        shld eax, edx, 16
        shr eax, 16
        ret
@bmin:  mov eax, b
        shld eax, edx, 16
        shr eax, 16
	ret
Min ENDP


ENDS

GLOBAL PASCAL Max : proc
GLOBAL PASCAL Min : proc

END