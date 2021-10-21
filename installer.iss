#define ApplicationFullName "InstallChocolatey"
#define ApplicationName "InstallChocolatey"
#define ApplicationPublisher "Dontnod Entertainment"

#define Configuration "Release"
#define Platform "x64"
#define BuildDirectory "bootstrapper/bin/" + Configuration + "/net47"
#define Executable "bootstrapper.exe"

; If the application executable does not exist, GetFileVersion fails silently,
; and InnoSetup will fail with an error about needing an AppVersion directive.
#define ApplicationVersion GetVersionNumbersString(BuildDirectory + "/" + Executable)

[Setup]
AppId={#ApplicationFullName}
AppName={#ApplicationName}
AppVersion={#ApplicationVersion}
AppPublisher={#ApplicationPublisher}
DisableProgramGroupPage=yes
DefaultDirName={commonpf}\{#ApplicationName}
OutputDir="."
OutputBaseFilename={#ApplicationFullName}-{#ApplicationVersion}
Compression=lzma
PrivilegesRequired=admin
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64

DisableDirPage=yes
;SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Types]
Name: "full"; Description: "Full installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "chocolatey"; Description: "Chocolatey"; Types: custom full; Flags: fixed
Name: "chocolatey_gui"; Description: "Graphical interface for Chocolatey"; Types: custom full
Name: "custom_source"; Description: "Custom package source"; Types: custom full

[Files]
Source: "{#BuildDirectory}/bootstrapper.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildDirectory}/chocolatey.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildDirectory}/log4net.dll"; DestDir: "{app}"; Flags: ignoreversion

[Run]
Filename: "{app}\bootstrapper.exe"; Parameters: "config"; \
    Flags: runascurrentuser runhidden;
Filename: "{app}\bootstrapper.exe"; Parameters: "upgrade -y --force chocolatey"; \
    Flags: runascurrentuser runhidden; Components: chocolatey
Filename: "{app}\bootstrapper.exe"; Parameters: "upgrade -y --force chocolateygui"; \
    Flags: runascurrentuser runhidden; Components: chocolatey_gui
Filename: "{app}\bootstrapper.exe"; Parameters: "{code:get_custom_source_params}"; \
    Flags: runascurrentuser runhidden; Components: custom_source

[Code]
var
    custom_page: TInputQueryWizardPage;

procedure InitializeWizard;
begin
    custom_page := CreateInputQueryPage(wpSelectComponents,
        'Custom Package Source',
        'Add an optional package source',
        'Add a custom package source, or click "Next" to skip this step');
    custom_page.Add('Source name:', False);
    custom_page.Add('Source URL:', False);
    custom_page.Add('Login (optional):', False);
    custom_page.Add('Password (optional):', True);
end;

function NextButtonClick(page_id: Integer): Boolean;
begin
    Result := True;
    if page_id = custom_page.ID then begin
        if custom_page.Values[0] = '' then begin
          MsgBox('Package source name is empty', mbError, MB_OK);
          Result := False;
        end else if custom_page.Values[1] = '' then begin
          MsgBox('Package source URL is empty', mbError, MB_OK);
          Result := False;
        end;
    end;
end;

function ShouldSkipPage(page_id: Integer): Boolean;
begin
    Result := (page_id = custom_page.ID) and not WizardIsComponentSelected('custom_source');
end;

function get_custom_source_params(_: string): string;
begin
    Result := 'source add --name="' + custom_page.Values[0] + '"' +
                        ' --source="' + custom_page.Values[1] + '"'
    if custom_page.Values[2] <> '' then begin
        Result := Result + ' --user="' + custom_page.Values[2] + '"' +
                           ' --password="' + custom_page.Values[3] + '"'
    end;
end;
