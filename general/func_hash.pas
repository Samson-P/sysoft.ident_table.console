unit func_hash;

interface
{ Модуль, обеспечивающий работу с таблицей идентификаторов,
  построенной на основе хэш-функции и рехэширования
  с помощью генератора псевдослучайных чисел }

uses table_element;

{ Функция начальной инициализации хэш-таблицы }
procedure InitHashVar;
{ Функция освобождения памяти хэш-таблицы }
procedure ClearHashVar;
{ Функция удаления дополнительной информации в таблице }
procedure ClearHashInfo;
{ Добавление элемента в таблицу идентификаторов }
function AddHashVar(const sName: string): TVarInfo;
{ Поиск элемента в таблице идентификаторов }
function GetHashVar(const sName: string): TVarInfo;
{ Функция, возвращающая количество операций сравнения }
function GetHashCount: integer;

implementation

const
{ Минимальный и максимальный элементы хэш-таблицы
 (охватывают весь диапазон значений хэш-функции) }
  HASH_MIN = Ord('0')+Ord('0')+Ord('0');
  HASH_MAX = Ord('z')+Ord('z')+Ord('z');
{ Константы для генератора псевдослучайных чисел,
  два простых числа: большее - ближайшее простое число
  к размеру хэш-таблицы (размер = 223 элемента),
  а меньшее - больше, чем 1/2 от большего }
  REHASH1 = 127;
  REHASH2 = 223;

var
  HashArray : array[HASH_MIN..HASH_MAX] of TVarInfo;
{ Массив для хэш-таблицы }
  iCmpCount : integer;
{ Счетчик количества сравнений }

function GetHashCount: integer;
begin
  Result := iCmpCount;
end;

function VarHash(const sName: string;
                 iNum: integer): longint;
{ Хэш функция - сумма кодов первого, среднего
  и последнего символов строки с добавлением индекса
  рехэширования (0 - рехэширования нет) }
begin
  Result := (Ord(sName[1])
          + Ord(sName[(Length(sName)+1) div 2])
          + Ord(sName[Length(sName)]) - HASH_MIN
          + iNum*REHASH1 mod REHASH2)
            mod (HASH_MAX-HASH_MIN+1) + HASH_MIN;
  if Result < HASH_MIN then Result := HASH_MIN;
end;

procedure InitHashVar;
{ Начальная инициализация хэш-таблицы -
  все элементы пустые }
var i : integer;
begin
  for i:=HASH_MIN to HASH_MAX do HashArray[i] := nil;
end;

procedure ClearHashVar;
{ Освобождение памяти для всех элементов хэш-таблицы }
var i : integer;
begin
  for i:=HASH_MIN to HASH_MAX do
  begin
    HashArray[i].Free;
    HashArray[i] := nil;
  end;
end;

procedure ClearHashInfo;
{ Удаление дополнительной информации для всех
  элементов хэш-таблицы }
var i : integer;
begin
  for i:=HASH_MIN to HASH_MAX do
   if HashArray[i] <> nil then HashArray[i].ClearInfo;
end;

function AddHashVar(const sName: string): TVarInfo;
{ Добавление элемента в хэш-таблицу }
var i,iHash: integer;
begin
  Result := nil;
  { Обнуляем счетчик количества сравнений }
  iCmpCount := 0;
  for i:=0 to REHASH2-1 do
  { Цикл для рехэширования (0 - рехэширования нет) }
  begin
    { Вычисляем хэш-адрес с помощью хэш-функции }
    iHash := VarHash(Upper(sName),i);
    { Проверяем, что элемент хэш-таблицы не занят }
    if HashArray[iHash] = nil then
    begin
      { Если ячейка свободна, создаем элемент и
        помещаем его в таблицу }
      Result := TVarInfo.Create(sName);
      HashArray[iHash] := Result;
      { Цикл рехэширования закончен }
      Break;
    end;
    { Увеличиваем счетчик сравнений }
    Inc(iCmpCount);
    { Проверяем, не совпадает ли имя элемента
      с заданным именем }
    if Upper(HashArray[iHash].VarName) = Upper(sName) then
    begin
      { Если совпадает, то такой элемент уже есть и цикл
        рехэширования закончен }
      Result := HashArray[iHash];
      Break;
    end;
    { Иначе переходим к следующей итерации цикла }
  end;
  { Если цикл рехэширования завершился, то элемент
    добавить невозможно }
end;

function GetHashVar(const sName: string): TVarInfo;
{ Поиск элемента в хэш-таблице }
var i,iHash: integer;
begin
  Result := nil;
  { Обнуляем счетчик количества сравнений }
  iCmpCount := 0;
  for i:=0 to REHASH2-1 do
  { Цикл для рехэширования (0 - рехэширования нет) }
  begin
    { Вычисляем хэш-адрес с помощью хэш-функции }
    iHash := VarHash(Upper(sName),i);
    { Если ячейка свободна, то такого элемента
      в таблице нет }
    if HashArray[iHash] = nil then Break;
    { Увеличиваем счетчик сравнений }
    Inc(iCmpCount);
    { Сравниваем имя элемента с искомой строкой }
    if Upper(HashArray[iHash].VarName) = Upper(sName) then
    begin
      { Если строки совпадают - элемент -найден }
      Result := HashArray[iHash];
      Break;
    end;
    { Иначе переходим к следующей итерации цикла }
  end;
end;

initialization
{ Вызов начальной инициализации таблицы
  при загрузке модуля }
  InitHashVar;

finalization
{ Вызов освобождения памяти таблицы при выгрузке модуля }
  ClearHashVar;

end.
