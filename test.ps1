# create mongo DB instances 
# methods: https://docs.mongodb.com/manual/reference/method/


Function Write-Log { # output to logFile
    param($message)

    $logDate = Get-Date -UFormat "%m/%d/%Y %H:%M:%S%p"
    "$logDate   $message" | Out-File $logFile -Append
    If ($verboseOutput -eq $true) {
        Write-Host $message
    }
}

Function Get-Dir {
    $path = Read-Host "Directory to contain MongoDB directory"
    If (!(Test-Path $path)) {
        Write-Host "Not a vaild directory.`n"
        $path = Get-Dir
    }
    Return $path

}

Function Create-Mongo {
    param([string]$srvName, [string]$dir, [string]$prt)

    $dbDir = "$dir\$srvName"
    If (!(Test-Path $dbDir)) {
        New-Item -Path $dbDir -ItemType Directory
    }

    $params = @(" --dbpath ""$dbDir""", " --logpath ""$dbDir\log.log""", " --port $prt", " --serviceName ""$srvName""", " --serviceDisplayName ""$srvName""", " --install")
    write-Host "Executing DB creation with params: $params"
    # & $mongoEXE $params
    $block ="""$mongoEXE"" $params"
    #Invoke-Command -ScriptBlock {cmd /c $block}
    Invoke-Expression -Command "cmd /c $block"
    Write-Host "Complete. Starting service..."
    Start-Service -Name $srvName -Confirm:$false

}

# gogo Mongo DB!
$scriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$global:logFile = $scriptDir + "\createMongos.log"
$global:mongoEXE = "C:\Program Files\MongoDB\Server\3.4\bin\mongod.exe"

$dbDir = Get-Dir
$serviceName = Read-Host "Service name"
$port = Read-Host "Port(default: 27017)"


$dbDir = "C:\MongoOthers"
$serviceName = "instance4"
$port = "27020"

If ((Get-Netfirewallrule -Name "MongoDB $serviceName") -eq $null) { # improve to query for port exception not name
    Write-Host "Creating firewall exceptions for TCP port: $port"
    New-NetFirewallRule -LocalPort $port -Name "MongoDB $serviceName" -DisplayName "MongoDB $serviceName" -Enabled True -Direction Inbound -Protocol TCP -Confirm:$false -ErrorAction Ignore
    New-NetFirewallRule -LocalPort $port -Name "MongoDB $serviceName" -DisplayName "MongoDB $serviceName" -Enabled True -Direction Outbound -Protocol TCP -Confirm:$false -ErrorAction Ignore
}

#Create-Mongo -srvName $serviceName -dir $dbDir -prt $port

$otherNodes = Read-Host "Other nodes:port(e.g 192.168.50.13:27018, 192.168.50.25:27019)" 

# $result = Invoke-Command -ScriptBlock {}

# %ProgramData%\GeoComm\Mongo\<DBName>

# > var cfg = { _id: 'ReplicaSet', members: [ { _id: 0, host: server + ':27017'}, { _id: 1, host: server + ':27018'}, { _id: 2, host:server + ':27019'} ] };