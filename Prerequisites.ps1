Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm
Install-PackageProvider NuGet -Force
Import-PackageProvider NuGet -Force

dotnet tool install --global dotnet-giio --version 1.0.2

PowerShellGet\Install-Module posh-sshell -Scope CurrentUser
Add-PoshSshellToProfile -AllHosts

choco install gh