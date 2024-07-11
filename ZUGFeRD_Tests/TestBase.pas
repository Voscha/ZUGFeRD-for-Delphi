unit TestBase;

interface

uses
    System.SysUtils;

type
  TTestBase = class
  protected
    function makeSurePathIsCrossPlatformCompatible(const path: string): string;
    procedure RandomizeByteArray(var A: TBytes);
  end;

implementation

uses System.IOUtils, System.Math;

{ TTestBase }

function TTestBase.makeSurePathIsCrossPlatformCompatible(const path: string): string;
begin
  if path.IsNullOrEmpty(path) then
    exit(path);
  result := path.Replace('\\', TPath.DirectorySeparatorChar);
end;

procedure TTestBase.RandomizeByteArray(var A: TBytes);
var
  I: Integer;
begin
  for I := 0 to High(A) do
  begin
    A[I] := RandomRange(Low(Byte), High(Byte) + 1);
  end;
end;

end.
