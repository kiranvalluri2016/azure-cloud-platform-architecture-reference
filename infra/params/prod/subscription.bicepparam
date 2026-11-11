using '../../subscription/main.bicep'

param existingSubscriptionBoundary = 'existing-prod-workload-subscription-selected-by-operator'
param workloadResourceGroupName = 'rg-reference-workload-prod'
param deploymentRegion = 'eastus'
param monthlyBudgetAmount = 500
param budgetNotificationEmail = 'finops-prod@example.invalid'
