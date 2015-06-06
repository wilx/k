{$M 64000,16384,655360} {nastaveni velikosti stacku, minheap, maxheap pri kompilaci}
{$ifdef DPMI}
  {$M 65520}
{$endif}
{$ifdef DEBUG}
  {$D+,L+,Y+,R+,I+,C+,S+,V+,Q-}
{$endif}
program K;
uses {$ifdef HUDBA}Hudba,{$endif}
     {$ifndef DPMI}{$ifdef OVR}Overlay,{$endif}{$endif}
     WinDos, Crt, Graph, EProcs, GraphO, AppO, Zpravy, Controls,
     Seznam, Myska, KeybCtrl, Konsts, Comm;
{$ifdef OVR}
  {$ifdef DPMI} overlaye jsou jen v realu {$endif}
  {$O GraphO}
  {$O Vyrez}
  {$O Controls}
  {$O Myska}
  {$O Zpravy}
  {$O KeybCtrl}
  {$O Konsts}
  {$O AppO}
{$endif}

{deklarace procedur}
function InitGr : boolean; forward;
procedure DoneGr; forward;


{nove typy}
type
     PSouradnice = ^TSouradnice;
     TSouradnice = record
                     x, y : longint;
                   end;
{redefinovane objekty a metody redefinovanych objektu}
type
{tlacitko tlElipsa}
PtlElipsa = ^TtlElipsa;
TtlElipsa = object(TPrikazoveTlacitko)
             procedure OnLButtonClick(sender : PKomunikace); virtual;
             constructor Init(ix, iy, ib, ibvypln : word; ityp : TClenTyp;
                              itext : string; imajitel : PKomunikace);
           end;
{tlacitko tlObdelnik}
PtlObdelnik = ^TtlObdelnik;
TtlObdelnik = object(TPrikazoveTlacitko)
	     procedure OnLButtonClick(sender : PKomunikace); virtual;
	     constructor Init(ix, iy, ib, ibvypln : word; ityp : TClenTyp;
			      itext : string; imajitel : PKomunikace);
	   end;
{tlacitko tlPosun}
PtlPresun = ^TtlPresun;
TtlPresun = object(TPrikazoveTlacitko)
	     procedure OnLButtonClick(sender : PKomunikace); virtual;
	     constructor Init(ix, iy, ib, ibvypln : word; ityp : TClenTyp;
			      itext : string; imajitel : PKomunikace);
	   end;
{tlacitko tlOdstran}
PtlOdstran = ^TtlOdstran;
TtlOdstran = object(TPrikazoveTlacitko)
	     procedure OnLButtonClick(sender : PKomunikace); virtual;
	     constructor Init(ix, iy, ib, ibvypln : word; ityp : TClenTyp;
			      itext : string; imajitel : PKomunikace);
	   end;

{tlacitko tlKonec}
PtlKonec = ^TtlKonec;
TtlKonec = object(TPrikazoveTlacitko)
	     procedure OnLButtonClick(sender : PKomunikace); virtual;
	     constructor Init(ix, iy, ib, ibvypln : word; ityp : TClenTyp;
			      itext : string; imajitel : PKomunikace);
	   end;
{text suradnice mysi}
PmSouradnice = ^TmSouradnice;
TmSouradnice = object(TText)
		 constructor Init(ix, iy, ib : word; ityp : TClenTyp;
		   itext : string; itexttyp: TextSettingsType; imajitel : PKomunikace);
		 procedure VezmiZpravu(sender : PKomunikace; co : word; info : pointer); virtual;
	       end;
{realtivni zmena souradnice mysi}
PmRelZmena = ^TmRelZmena;
TmRelZmena = object(TText)
		 constructor Init(ix, iy, ib : word; ityp : TClenTyp;
		   itext : string; itexttyp: TextSettingsType; imajitel : PKomunikace);
		 procedure VezmiZpravu(sender : PKomunikace; co : word; info : pointer); virtual;
	       end;
{stavova radka reagujici na zpravu zpStavRadkaSet}
PStavRadka = ^TStavRadka;
TStavRadka = object(TText)
		 constructor Init(ix, iy, ib : word; ityp : TClenTyp;
		   itext : string; itexttyp: TextSettingsType; imajitel : PKomunikace);
		 procedure VezmiZpravu(sender : PKomunikace; co : word; info : pointer); virtual;
	       end;
{snizi cislo barvy}
PtlBarvaDec = ^TtlBarvaDec;
TtlBarvaDec = object(TPrikazoveTlacitko)
		procedure OnLButtonClick(sender : PKomunikace); virtual;
		constructor Init(ix, iy, ib, ibvypln : word; ityp : TClenTyp;
			      itext : string; imajitel : PKomunikace);
	      end;
{zvysi cislo barvy}
PtlBarvaInc = ^TtlBarvaInc;
TtlBarvaInc = object(TPrikazoveTlacitko)
		procedure OnLButtonClick(sender : PKomunikace); virtual;
		constructor Init(ix, iy, ib, ibvypln : word; ityp : TClenTyp;
			      itext : string; imajitel : PKomunikace);
	      end;

