targetScope = 'resourceGroup'

@description('A private DNS zone selected by the architecture. Virtual-network links are deliberately environment-specific.')
param privateDnsZoneName string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

output privateDnsZoneId string = privateDnsZone.id
