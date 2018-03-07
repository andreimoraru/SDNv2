$uri = "REST endpoint here"
$macAddress= "001dd8b721bd"
$vmNetworkName = "Front End-d14906d1344546ec8679c0f179fe54bb"
$ipResourceName = "additionalIp00"

$macAddress = $macAddress.ToUpper()

$arrayOfNICAdapters = Get-NetworkControllerNetworkInterface -ConnectionUri $uri

$nicAdapter = $arrayOfNICAdapters | Where-Object {$_.Properties.PrivateMacAddress -eq $macAddress}

#$subnetObjectRef = $nicAdapter.Properties.IpConfigurations.Properties.Subnet

$virtualNetworkObjectRef = Get-NetworkControllerVirtualNetwork -ConnectionUri $uri | Where-Object {$_.Properties.Subnets.ResourceMetadata.ResourceName -eq $vmNetworkName}

$virtualSubnetObjectRef = Get-NetworkControllerVirtualSubnet -ConnectionUri $uri -VirtualNetworkId $virtualNetworkObjectRef.ResourceId | Where-Object {$_.ResourceMetadata.ResourceName -eq $vmNetworkName}

$ipProperties = New-Object Microsoft.Windows.NetworkController.NetworkInterfaceIpConfigurationProperties

$ipProperties.PrivateIPAddress = "192.168.3.14"
$ipProperties.PrivateIPAllocationMethod = "Static"
$ipProperties.Subnet = $virtualSubnetObjectRef

New-NetworkControllerNetworkInterfaceIpConfiguration -ConnectionUri $uri -NetworkInterfaceId $nicAdapter.ResourceId \
-ResourceId $ipResourceName -Properties $ipProperties