{redefinovany objekt TAplikace}
type
     TKreslik = object(TAplikace)
		  objs : TSeznam;
		  b1 : TSouradnice;
		  ObjRBDown, ObjLBDown : PKomunikace;
		  procedure Obnov;
		  procedure VezmiZpravu(sender : PKomunikace; co : word; info : pointer); virtual;
		  procedure Run; virtual;
                  procedure Idle; virtual;
                  constructor Init(ityp : TClenTyp);
                  destructor Done; virtual;
                end;


{promene}
var
    j, pocetstisku, aktbarva, aktvypln : word;
    nastroj, prednastroj : integer;
    t : TSeznam;
    {okno : TVyrez;}
    udal : TUdalost;
    ot1, ot2, konec : boolean;
    app : TKreslik;
    kurz : TKurzor;
    pocidle : longint;
    memstart, memend : longint;
    psr,psr2 : PStavRadka;
    pbarva : PText;
    krok : byte; {1 - roh|stred; 2 - roh2|polomer}
    vybranyobj : PGraphicObject;

const kcesta = 'kurzory\';       {realativni cesta k souborum s kurzorama}
      kSipka = 'sipkax.k';
      kKruz1 = 'kruz1.k';
      kKruz2 = 'kruz2.k';
      kObdel1 = 'obdel1.k';

      MaxGrObjektu = 1000;
      kroktext = 'krok: ';
      nastrojtext = 'nastroj: ';

      barvats : TextSettingsType = (Font:SansSerifFont;Direction:HorizDir;
                                      CharSize:3{velikost pisma};
                                      Horiz:CenterText;Vert:CenterText);

{metody redefinovanych objektu}
{TtlKonec}
procedure TtlKonec.OnLButtonClick(sender : PKomunikace);
begin
  konec := true;
end;

constructor TtlKonec.Init(ix, iy, ib, ibvypln : word; ityp : TClenTyp;
             itext : string; imajitel : PKomunikace);
begin
  inherited Init(ix, iy, ib, ibvypln, ityp, itext, imajitel);
end;

{TtlElipsa}
procedure TtlElipsa.OnLButtonClick(sender : PKomunikace);
var s : string;
begin
  mSetGrCursorFile(kcesta+kSipka);
  nastroj := ElipsaID;
  krok := 0;
  s := nastrojtext + 'Elipsa';
  app.PosliZpravu(psr,zpStavRadkaSet,@s);
  s := kroktext + '1. roh elipsy';
  app.PosliZpravu(psr2,zpStavRadkaSet,@s);
end;
constructor TtlElipsa.Init(ix, iy, ib, ibvypln : word; ityp : TClenTyp;
                              itext : string; imajitel : PKomunikace);
begin
  inherited Init(ix, iy, ib, ibvypln, ityp, itext, imajitel);
end;

{TtlObdelnik}
constructor TtlObdelnik.Init(ix, iy, ib, ibvypln : word;
            ityp : TClenTyp; itext : string; imajitel : PKomunikace);
begin
  inherited Init(ix, iy, ib, ibvypln, ityp, itext, imajitel);
end;

procedure TtlObdelnik.OnLButtonClick(sender : PKomunikace);
var s : string;
begin
  mSetGrCursorFile(kcesta+kObdel1);
  nastroj := ObdelnikID;
  krok := 0;
  s := nastrojtext + 'Obdelnik';
  app.PosliZpravu(psr,zpStavRadkaSet,@s);
  s := kroktext + '1. roh obdelniku';
  app.PosliZpravu(psr2,zpStavRadkaSet,@s);
end;

