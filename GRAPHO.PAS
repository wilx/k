{$ifdef DEBUG}
  {$D+,L+,Y+,R+,I+,C+,S+,V+,Q+}
{$endif}

{$X+,G+,O+}
unit GraphO;

interface
uses Graph, Seznam, Zpravy, Konsts;

type
    TGrSettings = record
                    ts : TextSettingsType;
                    fs : FillSettingsType;
                    {bkcol,} col : word;
                  end;
    {definice grafickych objektu}
    PGraphicObject = ^TGraphicObject;
    TGraphicObject = object (TSeznamClen)
                x, y, hladina, barva, vypln : word;
                constructor Init(ix, iy, ib, ivypln : word; ityp : TClenTyp;
                                 imajitel : PKomunikace);
                destructor Done; virtual;
                function GetX : word;
                function GetY : word;
                function GetCol : word; virtual;
                function Dotaz(ix, iy : word) : boolean; virtual;
                procedure Presun(ix, iy : word); virtual;
                procedure SetCol(ib : word); virtual;
                procedure SetVypln(ib : word); virtual;
                function GetVypln : word; virtual;
                procedure Zasvit; virtual;
                procedure Zhasni; virtual;
              end;
     {PBod = ^TBod;
     TBod = object (TGraphicObject)
              constructor Init(ix, iy, ib : word; ityp : TClenTyp);
              destructor Done; virtual;
              procedure Presun(ix, iy : word);
              procedure Zasvit; virtual;
              procedure Zhasni; virtual;
            end;
     }
     PElipsa = ^TElipsa;
     TElipsa = object (TGraphicObject)
                 a, b : word;
                 constructor Init(ix, iy, ia, ib, ibarva : word; ityp : TClenTyp; imajitel : PKomunikace);
                 destructor Done; virtual;
                 function Dotaz(ix, iy : word) : boolean; virtual;
                 {procedure Presun(ix, iy : word); virtual;}
                 procedure Zasvit; virtual;
                 procedure Zhasni; virtual;
               end;
     PElipsaPlna = ^TElipsaPlna;
     TElipsaPlna = object (TElipsa)
                     constructor Init(ix, iy, ia, ib, ibarva, ibvypln : word; ityp : TClenTyp; imajitel : PKomunikace);
                     destructor Done; virtual;
                     {procedure Presun(ix, iy : word); virtual;}
                     procedure Zasvit; virtual;
                     procedure Zhasni; virtual;
                   end;
     {PPrimka = ^TPrimka;
     TPrimka = object (TGraphicObject)
                 x2, y2 : word;
                 constructor Init(ix, iy, ix2, iy2, ib : word; ityp : TClenTyp);
                 destructor Done; virtual;
                 function Dotaz(ix, iy : word) : boolean; virtual;
                 procedure Presun(ix, iy : word); virtual;
                 procedure Zasvit; virtual;
                 procedure Zhasni; virtual;
               end;}
     PObdelnik = ^TObdelnik;
     TObdelnik = object (TGraphicObject)
                   x2, y2 : word;
                   constructor Init(ix, iy, ix2, iy2, ib : word; ityp : TClenTyp; imajitel : PKomunikace);
                   destructor Done; virtual;
                   function Dotaz(ix, iy : word) : boolean; virtual;
                   procedure Presun(ix, iy : word); virtual;
                   procedure Zasvit; virtual;
                   procedure Zhasni; virtual;
                 end;
     PObdelnikPlny = ^TObdelnikPlny;
     TObdelnikPlny = object (TObdelnik)
                       constructor Init(ix, iy, ix2, iy2, ib, ibvypln : word; ityp : TClenTyp; imajitel : PKomunikace);
                       destructor Done; virtual;
                       {procedure Presun(ix, iy : word); virtual;}
                       procedure Zasvit; virtual;
                       procedure Zhasni; virtual;
                     end;
     PText = ^TText;
     TText = object (TGraphicObject)
               text : string;
               vyska, sirka : word;
               texttyp: TextSettingsType;
               constructor Init(ix, iy, ib : word; ityp : TClenTyp;
                                itext : string; itexttyp: TextSettingsType; imajitel : PKomunikace);
               destructor Done; virtual;
               function Dotaz(ix, iy : word) : boolean; virtual;
               {procedure Presun(ix, iy : word); virtual;}
               procedure Zasvit; virtual;
               procedure Zhasni; virtual;
               function GetText : string;
               procedure SetText(itext : string);
               procedure GetVlastnosti(var itexttyp: TextSettingsType);
               procedure SetVlastnosti(var itexttyp: TextSettingsType);
             end;
     {TObrazek = object (TGraphicObject)
                constructor Init(ix, iy : word);
              end;}

