
function Import-ModuleIfNotAlreadyImported {
    param ([String]$Name)

    $isImported = Get-Module | Where-Object {$_.Name -eq $Name}
    
    if (!$isImported) {
        Import-Module $Name
        }
    } 

function Get-SCVPNConnectionNetworkRoutes {
    param(
    [String]$VMnetworkName,
    [String]$VPNConnectionName,
    [String]$Protocol="L3"
    )

    if (!$PSCmdlet.$Protocol) {
        Write-Warning "`n`n`n$Protocol variable not defined, using L3 as default value..." 
    }

    $VmNetworkObjectRef = Get-SCVMNetwork -Name $VMnetworkName

    $vmNetworkGatewayObjectRef = Get-SCVMNetworkGateway -VMNetwork $VmNetworkObjectRef

    $vpnConnection = Get-SCVPNConnection -Name $VPNConnectionName -VMNetworkGateway $vmNetworkGatewayObjectRef | Where-Object {$_.Protocol -eq $Protocol}

    if ($vpnConnection.count -gt 1) {
        throw "More than 1 connection with $VPNConnectionName name ..."
    } else {
        Get-SCNetworkRoute -VPNConnection $vpnConnection
    }
}

##
# module name
$moduleName = "virtualmachinemanager"
#
#
# VM network name
$VmNetworkName = "<VM network name here>"
#
#
# VPN connection name
$VPNConnectionName = "<VPN connection name>"
#
#
# Connection protocol
$protocol = "L3"
#
##

Import-ModuleIfNotAlreadyImported -Name $moduleName

Get-SCVPNConnectionNetworkRoutes -VMnetworkName $VmNetworkName -VPNConnectionName $VPNConnectionName
