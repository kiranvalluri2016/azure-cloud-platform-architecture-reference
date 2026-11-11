# ADR 001: Keep deployment scopes explicit

## Decision

Use four Bicep entry points with `tenant`, `managementGroup`, `subscription`, and `resourceGroup` target scopes.

## Rationale

Azure resource types support specific deployment scopes. A management-group hierarchy is tenant-scoped; it is not valid to model management-group creation in a management-group-scoped template. Subscription placement is not included: the subscription baseline is intended to be deployed only to an existing, separately selected subscription.

## Consequences

Local Bicep compilation detects invalid scope declarations. It cannot prove that a future operator has authority at a selected Azure scope.
