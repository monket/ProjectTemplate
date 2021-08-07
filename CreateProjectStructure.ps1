param([String]$projectName, [String]$parentDirectory="C:\Dev\Scratch\")

$originalDirectory = Get-Location

Set-Location -Path $parentDirectory
New-Item -Path $parentDirectory -Name $projectName -ItemType "directory"
Set-Location -Path ".\$projectName"
New-Item -Path ".\" -Name "config" -ItemType "directory"

dotnet new sln -n $projectName
dotnet new web -n $projectName -o ".\src\$projectName" -lang c# -f net5.0
dotnet new xunit -n "$projectName.Tests" -o ".\test\$projectName.Tests" -f net5.0
dotnet new xunit -n "$projectName.Acceptance.Tests" -o ".\test\$projectName.Acceptance.Tests" -f net5.0

Remove-Item -Path ".\test\$projectName.Tests\UnitTest1.cs"
Remove-Item -Path ".\test\$projectName.Acceptance.Tests\UnitTest1.cs"
New-Item -Path ".\readme.md"
Add-Content -Path ".\readme.md" "# $projectName"

dotnet add ".\test\$projectName.Tests\$projectName.Tests.csproj" reference ".\src\$projectName\$projectName.csproj"
dotnet add ".\test\$projectName.Tests\$projectName.Tests.csproj" package "AutoFixture.AutoMoq"
dotnet add ".\test\$projectName.Acceptance.Tests\$projectName.Acceptance.Tests.csproj" package "AutoFixture.AutoMoq"
dotnet add ".\test\$projectName.Acceptance.Tests\$projectName.Acceptance.Tests.csproj" package "Xbehave"

dotnet tool install --global dotnet-giio --version 1.0.2
dotnet giio generate visualstudio

$projectGuid = '{2150E333-8FDC-42A3-9474-1A3956D46DE8}'
$solutionItemsGuid = '{'+[guid]::NewGuid().ToString()+'}'
$configFolderGuid = '{'+[guid]::NewGuid().ToString()+'}'
Add-Content -Path ".\$projectName.sln" "`nProject(`"$projectGuid`") = `"SolutionItems`", `"SolutionItems`", `"$solutionItemsGuid`"
ProjectSection(SolutionItems) = preProject
    .gitignore = .gitignore
    readme.md = readme.md
EndProjectSection
EndProject
Project(`"$projectGuid`") = `"config`", `"config`", `"$configFolderGuid`"
EndProject"

dotnet sln "$projectName.sln" add ".\src\$projectName"
dotnet sln "$projectName.sln" add ".\test\$projectName.Tests"
dotnet sln "$projectName.sln" add ".\test\$projectName.Acceptance.Tests"

dotnet clean
dotnet restore
dotnet build

git config --global init.defaultBranch main
git init

Set-Location $originalDirectory