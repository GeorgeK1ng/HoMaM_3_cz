; Heroes 3 Complete - Instalátor èeštiny

[Setup]
AppId=H3CzechPatcher
AppName=Heroes of Might and Magic 3 Complete – Èeština
AppVersion=1.0
DefaultDirName={code:GetDefaultGameDir}
DisableWelcomePage=no
DisableDirPage=no
DisableProgramGroupPage=yes
Uninstallable=no
OutputBaseFilename=H3_CZ_Patcher
Compression=lzma2/ultra64
SolidCompression=yes
PrivilegesRequired=admin
WizardStyle=modern
AppendDefaultDirName=no
DirExistsWarning=no
SetupIconFile=icon.ico
WizardImageFile=logo.bmp
WizardSmallImageFile=smalllogo.bmp

[Files]
; Rozbalíme vše z koøene projektu do {tmp}\h3cz\payload
Source: "*"; DestDir: "{tmp}\h3cz\payload"; Flags: recursesubdirs createallsubdirs ignoreversion
; Tyto soubory nebalit
Source: "Installer.iss"; Flags: dontcopy
Source: "import.cmd";    Flags: dontcopy

[Languages]
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"

[Code]
// ---------- Registry lookup ----------
function RegistryQueryPath(const SubKey, ValueName: string): string;
begin
  if not RegQueryStringValue(HKLM, SubKey, ValueName, Result) then
    Result := '';
end;

function FindHeroes3Install(): string;
var
  p: string;
begin
  // GOG
  p := RegistryQueryPath('SOFTWARE\GOG.com\Games\1207658787', 'path');
  if p = '' then p := RegistryQueryPath('SOFTWARE\WOW6432Node\GOG.com\Games\1207658787', 'path');
  // NWC (® varianta)
  if p = '' then p := RegistryQueryPath('SOFTWARE\New World Computing\Heroes of Might and Magic® III\1.0', 'AppPath');
  if p = '' then p := RegistryQueryPath('SOFTWARE\WOW6432Node\New World Computing\Heroes of Might and Magic® III\1.0', 'AppPath');
  // NWC (bez ®)
  if p = '' then p := RegistryQueryPath('SOFTWARE\New World Computing\Heroes of Might and Magic III\1.0', 'AppPath');
  if p = '' then p := RegistryQueryPath('SOFTWARE\WOW6432Node\New World Computing\Heroes of Might and Magic III\1.0', 'AppPath');
  Result := p;
end;

// ---------- Helpers ----------
procedure LogInfo(const S: string);
begin
  Log(S);
end;

function EnsureDir(const Path: string): Boolean;
begin
  if DirExists(Path) then begin Result := True; exit; end;
  Result := ForceDirectories(Path);
end;

function CopyAllFiles(const SrcMask, DstDir: string): Integer;
var
  FindRec: TFindRec; Src, Dst: string;
begin
  Result := 0;
  if not EnsureDir(DstDir) then exit;
  if FindFirst(SrcMask, FindRec) then
  try
    repeat
      if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then begin
        Src := AddBackslash(ExtractFileDir(SrcMask)) + FindRec.Name;
        Dst := AddBackslash(DstDir) + FindRec.Name;
        if FileCopy(Src, Dst, False) then Inc(Result);
      end;
    until not FindNext(FindRec);
  finally
    FindClose(FindRec);
  end;
end;

function DeleteMask(const Mask: string): Integer;
var
  FindRec: TFindRec; P: string;
begin
  Result := 0;
  if FindFirst(Mask, FindRec) then
  try
    repeat
      if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then begin
        P := AddBackslash(ExtractFileDir(Mask)) + FindRec.Name;
        if DeleteFile(P) then Inc(Result);
      end;
    until not FindNext(FindRec);
  finally
    FindClose(FindRec);
  end;
end;

// ---------- LOD import ----------
function RunLodImport(const LodExe, LodPath, FileToImport: string): Boolean;
var
  ResultCode: Integer; Params: string;
