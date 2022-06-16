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
    { Счетчик поиска и переменные для хранения суммарных результатов поиска }
    iCountNum,iCountHash,iCountTree: integer;
    { Процедура поиска заданной строки }
    procedure SearchStr(const sSearch: string);
    { Процедура вывода на экран статистической информации о поиске переписана }
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
  { Начальная инициализация таблиц и счетчиков }
  InitTreeVar;
  InitHashVar;
  //iCountNum := 0;
  //iCountHash := 0;
  //iCountTree := 0;
end;

procedure TLab1Form.FormClose();
begin
  { Освобождение памяти таблиц при выходе из программы }
  ClearTreeVar;
  ClearHashVar;
end;

procedure TLab1Form.EditFileChange();
begin
  { Можно читать файл, только когда его имя не пустое }
   if DataFileName <> '' then FileLoad(DataFileName);
end;

procedure TLab1Form.ViewStatistic(iTree,iHash: integer);
{ Вывод на экран статистической информации о поиске }
begin
  write(Format('Всего поиск: %d раз',[iCountNum]));
  write(Format('Сравнений рехэширование: %d',[iHash]));
  write(Format('Сравнений ветвление: %d',[iTree]));
  write(Format('Всего сравнений рехэширование: %d',[iCountHash]));
  write(Format('Всего сравнений ветвление: %d',[iCountTree]));
  if iCountNum > 0 then
  begin
    write(Format('В среднем сравнений рехэширование: %.2f',[iCountHash/iCountNum]));
    write(Format('В среднем сравнений ветвление: %.2f',[iCountTree/iCountNum]));
  end
  else
  begin
    write(Format('В среднем сравнений рехэширование: %.2f',[0.0]));
    write(Format('В среднем сравнений ветвление: %.2f',[0.0]));
  end;
end;


procedure TLab1Form.FileLoad(Sender: string);
var
  sTmp: string[32]; // буфер для чтения из файла
  f: TextFile; // файл
  fName: string[80]; // имя файла
begin
  { Чтение файла }
  fName := Sender; AssignFile(f, fName);
//{$I-}
  Reset(f); // открыть для чтения
//{$I+}
  if IOResult <> 0 then
  begin
    write('Ошибка доступа к файлу ' + fName); exit;
  end;
  { Очищаем обе таблицы и счетчики }
  //ClearTreeVar;
  //ClearHashVar;
  //iCountNum := 0;
  //iCountHash := 0;
  //iCountTree := 0;
  { Просматриваем все строки прочитанного файла,
    считая каждую строку идентификатором }
  while not EOF(f) do
  begin
    readln(f, sTmp); write(sTmp);// прочитать строку из файла
    { Убираем незначащие пробелы в начале и в конце строки }
    if sTmp <> '' then { пустую строку пропускаем }
    begin
      { Увеличиваем счетчик считанных идентификаторов }
      Inc(iCountNum);
      { Добавляем идентификатор в дерево
        и увеличиваем счетчик сделанных сравнений }
      if AddTreeVar(sTmp) = nil then
        write(Format('Ошибка добавления идентификатора "%s" в дерево!',[sTmp]));
      Inc(iCountTree,GetTreeCount);
      { Добавляем идентификатор в таблицу рехэширования
        и увеличиваем счетчик сделанных сравнений }
      if AddHashVar(sTmp) = nil then
       write(Format('Ошибка рехэширования идентификатора "%s"!',[sTmp]));
      Inc(iCountHash,GetHashCount);
    end;
    //Strings[i] := sTmp;
  end{for};

  CloseFile(f); // закрыть файл
  write(Format('Считано %d идентификаторов',[iCountNum]));
  { Заполняем информацию о статистике сравнений для считанного файла }
  write('Поиск не проводился (рехэширование/ветвления)');
  ViewStatistic(0,0);

  { Поиск можно вести только для непустых строк }
  //BtnSearch.Enabled := (ListIdents.Lines.Count>0) and (Trim(EditSearch.Text)<>'');
end;

procedure TLab1Form.SearchFilename(Sender: string);
begin
  { Поиск можно вести только для непустых строк }
  if Trim(Sender)<>'' then FileLoad(Sender);
end;

procedure TLab1Form.SearchStr(const sSearch: string);
{ Поиск заданной строки }
begin
  { Ищем строку в дереве }
  if GetHashVar(sSearch) = nil then
   write('Идентификатор не найден')
  else
   write('Идентификатор найден');
  { Увеличиваем счетчик поиска }
  Inc(iCountHash,GetHashCount);
  { Ищем ту же самую строку в таблице рехэширования }
  if GetTreeVar(sSearch) = nil then
   write('Идентификатор не найден')
  else
   write('Идентификатор найден');
  { Увеличиваем счетчик поиска }
  Inc(iCountTree,GetTreeCount);
end;

procedure TLab1Form.BtnSearchClick(Sender: string);
var
  sSearch: string;
begin
  { Увеличиваем счетчик вызова поиска }
  Inc(iCountNum);
  { Убираем незначащие пробелы в начале и в конце искомой строки }
  sSearch := Trim(Sender);
  { Выполняем поиск идентификатора в обеих таблицах }
  SearchStr(sSearch);
  { Заполняем статистические данные }
  ViewStatistic(GetTreeCount,GetHashCount);
end;

procedure TLab1Form.AllSearchClick(Sender: TObject);
{ Авто-поиск всех подряд идентификаторов из списка }
var
  i,iAllTree,iAllHash: integer;
begin
  { Запоминаем текущие счетчики сравнений }
  iAllTree := iCountTree;
  iAllHash := iCountHash;

  with ListIdents.Lines do
  begin
    { Выполняем операцию поиска для каждой непустой строки }
    for i:=Count-1 downto 0 do
     if Strings[i] <> '' then
     begin
       { Увеличиваем счетчик операций поиска }
       Inc(iCountNum);
       { Выполняем поиск }
       SearchStr(Strings[i]);
     end;
  end;
  { Заполняем статистические данные }
  ViewStatistic(iCountTree-iAllTree,iCountHash-iAllHash);
end;

procedure TLab1Form.BtnResetClick();
begin
  { Обнуление статистической информации по кнопке "Сброс" }
  iCountNum := 0;
  iCountHash := 0;
  iCountTree := 0;
  { Заполняем статистические данные }
  write('Поиск не проводился');
  write('Поиск не проводился');
  ViewStatistic(0,0);
end;

procedure TLab1Form.ExitCom();
begin
  { Выход из программы }
  exit;
end;

end.
