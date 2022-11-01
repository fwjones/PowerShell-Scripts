﻿<#
.SYNOPSIS
	Configures Git 
.DESCRIPTION
	This PowerShell script configures the user settings for Git.
.PARAMETER FullName
	Specifies the user's full name
.PARAMETER EmailAddress
	Specifies the user's email address
.PARAMETER FavoriteEditor
	Specifies the user's favorite text editor
.EXAMPLE
	PS> ./configure-git
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz | License: CC0
#>

param([string]$FullName = "", [string]$EmailAddress = "", [string]$FavoriteEditor = "")

try {
	$StopWatch = [system.diagnostics.stopwatch]::startNew()
		
	Write-Host "⏳ (1/5) Searching for Git executable...  " -noNewline
	& git --version
	if ($lastExitCode -ne "0") { throw "Can't execute 'git' - make sure Git is installed and available" }

	"⏳ (2/5) Asking for details..."
	if ($FullName -eq "") { $FullName = read-host "Enter your full name" }
	if ($EmailAddress -eq "") { $EmailAddress = read-host "Enter your e-mail address"}
	if ($FavoriteEditor -eq "") { $FavoriteEditor = read-host "Enter your favorite text editor (atom,emacs,nano,subl,vi,vim,...)" }

	"⏳ (3/5) Saving personal settings (name,email,editor)..."
	& git config --global user.name $FullName
	& git config --global user.email $EmailAddress
	& git config --global core.editor $FavoriteEditor
	if ($lastExitCode -ne "0") { throw "'git config' failed with exit code $lastExitCode" }

	"⏳ (4/5) Saving basic settings (autocrlf,symlinks,longpaths,etc.)..."
	& git config --global core.autocrlf false          # don't change newlines
	& git config --global core.symlinks true           # enable support for symbolic link files
	& git config --global core.longpaths true          # enable support for long file paths
	& git config --global http.sslVerify false
	& git config --global init.defaultBranch main      # set the default branch name to 'main'
	& git config --global merge.renamelimit 99999
	& git config --global pull.rebase false
	& git config --global fetch.parallel 0             # enable parallel fetching to improve the speed
	if ($lastExitCode -ne "0") { throw "'git config' failed with exit code $lastExitCode" }

	"⏳ (5/5) Saving shortcut settings (co,br,ci,st,pl,ps,mrg,chp,ls,smu)..."
	& git config --global alias.co "checkout"
	& git config --global alias.br "branch"
	& git config --global alias.ci "commit"
	& git config --global alias.st "status"
	& git config --global alias.pl "pull --recurse-submodules"
	& git config --global alias.ps "push"
	& git config --global alias.mrg "merge --no-commit --no-ff"
	& git config --global alias.chp "cherry-pick --no-commit"
	& git config --global alias.ls "log -n20 --pretty=format:'%Cred%h%Creset%C(yellow)%d%Creset %s %C(bold blue)by %an%Creset %C(green)%cr%Creset' --abbrev-commit"
	& git config --global alias.smu "submodule update --init"
	if ($lastExitCode -ne "0") { throw "'git config' failed" }

	[int]$Elapsed = $StopWatch.Elapsed.TotalSeconds
	"✔️ saved your Git configuration in $Elapsed sec, it's now:"

	& git config --list
	if ($lastExitCode -ne "0") { throw "'git config --list' failed with exit code $lastExitCode" }
	exit 0 # success
} catch {
	"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber)): $($Error[0])"
	exit 1
}