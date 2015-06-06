uses KeybCtrl,crt;

begin
  writeln('Stiskni 2-krat klavesu');
  writeln('1. ',kGetKey,' 2. ',kGetKey101);
  delay(500);
  writeln(kGetPressed);
  writeln(kGetCtrl);
end.