{TtlOdstran}
constructor TtlOdstran.Init(ix, iy, ib, ibvypln : word;
            ityp : TClenTyp; itext : string; imajitel : PKomunikace);
begin
  inherited Init(ix, iy, ib, ibvypln, ityp, itext, imajitel);
end;

procedure TtlOdstran.OnLButtonClick(sender : PKomunikace);
var s : string;
begin
  mSetGrCursorFile(kcesta+kSipka);
  prednastroj := nastroj;
  nastroj := OdstranID;
  krok := 0;
  vybranyobj := nil;
  s := nastrojtext + 'Odstran';
  app.PosliZpravu(psr,zpStavRadkaSet,@s);
  s := kroktext + 'vyber objekt, ktery chces odstranit';
  app.PosliZpravu(psr2,zpStavRadkaSet,@s);
end;


{TtlPosun}
constructor TtlPresun.Init(ix, iy, ib, ibvypln : word;
            ityp : TClenTyp; itext : string; imajitel : PKomunikace);
begin
  inherited Init(ix, iy, ib, ibvypln, ityp, itext, imajitel);
end;

procedure TtlPresun.OnLButtonClick(sender : PKomunikace);
var s : string;
begin
  mSetGrCursorFile(kcesta+kSipka);
  nastroj := PresunID;
  krok := 0;
  vybranyobj := nil;
  s := nastrojtext + 'Posunuti';
  app.PosliZpravu(psr,zpStavRadkaSet,@s);
  s := kroktext  + 'klikni do objektu';
  app.PosliZpravu(psr2,zpStavRadkaSet,@s);
end;


{TmSouradnice}
constructor TmSouradnice.Init(ix, iy, ib : word; ityp : TClenTyp;
   itext : string; itexttyp: TextSettingsType; imajitel : PKomunikace);
begin
  inherited Init(ix, iy, ib, ityp, itext, itexttyp, imajitel);
end;

procedure TmSouradnice.VezmiZpravu(sender : PKomunikace; co : word; info : pointer);
var u : PUdalost absolute info;
    s, pom : string[30];
begin
  if (co = zpMouse) and (u^.jaka = zpMouseMove) then begin
    str(u^.x:3,pom);
    s := 'X:'+pom;
    str(u^.y:3,pom);
    s := s + ' Y:'+pom;
    SetText(s);
  end;
end;

{TmRelZmena}
constructor TmRelZmena.Init(ix, iy, ib : word; ityp : TClenTyp;
   itext : string; itexttyp: TextSettingsType; imajitel : PKomunikace);
begin
  inherited Init(ix,iy,ib,ityp,itext,itexttyp,imajitel);
end;

procedure TmRelZmena.VezmiZpravu(sender : PKomunikace; co : word; info : pointer);
var u : PUdalost absolute info;
    s, pom : string[30];
begin
  if (co = zpMouse) and (u^.jaka = zpMouseMove) then begin
    str(u^.rx:4,pom);
    s := 'RX:'+pom;
    str(u^.ry:4,pom);
    s := s + ' RY:'+pom;
    SetText(s);
  end;
end;

{TStavRadka}
constructor TStavRadka.Init(ix, iy, ib : word; ityp : TClenTyp;itext : string;
            itexttyp: TextSettingsType; imajitel : PKomunikace);
begin
  inherited Init(ix,iy,ib,ityp,itext,itexttyp,imajitel);
end;


procedure TStavRadka.VezmiZpravu(sender : PKomunikace; co : word; info : pointer);
begin
  if co = zpStavRadkaSet then begin
    mOff;
    SetText(String(info^));
    mOn;
  end;
end;

{TtlBarvaDec}
procedure TtlBarvaDec.OnLButtonClick(sender : PKomunikace);
var s : string;
begin
  if aktbarva = 1 then
    aktbarva := 15
  else
    dec(aktbarva);
  str(aktbarva,s);
  mOff;
  pbarva^.Zhasni;
  pbarva^.SetCol(aktbarva);
  pbarva^.SetText(s);
  pbarva^.Zasvit;
  mOn;
end;

constructor TtlBarvaDec.Init(ix, iy, ib, ibvypln : word; ityp : TClenTyp;
	     itext : string; imajitel : PKomunikace);
begin
  inherited Init(ix, iy, ib, ibvypln, ityp, itext, imajitel);
end;

