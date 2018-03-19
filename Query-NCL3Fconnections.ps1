$uri = "https://twaqidcdtsdnnc.dttcsms.local"
$moduleName = "networkcontroller"
$connectionType = "L3"


function Import-ModuleIfNotAlreadyImported {
    param ([String]$Name)

    $isImported = Get-Module | Where-Object {$_.Name -eq $Name}
    
    if (!$isImported) {
        Import-Module $Name
        }
    }

function Query-NCL3Fconnections {
    
    param (
    [String]$VmNetworkName,
    [String]$URI
    )
    
    $virtualGatewayArray = Get-NetworkControllerVirtualGateway -ConnectionUri $uri
    $connectionType = "L3"
    foreach ($virtualGateway in $virtualGatewayArray) {
        
        $L3FConnectionsArray = ((Get-NetworkControllerVirtualGatewayNetworkConnection -ConnectionUri $uri `
                                                                    -VirtualGatewayId $virtualGateway.ResourceId).Properties | `
                                                                    Where-Object {$_.ConnectionType -eq $connectionType})

        foreach ($L3FConnection in $L3FConnectionsArray) {
            $logicalNetworkResourceId = ($L3FConnection.L3Configuration.VlanSubnet.ResourceRef -split ("/"))[2]
        
            $L3FConnectionResourceName = (Get-NetworkControllerLogicalNetwork -ConnectionUri $uri -ResourceId $logicalNetworkResourceId).ResourceMetadata.ResourceName
            $L3FConnection | Add-Member -MemberType NoteProperty -Name "L3 connection name" -Value $L3FConnectionResourceName
            $L3FConnection

        }
    }
}


Import-ModuleIfNotAlreadyImported -Name $moduleName

Query-NCL3Fconnections -VmNetworkName $vmNetworkName -URI $uri
