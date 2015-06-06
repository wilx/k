{$ifdef DEBUG}
  {$D+,L+,Y+,R+,I+,C+,S+,V+,Q+}
{$endif}

{$X+,O-}
unit Seznam;

interface
uses {$ifdef LUT}LUTs,{$endif} {$ifndef NOMSG}Zpravy,{$endif} Nothing;

const
      {$ifdef LUT}
      CacheSize = 8;
      {$else}
      CacheSize = 1;
      {$endif}

type
     TVysledek = (Ok,NilPtr,BadPtr,BadPos,FullList,EmptyList);
     TClenTyp = (Static,Dynamic);
     PSeznamClen = ^TSeznamClen;
     TSeznamClen = object{$ifndef NOMSG}(TKomunikace){$endif}
                     next, prev : PSeznamClen;
                     typ : TClenTyp;
                     objtyp : word;
                     function GetPrev : PSeznamClen;
                     function GetNext : PSeznamClen;
                     {vrati zda je objekt staticky nebo dynamicky}
                     function GetClenTyp : TClenTyp;
                     {vrati cislo typu objektu pr.: SeznamClenID = 1}
                     function GetObjTyp : word;
                     constructor Init(ityp : TClenTyp{$ifndef NOMSG}; imajitel : PKomunikace{$endif});
                     destructor Done; virtual;
                     procedure VyradSe; virtual;
                   end;
     PSeznam = ^TSeznam;
     TSeznam = object (TSeznamClen)
                 pocet, maxobjs, cacheclenpos : longint;
                 vysl : TVysledek;
                 {$ifdef LUT}
                 cache : TPtrLookUpTable;
                 {$else}
                 cache : PSeznamClen;
                 {$endif}
                 constructor Init(imaxobjs : longint; ityp : TClenTyp{$ifndef NOMSG}; imajitel : PKomunikace{$endif});
                 destructor Done; virtual;
                 procedure VlozObj(po : PSeznamClen); virtual;
                 procedure SmazObj(po : PSeznamClen); virtual;
                 procedure SmazObjNa(pos : longint); virtual;
                 procedure SmazVsechny; virtual;
                 procedure PresunObjDo(po : PSeznamClen; nsez : PSeznam); virtual;
                 procedure PresunObjNaDo(pos : longint; nsez : PSeznam); virtual;
                 procedure PresunNahoru(po : PSeznamClen); virtual;
                 procedure PresunDolu(po : PSeznamClen); virtual;
                 function Pozice(pos : longint) : PSeznamClen;
                 function PocetObj : longint;
                 function Vysledek : TVysledek;
               end;

implementation
uses Konsts;
{metody objektu TSeznamClen}
function TSeznamClen.GetPrev : PSeznamClen;
begin
  GetPrev := prev;
end;

function TSeznamClen.GetNext : PSeznamClen;
begin
  GetNext := next;
end;

function TSeznamClen.GetClenTyp : TClenTyp;
begin
  GetClenTyp := typ;
end;

function TSeznamClen.GetObjTyp : word;
begin
  GetObjTyp := objtyp;
end;

procedure TSeznamClen.VyradSe;
begin
  if (next <> nil) and (prev <> nil) then begin
    prev^.next := next;
    next^.prev := prev;
    next := nil;
    prev := nil;
  end;
end;

constructor TSeznamClen.Init(ityp : TClenTyp{$ifndef NOMSG}; imajitel : PKomunikace{$endif});
begin
  {$ifndef NOMSG}inherited Init(imajitel){$endif};
  typ := ityp;
  next := nil; prev := nil;
  objtyp := SeznamClenID;
end;

destructor TSeznamClen.Done;
begin
  VyradSe;
  {$ifndef NOMSG}inherited Done{$endif};
end;

{metody objektu TSeznam}

function TSeznam.Vysledek : TVysledek;
begin
  Vysledek := vysl;
end;

function TSeznam.PocetObj : longint;
begin
  PocetObj := pocet;
end;

constructor TSeznam.Init(imaxobjs : longint; ityp : TClenTyp{$ifndef NOMSG}; imajitel : PKomunikace{$endif});
begin
  inherited Init(ityp{$ifndef NOMSG},imajitel{$endif}); {musi se volat drive, protoze dava next a prev = nil}
  if imaxobjs = 0 then begin
    inherited Done;
    Fail; {kdyz imaxobjs = 0, nemuzu pridat zadny objekt tak se ukoncim}
  end;
  objtyp := SeznamID;
  maxobjs := imaxobjs;
  pocet := 0;
  next := @self;
  prev := @self;
  {$ifdef LUT}
  cache.Init(CacheSize);
  {$else}
  cacheclenpos := 0;
  cache := @self;
  {$endif}
end;

procedure TSeznam.VlozObj(po : PSeznamClen);
begin
  if po = nil then vysl := NilPtr
  else begin
    if pocet < maxobjs then begin
      prev^.next := po;
      po^.prev := prev;
      po^.next := @self;
      prev := po;
      inc(pocet);
      {$ifdef LUT}
      cache.PutTag(pocet,po);
      {$endif}
      vysl := Ok;
    end
    else vysl := FullList; {seznam je uz plny}
  end;
end;

function TSeznam.Pozice(pos : longint) : PSeznamClen;
var pom : PSeznamClen;
    i : word;
