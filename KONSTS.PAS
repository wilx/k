{$ifdef DEBUG}
  {$D+,L+,Y+,R+,I+,C+,S+,V+,Q+}
{$endif}

unit Konsts;
{vseobecne konstatny vseho druhu}

interface

const
      {rozsah ID konstant volnych pro unitu Seznam je 0 - 5}
      SeznamClenID = 0;
      SeznamID = 1;
      {rozsah ID konstant volnych pro unitu GraphO je 6 - 20}
      GraphicObjectID = 6;
      {BodID = 7;}
      ElipsaID = 8;
      ElipsaPlnaID = 9;
      TextID = 10;
      ObdelnikID = 11;
      ObdelnikPlnyID = 12;
      {rozsah ID konstant volnych pro unitu Controls je 21 - 35}
      OvladaciPrvekID = 21;
      PrikazoveTlacitkoID = 22;
      MenuPrvekID = 23;
      MenuID = 24;
      {rozsah ID konstant volnych pro unitu Vyrez je 36 - 40}
      VyrezID = 36;
      ViewPortID = 37;
      {rozsah ID konstant volnych pro unitu EProcs je 41 - 45}
      ExitProcOID = 41;
      {rozsah ID konstant volnych pro unitu Zasobnik je 46 - 50}
      ZasobnikID = 46;
      {rozsah ID konstant volnych pro unitu seznam je 51 - 55}
      {ID konstaty nejsou implementovany, nemuze byt zarazen do seznamu, rezerva pro budoucnost}
      {rozsah ID konstant volnych pro unitu AppO je 56 - 60}
      AplikaceID = 56;
      {rozsah ID konstant volnych pro unitu Fronta je 61 - 65}
      FrontaID = 61;
      UserID = 100; {prvni ID konstanta, kterou muze pouzit uzivatel}
      {konstanty jsou pouzity take jako nastroje,
       nasleduji nestandardni nastroje}
      PresunID = UserID+1;
      OdstranID = UserID+2;

      {konstanty druhu zprav pouzivanych v metodach PosliZpravu a VezmiZpravu}
      zpKeyDown =      0;
      zpMouse =        6; {obecne jaka koliv zprava od misi}
      zpMouseMove =    1;
      zpLBDown =       2;
      zpLBUp =         3;
      zpRBDown =       4;
      zpRBUp =         5;
      zpMouseAuto =    7;
      zpLBClick =      8;
      zpRBClick =      9;
      zpReset =       -1;
      zpNothing =     -2;
      zpUser =        20; {prvni cislo zpravy, ktere muze pouzit uzivatle}
      {konstanty druhu zprav uzivatelsky definovane}
      zpStavRadkaSet = zpUser + 1;

      {kody klaves ktere vraci funkce z unity KeybCtrl}
      kAlt_X = $12d;
      kCtrl_F10 = $167;
      kO = word('O');
      kI = word('I');

implementation

end.