﻿<#
.SYNOPSIS
	Switches the Git branch
.DESCRIPTION
	This PowerShell script switches to the given branch in a Git repository and also updates the submodules.
.PARAMETER branchName
	Specifies the Git branch name to switch to
.PARAMETER pathToRepo
	Specifies the file path to the local Git repository
.EXAMPLE
	PS> ./switch-branch main 
	⏳ (1/6) Searching for Git executable...   git version 2.43.0.windows.1
	⏳ (2/6) Checking local repository...      C:\Repos\rust
	⏳ (3/6) Fetching remote updates...
	⏳ (4/6) Switching to branch 'main'...
	⏳ (5/6) Pulling remote updates...
	⏳ (6/6) Updating submodules...
	✅ Switched 📂rust repo to 'main' branch in 22s.
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz | License: CC0
#>

param([string]$branchName = "", [string]$pathToRepo = "$PWD")

try {
	if ($branchName -eq "") { $branchName = Read-Host "Enter the branch name to switch to" }

	$stopWatch = [system.diagnostics.stopwatch]::startNew()

	Write-Host "⏳ (1/6) Searching for Git executable...   " -noNewline
	& git --version
	if ($lastExitCode -ne "0") { throw "Can't execute 'git' - make sure Git is installed and available" }

	Write-Host "⏳ (2/6) Checking local repository...      $pathToRepo"
	if (-not(Test-Path "$pathToRepo" -pathType container)) { throw "Can't access repo folder: $pathToRepo" }
	$result = (git -C "$pathToRepo" status)
	if ($lastExitCode -ne "0") { throw "'git status' in $pathToRepo failed with exit code $lastExitCode" }
	if ("$result" -notmatch "nothing to commit, working tree clean") { throw "Git repository is NOT clean: $result" }
	$repoDirName = (Get-Item "$pathToRepo").Name

	Write-Host "⏳ (3/6) Fetching remote updates...        " -noNewline
	& git -C "$pathToRepo" remote get-url origin
        if ($lastExitCode -ne "0") { throw "'git remote get-url origin' failed with exit code $lastExitCode" }

	& git -C "$pathToRepo" fetch --all --prune --prune-tags --force
	if ($lastExitCode -ne "0") { throw "'git fetch' failed with exit code $lastExitCode" }

	"⏳ (4/6) Switching to branch '$branchName'..."
	& git -C "$pathToRepo" checkout --recurse-submodules "$branchName"
	if ($lastExitCode -ne "0") { throw "'git checkout $branchName' failed with exit code $lastExitCode" }

	"⏳ (5/6) Pulling remote updates..."
	& git -C "$pathToRepo" pull --recurse-submodules
	if ($lastExitCode -ne "0") { throw "'git pull' failed with exit code $lastExitCode" }

	"⏳ (6/6) Updating submodules..."	
	& git -C "$pathToRepo" submodule update --init --recursive
	if ($lastExitCode -ne "0") { throw "'git submodule update' failed with exit code $lastExitCode" }

	[int]$elapsed = $stopWatch.Elapsed.TotalSeconds
	"✅ Switched 📂$repoDirName repo to '$branchName' branch in $($elapsed)s."
	exit 0 # success
} catch {
	"⚠️ Error: $($Error[0]) in script line $($_.InvocationInfo.ScriptLineNumber)"
	exit 1
}