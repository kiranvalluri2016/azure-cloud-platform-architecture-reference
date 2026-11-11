targetScope = 'resourceGroup'

param virtualNetworkName string
param location string
param addressPrefix string
param subnetAddressPrefix string

resource spokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'workload'
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}

output virtualNetworkId string = spokeVirtualNetwork.id
