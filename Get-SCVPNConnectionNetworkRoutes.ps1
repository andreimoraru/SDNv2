$VmNetworkName = "Tenant-A-VM-Network"
$NextHopVmNetworkName = "L3F-LNet-Tenant-A-Transit"
$LocalIPAddresses = @("172.17.224.2/29")
$PeerIPAddresses = @("172.17.224.3")
$RoutingSubnets = @("192.168.0.0/29")
$VPNConnectionName = "L3F-Tenant-A"
$protocol = "L3"
$moduleName = "virtualmachinemanager"


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

    $VmNetworkObjectRef = Get-SCVMNetwork -Name $VmNetworkName

    $vmNetworkGatewayObjectRef = Get-SCVMNetworkGateway -VMNetwork $VmNetworkObjectRef

    $vpnConnection = Get-SCVPNConnection -Name $VPNConnectionName -VMNetworkGateway $vmNetworkGatewayObjectRef | Where-Object {$_.Protocol -eq $protocol}

    if ($vpnConnection.count -gt 1) {
        throw "More than 1 connection with $VPNConnectionName name ..."
    } else {
        Get-SCNetworkRoute -VPNConnection $vpnConnection
    }
}

Import-ModuleIfNotAlreadyImported -Name $moduleName

Get-SCVPNConnectionNetworkRoutes -VMnetworkName $VmNetworkName -VPNConnectionName $VPNConnectionName
