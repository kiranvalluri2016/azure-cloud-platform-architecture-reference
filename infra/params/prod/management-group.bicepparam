using '../../management-group/main.bicep'

param policyEffect = 'Deny'
param ownerTagName = 'owner'
param allowedLocations = [
  'eastus'
  'centralus'
]
