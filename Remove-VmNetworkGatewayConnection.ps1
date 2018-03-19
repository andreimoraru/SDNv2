###
##
# Script to remove SCVMM L3 Forwarding connection for a specific VM network
##
###
##
# Edit $connectionType and $vmNetworkName values and run the script
##
###


function Import-ModuleIfNotAlreadyImported {
    param ([String]$Name)

    $isImported = Get-Module | Where-Object {$_.Name -eq $Name}
    
    if (!$isImported) {
        Import-Module $Name
        }
    } 


function Remove-VmNetworkGatewayConnection {
    param (
        [String]$VmNetworkName,
        [String]$ConnectionType="L3",
        [String]$VPNconnectionName
        )
    $Name = "virtualmachinemanager"

    Import-ModuleIfNotAlreadyImported -Name $Name

    $vmNetwork = Get-SCVMNetwork -Name $vmNetworkName

    $vmNetworkGateway = Get-SCVMNetworkGateway -VMNetwork $vmNetwork

    $VPNConnectionObjectRef = Get-SCVPNConnection -VMNetworkGateway $VmNetworkGateway | Where-Object {$_.Protocol -eq $connectionType -and $_.Name -eq $VPNconnectionName}

    if ($VPNConnectionObjectRef) {
        Remove-SCVPNConnection -VPNConnection $VPNConnectionObjectRef
    } else {
        throw "$VPNconnectionName connection doesn't exist..."
    }

}

# change $vmNetworkName value to the name of VM network;
$vmNetworkName = "Tenant-A-VM-Network"
#
#
# change $connectionType value to type of connection that you want to query;
# valid values are: IKEv2, L2TP, PPTP, GRE, L3, IPSec
#
$connectionType = "L3"
##
#
#
## name of the connection
$VPNConnectionName = "L3F-Tenant-A1"
##
#
#

Query-VmNetworkGatewayConnections -VmNetworkName $VmNetworkName -ConnectionType $connectionType

Remove-VmNetworkGatewayConnection -VmNetworkName $vmNetworkName -connectionType $connectionType -VPNconnectionName $VPNConnectionName
