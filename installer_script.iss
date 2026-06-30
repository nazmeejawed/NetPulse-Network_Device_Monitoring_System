[Setup]
AppName=NetPulse
AppVersion=1.0
DefaultDirName={autopf}\NetPulse
DefaultGroupName=NetPulse
OutputDir=.\Installer
OutputBaseFilename=NetPulse_Setup
Compression=lzma
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\NetPulse"; Filename: "{app}\ping_checker.exe"
Name: "{autodesktop}\NetPulse"; Filename: "{app}\ping_checker.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"
