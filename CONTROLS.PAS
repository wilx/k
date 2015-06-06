{$ifdef DEBUG}
  {$D+,L+,Y+,R+,I+,C+,S+,V+,Q+}
{$endif}

unit Controls;

interface
uses Seznam, GraphO, Zpravy, Konsts, Graph, Crt;

const
      BarvaStisku = EgaWhite;
      DobaCekaniStisku = 1000; {v milisekundach}
      {konstanta defaultoveho typu pisma}
      defaultts : TextSettingsType = (Font:DefaultFont;Direction:HorizDir;
                                      CharSize:1{velikost pisma};
                                      Horiz:CenterText;Vert:CenterText);
      defaultts_lt : TextSettingsType = (Font:DefaultFont;Direction:HorizDir;
                                      CharSize:1{velikost pisma};
                                      Horiz:LeftText;Vert:TopText);


type {definice pomocnych typu}
     PUdalost = ^TUdalost;
     TUdalost = record
                  case jaka : integer of
                    zpNothing : ();
                    zpMouseMove,
                    zpLBDown,
                    zpLBUp,
                    zpRBDown,
                    zpRBUp : (
                      x, y : word;
                      rx, ry : integer;
                      t1, t2, t3, click : boolean;
                    );
                    zpKeyDown : (
                      shift, kod : word;
                    );
                end;
     {definice ovladacich prvku}
     POvladaciPrvek = ^TOvladaciPrvek;
     {TUdalostHandler = procedure(obj : POvladaciPrvek; var iu : TUdalost);}
     TOvladaciPrvek = object(TGraphicObject)
                        aktiv : boolean;
                        constructor Init(ix, iy, ib, ibvypln : word;
                                    ityp : TClenTyp; imajitel : PKomunikace);
                        destructor Done; virtual;
                        {function GetX : word;
                        function GetY : word;}
                        {function GetCol : word; virtual;
                        procedure SetCol(ib : word); virtual;}
                        {function GetVypln : word; virtual;
                        procedure SetVypln(ib : word); virtual;}
                        function GetVyska : word; virtual;
                        function GetSirka : word; virtual;
                        function Dotaz(ix, iy : word) : boolean; virtual;
                        procedure Presun(ix, iy : word); virtual;
                        procedure Zasvit; virtual;
                        procedure Zhasni; virtual;
                        procedure Zvyrazni; virtual;
                        procedure Udalost(var iu : TUdalost); virtual;
                        function JeAktivni : boolean;
                      end;
     PPrikazoveTlacitko = ^TPrikazoveTlacitko;
     TPrikazoveTlacitko = object (TOvladaciPrvek)
                            obrys : TObdelnikPlny;
                            napis : TText;
                            vyska, sirka : word;
                            constructor Init(ix, iy, ib, ibvypln : word; ityp : TClenTyp;
                                             itext : string; imajitel : PKomunikace);
                            destructor Done; virtual;
                            function Dotaz(ix, iy : word) : boolean; virtual;
                            procedure Presun(ix, iy : word); virtual;
                            procedure Zasvit; virtual;
                            procedure Zhasni; virtual;
                            procedure Zvyrazni; virtual;
                            {procedure Udalost(var iu : TUdalost); virtual;}
                            function GetVyska : word; virtual;
                            function GetSirka : word; virtual;
                          end;
     (*
     PMenuPrvek = ^TMenuPrvek;
     TMenuPrvek = object (TOvladaciPrvek)
                    napis : TText;
                    constructor Init(ix, iy, ib : word; ityp : TClenTyp; itext : string);
                    destructor Done; virtual;
                    function Dotaz(ix, iy : word) : boolean; virtual;
                    procedure Presun(ix, iy : word); virtual;
                    procedure Zasvit; virtual;
                    procedure Zhasni; virtual;
                    procedure Zvyrazni; virtual;
                    procedure Udalost(var iu : TUdalost); virtual;
                  end;
     PMenu = ^TMenu;
     TMenu = object (TOvladaciPrvek)
               obrys : TObdelnik;
               msez : TSeznam;
             end;
     *)

{deklarace neobjektovych procedur a funkci}

{konstanty}

implementation

constructor TOvladaciPrvek.Init(ix, iy, ib, ibvypln : word; ityp : TClenTyp;
                                imajitel : PKomunikace);
begin
  inherited Init(ix,iy,ib,ibvypln,ityp, imajitel);
  objtyp := OvladaciPrvekID;
end;

destructor TOvladaciPrvek.Done;
begin
  inherited Done;
  Zhasni;
end;

{function TOvladaciPrvek.GetX : word;
begin
  GetX := x;
end;

function TOvladaciPrvek.GetY : word;
begin
  GetY := y;
end;}