begin
  if (pos > 0) and (pos <= pocet) and (pocet > 0) then begin
    {$ifdef LUT}
    pom := cache.LookUp(pos); {jestli je ta poziece v cache tak ji vrat}
    if pom <> nil then begin
      Pozice := pom;
      exit;
    end
    {$else}
    if pos = cacheclenpos then {jestli je ta poziece v cache tak ji vrat}
      Pozice := cache
    {$endif}
    else begin
      pom := next;
      i := 1;
      while (i < pos) and (i <= pocet) do begin
        pom := pom^.next;
        inc(i);
      end;
      Pozice := pom;
      {$ifdef LUT}
      cache.PutTag(pos,pom);
      {$else}
      cache := pom;
      cacheclenpos := pos;
      {$endif}
    end;
  end
  else vysl := BadPos; {kdyz neni splnea podminka ^, nastavi se BadPos}
end;

procedure TSeznam.SmazObj(po : PSeznamClen);
begin
  if po = nil then vysl := NilPtr
  else begin
    if pocet > 0 then begin
      {$ifdef LUT}
      cache.DeleteTagPtr(po);
      {$else}
      if cache = po then begin
        cache := @self;
        cacheclenpos := 0;
      end;
      {$endif}
      if po^.GetClenTyp = Dynamic then
        dispose(po,Done)
      else
        po^.Done;
      dec(pocet);
    end;
    vysl := Ok;
  end;
end;

procedure TSeznam.SmazObjNa(pos : longint);
var i : word;
    pom : PSeznamClen;
begin
  if (pos > 0) and (pos <= pocet) and (pocet > 0) then begin
    pom := Pozice(pos);
    {$ifdef LUT}
    cache.DeleteTag(pos);
    {$else}
    cache := @self; {zneplatnim cache, protoze bude vzdy neplatna,}
    cacheclenpos := 0; {protoze posledni hledany objekt bude zrusen, vymazan}
    {$endif}
    if pom^.GetClenTyp = Dynamic then
      dispose(pom,Done)
    else
      pom^.Done;
    dec(pocet);
  end
  else vysl := BadPos;
end;

procedure TSeznam.PresunObjDo(po : PSeznamClen; nsez : PSeznam);
begin
  if po = nil then vysl := NilPtr
  else begin
    {$ifdef LUT}
    cache.DeleteTagPtr(po);
    {$else}
    if cache = po then begin {zajisteni konzistence cache}
      cache := @self;
      cacheclenpos := 0;
    end;
    {$endif}
    po^.VyradSe;
    if nsez^.pocet < nsez^.maxobjs then begin
      nsez^.VlozObj(po);
      vysl := Ok;
    end
    else vysl := FullList; {seznam je uz plny}
  end;
end;

procedure TSeznam.PresunObjNaDo(pos : longint; nsez : PSeznam);
var pom : PSeznamClen;
begin
  if (pos > 0) and (pos <= pocet) and (pocet > 0) then begin
    pom := Pozice(pos);
    if pom = nil then vysl := NilPtr
    else begin
      {$ifdef LUT}
      cache.DeleteTagPtr(pom);
      {$else}
      if cache = pom then begin {zajisteni konzistence cache}
        cache := @self;
        cacheclenpos := 0;
      end;
      {$endif}
      if nsez^.pocet < nsez^.maxobjs then begin
        pom^.VyradSe;
        nsez^.VlozObj(pom);
        vysl := Ok;
      end
      else
        vysl := FullList; {seznam je uz plny}
    end;
  end
  else vysl := BadPos; {kdyz neni splnea podminka ^ (uplne nahore), nastavi se BadPos}
end;

procedure TSeznam.PresunNahoru(po : PSeznamClen); {smerem ke konci}
var pom, pom2, pom3 : PSeznamClen;
begin
  pom := po^.next;
  pom2 := po^.next^.next;
  pom3 := pom^.prev;
  {$ifdef LUT}
  cache.DeleteTagPtr(po);
  cache.DeleteTagPtr(pom);
  {$else}
  if (cache = po) or (cache = pom) then begin {zajisteni konzistence cache}
    cache := @self;
    cacheclenpos := 0;
  end;
  {$endif}
  po^.next := pom2;
  po^.prev := pom;
  pom^.next := po;
  pom^.prev := pom3;
  pom3^.next := pom;
  pom2^.prev := po;
end;

procedure TSeznam.PresunDolu(po : PSeznamClen); {smerem k zacatku seznamu}
var pom, pom2, pom3 : PSeznamClen;
begin
  pom := po^.prev;
  pom2 := po^.prev^.prev;
  pom3 := pom^.next;
  {$ifdef LUT}
  cache.DeleteTagPtr(po);
  cache.DeleteTagPtr(pom);
  {$else}
  if (cache = po) or (cache = pom) then begin {zajisteni konzistence cache}
    cache := @self;
    cacheclenpos := 0;
  end;
  {$endif}
  po^.prev := pom2;
  po^.next := pom;
  pom^.prev := po;
  pom^.next := pom3;
  pom3^.prev := pom;
  pom2^.next := po;
end;


procedure TSeznam.SmazVsechny;
begin
  while pocet > 0 do SmazObj(prev);
end;

destructor TSeznam.Done;
begin
  SmazVsechny;
  {$ifdef LUT}
  cache.Done;
  {$endif}
  {$ifndef NOMSG}
  inherited Done;
  {$endif}
end;

end.