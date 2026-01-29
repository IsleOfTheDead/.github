########################################################################################################################
# PARAMETERS
########################################################################################################################
param (
  [Alias("Help")]
  [Parameter(Mandatory = $false)]
  [switch]$H,

  [Alias("List")]
  [Parameter(Mandatory = $false)]
  [switch]$L,

  [Alias("Mount")]
  [Parameter(Mandatory = $false)]
  [string]$M,

  [Alias("Unmount")]
  [Parameter(Mandatory = $false)]
  [string]$U,

  [Alias("Junction")]
  [Parameter(Mandatory = $false)]
  [string]$J,

  [Alias("Project")]
  [Parameter(Mandatory = $false)]
  [switch]$P,

  [Alias("Remove")]
  [Parameter(Mandatory = $false)]
  [string]$R,

  [Alias("Client")]
  [Parameter(Mandatory = $false)]
  [string]$C,

  [Alias("Diag")]
  [Parameter(Mandatory = $false)]
  [string]$D,

  [Alias("Server")]
  [Parameter(Mandatory = $false)]
  [string]$S
)

########################################################################################################################
# CONSTANTS
########################################################################################################################
$task = "dzDrive"

$drives = @{
  P = @{ Label = "Projects"; Path = "D:\CR\Documents\DayZ Projects"; }
  T = @{ Label = "Tools"; Path = "D:\Program Files\Steam\steamapps\common\DayZ Tools"; }
  W = @{ Label = "Workshop"; Path = "D:\Program Files\Steam\steamapps\common\DayZ\!Workshop"; }
  Z = @{ Label = "Server"; Path = "D:\Program Files\Steam\steamapps\common\DayZServer"; }
}
$client = "D:\Program Files\Steam\steamapps\common\DayZ"
$server = "D:\Program Files\Steam\steamapps\common\DayZServer"

########################################################################################################################
# FUNCTIONS
########################################################################################################################
function New-Junction {
  param (
    [Parameter(Mandatory = $true)]
    [string]$Link,

    [Parameter(Mandatory = $true)]
    [string]$Target
  )
  try {
    cmd /c mklink /J "$Link" "$Target" | Out-Null
    if ($LASTEXITCODE -eq 0) { return $true }
    else { return $false }
  }
  catch {
    Write-Error " Exception occurred while creating junction: $_"
    return $null
  }
}

function Get-Mods {
  param (
    [Parameter(Mandatory = $true)]
    [string]$Junction
  )
  return Get-ChildItem -Path $Junction -Force -Attributes ReparsePoint -ErrorAction SilentlyContinue
}

########################################################################################################################
# VALIDATION
########################################################################################################################
$params = New-Object System.Collections.Generic.List[string]
if ($L) { $params.Add($L) }
if ($M) { $M = $M.ToUpper(); $params.Add($M) }
if ($U) { $U = $U.ToUpper(); $params.Add($U) }
if ($J) { $params.Add($J) }
if ($R) { $params.Add($R) }
if ($C) { $params.Add($C) }
if ($D) { $params.Add($D) }
if ($S) { $params.Add($S) }
# Validate drive letter
if (($M -eq $true -and -not $drives.ContainsKey($M)) -or ($U -eq $true -and -not $drives.ContainsKey($U))) {
  Write-Error "Invalid drive letter."
  exit 0
}
# Validate junction and type
if ($P -and -not $J) {
  Write-Error "You must specify a mod to junction."
  exit 0
}

# Ensure only 1 operation is chosen
if ($H -or $params.Count -ne 1) {
  Write-Host ""
  Write-Host "dzDrive.ps1 <Operation> <Argument>"
  Write-Host ""
  Write-Host "Operations:"
  Write-Host " -H | -Help     => Displays this help message."
  Write-Host " -L | -List     => Displays a list of all details."
  Write-Host " -M | -Mount    => Mounts the given drive letter."
  Write-Host " -U | -Unmount  => Unmounts the given drive letter."
  Write-Host " -J | -Junction => Adds a junction link."
  Write-Host " -T | -Type     => Type of junction."
  Write-Host " -R | -Remove   => Removes a junction link."
  Write-Host " -S | -Client   => Starts a sp client."
  Write-Host " -S | -Server   => Starts a mp server."
  Write-Host ""
  Write-Host "Examples:"
  Write-Host " > dzDrive.ps1 -H"
  Write-Host " > dzDrive.ps1 -L"
  Write-Host " > dzDrive.ps1 -M Z"
  Write-Host " > dzDrive.ps1 -U Z"
  Write-Host " > dzDrive.ps1 -J @ServerPack -J P"
  Write-Host " > dzDrive.ps1 -R @ServerPack"
  Write-Host " > dzDrive.ps1 -C"
  Write-Host " > dzDrive.ps1 -S ""@mod;@list"""
  Write-Host ""
  exit 0;
}