{function TOvladaciPrvek.GetCol : word;
begin
  GetCol := barva;
end;

procedure TOvladaciPrvek.SetCol(ib : word);
begin
  barva := ib;
end;}

function TOvladaciPrvek.GetVyska : word;
begin
end;

function TOvladaciPrvek.GetSirka : word;
begin
end;

{function TOvladaciPrvek.GetVypln : word;
begin
  GetVypln := vypln;
end;

procedure TOvladaciPrvek.SetVypln(ib : word);
begin
  vypln := ib;
end;}

function TOvladaciPrvek.Dotaz(ix, iy : word) : boolean;
begin
  Dotaz := false;
end;

procedure TOvladaciPrvek.Presun(ix, iy : word);
begin
  Zhasni;
  x := ix;
  y := iy;
  Zasvit;
end;

procedure TOvladaciPrvek.Zvyrazni;
var pom : word;
begin
  pom := GetCol;
  SetCol(BarvaStisku);
  Zasvit;
  delay(DobaCekaniStisku);
  SetCol(pom);
  Zasvit;
end;

procedure TOvladaciPrvek.Zasvit;
begin
  aktiv := true;
end;

procedure TOvladaciPrvek.Zhasni;
begin
  aktiv := false;
end;

procedure TOvladaciPrvek.Udalost(var iu : TUdalost);
begin
end;

function TOvladaciPrvek.JeAktivni : boolean;
begin
  JeAktivni := aktiv;
end;

{metody objektu TPrikazoveTlacitko}
constructor TPrikazoveTlacitko.Init(ix, iy, ib, ibvypln : word; ityp : TClenTyp;
                 itext : string; imajitel : PKomunikace);
var v, s : word;
    ts : TextSettingsType;
begin
  inherited Init(ix,iy,ib,ibvypln,ityp,imajitel);
  objtyp := PrikazoveTlacitkoID;
  SaveTextSettings(ts);
  LoadTextSettings(defaultts);
  v := TextHeight(itext);
  s := TextWidth(itext);
  LoadTextSettings(ts);
  if v < 15 then v := 10;
  if s < 20 then s := 20;
  obrys.Init(ix,iy,ix+s+10,iy+v+10,ib,ibvypln,Static, @self);
  napis.Init((2*ix+s+10) div 2,(2*iy+v+10) div 2,ib,Static,itext,defaultts, @self);
end;

destructor TPrikazoveTlacitko.Done;
begin
  obrys.Done;
  napis.Done;
  inherited Done;
end;

procedure TPrikazoveTlacitko.Zhasni;
begin
  aktiv := false;
  napis.Zhasni;
  obrys.Zhasni;
end;

procedure TPrikazoveTlacitko.Zasvit;
begin
  aktiv := true;
  obrys.Zasvit;
  napis.Zasvit;
end;

procedure TPrikazoveTlacitko.Zvyrazni;
var pom : word;
begin
  pom := GetCol;
  SetCol(BarvaStisku);
  Zasvit;
  delay(DobaCekaniStisku);
  SetCol(pom);
  Zasvit;
end;

{procedure TPrikazoveTlacitko.Udalost(var iu : TUdalost);
begin
end;}


function TPrikazoveTlacitko.Dotaz(ix, iy : word) : boolean;
begin
  Dotaz := obrys.Dotaz(ix,iy);
end;

procedure TPrikazoveTlacitko.Presun(ix, iy : word);
begin
  Zhasni;
  x := ix;
  y := iy;
  Zasvit;
end;

function TPrikazoveTlacitko.GetVyska : word;
begin
  GetVyska := vyska;
end;

function TPrikazoveTlacitko.GetSirka : word;
begin
  GetSirka := sirka;
end;

{metody objektu TMenuPrvek}
(*
constructor TMenuPrvek.Init(ix, iy, ib : word; ityp : TClenTyp;
                            itext : string);
begin
  inherited Init(ix,iy,ib,Black,ityp);
  napis.Init(ix,iy,ib,Static,itext,defaultts);
  objtyp := MenuPrvekID;
end;

destructor TMenuPrvek.Done;
begin
  inherited Done;
  napis.Done;
  Zhasni;
end;

function TMenuPrvek.Dotaz(ix, iy : word) : boolean;
begin
  napis.Dotaz(ix,iy);
end;

procedure TMenuPrvek.Presun(ix, iy : word);
begin
  napis.Zhasni;
  x := ix;
  y := iy;
  napis.Zasvit;
end;

procedure TMenuPrvek.Zasvit;
begin
  napis.Zasvit;
end;

procedure TMenuPrvek.Zhasni;
begin
  napis.Zhasni;
end;

procedure TMenuPrvek.Zvyrazni;
begin
  aktiv := true;
  napis.SetCol(BarvaStisku);
  napis.Zasvit;
end;

procedure TMenuPrvek.Udalost(var iu : TUdalost);
begin
end;
*)
end.