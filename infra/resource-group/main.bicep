targetScope = 'resourceGroup'

@allowed([
  'Hub'
  'DevSpoke'
  'ProdSpoke'
])
@description('Selects the platform hub, DEV spoke, or PROD spoke configuration.')
param networkRole string

@description('Name for the selected virtual network.')
param virtualNetworkName string

@description('Address space for the selected virtual network.')
param virtualNetworkAddressPrefix string

@description('Workload or shared-services subnet prefix for the selected virtual network.')
param subnetAddressPrefix string

@description('Azure region for the selected virtual network.')
param deploymentRegion string

@description('Synthetic placeholder object ID for a least-privilege Reader assignment.')
param readerPrincipalObjectId string

@description('Workspace resource ID contract for a future provider-specific diagnostic setting.')
param logAnalyticsWorkspaceResourceId string

@description('Service-specific Private Link DNS zone reference; the hub owns the zone.')
param privateLinkDnsZoneName string

module hubNetwork '../modules/network/hub-vnet.bicep' = if (networkRole == 'Hub') {
  name: 'hub-network'
  params: {
    virtualNetworkName: virtualNetworkName
    location: deploymentRegion
    addressPrefix: virtualNetworkAddressPrefix
    subnetAddressPrefix: subnetAddressPrefix
  }
}

module spokeNetwork '../modules/network/spoke-vnet.bicep' = if (networkRole == 'DevSpoke' || networkRole == 'ProdSpoke') {
  name: 'spoke-network'
  params: {
    virtualNetworkName: virtualNetworkName
    location: deploymentRegion
    addressPrefix: virtualNetworkAddressPrefix
    subnetAddressPrefix: subnetAddressPrefix
  }
}

module privateDns '../modules/network/private-dns.bicep' = if (networkRole == 'Hub') {
  name: 'private-dns-contract'
  params: {
    privateDnsZoneName: privateLinkDnsZoneName
  }
}

module readerAssignment '../modules/security/reader-role-assignment.bicep' = {
  name: 'least-privilege-reader'
  params: {
    principalObjectId: readerPrincipalObjectId
  }
}

module managedIdentity '../modules/security/user-assigned-identity.bicep' = {
  name: 'workload-managed-identity'
  params: {
    identityName: 'workload-managed-identity'
    location: deploymentRegion
  }
}

module diagnosticContract '../modules/operations/diagnostic-setting-contract.bicep' = {
  name: 'diagnostic-setting-contract'
  params: {
    targetResourceId: resourceGroup().id
    workspaceResourceId: logAnalyticsWorkspaceResourceId
  }
}

output configuredNetworkRole string = networkRole
output privateLinkDnsZone string = privateLinkDnsZoneName
output diagnosticBoundary string = diagnosticContract.outputs.validationBoundary
