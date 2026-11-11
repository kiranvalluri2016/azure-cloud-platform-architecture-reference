using '../../management-group/main.bicep'

param policyEffect = 'Audit'
param ownerTagName = 'owner'
param allowedLocations = [
  'eastus'
  'centralus'
]