{verejne procedure a funkce}
procedure SaveTextSettings(var ts : TextSettingsType);
procedure LoadTextSettings(var ts : TextSettingsType);
procedure SaveAllSettings(var s : TGrSettings);
procedure LoadAllSettings(var s : TGrSettings);

implementation
const MAXDISTANCE = 5; {maximalni vzdalenost 5 pixelu (od stredu u Elipsa)}
{tela verejnych procedur a funkce}
procedure SaveTextSettings(var ts : TextSettingsType);
begin
  GetTextSettings(ts);
end;

procedure LoadTextSettings(var ts : TextSettingsType);
begin
  with ts do begin
    SetTextStyle(Font,Direction,CharSize);
    SetTextJustify(Horiz,Vert);
  end;
end;

procedure SaveAllSettings(var s : TGrSettings);
begin
  SaveTextSettings(s.ts);
  GetFillSettings(s.fs);
  s.col := GetColor;
  {s.bkcol := GetBkColor;}
end;

procedure LoadAllSettings(var s : TGrSettings);
begin
  LoadTextSettings(s.ts);
  SetFillStyle(s.fs.pattern,s.fs.color);
  SetColor(s.col);
  {SetBkColor(s.bkcol);}
end;


{*** tela metod objketu TGraphicObject ****}
constructor TGraphicObject.Init(ix, iy, ib, ivypln : word; ityp : TClenTyp; imajitel : PKomunikace);
begin
  inherited Init(ityp, imajitel);
  x := ix; y := iy; barva := ib; vypln := ivypln;
  objtyp := GraphicObjectID;
end;

destructor TGraphicObject.Done;
begin
  inherited Done;
end;

procedure TGraphicObject.Presun(ix, iy : word);
begin
  Zhasni;
  x := ix; y := iy;
  Zasvit;
end;

procedure TGraphicObject.Zasvit;
begin
end;

procedure TGraphicObject.Zhasni;
begin
end;

function TGraphicObject.GetX : word;
begin
  GetX := x;
end;

function TGraphicObject.GetY : word;
begin
  GetY := y;
end;

function TGraphicObject.Dotaz(ix, iy : word) : boolean;
begin
end;

function TGraphicObject.GetCol : word;
begin
  GetCol := barva;
end;

procedure TGraphicObject.SetCol(ib : word);
begin
  barva := ib;
end;

procedure TGraphicObject.SetVypln(ib : word);
begin
  vypln := ib;
end;

function TGraphicObject.GetVypln : word;
begin
  GetVypln := vypln;
end;

{*** tela metod objektu TBod ****}
{constructor TBod.Init(ix, iy : word; ib : word; ityp : TClenTyp);
begin
  inherited Init(ix, iy, ib, 0, ityp);
  objtyp := BodID;
end;

destructor TBod.Done;
begin
  Zhasni;
  inherited Done;
end;

procedure TBod.Zasvit;
begin
  putpixel(x, y, barva);
end;

procedure TBod.Zhasni;
begin
  putpixel(x, y, 0);
end;

procedure TBod.Presun(ix, iy : word);
begin
  Zhasni;
  x := ix; y := iy;
  Zasvit;
end;
}

{*** tela metod objektu TElipsa ****}
constructor TElipsa.Init(ix, iy, ia, ib, ibarva : word; ityp : TClenTyp; imajitel : PKomunikace);
begin
  inherited Init(ix, iy, ibarva, 0, ityp, imajitel);
  a := ia;
  b := ib;
  objtyp := ElipsaID;
end;

destructor TElipsa.Done;
begin
  Zhasni;
  inherited Done;
end;

