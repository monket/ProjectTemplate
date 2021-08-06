param([String]$projectName, [String]$parentDirectory="C:\Dev\Scratch\")

$originalDirectory = Get-Location

Set-Location -Path $parentDirectory
New-Item -Path $parentDirectory -Name $projectName -ItemType "directory"
Set-Location -Path ".\$projectName"

dotnet new sln -n $projectName
dotnet new web -n $projectName -o ".\src\$projectName" -lang c# -f net5.0
dotnet new xunit -n "$projectName.Tests" -o ".\test\$projectName.Tests" -f net5.0
dotnet new xunit -n "$projectName.Acceptance.Tests" -o ".\test\$projectName.Acceptance.Tests" -f net5.0

dotnet add ".\test\$projectName.Tests\$projectName.Tests.csproj" reference ".\src\$projectName\$projectName.csproj"
dotnet add ".\test\$projectName.Tests\$projectName.Tests.csproj" package "AutoFixture.AutoMoq"
dotnet add ".\test\$projectName.Acceptance.Tests\$projectName.Acceptance.Tests.csproj" package "AutoFixture.AutoMoq"
dotnet add ".\test\$projectName.Acceptance.Tests\$projectName.Acceptance.Tests.csproj" package "Xbehave"

dotnet sln "$projectName.sln" add ".\src\$projectName"
dotnet sln "$projectName.sln" add ".\test\$projectName.Tests"

dotnet tool install --global dotnet-giio --version 1.0.2
dotnet giio generate visualstudio

dotnet clean
dotnet restore
dotnet build

git config --global init.defaultBranch main
git init

Set-Location $originalDirectory