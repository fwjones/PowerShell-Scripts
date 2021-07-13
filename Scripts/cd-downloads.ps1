﻿<#
.SYNOPSIS
	cd-downloads.ps1 
.DESCRIPTION
	go to the user's downloads folder
.EXAMPLE
	PS> .\cd-downloads.ps1 
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz / License: CC0
#>

$TargetDir = resolve-path "$HOME/Downloads"
if (-not(test-path "$TargetDir" -pathType container)) {
	write-warning "Sorry, there is no folder 📂$TargetDir (yet)"
	exit 1
}
set-location "$TargetDir"
"📂$TargetDir"
exit 0
