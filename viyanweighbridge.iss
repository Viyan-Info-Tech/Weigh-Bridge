; ============================================================
; Viyan Weighbridge - Windows Installer
; ============================================================

#define MyAppName "Viyan Weighbridge"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Viyan Infotech"
#define MyAppExeName "weighbridge.exe"

; Flutter Windows Release folder
#define MyAppSource "G:\Flutter\Weigh-Bridge\build\windows\x64\runner\Release"


; ============================================================
; SETUP
; ============================================================

[Setup]

AppId={{1896D297-5D97-4C73-B535-8CD23A53AD99}

AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName={autopf}\{#MyAppName}

UninstallDisplayIcon={app}\{#MyAppExeName}

; 64-bit Windows
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; Install for all Windows users
PrivilegesRequired=admin

; Don't show Start Menu group selection
DisableProgramGroupPage=yes

; Installer output folder
OutputDir=G:\Flutter\Weigh-Bridge\installer_output

; Installer file name
OutputBaseFilename=Weighbridge_Setup-1.0.0

; Compression
Compression=lzma
SolidCompression=yes

; Modern installer UI
WizardStyle=modern


; ============================================================
; LANGUAGE
; ============================================================

[Languages]

Name: "english"; MessagesFile: "compiler:Default.isl"


; ============================================================
; TASKS
; ============================================================

[Tasks]

; Desktop shortcut
Name: "desktopicon"; \
    Description: "{cm:CreateDesktopIcon}"; \
    GroupDescription: "{cm:AdditionalIcons}"; \
    Flags: unchecked


; ============================================================
; APPLICATION FILES
; ============================================================

[Files]

; Copy EVERYTHING from Flutter Windows Release folder.
; This preserves the required Flutter data folder structure.

Source: "{#MyAppSource}\*"; \
    DestDir: "{app}"; \
    Flags: ignoreversion recursesubdirs createallsubdirs


; ============================================================
; SHORTCUTS
; ============================================================

[Icons]

; Start Menu shortcut
Name: "{autoprograms}\{#MyAppName}"; \
    Filename: "{app}\{#MyAppExeName}"

; Desktop shortcut
Name: "{autodesktop}\{#MyAppName}"; \
    Filename: "{app}\{#MyAppExeName}"; \
    Tasks: desktopicon


; ============================================================
; RUN APPLICATION AFTER INSTALLATION
; ============================================================

[Run]

Filename: "{app}\{#MyAppExeName}"; \
    Description: "Launch {#MyAppName}"; \
    Flags: nowait postinstall skipifsilent