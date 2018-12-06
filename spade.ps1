#Requires -Version 2.0
# Spade
# Spade is for digging
# Let's call a spade a spade
# Occupi 2018

$logfile = "spade.log"
$version = "0.1"

Function Build-Machine (
    [Parameter(Mandatory=$True)][hashtable]$propertiesTable
) {
    return (New-Object -TypeName psobject -Property $propertiesTable)
}

Function Write-JSONLog (
    [Parameter(Mandatory=$True)][psobject]$Machine
) {
    $Machine | ConvertTo-Json | Out-File -FilePath $logfile
    $Machine.PSObject.Properties | ForEach-Object {
        Write-Host "[+] Wrote",$_.Name,"to $logfile"
    }
}

Function Write-JSON () {

}

Function Get-BasicWindowsInformation (
    [Parameter(Mandatory=$True)][hashtable]$propertiesTable    
) {
    
    $hostname = (Invoke-Expression hostname)
    $propertiesTable.Add("Hostname",$hostname)

    $whoami = $env:UserName
    $propertiesTable.Add("Username",$whoami)

    $winVersion = [System.Environment]::OSVersion.VersionString
    $propertiesTable.Add("Windows Version",$winVersion)

    return $propertiesTable
}

Function Get-RunningProcesses (
    [Parameter(Mandatory=$True)][hashtable]$propertiesTable
)
{
    $processes = [hashtable]@{}

    Write-Host "[*] Collecting running processes..."

    Get-WmiObject -Query "Select * from Win32_Process" | where {$_.Name -notlike "svchost*"} | Select Name, Handle, @{Label="Owner";Expression={$_.GetOwner().User}} | ForEach-Object {
        $processes[$_.Name] = $_.Owner
    }
    $propertiesTable.Add("Processes", $processes)
    return $propertiesTable
}

Function Get-AllServices (
    [Parameter(Mandatory=$True)][hashtable]$propertiesTable
)
{
    $services = [hashtable]@{}

    Write-Host "[*] Collecting all services..."

    Get-Service | ForEach-Object {
        $services.Add($_.Name, [string]$_.Status)
    }
    $propertiesTable.Add("Services", $services)
    return $propertiesTable
}

Function Start-Digging () {
    [hashtable]$tempProperties = @{}

    Write-Host "[*] Digging..."

    $tempProperties = Get-BasicWindowsInformation($tempProperties)
    $tempProperties = Get-RunningProcesses($tempProperties)
    $tempProperties = Get-AllServices($tempProperties)
    $builtMachine = Build-Machine($tempProperties)
    Write-JSONLog($builtMachine)
}

Function Initialize-Spade () {
    Write-Host @"
                      _       ┌──────────┐
                     | |      │   ./\.   │
  ___ _ __   __ _  __| | ___  │ .'    '. │
 / __| '_ \ / _  |/ _  |/ _ \ │{        }│
 \__ \ |_) | (_| | (_| |  __/ │ -.~||~.- │
 |___/ .__/ \__,_|\__,_|\___| │    ||    │
     | |                      │   '--'   │
     |_|                      └──────────┘

Spade♤ is for digging...

"@
    Write-Host "[*] Initializing Spade v$version ..."
}

Try {
    Initialize-Spade
    Start-Digging
    Write-Host "[+] Success!"
    Write-Host
}
Catch {
    Write-Host "[-] Oops, we broke somewhere."
}