{TtlBarvaInc}
procedure TtlBarvaInc.OnLButtonClick(sender : PKomunikace);
var s : string;
begin
  if aktbarva = 15 then
    aktbarva := 1
  else
    inc(aktbarva);
  str(aktbarva,s);
  mOff;
  pbarva^.Zhasni;
  pbarva^.SetCol(aktbarva);
  pbarva^.SetText(s);
  pbarva^.Zasvit;
  mOn;
end;

constructor TtlBarvaInc.Init(ix, iy, ib, ibvypln : word; ityp : TClenTyp;
	     itext : string; imajitel : PKomunikace);
begin
  inherited Init(ix, iy, ib, ibvypln, ityp, itext, imajitel);
end;

{TKreslik}
procedure TKreslik.VezmiZpravu(sender : PKomunikace; co : word; info : pointer);
var iu : PUdalost absolute info;
    i : word;
    pom : PKomunikace;
    nasel : boolean;
    pom2, pom3 : word;
    pom5 : PGraphicObject;
    s : string;
begin
  case co of
    zpMouse:
      case iu^.jaka of
	zpLBClick : begin
	  case nastroj of
	    ObdelnikID : begin
	      case krok of
		0 : begin
		  b1.x := iu^.x;
		  b1.y := iu^.y;
		  krok := 1;
		  s := kroktext + '2. roh obdelniku';
		  PosliZpravu(psr2,zpStavRadkaSet,@s);
		end;
		1 : begin
		  objs.VlozObj(new(PObdelnik,Init(Min(b1.x,iu^.x),Min(b1.y,iu^.y),
			       Max(b1.x,iu^.x),Max(b1.y,iu^.y),aktbarva,Dynamic,@app)));
		  Obnov;
		  krok := 0;
		  s := kroktext + '1. roh obdelniku';
		  PosliZpravu(psr2,zpStavRadkaSet,@s);
		end;
	      end;
	    end;
	    ElipsaID : begin
	      case krok of
		0 : begin
		  b1.x := iu^.x;
		  b1.y := iu^.y;
		  krok := 1;
		  s := kroktext + '2. roh elipsy';
		  PosliZpravu(psr2,zpStavRadkaSet,@s);
		end;
		1 : begin
                  pom2 := (b1.x+iu^.x) div 2;
		  pom3 := (b1.y+iu^.y) div 2;
		  objs.VlozObj(new(PElipsa,Init(pom2, pom3,
			       pom2-Min(b1.x,iu^.x),pom3-Min(b1.y,iu^.y),
			       aktbarva,Dynamic,@app)));
		  Obnov;
		  krok := 0;
		  s := kroktext + '1. roh elipsy';
		  PosliZpravu(psr2,zpStavRadkaSet,@s);
                end;
              end;
            end;
            PresunID : begin
	      case krok of
		0 : begin
                  if objs.PocetObj > 0 then begin
                    for i := objs.PocetObj downto 1 do begin
                      pom5 := PGraphicObject(objs.Pozice(i));
                      if pom5^.Dotaz(iu^.x,iu^.y) = true then begin
                        vybranyobj := pom5;
                        krok := 1;
                        b1.x := iu^.x;
                        b1.y := iu^.y;
                        break;
                      end;
                    end;
                    if pom5 <> nil then begin
   		      s := kroktext + 'klikni na misto, kam ho chces presunout';
      		      PosliZpravu(psr2,zpStavRadkaSet,@s);
                    end;
                  end;
		end;
		1 : begin
                  vybranyobj^.Presun(vybranyobj^.GetX+iu^.x-b1.x,vybranyobj^.GetY+iu^.y-b1.y);
		  Obnov;
		  krok := 0;
		  s := kroktext + 'klikni do objektu';
		  PosliZpravu(psr2,zpStavRadkaSet,@s);
                  vybranyobj := nil;
		end;
	      end;
	    end;
            OdstranID : begin
	      case krok of
		0 : begin
                  if objs.PocetObj > 0 then begin
                    for i := objs.PocetObj downto 1 do begin
                      pom5 := PGraphicObject(objs.Pozice(i));
                      if pom5^.Dotaz(iu^.x,iu^.y) = true then begin
                        objs.SmazObj(pom5);
                        break;
                      end;
                    end;
                    nastroj := -1;
                    {-1 neni zadny nastroj;
                     aby sis nahodou nechtene nesmazal dalsi objekt}
                    Obnov;
   		    s := kroktext + 'vyber nastroj';
    		    PosliZpravu(psr2,zpStavRadkaSet,@s);
                  end;
		end;
	      end;
	    end;
          end;
        end;
        zpLBUp: begin
          if pocet > 0 then begin
	    nasel := false;
            for i := 1 to pocet do begin
              pom := Pozice(i);
              if PGraphicObject(pom)^.Dotaz(iu^.x, iu^.y) = true then begin
                nasel := true;
                pom^.OnLButtonUp(@app);
                if (ObjRBDown = pom) and (ObjRBDown <> nil) then
                   pom^.OnLButtonClick(@app);
                break;
              end;
            end;
            if (ObjRBDown = nil) and (nasel = false) then begin
              iu^.jaka := zpLBClick;
              PosliZpravu(@app,zpMouse,iu);
            end;
            ObjRBDown := nil;
          end;
        end;
        zpLBDown : begin
          if pocet > 0 then begin
            ObjRBDown := nil;
            for i := 1 to pocet do begin
              pom := Pozice(i);
              if PGraphicObject(pom)^.Dotaz(iu^.x, iu^.y) = true then begin
                ObjRBDown := pom;
                pom^.OnLButtonDown(@app);
                break;
              end;
            end;
          end;
        end;
        zpMouseMove : begin
          if pocet > 0 then begin
            for i := 1 to pocet do begin
              pom := Pozice(i);
              PosliZpravu(pom,zpMouse,iu);
            end;
          end;
        end;
      end;
    zpKeyDown:
      case iu^.kod of
        kAlt_X, kCtrl_F10 : konec := true;
        kO : Obnov;
        kI : begin
          mOff;
          DoneGr;
            writeln('INFO');
            writeln('~~~~');
            writeln('objs.PocetObj  = ',objs.PocetObj);
            {$ifdef LUT}
            writeln('objs.cache.poc = ',objs.cache.poc);
            write('objs.cache.buf^[] (key,age,ptr) = (');
            if objs.cache.poc > 0 then begin
              for i := 1 to objs.cache.poc do begin
                write(' (',objs.cache.buf^[i].key,',',
                      objs.cache.buf^[i].age,',',
                      Seg(objs.cache.buf^[i].p),':',
                      Ofs(objs.cache.buf^[i].p),')');
              end;
            end;
            writeln(')');
            {$endif}
            writeln('app.PocetObj   = ',app.PocetObj);
            writeln('MemAvail       = ',MemAvail);
            readkey;
          InitGr;
          mOn;
          Obnov;
        end;
      end;
  end;
