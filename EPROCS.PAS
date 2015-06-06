{$ifdef DEBUG}
  {$D+,L+,Y+,R+,I+,C+,S+,V+,Q+}
{$endif}

unit EProcs;

interface
uses Seznam, Graph;

type
     TExitProc = procedure;
     PExitProcO = ^TExitProcO;
     TExitProcO = object(TSeznamClen)
                         proc : TExitProc;
                         procedure CallProc;
                         constructor Init(iproc : TExitProc; ityp : TClenTyp);
                       end;
var epchain : TSeznam;

{Hex prevadeni asi nejfunguje jak by melo tzn. prevadi spatne.}
const HexDigits : array [0..15] of char = ('0','1','2','3','4','5','6',
                                           '7','8','9','A','B','C','D',
                                           'E','F');
function HexDump(x : word) : string;

implementation

var oldexitproc : pointer;

function HexDump(x : word) : string;
var pom : string[4];
begin
  pom[0] := #4;
  pom[1] := HexDigits[Hi(x) shr 4];
  pom[2] := HexDigits[Hi(x) and $f];
  pom[3] := HexDigits[Lo(x) shr 4];
  pom[4] := HexDigits[Lo(x) and $f];
  HexDump := pom;
end;

procedure ExitProcHandler; far; {tato procedura se vyvola pri ukonceni programu}
var i, poc : word;
begin
  ExitProc := oldexitproc;
  poc := epchain.PocetObj;
  if poc > 0 then
    for i := 1 to poc do
      PExitProcO(epchain.Pozice(i))^.CallProc;
  epchain.Done;
{$ifdef CZ_EXIT_TEXT} {vypis duvodu ukonceni}
  if (ExitCode = 0) and (ErrorAddr = nil) then
    writeln('Normalni ukonceni.')
  else
    if (ErrorAddr = nil) then
      writeln('Ukonceni procedurou Halt(',ExitCode,')')
    else
      writeln('Ukonceni chybou za behu s chybovym kodem ',ExitCode,
              ' na adrese ',HexDump(Seg(ErrorAddr)),':',HexDump(Ofs(ErrorAddr)));
  ExitCode := 0; {aby se nevypisovala pripadna chybova zprava dvakrat}
  ErrorAddr := nil;
{$endif}
end;

procedure TExitProcO.CallProc;
begin
  proc;
end;

constructor TExitProcO.Init(iproc : TExitProc; ityp : TClenTyp);
begin
  inherited Init(ityp, nil);
  proc := iproc;
end;

begin
  epchain.Init(256,Static,nil);
  oldexitproc := ExitProc;
  ExitProc := @ExitProcHandler;
end.