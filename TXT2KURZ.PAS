uses crt;

type PKurzor = ^TKurzor;
     TKurzor = record
                 maskaobr : array [0..15] of word;
                 maskakur : array [0..15] of word;
                 hotx : integer;
                 hoty : integer;
               end;

procedure Help;
begin
  writeln;
  writeln('txt2kurz <soubor_in.txt> <soubor_out.k>');
  writeln('-  kurzor: jednicky (''1'') a nuly (''0'')');
  writeln('-  na kazde radce jeden radek kurzoru');
  writeln('-  posledni dva radky jsou cisla hotx a hoty');
  halt;
end;

var fin : text;
    fout : file of integer;
    radektext : string;
    radekbin, i, j : integer;
    hot,c : integer;

procedure SetBit(var x : integer; count : byte); {bity 0 - 15}
begin
  x := x or (1 shl count);
end;

begin
  if ParamCount <> 2 then
    help;
  assign(fin,ParamStr(1));
  assign(fout,ParamStr(2));
  reset(fin);
  rewrite(fout);
  clrscr;
  for j := 0 to 15 do begin {maska obrazovky}
    readln(fin,radektext);
    radekbin := 0;
    writeln;
    for i := 0 to 15 do begin
      write(radektext[i+1]);
      if radektext[i+1] = '1' then
        SetBit(radekbin,15-i);
    end;
    write(fout,radekbin);
  end;
  writeln;
  for j := 0 to 15 do begin {maska obrazovky}
    readln(fin,radektext);
    radekbin := 0;
    writeln;
    for i := 0 to 15 do begin
      write(radektext[i+1]);
      if radektext[i+1] = '1' then
        SetBit(radekbin,15-i);
    end;
    write(fout,radekbin);
  end;

  {hotx a hoty}
  {hotx}
  readln(fin,radektext);
  val(radektext,hot,c);
  write(fout,hot);
  {hoty}
  radektext := '';
  hot := 0;
  readln(fin,radektext);
  val(radektext,hot,c);
  write(fout,hot);

  close(fin);
  close(fout);
end.