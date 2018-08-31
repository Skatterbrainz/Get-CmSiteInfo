# Get-CmSiteInfo.ps1
Get CM Site Information

## .SYNOPSIS
Query Configuration Manager Database information

## .DESCRIPTION
Just what the Synopsis guy just said

## PARAMETERS

### SiteServer
[string] FQDN for ConfigMgr SQL Database server

### SiteCode
[string] Site Code

### OutputLayout
[string] Format for output: LIST, TABLE or RAW
RAW is intended for pipeline and post-processing usage
TABLE and LIST are for visual layout

### ConfigFile
[string] Path to XML configuration file. Default is cm-site-status.xml in same folder

### QueryName
[string] Specific query to run (only one at a time)

### Interactive
[switch] Display queries from config file in grid view for user selection

## EXAMPLES

### EXAMPLE 1
.\Get-CmSiteInfo.ps1 -SiteServer "cm01.contoso.local" -SiteCode "P01" -Verbose

### EXAMPLE 2
.\Get-CmSiteInfo.ps1 -SiteServer "cm01.contoso.local" -SiteCode "P01" -OutputLayout LIST

### EXAMPLE 3
.\Get-CmSiteInfo.ps1 -SiteServer "cm01.contoso.local" -SiteCode "P01" -Interactive

### EXAMPLE 4
.\Get-CmSiteInfo.ps1 -SiteServer "cm01.contoso.local" -SiteCode "P01" -QueryName "DB Index Fragmentation Details" -OutputLayout RAW | Set-Variable -Name frag
$frag | Where-Object {$_.FragPct -gt 50}

## NOTES
0.1808.30 aka 0.1 aka brandnoobian - DS - First time getting drunk and passed out
