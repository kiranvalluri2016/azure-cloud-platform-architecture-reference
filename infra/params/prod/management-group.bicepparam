using '../../management-group/main.bicep'

param policyEffect = 'Deny'
param requiredTagNames = [
  'environment'
  'owner'
  'costCenter'
  'dataClassification'
]
param allowedLocations = [
  'eastus'
  'centralus'
]
