unit func_hash;

interface
{ ������, �������������� ������ � �������� ���������������,
  ����������� �� ������ ���-������� � �������������
  � ������� ���������� ��������������� ����� }

uses table_element;

{ ������� ��������� ������������� ���-������� }
procedure InitHashVar;
{ ������� ������������ ������ ���-������� }
procedure ClearHashVar;
{ ������� �������� �������������� ���������� � ������� }
procedure ClearHashInfo;
{ ���������� �������� � ������� ��������������� }
function AddHashVar(const sName: string): TVarInfo;
{ ����� �������� � ������� ��������������� }
function GetHashVar(const sName: string): TVarInfo;
{ �������, ������������ ���������� �������� ��������� }
function GetHashCount: integer;

implementation

const
{ ����������� � ������������ �������� ���-�������
 (���������� ���� �������� �������� ���-�������) }
  HASH_MIN = Ord('0')+Ord('0')+Ord('0');
  HASH_MAX = Ord('z')+Ord('z')+Ord('z');
{ ��������� ��� ���������� ��������������� �����,
  ��� ������� �����: ������� - ��������� ������� �����
  � ������� ���-������� (������ = 223 ��������),
  � ������� - ������, ��� 1/2 �� �������� }
  REHASH1 = 127;
  REHASH2 = 223;

var
  HashArray : array[HASH_MIN..HASH_MAX] of TVarInfo;
{ ������ ��� ���-������� }
  iCmpCount : integer;
{ ������� ���������� ��������� }

function GetHashCount: integer;
begin
  Result := iCmpCount;
end;

function VarHash(const sName: string;
                 iNum: integer): longint;
{ ��� ������� - ����� ����� �������, ��������
  � ���������� �������� ������ � ����������� �������
  ������������� (0 - ������������� ���) }
begin
  Result := (Ord(sName[1])
          + Ord(sName[(Length(sName)+1) div 2])
          + Ord(sName[Length(sName)]) - HASH_MIN
          + iNum*REHASH1 mod REHASH2)
            mod (HASH_MAX-HASH_MIN+1) + HASH_MIN;
  if Result < HASH_MIN then Result := HASH_MIN;
end;

procedure InitHashVar;
{ ��������� ������������� ���-������� -
  ��� �������� ������ }
var i : integer;
begin
  for i:=HASH_MIN to HASH_MAX do HashArray[i] := nil;
end;

procedure ClearHashVar;
{ ������������ ������ ��� ���� ��������� ���-������� }
var i : integer;
begin
  for i:=HASH_MIN to HASH_MAX do
  begin
    HashArray[i].Free;
    HashArray[i] := nil;
  end;
end;

procedure ClearHashInfo;
{ �������� �������������� ���������� ��� ����
  ��������� ���-������� }
var i : integer;
begin
  for i:=HASH_MIN to HASH_MAX do
   if HashArray[i] <> nil then HashArray[i].ClearInfo;
end;

function AddHashVar(const sName: string): TVarInfo;
{ ���������� �������� � ���-������� }
var i,iHash: integer;
begin
  Result := nil;
  { �������� ������� ���������� ��������� }
  iCmpCount := 0;
  for i:=0 to REHASH2-1 do
  { ���� ��� ������������� (0 - ������������� ���) }
  begin
    { ��������� ���-����� � ������� ���-������� }
    iHash := VarHash(Upper(sName),i);
    { ���������, ��� ������� ���-������� �� ����� }
    if HashArray[iHash] = nil then
    begin
      { ���� ������ ��������, ������� ������� �
        �������� ��� � ������� }
      Result := TVarInfo.Create(sName);
      HashArray[iHash] := Result;
      { ���� ������������� �������� }
      Break;
    end;
    { ����������� ������� ��������� }
    Inc(iCmpCount);
    { ���������, �� ��������� �� ��� ��������
      � �������� ������ }
    if Upper(HashArray[iHash].VarName) = Upper(sName) then
    begin
      { ���� ���������, �� ����� ������� ��� ���� � ����
        ������������� �������� }
      Result := HashArray[iHash];
      Break;
    end;
    { ����� ��������� � ��������� �������� ����� }
  end;
  { ���� ���� ������������� ����������, �� �������
    �������� ���������� }
end;

function GetHashVar(const sName: string): TVarInfo;
{ ����� �������� � ���-������� }
var i,iHash: integer;
begin
  Result := nil;
  { �������� ������� ���������� ��������� }
  iCmpCount := 0;
  for i:=0 to REHASH2-1 do
  { ���� ��� ������������� (0 - ������������� ���) }
  begin
    { ��������� ���-����� � ������� ���-������� }
    iHash := VarHash(Upper(sName),i);
    { ���� ������ ��������, �� ������ ��������
      � ������� ��� }
    if HashArray[iHash] = nil then Break;
    { ����������� ������� ��������� }
    Inc(iCmpCount);
    { ���������� ��� �������� � ������� ������� }
    if Upper(HashArray[iHash].VarName) = Upper(sName) then
    begin
      { ���� ������ ��������� - ������� -������ }
      Result := HashArray[iHash];
      Break;
    end;
    { ����� ��������� � ��������� �������� ����� }
  end;
end;

initialization
{ ����� ��������� ������������� �������
  ��� �������� ������ }
  InitHashVar;

finalization
{ ����� ������������ ������ ������� ��� �������� ������ }
  ClearHashVar;

end.
