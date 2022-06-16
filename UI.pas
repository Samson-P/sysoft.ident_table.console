unit UI;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Vcl.StdCtrls;

type
  TLab1Form = class(TObject)
    DataFileName: string;
    EditSearch: string;
    BtnSearch: string;
    ListIdents: TMemo;
    BtnExit: string;
    BtnReset: string;
    BtnAllSearch: string;
    BtnFile: string;
    procedure FormCreate();
    procedure EditFileChange();
    procedure FileLoad(Sender: string);
    procedure SearchFilename(Sender: string);
    procedure ExitCom();
    procedure BtnSearchClick(Sender: string);
    procedure BtnResetClick();
    procedure AllSearchClick(Sender: TObject);
    procedure FormClose();
   private
    { ������� ������ � ���������� ��� �������� ��������� ����������� ������ }
    iCountNum,iCountHash,iCountTree: integer;
    { ��������� ������ �������� ������ }
    procedure SearchStr(const sSearch: string);
    { ��������� ������ �� ����� �������������� ���������� � ������ ���������� }
    procedure ViewStatistic(iTree,iHash: integer);
   public
    { Public declarations }
  end;

var
  Lab1Form: TLab1Form;

implementation

//{$R *.DFM}

uses func_tree, func_hash;

procedure TLab1Form.FormCreate();
begin
  { ��������� ������������� ������ � ��������� }
  InitTreeVar;
  InitHashVar;
  //iCountNum := 0;
  //iCountHash := 0;
  //iCountTree := 0;
end;

procedure TLab1Form.FormClose();
begin
  { ������������ ������ ������ ��� ������ �� ��������� }
  ClearTreeVar;
  ClearHashVar;
end;

procedure TLab1Form.EditFileChange();
begin
  { ����� ������ ����, ������ ����� ��� ��� �� ������ }
   if DataFileName <> '' then FileLoad(DataFileName);
end;

procedure TLab1Form.ViewStatistic(iTree,iHash: integer);
{ ����� �� ����� �������������� ���������� � ������ }
begin
  write(Format('����� �����: %d ���',[iCountNum]));
  write(Format('��������� �������������: %d',[iHash]));
  write(Format('��������� ���������: %d',[iTree]));
  write(Format('����� ��������� �������������: %d',[iCountHash]));
  write(Format('����� ��������� ���������: %d',[iCountTree]));
  if iCountNum > 0 then
  begin
    write(Format('� ������� ��������� �������������: %.2f',[iCountHash/iCountNum]));
    write(Format('� ������� ��������� ���������: %.2f',[iCountTree/iCountNum]));
  end
  else
  begin
    write(Format('� ������� ��������� �������������: %.2f',[0.0]));
    write(Format('� ������� ��������� ���������: %.2f',[0.0]));
  end;
end;


procedure TLab1Form.FileLoad(Sender: string);
var
  sTmp: string[32]; // ����� ��� ������ �� �����
  f: TextFile; // ����
  fName: string[80]; // ��� �����
begin
  { ������ ����� }
  fName := Sender; AssignFile(f, fName);
//{$I-}
  Reset(f); // ������� ��� ������
//{$I+}
  if IOResult <> 0 then
  begin
    write('������ ������� � ����� ' + fName); exit;
  end;
  { ������� ��� ������� � �������� }
  //ClearTreeVar;
  //ClearHashVar;
  //iCountNum := 0;
  //iCountHash := 0;
  //iCountTree := 0;
  { ������������� ��� ������ ������������ �����,
    ������ ������ ������ ��������������� }
  while not EOF(f) do
  begin
    readln(f, sTmp); write(sTmp);// ��������� ������ �� �����
    { ������� ���������� ������� � ������ � � ����� ������ }
    if sTmp <> '' then { ������ ������ ���������� }
    begin
      { ����������� ������� ��������� ��������������� }
      Inc(iCountNum);
      { ��������� ������������� � ������
        � ����������� ������� ��������� ��������� }
      if AddTreeVar(sTmp) = nil then
        write(Format('������ ���������� �������������� "%s" � ������!',[sTmp]));
      Inc(iCountTree,GetTreeCount);
      { ��������� ������������� � ������� �������������
        � ����������� ������� ��������� ��������� }
      if AddHashVar(sTmp) = nil then
       write(Format('������ ������������� �������������� "%s"!',[sTmp]));
      Inc(iCountHash,GetHashCount);
    end;
    //Strings[i] := sTmp;
  end{for};

  CloseFile(f); // ������� ����
  write(Format('������� %d ���������������',[iCountNum]));
  { ��������� ���������� � ���������� ��������� ��� ���������� ����� }
  write('����� �� ���������� (�������������/���������)');
  ViewStatistic(0,0);

  { ����� ����� ����� ������ ��� �������� ����� }
  //BtnSearch.Enabled := (ListIdents.Lines.Count>0) and (Trim(EditSearch.Text)<>'');
end;

procedure TLab1Form.SearchFilename(Sender: string);
begin
  { ����� ����� ����� ������ ��� �������� ����� }
  if Trim(Sender)<>'' then FileLoad(Sender);
end;

procedure TLab1Form.SearchStr(const sSearch: string);
{ ����� �������� ������ }
begin
  { ���� ������ � ������ }
  if GetHashVar(sSearch) = nil then
   write('������������� �� ������')
  else
   write('������������� ������');
  { ����������� ������� ������ }
  Inc(iCountHash,GetHashCount);
  { ���� �� �� ����� ������ � ������� ������������� }
  if GetTreeVar(sSearch) = nil then
   write('������������� �� ������')
  else
   write('������������� ������');
  { ����������� ������� ������ }
  Inc(iCountTree,GetTreeCount);
end;

procedure TLab1Form.BtnSearchClick(Sender: string);
var
  sSearch: string;
begin
  { ����������� ������� ������ ������ }
  Inc(iCountNum);
  { ������� ���������� ������� � ������ � � ����� ������� ������ }
  sSearch := Trim(Sender);
  { ��������� ����� �������������� � ����� �������� }
  SearchStr(sSearch);
  { ��������� �������������� ������ }
  ViewStatistic(GetTreeCount,GetHashCount);
end;

procedure TLab1Form.AllSearchClick(Sender: TObject);
{ ����-����� ���� ������ ��������������� �� ������ }
var
  i,iAllTree,iAllHash: integer;
begin
  { ���������� ������� �������� ��������� }
  iAllTree := iCountTree;
  iAllHash := iCountHash;

  with ListIdents.Lines do
  begin
    { ��������� �������� ������ ��� ������ �������� ������ }
    for i:=Count-1 downto 0 do
     if Strings[i] <> '' then
     begin
       { ����������� ������� �������� ������ }
       Inc(iCountNum);
       { ��������� ����� }
       SearchStr(Strings[i]);
     end;
  end;
  { ��������� �������������� ������ }
  ViewStatistic(iCountTree-iAllTree,iCountHash-iAllHash);
end;

procedure TLab1Form.BtnResetClick();
begin
  { ��������� �������������� ���������� �� ������ "�����" }
  iCountNum := 0;
  iCountHash := 0;
  iCountTree := 0;
  { ��������� �������������� ������ }
  write('����� �� ����������');
  write('����� �� ����������');
  ViewStatistic(0,0);
end;

procedure TLab1Form.ExitCom();
begin
  { ����� �� ��������� }
  exit;
end;

end.
