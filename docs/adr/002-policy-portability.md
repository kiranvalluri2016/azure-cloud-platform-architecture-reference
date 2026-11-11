# ADR 002: Limit V1 policy to portable aliases

## Decision

Implement custom tag and allowed-region policies only, with DEV `Audit` and PROD `Deny` assignments.

## Rationale

`tags[...]` and `location` are portable policy fields for this limited reference. Public-network and diagnostic requirements vary materially among Azure resource providers and cannot be truthfully represented as one universal policy without target-provider alias validation.

## Consequences

The architecture documents private endpoints, DNS, and diagnostics as future deployment contracts rather than claiming enforcement or compliance.