end;

procedure TKreslik.Obnov;
var i : word;
    pom : PGraphicObject;
begin
  mOff;
  ClearDevice;
  if objs.PocetObj > 0 then
    for i := 1 to objs.PocetObj do begin
      pom := PGraphicObject(objs.Pozice(i));
      pom^.Zasvit;
    end;
  if pocet > 0 then
    for i := 1 to pocet do begin
      pom := PGraphicObject(Pozice(i));
      pom^.Zasvit;
    end;
  mOn;
end;

procedure TKreslik.Idle;
begin
  pocidle := pocidle + 1;
end;

procedure TKreslik.Run;
var iu : TUdalost;
    rx, ry, x, y : word;
    t1, t2 : boolean;

  procedure InitProstredi;
  begin
    ot1 := false; ot2 := false; nastroj := 0;
    {tlacitka}
    app.VlozObj(new(PtlElipsa,Init(5,360,LightBlue,Black,Dynamic,' Elipsa ',@app)));
    app.VlozObj(new(PtlObdelnik,Init(5,320,LightBlue,Black,Dynamic,'Obdelnik',@app)));
    app.VlozObj(new(PtlKonec,Init(5,400,Red,Black,Dynamic,' Konec  ',@app)));
    app.VlozObj(new(PtlPresun,Init(5,280,LightBlue,Black,Dynamic,' Presun ',@app)));
    app.VlozObj(new(PtlOdstran,Init(5,240,LightBlue,Black,Dynamic,'Odstran ',@app)));
    {souradnice}
    app.VlozObj(new(PmRelZmena,Init(550,40,LightBlue,Dynamic,'RX= RY=',defaultts,@app)));
    app.VlozObj(new(PmSouradnice,Init(550,20,Red,Dynamic,'X= Y=',defaultts,@app)));
    {dolni a horni stavova radka}
    psr := new(PStavRadka,Init(320, 470, Blue,Dynamic,'stavova radka',defaultts,@app));
    app.VlozObj(psr);
    psr2 := new(PStavRadka,Init(320, 10, Blue,Dynamic,'kroky',defaultts,@app));
    app.VlozObj(psr2);
    {barva}
    app.VlozObj(new(PtlBarvaDec,Init(520,400,Green,Black,Dynamic,'-',@app)));
    aktbarva := 1;
    pbarva := new(PText,Init(575,407,aktbarva,Dynamic,'1',barvats,@app));
    app.VlozObj(pbarva);
    app.VlozObj(new(PtlBarvaInc,Init(600,400,Green,Black,Dynamic,'+',@app)));
  end;

