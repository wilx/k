{$ifdef DEBUG}
  {$D+,L+,Y+,R+,I+,C+,S+,V+,Q+}
{$endif}
unit AppO;

interface
uses Seznam, Controls, Zpravy, Konsts;

const
      MaxObjVAplikaci = 500;

type
     TAplikace = object(TSeznam)
                   constructor Init(ityp : TClenTyp);
                   procedure Run; virtual;
                   procedure Idle; virtual;
                   procedure VezmiZpravu(sender : PKomunikace; co : word;
                                         info : pointer); virtual;
                   destructor Done; virtual;
                 end;

implementation

procedure TAplikace.VezmiZpravu(sender : PKomunikace; co : word;
                                info : pointer);
begin
end;

procedure TAplikace.Run;
begin
end;

{
 V procedure Idle by meli byt prikazy, ktere se provedou, pokud nenastane
 zadna udalost. Nemelo by to byt neco moc narocneho, protoze to muze zpomalit
 chod programu.
}
procedure TAplikace.Idle;
begin
end;

constructor TAplikace.Init(ityp : TClenTyp);
begin
  inherited Init(MaxObjVAplikaci, ityp, nil);
  objtyp := AplikaceID;
end;

destructor TAplikace.Done;
begin
  inherited Done;
end;

end.