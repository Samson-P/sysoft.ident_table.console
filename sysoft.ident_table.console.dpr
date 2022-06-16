program sysoft.ident_table.console;

{$APPTYPE CONSOLE}

uses
  UI in 'UI.pas',
  func_hash in '.\general\func_hash.pas',
  func_tree in '.\general\func_tree.pas',
  table_element in '.\general\table_element.pas';

{$R *.res}

var
  ident: string;

begin
  writeln('Lab. work 1. War10.');

  UI.Lab1Form.FormCreate();
  UI.Lab1Form.FileLoad(
    'C:\Users\samson\Documents\GitHub\sysoft.ident_table.console\data.dat');
  //UI.Lab1Form.AllSearchClick();
  write('Hello! '); read(ident);
  UI.Lab1Form.BtnSearchClick(ident);
  UI.Lab1Form.BtnResetClick();
  UI.Lab1Form.ExitCom();
end.
