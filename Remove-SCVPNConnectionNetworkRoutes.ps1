##
# remove network route(s) in network routes list from VM network gateway of VM network
#
#
##

function Import-ModuleIfNotAlreadyImported {
    param ([String]$Name)

    $isImported = Get-Module | Where-Object {$_.Name -eq $Name}
    
    if (!$isImported) {
        Import-Module $Name
        }
    } 

function Remove-SCVPNConnectionNetworkRoutes {
    param(
    [String]$VMnetworkName,
    [String]$VPNConnectionName,
    [String[]]$RoutingSubnets,
    [String]$Protocol="L3"
    )
    
    if (!$PSCmdlet.$Protocol) {
        Write-Warning "`n`n`n$Protocol variable not defined, using L3 as default value..." 
    }

    $VmNetworkObjectRef = Get-SCVMNetwork -Name $VmNetworkName

    $vmNetworkGatewayObjectRef = Get-SCVMNetworkGateway -VMNetwork $VmNetworkObjectRef

    $vpnConnection = Get-SCVPNConnection -Name $VPNConnectionName -VMNetworkGateway $vmNetworkGatewayObjectRef | Where-Object {$_.Protocol -eq $Protocol}

    # Remove network routes from VM network gateway...
    try 
    {
        foreach($route in $RoutingSubnets)
            {   
                
                $networkRouteObjectRef = Get-SCNetworkRoute -VPNConnection $vpnConnection | Where-Object {$_.IPSubnet -eq $route}
                if ($networkRouteObjectRef) {
                     Write-Host "`nRemoving network route $route from the routing table...`n`n"
                     $routeRemoveResult = Remove-SCNetworkRoute -NetworkRoute $networkRouteObjectRef
                     if ($routeRemoveResult) {
                          Write-Host "`nNetwork route was removed...`n`n"
                     }
                } else {
                    Write-Host "`n`nNo network route was found..."
                }
            }

    }

    catch
    {
        $PSItem.Exception.InnerExceptionMessage
    }

        Write-Host "`n`n`nFollowing network routes exists for $VPNConnectionName $Protocol connection of $VMnetworkName VM network..."
        Get-SCNetworkRoute -VPNConnection $vpnConnection
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
#
# Network routes
$routingSubnets = @(
    "192.168.10.0/29",
    "192.168.20.0/29"
    )
#
#
#
##

Import-ModuleIfNotAlreadyImported -Name $moduleName

Remove-SCVPNConnectionNetworkRoutes -VMnetworkName $VmNetworkName -VPNConnectionName $VPNConnectionName -RoutingSubnets $routingSubnets