########################################################################################################################
# APPLICATION
########################################################################################################################
Write-Host ""
if ($L) {
  Write-Host " Mounted Drives:"
  Write-Host " --------------------------------------------------------------------------"
  foreach ($key in $drives.Keys) {
    if ($null -ne (subst | Select-String "^$($key):")) {
      Write-Host "  Mounted " -ForegroundColor DarkGreen -NoNewline
    }
    else {
      Write-Host "  Inactive" -ForegroundColor DarkRed -NoNewline
    }
    Write-Host (" {0}:[{1}] ({2})" -f $key, $drives[$key].Label, $drives[$key].Path)
  }
  Write-Host ""
  Write-Host " Junctionned Mods:"
  Write-Host " --------------------------------------------------------------------------"
  $mods = Get-ChildItem -Path "$($drives["Z"].Path)" -Force -Attributes ReparsePoint -ErrorAction SilentlyContinue
  foreach ($mod in $mods) {
    try {
      $output = fsutil reparsepoint query "$($mod.FullName)" 2>$null
      if ($output) {
        $targetLine = $output | Where-Object { $_ -match "Substitute Name:" }
        if ($targetLine) {
          $target = $targetLine -replace ".*Substitute Name:\s*\\\?\?\\", ""
          $targetKey = $drives.Keys | Where-Object { $drives[$_].Path -eq "$((Get-Item $target).Parent.FullName)" }
          Write-Host "  $($targetKey):\" -NoNewline -ForegroundColor DarkGreen
          Write-Host "$($mod.Name)" -ForegroundColor Cyan
        }
      }
    }
    catch {
      Write-Host " Failed to resolve target. Error: $_" -ForegroundColor DarkRed
    }
  }
  Write-Host ""
  exit 0
}
if ($M) {
  try {
    if (Get-ScheduledTask -TaskName "$($task)$M" -ErrorAction SilentlyContinue) {
      Write-Host " Removing existing scheduled task '$($task)$M'."
      Unregister-ScheduledTask -TaskName "$($task)$M" -Confirm:$false -ErrorAction Stop
    }

    $action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c subst $($M): `"$($drives[$M].Path)`""
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $logonTrigger = New-ScheduledTaskTrigger -AtLogOn
    $nowTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(5)
    $scheduledTask = New-ScheduledTask -Action $action -Trigger @($logonTrigger, $nowTrigger) -Principal $principal

    Register-ScheduledTask -TaskName "$($task)$M" -InputObject $scheduledTask -Force -ErrorAction Stop | Out-Null
    Start-ScheduledTask -TaskName "$($task)$M" -ErrorAction Stop

    Write-Host " Scheduled task '$($task)$M' created."
    Write-Host " Drive $($M):[$($drives[$M].Label)] mounted."
  }
  catch {
    Write-Error " Failed to mount drive or register/start scheduled task. Error: $_"
  }
  Write-Host ""
  exit 0
}
if ($U) {
  try {
    if (Get-ScheduledTask -TaskName "$($task)$U" -ErrorAction SilentlyContinue) {
      Unregister-ScheduledTask -TaskName "$($task)$U" -Confirm:$false -ErrorAction Stop
      Write-Host " Scheduled task '$($task)$U' removed."
    }
    else {
      Write-Host " Scheduled task '$($task)$U' not found."
    }

    subst "$($U):" /d
    Write-Host " Drive $($U):[$($drives[$U].Label)] unmounted."
  }
  catch {
    Write-Error " Failed to unmount drive or remove scheduled task. Error: $_"
  }
  Write-Host ""
  exit 0
}
if ($J) {
  $target = $drives["W"].Path
  if ($P) { $target = $drives["P"].Path }

  if (Test-Path "$($drives["Z"].Path)\$J") {
    Write-Host " Junction already exists: $($drives["Z"].Path)\$J" -ForegroundColor DarkYellow
  }
  else {
    if (New-Junction -Link "$($drives["Z"].Path)\$J" -Target "$target\$J") {
      Write-Host " Junction created: Server\$J" -ForegroundColor DarkGreen
    }
    else {
      Write-Host " Failed to create junction: $($drives["Z"].Path)\$J => $target\$J" -ForegroundColor DarkYellow
    }
  }
  Write-Host ""
  exit 0
}
if ($R) {
  if (Test-Path "$($drives["Z"].Path)\$R") {
    Remove-Item -Path "$($drives["Z"].Path)\$R" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host " Removed junction $R" -ForegroundColor Cyan
  }
  else {
    Write-Host " Junction does not exist $($drives["Z"].Path)\$R" -ForegroundColor DarkYellow
  }
  Write-Host ""
  exit 0
}

if ($C) {
  try {
    cmd /c start `
      /d "$client" DayZ_x64.exe `
      -mod="W:\@CF;W:\@Community-Online-Tools;W:\@Zens COT+;$C" `
      -connect=127.0.0.1 `
      -port=23002 `
      -nosplash `
      -noPause `
      -noBenchmark `
      -filePatching `
      -doLogs `
      -scriptDebug=true `
      -name=moldypenguins `
      -window
  }
  catch {
    Write-Error " Exception occurred while starting client: $_"
  }
  exit 0
}

if ($D) {
  try {
    cmd /c start `
      /d "$client" DayZDiag_x64.exe `
      -mod="W:\@CF;W:\@Community-Online-Tools;W:\@Zens COT+;$D" `
      -connect=172.24.48.1 `
      -port=23002 `
      -nosplash `
      -noPause `
      -noBenchmark `
      -filePatching `
      -doLogs `
      -scriptDebug=true `
      -name=moldypenguins `
      -window
  }
  catch {
    Write-Error " Exception occurred while starting diag client: $_"
  }
  exit 0
}

if ($S) {
  try {
    # launches DayZServer_x64.exe with required arguments
    cmd /c start `
      /d "$server" DayZServer_x64.exe `
      -port=23002 `
      -cpuCount=2 `
      -config="local.cfg" `
      -profiles="profiles" `
      -mod="W:\@CF;W:\@Community-Online-Tools;W:\@Zens COT+;$S" `
      -dologs `
      -adminlog `
      -netlog `
      -freezecheck
  }
  catch {
    # logs any exception during process launch
    Write-Error "Exception occurred while starting server: $_"
  }
  exit 0
}

# exit with error
exit 1
