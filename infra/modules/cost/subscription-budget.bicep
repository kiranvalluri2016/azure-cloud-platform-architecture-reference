targetScope = 'subscription'

param budgetName string

@minValue(1)
param amount int

param notificationEmail string

resource budget 'Microsoft.Consumption/budgets@2023-05-01' = {
  name: budgetName
  properties: {
    category: 'Cost'
    amount: amount
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: '2026-01-01T00:00:00Z'
      endDate: '2030-01-01T00:00:00Z'
    }
    notifications: {
      forecastThreshold: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 100
        contactEmails: [
          notificationEmail
        ]
      }
    }
  }
}

output budgetResourceId string = budget.id
