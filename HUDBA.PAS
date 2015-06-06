{$ifdef DEBUG}
  {$D+,L+,Y+,R+,I+,C+,S+,V+,Q+}
{$endif}

{$O-,G+,X+}
unit Hudba;

interface
uses EProcs, Seznam, midas, mconfig, vgatext, mfile, mplayer, errors, s3m;

function hudbaStart(soub : PChar) : boolean;
function hudbaStop : boolean;

implementation

var configured : integer;
    module : PmpModule;
    i, error, isConfig : integer;
    str : array [0..256] of char;
    HudbaExitProcO : TExitProcO;
(*
function toASCIIZ(dest : PChar; str : string) : PChar;
var
    spos, slen : integer;
    i : integer;
begin
    spos := 0;                          { string position = 0 }
    slen := ord(str[0]);                { string length }
    { copy string to ASCIIZ conversion buffer: }
    while spos < slen do
    begin
        dest[spos] := str[spos+1];
        spos := spos + 1;
    end;
    dest[spos] := chr(0);               { put terminating 0 to end of string }
    toASCIIZ := dest;
end;
*)

function hudbaStart(soub : PChar) : boolean;
BEGIN
    error := fileExists('MIDAS.CFG', @isConfig);
    if error <> OK then
        midasError(error);
    if isConfig <> 1 then
    begin
      midasSetDefaults;                   { set MIDAS defaults }
      { Run MIDAS Sound System configuration: }
      configured := midasConfig;
      { Reset display mode: }
      vgaSetMode($03);
      if configured = 1 then
      begin
        { Configuration succesful - save configuration file: }
        midasSaveConfig('MIDAS.CFG');
        WriteLn('Konfigurace byla zapsana do MIDAS.CFG');
      end
      else
      begin
        { Configuration unsuccessful: }
        WriteLn('Konfigurace NEBYLA zapsana');
      end;
    end;
    midasSetDefaults;                   { set MIDAS defaults }
    midasLoadConfig('MIDAS.CFG');       { load configuration }
    midasInit;                          { initialize MIDAS Sound System }
    module := midasLoadModule(soub, @mpS3M, NIL);
    midasPlayModule(module, 0);         { start playing }
end;

function hudbaStop : boolean;
begin
    midasStopModule(module);            { stop playing }
    midasFreeModule(module);            { deallocate module }
    midasClose;                         { uninitialize MIDAS }
end;

procedure HudbaExitProc; far;
begin
  if midasMPInit = 1 then begin
    if midasMPPlay = 1 then begin
      midasStopModule(module);
      midasFreeModule(module);
    end;
    midasClose;
  end;
end;

begin
  HudbaExitProcO.Init(HudbaExitProc,Static);
  epchain.VlozObj(@HudbaExitProcO);
end.