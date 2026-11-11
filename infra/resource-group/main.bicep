targetScope = 'resourceGroup'

@allowed([
  'Hub'
  'Spoke'
])
@description('Determines which bounded network module is selected.')
param topologyRole string

@description('Name for the hub virtual network when topologyRole is Hub.')
param hubVirtualNetworkName string

@description('Name for the spoke virtual network when topologyRole is Spoke.')
param spokeVirtualNetworkName string

@description('Azure region for the selected virtual network.')
param deploymentRegion string

@description('Synthetic placeholder object ID for a least-privilege Reader assignment.')
param readerPrincipalObjectId string

@description('Workspace resource ID contract for a future provider-specific diagnostic setting.')
param logAnalyticsWorkspaceResourceId string

module hubNetwork '../modules/network/hub-vnet.bicep' = if (topologyRole == 'Hub') {
  name: 'hub-network'
  params: {
    virtualNetworkName: hubVirtualNetworkName
    location: deploymentRegion
  }
}

module spokeNetwork '../modules/network/spoke-vnet.bicep' = if (topologyRole == 'Spoke') {
  name: 'spoke-network'
  params: {
    virtualNetworkName: spokeVirtualNetworkName
    location: deploymentRegion
  }
}

module privateDns '../modules/network/private-dns.bicep' = {
  name: 'private-dns-contract'
  params: {
    privateDnsZoneName: 'privatelink.${environment().suffixes.storage}'
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

output networkRole string = topologyRole
output diagnosticBoundary string = diagnosticContract.outputs.validationBoundary
