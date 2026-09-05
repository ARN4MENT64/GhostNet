$code = @'
# ====================================================================
#                   GHOSTNET - Autonomous P2P Chat             
# ====================================================================
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$PORT = 6005

# Automatically clear the port from previous sessions
try {
    $portOwner = Get-NetUDPEndpoint -LocalPort $PORT -ErrorAction SilentlyContinue
    if ($portOwner) {
        Write-Host "[*] Freeing port $PORT..." -ForegroundColor Yellow
        Stop-Process -Id $portOwner.OwningProcess -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
} catch {}

# Initialize UDP Client
try {
    $udpClient = New-Object System.Net.Sockets.UdpClient($PORT)
    $udpClient.EnableBroadcast = $true
} catch {
    Write-Host "[-] Critical Error: Could not bind to port $PORT." -ForegroundColor Red
    Exit
}

$sharedData = [hashtable]::Synchronized(@{
    PartnerIP = $null
    PartnerPort = $null
    HasPartner = $false
})

# Background listener thread (Receiver)
$receiverCode = {
    param($udpClient)
    $remoteEP = New-Object System.Net.IpEndPoint([System.Net.IPAddress]::Any, 0)
    
    while ($true) {
        try {
            $bytes = $udpClient.Receive([ref]$remoteEP)
            # Decodes incoming bytes strictly in UTF-8 (supports Cyrillic and international chars)
            $message = [System.Text.Encoding]::UTF8.GetString($bytes)
            
            Write-Host "`n[$($remoteEP.Address.IPAddressToString)]: $message" -ForegroundColor Cyan
            Write-Host "You: " -NoNewline
            
            # Switch to a direct P2P channel once a peer is found
            $Runspace.TransitionInfo.PartnerIP = $remoteEP.Address.IPAddressToString
            $Runspace.TransitionInfo.PartnerPort = $remoteEP.Port
            $Runspace.TransitionInfo.HasPartner = $true
        } catch { break }
    }
}

$runspace = [runspacefactory]::CreateRunspace()
$runspace.Open()
$runspace.SessionStateProxy.SetVariable('Runspace', $sharedData)
$powershell = [powershell]::Create().AddScript($receiverCode).AddArgument($udpClient)
$powershell.Runspace = $runspace
$handle = $powershell.BeginInvoke()

# Global English Interface
Clear-Host
Write-Host " =================================================================== " -ForegroundColor Green
Write-Host "   ███  █   █  ███   ████ █████ █   █ █████ █████    █   █   █        " -ForegroundColor Green
Write-Host "  █     █   █ █   █ █       █   ██  █ █       █      █   █  ██       " -ForegroundColor Green
Write-Host "  █  ██ █████ █   █  ███    █   █ █ █ ████    █      █   █   █       " -ForegroundColor Green
Write-Host "  █   █ █   █ █   █     █   █   █  ██ █       █       █ █    █       " -ForegroundColor Green
Write-Host "   ███  █   █  ███  ████    █   █   █ █████   █        █    ███      " -ForegroundColor Green
Write-Host " =================================================================== " -ForegroundColor Green
Write-Host "[*] Status: Connected. Local broadcast active." -ForegroundColor Green
Write-Host "[*] Network Port: $PORT" -ForegroundColor Gray
Write-Host "[!] Send your first message to pair devices." -ForegroundColor Yellow
Write-Host "[!] Type 'exit' to disconnect from the grid." -ForegroundColor DarkYellow
Write-Host ""

# Main sending loop (Sender)
while ($true) {
    Write-Host "You: " -NoNewline
    $msg = [Console]::ReadLine()
    
    if ($msg -eq "exit") { break }
    if ([string]::IsNullOrWhiteSpace($msg)) { continue }
    
    # Encodes output messages in UTF-8 to correctly send Russian text
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($msg)
    
    if ($sharedData.HasPartner) {
        $targetEP = New-Object System.Net.IpEndPoint([System.Net.IPAddress]::Parse($sharedData.PartnerIP), $sharedData.PartnerPort)
        $udpClient.Send($bytes, $bytes.Length, $targetEP) | Out-Null
    } else {
        $targetEP = New-Object System.Net.IpEndPoint([System.Net.IPAddress]::Broadcast, $PORT)
        $udpClient.Send($bytes, $bytes.Length, $targetEP) | Out-Null
    }
}

$udpClient.Close()
$powershell.Dispose()
$runspace.Close()
Write-Host "[*] GhostNet: Channel closed. Session destroyed." -ForegroundColor Red
'@