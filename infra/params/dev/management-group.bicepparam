using '../../management-group/main.bicep'

param policyEffect = 'Audit'
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
