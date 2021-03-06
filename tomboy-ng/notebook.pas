unit Notebook;

{
 * Copyright (C) 2017 David Bannon
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

{  This GUI based unit has a form to allow user to see and select what notebooks
    the current note is a member of. It looks at settings to see if we are allowing
    a particular note to be a member of more than one notebook. If not, will cancel
    a previous choice if a user selects a new notebook.

    History -
    2018/01/30 -replaced the function that cancels previous Notebook selection when
                a new one is made (if settings so demand). This one works on Macs
                and is a better job on the other platforms too.
}


{ TODO : URGENT - This needs to be rewritten so that form is created on the fly.
At present, if a user opens two notes and then opens the Notebook form for each, bad things happen. }

{$mode objfpc}{$H+}

interface

uses
		Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, CheckLst,
		ExtCtrls, StdCtrls, Buttons, ComCtrls;

type

		{ TNoteBookPick }

  TNoteBookPick = class(TForm)
				Button1: TButton;
				ButtonOK: TButton;
				CheckListBox1: TCheckListBox;
				EditNewNotebook: TEdit;
				Label1: TLabel;
				Label2: TLabel;
				Label3: TLabel;
				Label4: TLabel;
				Label5: TLabel;
				PageControl1: TPageControl;
				Panel1: TPanel;
				TabExisting: TTabSheet;
				TabNewNoteBook: TTabSheet;
				procedure ButtonOKClick(Sender: TObject);
    procedure CheckListBox1ItemClick(Sender: TObject; Index: integer);
    procedure FormShow(Sender: TObject);
    // procedure PageControl1Change(Sender: TObject);
		private

		public
	FullFileName : ANSIString;
    Title : ANSIString;
		end;

var
		NoteBookPick: TNoteBookPick;

implementation

{$R *.lfm}

{ TNoteBookPick }

uses MainUnit, LazFileUtils, Settings, SaveNote;

procedure TNoteBookPick.FormShow(Sender: TObject);
var
        SL : TStringList;
        Index, I : Integer;
begin
    Label1.Caption := Title;
    if Sett.CheckManyNotebooks.Checked then
        Label2.Caption := 'Settings allow multiple Notebooks'
    else Label2.Caption := 'Settings allow only one Notebook';
    //CheckListBox1.MultiSelect:=Sett.CheckManyNotebooks.Checked;
    Label3.Caption := 'Set the notebooks this note is a member of';
    SL := TStringList.Create;
    RTSearch.NoteLister.GetNotebooks(SL);
    CheckListBox1.Items.Assign(SL);
    SL.Free;
    SL := TStringList.Create;
    RTSearch.NoteLister.GetNotebooks(SL, ExtractFileNameOnly(FullFileName) + '.note');
    for I := 0 to CheckListBox1.Count-1 do
        CheckListBox1.Checked[I] := False;
    for Index := 0 to SL.Count -1 do
    	for I := 0 to CheckListBox1.Count-1 do
			if SL[Index] = CheckListBox1.Items[I] then
            	CheckListBox1.Checked[I] := True;
    SL.Free;
end;





procedure TNoteBookPick.CheckListBox1ItemClick(Sender: TObject; Index: integer);
var
	I : integer;
begin
    if Sett.CheckManyNotebooks.Checked then exit;
    // ensure only one clicked.
    if (Sender as TCheckListBox).Checked[Index] then begin
        for I := 0 to CheckListBox1.Count -1 do
            CheckListBox1.Checked[I] := False;
        CheckListBox1.Checked[Index] := True;
    end;
end;

procedure TNoteBookPick.ButtonOKClick(Sender: TObject);
var
        SL : TStringList;
        Index : Integer;
        Saver : TBSaveNote;
begin
    SL := TStringList.Create;
    try
        if PageControl1.ActivePage = TabExisting then begin
			for Index := 0 to CheckListBox1.Count -1 do
        		if CheckListBox1.Checked[Index] then SL.Add(CheckListBox1.Items[Index]);
    		RTSearch.NoteLister.SetNotebookMembership(ExtractFileNameOnly(FullFileName) + '.note', SL);
		end else begin
          	if EditNewNotebook.Text <> '' then begin
            	Saver := TBSaveNote.Create();
                try
                    Saver.SaveNewTemplate(EditNewNotebook.Text);
                    // OK, now add current note to the new Notebook
                    RTSearch.NoteLister.AddNoteBook(ExtractFileNameOnly(FullFileName) + '.note', EditNewNotebook.Text, False);
				finally
                	Saver.Destroy;
				end;
            end else showmessage('Enter a new Notebook Name please');
		end;
	finally
    	Sl.Free;
	end;
	ModalResult := mrOK;
end;

end.

