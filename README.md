# Get-CmSiteInfo.ps1
Get CM Site Information

## .SYNOPSIS
Query Configuration Manager Database information

## .DESCRIPTION
Just what the Synopsis guy just said

## .PARAMETER SiteServer
FQDN for ConfigMgr SQL Database server

## .PARAMETER SiteCode
Site Code

## .PARAMETER OutputLayout
Format for output: LIST, TABLE or RAW
RAW is intended for pipeline and post-processing usage
TABLE and LIST are for visual layout

## .PARAMETER ConfigFile
Path to XML configuration file. Default is cm-site-status.xml in same folder

## .PARAMETER QueryName
Specific query to run (only one at a time)

## .PARAMETER Interactive
Display queries from config file in grid view for user selection

## .EXAMPLE 
.\Get-CmSiteInfo.ps1 -SiteServer "cm01.contoso.local" -SiteCode "P01" -Verbose

## .EXAMPLE
.\Get-CmSiteInfo.ps1 -SiteServer "cm01.contoso.local" -SiteCode "P01" -OutputLayout LIST

## .EXAMPLE
.\Get-CmSiteInfo.ps1 -SiteServer "cm01.contoso.local" -SiteCode "P01" -Interactive

## .EXAMPLE
.\Get-CmSiteInfo.ps1 -SiteServer "cm01.contoso.local" -SiteCode "P01" -QueryName "DB Index Fragmentation Details" -OutputLayout RAW | Set-Variable -Name frag
$frag | Where-Object {$_.FragPct -gt 50}

## .NOTES
0.1808.30 - DS - First time getting drunk and passed out
