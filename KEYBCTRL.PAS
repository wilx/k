{$ifdef DEBUG}
  {$D+,L+,Y+,R+,I+,C+,S+,V+,Q+}
{$endif}

unit KeybCtrl;

interface

{konstanty klavesovych kodu vracemych mojema funkcema}

function kGetKey : word;
function kGetKey101 : word;
function kGetPressed : word;
function kGetPressed101 : word;
function kGetShifts : byte;
function kGetCtrl : boolean;
function kGetAlt : boolean;
function kGetShift : boolean;

implementation

function kGet : byte; assembler;
asm
  xor ax,ax {00h = cteni ascii kodu v AL}
  int 16h
end;

function kGet101 : byte; assembler;
asm
  mov ax,0010h {10h = cteni ascii kodu z rozsirene klavesnice 101/102 v AL}
  int 16h
end;

function kGetKey : word; assembler;
asm
  call [kGet]
  cmp al,0
  je @@kGetKey_rozsireny
  xor ah,ah
  ret
@@kGetKey_rozsireny:
  mov al,ah           {AX = AH + 100h}
  mov ah,1
end;

function kGetKey101 : word; assembler;
asm
  call [kGet101]
  cmp al,0
  je @@kGetKey101_rozsireny
  xor ah,ah
  ret
@@kGetKey101_rozsireny:
  mov al,ah       {AX = AH + 100h}
  mov ah,1
end;

function kGetPressed : word; assembler;
asm
  mov ah,01h
  int 16h
  jz @@kGetPressed_ne
  cmp al,0
  je @@kGetPressed_rozsireny
  xor ah,ah
  ret
@@kGetPressed_rozsireny:
  mov al,ah             {AX = AH + 100h}
  mov ah,1
  ret
@@kGetPressed_ne:
  xor ax,ax             {zadna klavesa, zadny kod}
end;

function kGetPressed101 : word; assembler;
asm
  mov ah,01h
  int 16h
  jz @@kGetPressed101_ne
  cmp al,0
  je @@kGetPressed101_rozsireny
  xor ah,ah
  ret
@@kGetPressed101_rozsireny:
  mov al,ah            {AX = AH + 100h}
  mov ah,1
  ret
@@kGetPressed101_ne:
  xor ax,ax             {zadna klavesa, zadny kod}
end;

function kGetShifts : byte; assembler;
asm
  mov ah,02h
  int 16h               {v AL vraci stav shiftovych klaves}
end;

function kGetCtrl : boolean; assembler;
asm
  call [kGetShifts]
  and al,100b          {Ctrl klavesa}
  jnz @@kGetCtrl_ano
  ret
@@kGetCtrl_ano:
  mov al,1
end;

function kGetAlt : boolean; assembler;
asm
  call [kGetShifts]
  and al,1000b          {Alt klavesa}
  jnz @@kGetAlt_ano
  ret
@@kGetAlt_ano:
  mov al,1
end;

function kGetShift : boolean; assembler;
asm
  call [kGetShifts]
  and al,11b          {LShift nebo RShift klavesa} {}
  jnz @@kGetCtrl_ano
  mov al,0
  ret
@@kGetCtrl_ano:
  mov al,1
end;

end.