using '../../subscription/main.bicep'

param existingSubscriptionBoundary = 'existing-dev-workload-subscription-selected-by-operator'
param workloadResourceGroupName = 'rg-reference-workload-dev'
param deploymentRegion = 'eastus'
param monthlyBudgetAmount = 100
param budgetNotificationEmail = 'finops-dev@example.invalid'
