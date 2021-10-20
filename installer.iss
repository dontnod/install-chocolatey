#define ApplicationFullName "InstallChocolatey"
#define ApplicationName "InstallChocolatey"
#define ApplicationPublisher "Dontnod Entertainment"

#define Configuration "Release"
#define Platform "x64"
#define BuildDirectory "bootstrapper/bin/" + Configuration + "/net48"
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

[Files]
Source: "{#BuildDirectory}/bootstrapper.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildDirectory}/chocolatey.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildDirectory}/log4net.dll"; DestDir: "{app}"; Flags: ignoreversion

[Run]
Filename: "{app}\bootstrapper.exe"; Flags: runascurrentuser runhidden