function TElipsa.Dotaz(ix, iy : word) : boolean;
var pom : real;
begin
  pom := sqrt((ix-x)*(ix-x)+(iy-y)*(iy-y));
  if (round(pom) <= MAXDISTANCE) then
    Dotaz := true
  else
    Dotaz := false;
  {zkousel jsem to i analyticky, ale ocividne to tak nefunguje}
  {
  if a >=  b then
    if ((sqr(x-ix)/sqr(a)+sqr(y-iy)/sqr(b)) <= 1) then
      Dotaz := true
    else
      Dotaz := false
  else
    if ((sqr(x-ix)/sqr(b)+sqr(y-iy)/sqr(a)) <= 1) then
      Dotaz := true
    else
      Dotaz := false;
  }
end;

procedure TElipsa.Zasvit;
begin
  SetColor(barva);
  ellipse(x,y,0,360,a,b);
end;

procedure TElipsa.Zhasni;
begin
  SetColor(0);
  ellipse(x,y,0,360,a,b);
end;

{metody objektu TElipsaPlna}
constructor TElipsaPlna.Init(ix, iy, ia, ib, ibarva, ibvypln : word; ityp : TClenTyp; imajitel : PKomunikace);
begin
  inherited Init(ix, iy, ia, ib, ibarva, ityp, imajitel);
  vypln := ibvypln;
  objtyp := ElipsaPlnaID;
end;

destructor TElipsaPlna.Done;
begin
  Zhasni;
  inherited Done;
end;

procedure TElipsaPlna.Zasvit;
var pom : TGrSettings;
begin
  SaveAllSettings(pom);
  setfillstyle(SolidFill,vypln);
  setcolor(barva);
  FillEllipse(x,y,a,b);
  LoadAllSettings(pom);
end;

procedure TElipsaPlna.Zhasni;
var pom : TGrSettings;
begin
  SaveAllSettings(pom);
  setfillstyle(SolidFill,0);
  setcolor(EgaBlack);
  FillEllipse(x,y,a,b);
  LoadAllSettings(pom);
end;

{procedure TElipsaPlna.Presun(ix, iy : word);
begin
  Zhasni;
  x := ix; y := iy;
  Zasvit;
end;
}

{metody objektu TPrimka}
{constructor TPrimka.Init(ix, iy, ix2, iy2, ib : word; ityp : TClenTyp);
begin
  inherited Init(ix, iy, ib, 0, ityp);
  x2 := ix2;
  y2 := iy2;
  objtyp := PrimkaID;
end;

destructor TPrimka.Done;
begin
  Zhasni;
  inherited Done;
end;

procedure TPrimka.Presun(ix, iy : word);
begin
end;

procedure TPrimka.Zasvit;
begin
  SetColor(barva);
  Line(x,y,x2,y2);
end;

procedure TPrimka.Zhasni;
begin
  SetColor(0);
  Line(x,y,x2,y2);
end;

function TPrimka.Dotaz(ix, iy : word) : boolean;
var v1, v2 : real;
begin
  if ((ix-x)/(x2-x)) = ((iy-y)/(y2-y)) then Dotaz := true
  else Dotaz := false;
end;
}

{metody objektu TObdelnik}
constructor TObdelnik.Init(ix, iy, ix2, iy2, ib : word; ityp : TClenTyp; imajitel : PKomunikace);
begin
  inherited Init(ix, iy, ib, 0, ityp, imajitel);
  x2 := ix2;
  y2 := iy2;
  objtyp := ObdelnikID;
end;

destructor TObdelnik.Done;
begin
  Zhasni;
  inherited Done;
end;

function TObdelnik.Dotaz(ix, iy : word) : boolean;
begin
  if ((ix >= x) and (ix <= x2)) and ((iy >= y) and (iy <= y2)) then
    Dotaz := true
  else
    Dotaz := false;
end;

procedure TObdelnik.Presun(ix, iy : word);
var rx, ry : integer; {promene pro vypocet relativniho presunu}
begin
  rx := ix - x;
  ry := iy - y;
  Zhasni;
  x := ix;
  y := iy;
  x2 := x2 + rx;
  y2 := y2 + ry;
  Zasvit;
end;

procedure TObdelnik.Zasvit;
begin
  SetColor(barva);
  Rectangle(x,y,x2,y2);
