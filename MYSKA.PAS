{$ifdef DEBUG}
  {$D+,L+,Y+,R-,I+,C+,S+,V+,Q+}
{$endif}

{$X+,G+,O+,A-}
unit Myska;

interface
uses WinDos;

type PKurzor = ^TKurzor;
     TKurzor = record
                 maskaobr : array [0..15] of word;
                 maskakur : array [0..15] of word;
                 hotx : integer;
                 hoty : integer;
               end;

var mButtons : byte;

procedure mGetXY(var ix, iy : word);
procedure mGetXYZ(var ix, iy, tlac : word);
function mGetX : word;
function mGetY : word;
procedure mSetXY(ix, iy : word);
function mGetTlac : word;
function mGetT1 : boolean;
function mGetT2 : boolean;
function mGetT3 : boolean; {prostredni}
procedure mGetRXY(var ix, iy : integer);
procedure mGetRXYZ(var ix, iy : integer; var tlac : word);
{nasledujici dve procedury nefunguji! nepouzivat!}
procedure mSetUsrEventHandle(maska : word; phandle : pointer);
procedure mClearUsrEventHandle;
procedure mSetMinMaxXY(ix, ix2, iy, iy2 : word);
procedure mSetMinMaxX(ix, ix2 : word);
procedure mSetMinMaxY(iy, iy2 : word);
procedure mSetGrCursor(ikurzor : PKurzor); {dodelat uplne do assembleru}
procedure mLoadCursor(isoubor : string; var ikurzor : TKurzor);
procedure mSetGrCursorFile(isoubor : string);
procedure mOn;
procedure mOff;
function mInit : boolean;
procedure mDone;

implementation

var ox, oy : word;

procedure mOn; assembler;
asm
  mov ax,1
  int 33h
end;

procedure mOff; assembler;
asm
  mov ax,2
  int 33h
end;

procedure mGetXY(var ix, iy : word); assembler;
asm
  push es
  mov ax,3
  int 33h
  les di, ix
  mov es:[di], cx
  les di, iy
  mov es:[di], dx
  pop es
end;


procedure mGetXYZ(var ix, iy, tlac : word); assembler;
asm
  push es
  mov ax,3
  int 33h
  les di,ix
  mov es:[di],cx
  les di,iy
  mov es:[di],dx
  les di,tlac
  mov es:[di],bx
  pop es
end;

function mGetX : word; assembler;
asm
  mov ax,3
  int 33h
  mov ax, cx
end;

function mGetY : word; assembler;
asm
  mov ax,3
  int 33h
  mov ax, dx
end;

procedure mSetXY(ix, iy : word); assembler;
asm
  mov ax,4
  mov cx, ix
  mov dx, iy
  int 33h
end;

function mGetTlac : word; assembler;
asm
  mov ax,3
  int 33h
  mov ax, bx
end;

function mGetT1 : boolean; assembler;
asm
  mov ax,3
  int 33h
  and bx,1
  jz @neni
  mov ax,1
  ret
@neni:
  xor ax,ax {false (ax = 0)}
end;


function mGetT2 : boolean; assembler;
asm
  mov ax,3
  int 33h
  and bx,2
  jz @neni
  mov ax,1
  ret
@neni:
  xor ax,ax {false (ax = 0)}
end;

function mGetT3 : boolean; assembler; {prostredni tlacitko}
asm
  mov ax,3
  int 33h
  and bx,4
  jz @neni
  mov ax,1
  ret
@neni:
  xor ax,ax {false (ax = 0)}
end;

procedure mGetRXY(var ix, iy : integer);
var x, y : word;
begin
  mGetXY(x,y);
  ix := x - ox;
  iy := y - oy;
  ox := x;
  oy := y;
end;

procedure mGetRXYZ(var ix, iy : integer; var tlac : word);
var x, y, tl : word;
begin
  mGetXYZ(x,y,tl);
  ix := x - ox;
  iy := y - oy;
  tlac := tl;
  ox := x;
  oy := y;
end;

procedure mSetUsrEventHandle(maska : word; phandle : pointer); assembler;
asm
  mov ax,000cH
  mov cx,maska
  les dx,phandle
  int 33h
end;

procedure mClearUsrEventHandle; assembler;
asm
  xor cx,cx
  mov es,cx {do es 0}
  xor dx,dx
  mov ax,000cH
  int 33h
end;

procedure mSetMinMaxXY(ix, ix2, iy, iy2 : word); assembler;
asm
  mov ax, 0007h
  mov cx, ix
  mov dx, ix2
  int 33h
  mov ax, 0008h
  mov cx, iy
  mov dx, iy2
  int 33h
end;

procedure mSetMinMaxX(ix, ix2 : word); assembler;
asm
  mov ax, 0007h
  mov cx, ix
  mov dx, ix2
  int 33h
end;

procedure mSetMinMaxY(iy, iy2 : word); assembler;
asm
  mov ax, 0008h
  mov cx, iy
  mov dx, iy2
  int 33h
end;

procedure mSetGrCursor(ikurzor : PKurzor);
var r : TRegisters;
    hx, hy : integer;
begin
  hx := ikurzor^.hotx;
  hy := ikurzor^.hoty;
  asm
    push es
    mov bx, hx
    mov cx, hy
    les dx, ikurzor
    mov ax, 0009h
    int 33h
    pop es
  end;
end;

function mInit : boolean; assembler;
asm
  xor ax,ax {ax = 0}
  int 33h
  cmp ax,0ffffh
  jne @neni
  mov mButtons, bl
  mov ax,1 {vracime true}
  jmp @end
@neni:
  mov ax,0 {jinak false}
@end:
end;

procedure mDone; assembler;
asm
  call [mInit];
{mInit vlastne jen nastavi implicitni hodnoty a vypne kurzor,
 proto ho muzeme zavolat i tady}
end;

{pouziva soubory zkonvertovane programem txt2kurz}
procedure mLoadCursor(isoubor : string; var ikurzor : TKurzor);
var f : file of TKurzor;
begin
  assign(f,isoubor);
  reset(f);
  read(f,ikurzor);
  close(f);
end;

procedure mSetGrCursorFile(isoubor : string);
var f : file of TKurzor;
    kurz : TKurzor;
begin
  mLoadCursor(isoubor,kurz);
  mSetGrCursor(@kurz);
end;

end.