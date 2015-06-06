uses crt;

var f : text;
    radky : array[0..15] of string;
    i, j : integer;
    c : integer;

begin
  assign(f,ParamStr(1));
  reset(f);
  clrscr;
  for j := 0 to 15 do begin {maska obrazovky}
    readln(f,radky[j]);
    writeln(radky[j]);
  end;
  close(f);
  writeln;
  for j := 0 to 15 do begin {inverze}
    for i := 1 to 16 do begin
      if radky[j][i] = '1' then
        radky[j][i] := '0'
      else
        if radky[j][i] = '0' then
          radky[j][i] := '1';
    end;
  end;
  append(f);
  for j := 0 to 15 do begin {maska mysi}
    writeln(f,radky[j]);
  end;
  close(f);
end.