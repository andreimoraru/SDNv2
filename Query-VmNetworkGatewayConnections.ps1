###
##
# Script to query SCVMM about details of all L3 Forwarding connections for a specific VM network
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

function Query-VmNetworkGatewayConnections {
    param (
        [String]$VmNetworkName,
        [String]$connectionType="L3"
        )
    if (!$PSCmdlet.$Protocol) {
        Write-Warning "`n`n`n$Protocol variable not defined, using L3 as default value..." 
    }

    $vmNetwork = Get-SCVMNetwork -Name $vmNetworkName

    $vmNetworkGateway = Get-SCVMNetworkGateway -VMNetwork $vmNetwork

    Get-SCVPNConnection -VMNetworkGateway $VmNetworkGateway | Where-Object {$_.Protocol -eq $connectionType}

}

##
# module name
#
$moduleName = "virtualmachinemanager"

# change $vmNetworkName value to the name of VM network;
$vmNetworkName = "<VM network name here>"
#
#
# change $connectionType value to type of connection that you want to query;
# valid values are: IKEv2, L2TP, PPTP, GRE, L3, IPSec
#
$connectionType = "<VM network gateway connection type>"
##
Import-ModuleIfNotAlreadyImported -Name $moduleName
Query-VmNetworkGatewayConnections -VmNetworkName $vmNetworkName -ConnectionType $connectionType
