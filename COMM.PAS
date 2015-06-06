unit Comm;

interface

function Max(a, b : longint) : longint;
function Min(a, b : longint) : longint;

implementation

{function Max(a, b : longint) : longint;
begin
  if a > b then
    Max := a
  else
    Max := b;
end;

function Min(a, b : longint) : longint;
begin
  if a < b then
    Min := a
  else
    Min := b;
end;}



function Max(a, b : longint) : longint; external;
function Min(a, b : longint) : longint; external;
{$L comm.obj}

end.