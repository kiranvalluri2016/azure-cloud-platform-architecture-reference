targetScope = 'resourceGroup'

param virtualNetworkName string
param location string
param addressPrefix string
param subnetAddressPrefix string

resource hubVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
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
        name: 'shared-services'
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
      {
        name: 'private-endpoints'
        properties: {
          addressPrefix: '10.0.2.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output virtualNetworkId string = hubVirtualNetwork.id