begin
  Params := Format('"%s" "%s"', [LodPath, FileToImport]);
  Result := Exec(LodExe, Params, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
  if not Result then
    Log(Format('WARN: lodimport failed (%d) for %s -> %s', [ResultCode, LodPath, FileToImport]));
end;

procedure PatchLods(const PayloadRoot, GameRoot: string);
var
  DataDir, LodExe, LodsDir: string;
  FR, FR2: TFindRec;
  BaseName, SubDir, LodPath, FilePath: string;
  Imported, Total, Failed, Skipped: Integer;
begin
  DataDir := PayloadRoot;
  LodExe := AddBackslash(PayloadRoot) + 'lodimport.exe';
  LodsDir := AddBackslash(GameRoot) + 'data';

  if not FileExists(LodExe) then begin
    MsgBox('Chybí lodimport.exe v payloadu!', mbError, MB_OK); exit;
  end;

  Total := 0; Failed := 0; Skipped := 0;

  if FindFirst(AddBackslash(DataDir) + '*', FR) then
  try
    repeat
      if (FR.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then begin
        BaseName := FR.Name;
        if (BaseName <> '.') and (BaseName <> '..') and (Lowercase(BaseName) <> 'maps') then begin
          SubDir := AddBackslash(DataDir) + BaseName;
          LodPath := AddBackslash(LodsDir) + BaseName + '.lod';
          if FileExists(LodPath) then begin
            LogInfo('Aktualizace: ' + LodPath);
            Imported := 0;
            if FindFirst(AddBackslash(SubDir) + '*', FR2) then
            try
              repeat
                if (FR2.Attributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then begin
                  FilePath := AddBackslash(SubDir) + FR2.Name;
                  if RunLodImport(LodExe, LodPath, FilePath) then begin
                    Inc(Imported); Inc(Total);
                  end else begin
                    Inc(Failed);
                    LogInfo('  [WARN] Selhal import: ' + FilePath);
                  end;
                end;
              until not FindNext(FR2);
            finally
              FindClose(FR2);
            end;
            LogInfo(Format('  Importováno: %d souborù.', [Imported]));
          end else begin
            LogInfo('[SKIP] Nenalezen LOD: ' + LodPath);
            Inc(Skipped);
          end;
        end;
      end;
    until not FindNext(FR);
  finally
    FindClose(FR);
  end;

  LogInfo(Format('Souhrn: TOTAL=%d, FAILED=%d, SKIPPED=%d', [Total, Failed, Skipped]));
end;

procedure UpdateMaps(const PayloadRoot, GameRoot: string);
var
  GameMaps, SrcMaps: string;
begin
  SrcMaps := AddBackslash(PayloadRoot) + 'maps';
  if not DirExists(SrcMaps) then begin
    Log('maps složka v payloadu nenalezena – pøeskoèeno.'); exit;
  end;

  GameMaps := AddBackslash(GameRoot) + 'Maps';
  if DirExists(GameMaps) then
    DelTree(GameMaps, True, True, True);
  ForceDirectories(GameMaps);

  CopyAllFiles(AddBackslash(SrcMaps) + '*', GameMaps);
end;

procedure UpdateManualsAndReadme(const PayloadRoot, GameRoot: string);
var
  pdfSrcMask, readmeSrc, readmeDst: string;
begin
  DeleteMask(AddBackslash(GameRoot) + '*.pdf');
  pdfSrcMask := AddBackslash(PayloadRoot) + '*.pdf';
  CopyAllFiles(pdfSrcMask, GameRoot);

  readmeDst := AddBackslash(GameRoot) + 'README.txt';
  if FileExists(readmeDst) then DeleteFile(readmeDst);
  readmeSrc := AddBackslash(PayloadRoot) + 'README.TXT';
  if not FileExists(readmeSrc) then
    readmeSrc := AddBackslash(PayloadRoot) + 'README.txt';
  if FileExists(readmeSrc) then
    FileCopy(readmeSrc, readmeDst, False);

  DeleteMask(AddBackslash(GameRoot) + 'gog*');
end;

// ---------- Wizard plumbing ----------
function GetDefaultGameDir(Param: string): string;
var
  p: string;
begin
  p := FindHeroes3Install();
  if p = '' then
    p := 'C:\GOG Games\HoMM 3 Complete';
  Result := p;
end;

procedure InitializeWizard();
begin
  WizardForm.SelectDirLabel.Caption :=
    'Vyber složku, kde máš nainstalovanou hru Heroes of Might and Magic III Complete.';

  // Pøedvyplò z autodetekce (když by DefaultDirName nestaèil napø. pøi ruèním návratu zpìt)
  WizardForm.DirEdit.Text := GetDefaultGameDir('');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  gameRoot, dataDir: string;
begin
  Result := True;
  if CurPageID = wpSelectDir then begin
    gameRoot := WizardDirValue;
    dataDir := AddBackslash(gameRoot) + 'data';
    if not DirExists(gameRoot) then begin
      MsgBox('Zvolená složka neexistuje.', mbError, MB_OK);
      Result := False; exit;
    end;
    if not DirExists(dataDir) then begin
      if MsgBox('Ve zvolené složce chybí podsložka "data". Jsi si jistý, že je to koøen instalace hry?',
                mbConfirmation, MB_YESNO) = IDNO then
      begin
        Result := False; exit;
      end;
    end;
  end;
end;

// Hlavní práce po rozbalení souborù do {tmp}
procedure DoPatch(const GameRoot: string);
var
  PayloadRoot: string;
begin
  PayloadRoot := ExpandConstant('{tmp}\h3cz\payload');
  Log('H3 cesta: ' + GameRoot);
  Log('Payload: ' + PayloadRoot);

  PatchLods(PayloadRoot, GameRoot);
  UpdateMaps(PayloadRoot, GameRoot);
  UpdateManualsAndReadme(PayloadRoot, GameRoot);

  Log('Hotovo! Patch byl aplikován.');
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    DoPatch(WizardDirValue);
end;
