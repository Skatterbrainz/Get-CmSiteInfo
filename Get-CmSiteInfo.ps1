<#
.SYNOPSIS
Query Configuration Manager Database information

.DESCRIPTION
Just what the Synopsis guy just said

.PARAMETER SiteServer
FQDN for ConfigMgr SQL Database server

.PARAMETER SiteCode
Site Code

.PARAMETER OutputLayout
Format for output: LIST, TABLE or RAW
RAW is intended for pipeline and post-processing usage
TABLE and LIST are for visual layout

.PARAMETER ConfigFile
Path to XML configuration file. Default is cm-site-status.xml in same folder

.PARAMETER QueryName
Specific query to run (only one at a time)

.PARAMETER Interactive
Display queries from config file in grid view for user selection

.EXAMPLE 
.\Get-CmSiteInfo.ps1 -SiteServer "cm01.contoso.local" -SiteCode "P01" -Verbose

.EXAMPLE
.\Get-CmSiteInfo.ps1 -SiteServer "cm01.contoso.local" -SiteCode "P01" -OutputLayout LIST

.EXAMPLE
.\Get-CmSiteInfo.ps1 -SiteServer "cm01.contoso.local" -SiteCode "P01" -Interactive

.EXAMPLE
.\Get-CmSiteInfo.ps1 -SiteServer "cm01.contoso.local" -SiteCode "P01" -QueryName "DB Index Fragmentation Details" -OutputLayout RAW | Set-Variable -Name frag
$frag | Where-Object {$_.FragPct -gt 50}

.NOTES
0.1808.30 - DS - First time getting drunk and passed out

#>

[CmdletBinding()]
param (
    [parameter(Mandatory=$True, HelpMessage="Site SQL Server FQDN")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteServer,
    [parameter(Mandatory=$True, HelpMessage="Site Code")]
        [ValidateNotNullOrEmpty()]
        [string] $SiteCode,
    [parameter(Mandatory=$False, HelpMessage="Output Format")]
        [ValidateSet('TABLE','LIST','RAW')]
        [string] $OutputLayout = 'TABLE',
    [parameter(Mandatory=$False, HelpMessage="Configuration XML file")]
        [string] $ConfigFile = ".\cm-site-status.xml",
    [parameter(Mandatory=$False, HelpMessage="Query Name")]
        [string] $QueryName = "",
    [parameter(Mandatory=$False, HelpMessage="Prompt for Selected Queries")]
        [switch] $Interactive
)
Write-Verbose "site server... $SiteServer"
Write-Verbose "site code..... $SiteCode"
Write-Verbose "outputlayout.. $OutputLayout"
Write-Verbose "configfile.... $ConfigFile"
Write-Verbose "queryname..... $QueryName"
if (!(Test-Path $ConfigFile)) {
    Write-Warning "configuration file not found: $ConfigFile"
    break
}
Write-Verbose "loading queries from: $ConfigFile"
[xml]$queryset = Get-Content $ConfigFile
if (!([string]::IsNullOrEmpty($QueryName))) {
    $qset = $queryset.queries.query | Where {$_.name -eq $QueryName}
    if (!$qset) {
        Write-Error "no matching query found"
        break
    }
}
elseif ($Interactive) {
    Write-Verbose "display grid for user selection"
    $qset = $queryset.queries.query | Sort-Object name | Out-GridView -Title "Select Items to Run (CTRL or SHIFT select)" -OutputMode Multiple
    Write-Verbose "selected queries: $($qset.length)"
}
else {
    Write-Verbose "all queries selected (default)"
    $qset = $queryset.queries.query
}
$time1 = Get-Date 
Write-Verbose "opening sql database connection"
$cs = "Server=$SiteServer;Database=CM_$SiteCode;Integrated Security=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $cs
try {
    $connection.Open()
    Write-Verbose "connection opened successfully"
}
catch {
    Write-Error $_.Exception.Message
    break
}
$command = $connection.CreateCommand()
$htmlbody = ""
Write-Verbose "processing queries"
foreach ($query in $qset) {
    $queryName = $query.name
    Write-Verbose "query: $queryName"
    Write-Verbose "expression: $($query.exp)"
    $command.CommandText = $query.exp
    $result = $command.ExecuteReader()
    $table  = New-Object System.Data.DataTable
    $table.Load($result)
    switch ($OutputLayout) {
        'TABLE' {
            Write-Output "Query: $queryName"
            $table | Format-Table
            break
        }
        'LIST' {
            Write-Output "Query: $queryName"
            $table | Format-List
            break
        }
        'RAW' {
            $table
        }
    } # switch
}
$connection.Close()
Write-Verbose "connection closed"
$time2 = Get-Date
$timex = New-TimeSpan -Start $time1 -End $time2
Write-Verbose "runtime: $($timex.TotalSeconds) seconds"
