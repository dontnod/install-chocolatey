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
Name: "chocolateygui"; Description: "Graphical Interface for Chocolatey"; Types: custom full

[Files]
Source: "{#BuildDirectory}/bootstrapper.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildDirectory}/chocolatey.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildDirectory}/log4net.dll"; DestDir: "{app}"; Flags: ignoreversion

[Run]
Filename: "{app}\bootstrapper.exe"; Parameters: "upgrade -y --force chocolatey"; \
    Flags: runascurrentuser runhidden; Components: chocolatey
Filename: "{app}\bootstrapper.exe"; Parameters: "upgrade -y --force chocolateygui"; \
    Flags: runascurrentuser runhidden; Components: chocolateygui
