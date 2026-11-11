targetScope = 'managementGroup'

@allowed([
  'Audit'
  'Deny'
])
@description('DEV uses Audit; PROD uses Deny. This is an assignment effect, not a deployment action.')
param policyEffect string

@description('Required governance tag names. The Indexed policy mode evaluates taggable resources only.')
param requiredTagNames array

@description('Allowed Azure regions for workload resources.')
param allowedLocations array

resource requiredTagsPolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'require-resource-owner-tag'
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Require a governance tag on taggable resources'
    description: 'Requires one configured governance tag on resources evaluated by Indexed policy mode.'
    parameters: {
      tagName: {
        type: 'String'
        metadata: {
          displayName: 'Required tag name'
        }
      }
      effect: {
        type: 'String'
        allowedValues: [
          'Audit'
          'Deny'
        ]
        metadata: {
          displayName: 'Policy effect'
        }
      }
    }
    policyRule: {
      if: {
        field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
        exists: 'false'
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}

resource allowedLocationsPolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'allow-approved-regions'
  properties: {
    policyType: 'Custom'
    mode: 'Indexed'
    displayName: 'Allow approved Azure regions'
    description: 'Audits or denies resources outside the configured approved regions.'
    parameters: {
      allowedLocations: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed locations'
        }
      }
      effect: {
        type: 'String'
        allowedValues: [
          'Audit'
          'Deny'
        ]
        metadata: {
          displayName: 'Policy effect'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'location'
            notIn: '[parameters(\'allowedLocations\')]'
          }
          {
            field: 'location'
            notEquals: 'global'
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}

resource requiredTagAssignments 'Microsoft.Authorization/policyAssignments@2024-04-01' = [for tagName in requiredTagNames: {
  name: 'require-${tagName}-tag'
  properties: {
    displayName: 'Require ${tagName} tag'
    policyDefinitionId: requiredTagsPolicy.id
    enforcementMode: 'Default'
    parameters: {
      tagName: {
        value: tagName
      }
      effect: {
        value: policyEffect
      }
    }
  }
}]

resource allowedLocationsAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'allow-approved-regions'
  properties: {
    displayName: 'Allow approved Azure regions'
    policyDefinitionId: allowedLocationsPolicy.id
    enforcementMode: 'Default'
    parameters: {
      allowedLocations: {
        value: allowedLocations
      }
      effect: {
        value: policyEffect
      }
    }
  }
}

output configuredEffect string = policyEffect
output requiredTags array = requiredTagNames
output policyBoundary string = 'Only generic tag and location aliases are asserted by this reference. Provider-specific public-network and diagnostic policies require separate alias validation.'
