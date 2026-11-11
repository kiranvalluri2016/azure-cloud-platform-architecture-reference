# ADR 003: Use local Bicep and static validation only

## Decision

Validate source with local Bicep build/lint, parameter compilation, and Python static contract tests. Do not use Azure login or deployment commands.

## Rationale

The portfolio POC must be reproducible without a paid Azure environment, real identifiers, or cloud-side changes.

## Consequences

Passing validation proves local syntax and contract consistency only. It is not evidence of Azure deployment success, operational readiness, policy compliance, or security certification.