end;

procedure TObdelnik.Zhasni;
begin
  SetColor(0);
  Rectangle(x,y,x2,y2);
end;

{metody objektu TObdelnikPlny}
constructor TObdelnikPlny.Init(ix, iy, ix2, iy2, ib, ibvypln : word; ityp : TClenTyp; imajitel : PKomunikace);
begin
  inherited Init(ix,iy,ix2,iy2,ib{,ibvypln},ityp, imajitel);
  {x2 := ix2;
  y2 := iy2;}
  vypln := ibvypln;
  objtyp := ObdelnikPlnyID;
end;

destructor TObdelnikPlny.Done;
begin
  inherited Done;
  Zhasni;
end;

{procedure TObdelnikPlny.Presun(ix, iy : word);
var rx, ry : integer;
begin
  rx := ix - x;
  ry := iy - y;
  Zhasni;
  x := ix;
  y := iy;
  x2 := x2 + rx;
  y2 := y2 + ry;
  Zasvit;
end;}

procedure TObdelnikPlny.Zasvit;
var pom : TGrSettings;
begin
  SaveAllSettings(pom);
  setcolor(barva);
  setfillstyle(SolidFill,vypln);
  Bar3D(x,y,x2,y2,0,true);
  LoadAllSettings(pom);
end;

procedure TObdelnikPlny.Zhasni;
var pom : TGrSettings;
begin
  SaveAllSettings(pom);
  setcolor(0);
  setfillstyle(SolidFill,0);
  Bar3D(x,y,x2,y2,0,true);
  LoadAllSettings(pom);
end;


{metody objektu TText}
constructor TText.Init(ix, iy, ib : word; ityp : TClenTyp;
                 itext : string; itexttyp: TextSettingsType; imajitel : PKomunikace);
begin
  inherited Init(ix, iy, ib, Black, ityp, imajitel);
  text := itext;
  texttyp := itexttyp;
  sirka := TextWidth(text);
  vyska := TextHeight(text);
  objtyp := TextID;
end;

destructor TText.Done;
begin
  inherited Done;
  Zhasni;
end;

function TText.Dotaz(ix, iy : word) : boolean;
begin
  with texttyp do begin
    if (horiz = CenterText) and (vert = CenterText) then begin
      if ((ix >= (x - sirka div 2)) and (ix <= (x + sirka div 2)))
         and ((iy >= (y - vyska div 2)) and (iy <= (y + vyska div 2))) then
        Dotaz := true
      else
        Dotaz := false;
    end
    else if (horiz = LeftText) and (vert = TopText) then begin
      if ((ix >= x) and (ix <= (x + sirka)))
         and ((iy >= y) and (iy <= (y + vyska))) then
        Dotaz := true
      else
        Dotaz := false;
    end
    else Dotaz := false;
  end;
end;

{procedure TText.Presun(ix, iy : word);
begin
  Zhasni;
    x := ix;
    y := iy;
  Zasvit;
end;}

procedure TText.Zasvit;
var pom : TextSettingsType;
    pom2 : word;
begin
  pom := texttyp;
  pom2 := GetColor;
  SetColor(barva);
  SaveTextSettings(pom);
  LoadTextSettings(texttyp);
  OutTextXY(x,y,text);
  SetColor(pom2);
  LoadTextSettings(pom);
end;

procedure TText.Zhasni;
var pom : TextSettingsType;
    pom2 : word;
begin
  pom2 := GetColor;
  SetColor(0);
  SaveTextSettings(pom);
  LoadTextSettings(texttyp);
  OutTextXY(x,y,text);
  SetColor(pom2);
  LoadTextSettings(pom);
end;

function TText.GetText : string;
begin
  GetText := text;
end;

procedure TText.SetText(itext : string);
begin
  Zhasni;
  text := itext;
  Zasvit;
end;

procedure TText.GetVlastnosti(var itexttyp: TextSettingsType);
begin
  itexttyp := texttyp;
end;

procedure TText.SetVlastnosti(var itexttyp: TextSettingsType);
begin
  texttyp := itexttyp;
end;

{metody objektu TObrazek}
{constructor TObrazek.Init(ix, iy : word);
begin
end;}

end.