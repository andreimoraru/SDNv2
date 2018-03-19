##
# add network routes in network routes list of VPN connection, on top of VM network gateway of VM network
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

function Add-SCVPNConnectionNetworkRoutes {
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

    $vpnConnection = Get-SCVPNConnection -Name $VPNConnectionName -VMNetworkGateway $vmNetworkGatewayObjectRef | Where-Object {$_.Protocol -eq $protocol}

    # Add all the required static routes to the newly created network connection interface
    try 
    {
        foreach($route in $RoutingSubnets)
            {   
                Write-Host "`nAdding network route $route to the routing table...`n`n"
                $routeAddResult = Add-SCNetworkRoute -IPSubnet $route -RunAsynchronously -VPNConnection $vpnConnection -VMNetworkGateway $vmNetworkGatewayObjectRef
                if ($routeAddResult) {
                    Write-Host "`nNetwork route was added...`n`n"
                    }
            }

    }

    catch
    {
        $PSItem.Exception.InnerExceptionMessage
    }

    if ($vpnConnection.count -gt 1) {
        throw "More than 1 connection with $VPNConnectionName name ..."
    } else {
        Write-Host "`n`n`nFollowing network routes exists for $VPNConnectionName $Protocol connection of $VMnetworkName VM network..."
        Get-SCNetworkRoute -VPNConnection $vpnConnection
    }
}


##
# module name
$moduleName = "virtualmachinemanager"
#
#
# VM network name
$VmNetworkName = "Tenant-A-VM-Network"
#
#
# VPN connection name
$VPNConnectionName = "L3F-Tenant-A"
#
#
# Connection protocol
$protocol = "L3"
#
#
# Network routes
$routingSubnets = @(
    "172.16.0.0/29"
    )
#
#
##

Import-ModuleIfNotAlreadyImported -Name $moduleName

Add-SCVPNConnectionNetworkRoutes -VMnetworkName $VmNetworkName -VPNConnectionName $VPNConnectionName -RoutingSubnets $routingSubnets

