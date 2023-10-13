; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "LEDColor"
#define MyAppVersion "0.1.2.0"
#define MyAppPublisher "Mr.CivsteR"
#define MyCopyright "Copyright � 2023"
#define MyAppExeName "LEDColor.exe"
#define MyExcludes "*.config,*.pdb"
#define MyAppIcon "..\Graphics\icon.ico"
[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{BC1BA581-7799-475B-92C0-A35BDC71ABB2}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
; AppVerName={#MyAppName} {#MyAppVersion}
VersionInfoVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppCopyright={#MyCopyright} {#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DisableDirPage=yes
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
PrivilegesRequired=admin
OutputBaseFilename=LEDColor Installer
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64
SetupIconFile={#MyAppIcon}
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\Builds - LEDColor\Windows 64 bit\LEDColor\*"; Excludes: {#MyExcludes}; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\LEDControl\bin\Release\*"; Excludes: {#MyExcludes}; DestDir: "{app}\LEDControl"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\Defaults\ColorInfo.txt"; DestDir: "{userappdata}\LEDColor"; Flags: ignoreversion
Source: "..\Defaults\LEDColor.xml"; DestDir: "{tmp}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent runascurrentuser
Filename: "schtasks"; Parameters: "/create /tn LEDColor /xml ""{tmp}\LEDColor.xml"""

[UninstallRun]
Filename: "schtasks"; Parameters: "/delete /tn LEDColor /f"; RunOnceId: "DeleteSchedule"

[Messages]
; define wizard title and tray status msg
; both are normally defined in innosetup's default.isl (install folder)
SetupAppTitle = Setup LEDColor
SetupWindowTitle = LEDColor by {#MyAppPublisher}