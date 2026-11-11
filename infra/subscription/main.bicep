targetScope = 'subscription'

@description('Existing subscription boundary label. It is not a subscription identifier and this template does not create or move subscriptions.')
param existingSubscriptionBoundary string

@description('Name for an illustrative workload resource group.')
param workloadResourceGroupName string

@description('Azure region for the illustrative workload resource group.')
param deploymentRegion string

@minValue(1)
@description('Illustrative monthly budget amount in the subscription billing currency.')
param monthlyBudgetAmount int

@description('Example non-production contact address for budget notifications.')
param budgetNotificationEmail string

@description('Environment tag value, for example development or production.')
param environmentName string

@description('Accountable ownership tag value.')
param ownerTagValue string

@description('Cost allocation tag value.')
param costCenterTagValue string

@description('Data-handling tag value.')
param dataClassificationTagValue string

resource workloadResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: workloadResourceGroupName
  location: deploymentRegion
  tags: {
    environment: environmentName
    owner: ownerTagValue
    costCenter: costCenterTagValue
    dataClassification: dataClassificationTagValue
  }
}

module subscriptionBudget '../modules/cost/subscription-budget.bicep' = {
  name: 'subscription-budget'
  params: {
    budgetName: '${workloadResourceGroupName}-monthly-budget'
    amount: monthlyBudgetAmount
    notificationEmail: budgetNotificationEmail
  }
}

output selectedBoundary string = existingSubscriptionBoundary
output createdResourceGroupName string = workloadResourceGroup.name
