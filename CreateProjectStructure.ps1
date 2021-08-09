param([String]$projectName, [String]$projectType="worker", [String]$parentDirectory="C:\Dev\Scratch\", [bool]$pushToGitHub=$False)

$originalDirectory = Get-Location

Set-Location -Path $parentDirectory
New-Item -Path $parentDirectory -Name $projectName -ItemType "directory"
Set-Location -Path ".\$projectName"
New-Item -Path ".\" -Name "config" -ItemType "directory"

dotnet new sln -n $projectName
dotnet new $projectType -n $projectName -o ".\src\$projectName" -lang c# -f net5.0
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

git init
git add .
git commit -m "Initial commit"
git branch -m main

if ($pushToGitHub) {
    gh repo create --public
    git push --set-upstream origin main    
}

Set-Location $originalDirectory