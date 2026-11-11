targetScope = 'resourceGroup'

param virtualNetworkName string
param location string

resource spokeVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'workload'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}

output virtualNetworkId string = spokeVirtualNetwork.id
