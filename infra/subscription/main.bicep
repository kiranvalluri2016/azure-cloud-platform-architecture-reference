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

resource workloadResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: workloadResourceGroupName
  location: deploymentRegion
  tags: {
    environment: 'configured-by-parameter-file'
    owner: 'configured-by-parameter-file'
    costCenter: 'configured-by-parameter-file'
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