{hlavni blok aplikace}

begin
  InitGr;
  InitProstredi;
  Obnov;
  mInit;
  mSetGrCursorFile(kcesta+kSipka);
  mOn;
  konec := false;
  nastroj := -1;
  repeat
    mGetXY(iu.x,iu.y);
    mGetRXY(iu.rx,iu.ry);
    t1 := mGetT1;
    t2 := mGetT1;
    iu.jaka := zpNothing;
    iu.click := false;
    if (ot1 <> t2) or (ot2 <> t2) then begin
      if (ot1 = true) and (t1 = false) then begin
        iu.jaka := zpLBUp;
        PosliZpravu(@app,zpMouse,@iu);
      end;
      if (ot2 = true) and (t2 = false) then begin
        iu.jaka := zpRBUp;
        PosliZpravu(@app,zpMouse,@iu);
      end;
      if (ot1 = false) and (t1 = true) then begin
        iu.jaka := zpLBDown;
        PosliZpravu(@app,zpMouse,@iu);
      end;
      if (ot2 = false) and (t2 = true) then begin
        iu.jaka := zpRBDown;
        PosliZpravu(@app,zpMouse,@iu);
      end;
    end;
    if ((t1 = ot1) and (t1)) or ((t2 = ot2) and (t2)) then begin
      {kdyz je maska stejna a je stisknuto alspon jedno tlacitko}
      iu.jaka := zpMouseAuto;
      PosliZpravu(@app,zpMouse,@iu);
    end;
    if (iu.rx <> 0) or (iu.ry <> 0) then begin
      iu.jaka := zpMouseMove;
      PosliZpravu(@app,zpMouse,@iu);
    end;
    ot1 := t1;
    ot2 := t2;
    if kGetPressed <> 0 then begin
      iu.jaka := zpKeyDown;
      iu.kod := kGetKey;
      if iu.kod < $100 then
	iu.kod := word(upcase(char(iu.kod)));
      iu.shift := kGetShifts;
      PosliZpravu(@app,zpKeyDown,@iu);
    end;
    if iu.jaka = zpNothing then
      Idle;
  until konec = true;
  mOff;
  mDone;
end;

constructor TKreslik.Init(ityp : TClenTyp);
begin
  inherited Init(ityp);
  objs.Init(100,Static,@app);
  InitGr;
end;

destructor TKreslik.Done;
begin
  objs.Done;
  inherited Done;
  DoneGr;
end;

{ostatni}
function InitGr : boolean;
var grm, grd : integer;
begin
  grd := VGA;
  grm := VGAHi;
  InitGraph(grd, grm, 'BGI\');
end;

procedure DoneGr;
begin
  CloseGraph;
  asm
    mov ax, 0003h
    int 10h
  end;
end;

begin
{$ifdef OVR}
  OvrInit('kreslik.ovr');
  if OvrResult <> ovrOk then begin
    writeln('Chyba pri inicializaci overlaye.');
    halt(-OvrResult);
  end;
{$endif}
  clrscr;
  memstart := MemAvail;
  app.Init(Static);
  {$ifdef HUDBA}hudbaStart('k_sub.s3m');{$endif}
  app.Run;
  {$ifdef HUDBA}hudbaStop;{$endif}
  app.Done;
  memend := MemAvail;
  writeln;
  writeln('memstart = ',memstart,' B');
  writeln('memend = ',memend,' B');
  writeln('memstart - memend = ',memstart-memend,' B');
  writeln('Idle volano ',pocidle,'-krat');
end.