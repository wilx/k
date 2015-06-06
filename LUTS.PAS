{$ifdef DEBUG}
  {$D+,L+,Y+,R+,I+,C+,S+,V+,Q+}
{$endif}

unit Luts;

interface

const MaxTableSize = 8190; {maximalni pocet zaznamu v tabulce}

type
    PPtrLookUpTag = ^TPtrLookUpTag;
    TPtrLookUpTag = record
			 key, age : word;
			 p : pointer;
		       end;
    PLookUpTableArray = ^TLookUpTableArray;
    TLookUpTableArray = array [1..MaxTableSize] of TPtrLookUpTag;
    PPtrLookUpTable = ^TPtrLookUpTable;
    TPtrLookUpTable = object
                           buf : PLookUpTableArray;
                           maxpoc, poc : word;
                           function LookUp(ikey : word) : pointer;
                           function PutTag(ikey : word; p : pointer) : boolean;
                           function DeleteTag(ikey : word) : boolean;
                           function DeleteTagPtr(p : pointer) : boolean;
                           function IsPtrIn(p : pointer) : boolean;
                           function IsKeyIn(ikey : word) : boolean;
                           constructor Init(ivel : word);
                           destructor Done;
                         end;

implementation

function TPtrLookUpTable.IsKeyIn(ikey : word) : boolean;
var i : word;
begin
  IsKeyIn := false;
  for i := poc downto 1 do
    if buf^[i].key = ikey then begin
      IsKeyIn := true;
      break;
    end;
end;

function TPtrLookUpTable.IsPtrIn(p : pointer) : boolean;
var i : word;
begin
  IsPtrIn := false;
  for i := poc downto 1 do
    if buf^[i].p = p then begin
      IsPtrIn := true;
      break;
    end;
end;

function TPtrLookUpTable.LookUp(ikey : word) : pointer;
var i : word;
begin
  if poc > 0 then begin
    LookUp := nil;
    for i := poc downto 1 do begin
      inc(buf^[i].age);
      if buf^[i].key = ikey then begin
        buf^[i].age := 1;
        LookUp := buf^[i].p;
        break;
      end;
    end;
  end
  else
    LookUp := nil;
end;

function TPtrLookUpTable.PutTag(ikey : word; p : pointer) : boolean;
var i, oldest, pom : word;
begin
  PutTag := false;
  if poc > 0 then begin
    for i := 1 to poc do
      inc(buf^[i].age);
    if poc < maxpoc then begin {kdyz je v tabulce jeste nejake misto}
      if not IsPtrIn(p) then begin {pokud tam takovej ptr jeste neni}
        inc(poc);
        buf^[poc].key := ikey;
        buf^[poc].p := p;
        buf^[poc].age := 1;
      end
      else begin
        PutTag := true; {uz je pritomen}
        exit;
      end;
    end
    else begin {kdyz uz v tabulce neni misto}
      if not IsPtrIn(p) then begin {a pokud tam takovej ptr jeste neni}
        oldest := poc;
        for i := poc downto 1 do {najdu nejstarsi zaznam}
          if buf^[i].age > buf^[oldest].age then
            oldest := i;
        if (poc - oldest > 0) and (oldest <> poc) then {smrsknu tabulku}
          for i := oldest + 1 to poc do
            buf^[i-1] := buf^[i];
        buf^[poc].key := ikey; {a na uvonene misto dam novy zaznam}
        buf^[poc].p := p;
        buf^[poc].age := 1;
      end
      else
        exit; {kdyz uz tam takovy ptr je, tak nic}
    end;
  end
  else begin {prvni zaznam}
    buf^[1].key := ikey;
    buf^[1].p := p;
    buf^[1].age := 1;
    inc(poc);
  end;
end;

function TPtrLookUpTable.DeleteTagPtr(p : pointer) : boolean;
var i, t, pom : word;
    nalezen : boolean;
begin
  if poc > 0 then begin
    nalezen := false;
    for i := poc downto 1 do {najdu ten, kterej chci smazat}
      if buf^[i].p = p then begin
        t := i;
        nalezen := true;
        pom := poc - t;
        break;
      end;
    if nalezen then begin
      if (pom > 0) and (t <> poc) then {smrsknu tabulku}
        for i :=t+1 to poc do
          buf^[i-1] := buf^[i];
      dec(poc);
      DeleteTagPtr := true;
    end
    else
      DeleteTagPtr := false;
  end
  else
    DeleteTagPtr := false;
end;

function TPtrLookUpTable.DeleteTag(ikey : word) : boolean;
var i, t, pom : word;
    nalezen : boolean;
begin
  if poc > 0 then begin
    nalezen := false;
    for i := poc downto 1 do {najdu ten, kterej chci smazat}
      if buf^[i].key = ikey then begin
        t := i;
        nalezen := true;
        pom := poc - t;
        break;
      end;
    if nalezen then begin
      if (pom > 0) and (t <> poc) then {smrsknu tabulku, kdyz to neni jedinej}
        for i :=t+1 to poc do          {ani posledni zaznam, jinak jenom}
          buf^[i-1] := buf^[i];        {sniz pocet o 1}
      dec(poc);
      DeleteTag := true;
    end
    else
      DeleteTag := false;
  end
  else
    DeleteTag := false;
end;

constructor TPtrLookUpTable.Init(ivel : word); {pocet zaznamu}
begin
  maxpoc := ivel;
  GetMem(buf,sizeof(TPtrLookUpTag)*ivel);
  poc := 0
end;

destructor TPtrLookUpTable.Done;
begin
  FreeMem(buf,sizeof(TPtrLookUpTag)*maxpoc);
end;

end.