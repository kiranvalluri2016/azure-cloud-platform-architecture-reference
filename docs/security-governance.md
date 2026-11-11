# Security and governance model

## Identity and separation of duties

The reference uses Microsoft Entra group and managed-identity patterns rather than embedded secrets.

| Responsibility | Illustrative control | Boundary |
|---|---|---|
| Platform governance | Management-group policy definitions and assignments | Requires separately approved tenant or management-group authority |
| Workload operators | Resource-group-scoped Reader role assignment example | Placeholder principal only; no identity is granted locally |
| Workload runtime | User-assigned managed identity module | Identity is not created by local validation |
| Privileged operations | Separate privileged access and change-approval process | Not implemented or simulated by this reference |

The example role assignment uses the built-in Reader role definition to illustrate least privilege. It must not be broadened to Owner or Contributor without a documented workload need and separate review.

## Policy-as-code contract

The policy entry point contains only two portable custom policies:

1. Required ownership tag using a `tags[...]` alias.
2. Allowed regions using the `location` alias.

Both definitions permit only `Audit` or `Deny`. DEV parameter files set `Audit` to expose policy impact; PROD parameter files set `Deny` to enforce an approved baseline. The policy assignments are Bicep artifacts, not evidence of an active Azure assignment.

No generic policy in this project claims to disable public network access for every Azure resource. Such settings use different aliases and semantics across providers. Similarly, no universal diagnostics policy is claimed because diagnostic categories are provider-specific.

## Tagging and FinOps

The baseline establishes these required governance concepts:

- `environment` for DEV/PROD attribution.
- `owner` for accountable operational ownership.
- `costCenter` for cost allocation.
- Subscription-level monthly budget and forecast threshold.

The budget module uses an `example.invalid` email in parameter examples. A real notification recipient is operational configuration, not repository source.

## Secrets and identifiers

Never commit tenant IDs, subscription IDs, principal IDs, workspace IDs, certificates, access tokens, connection strings, or production email addresses. Production deployments should use approved identity mechanisms and secrets stores, with access granted under least-privilege controls.

## Governance limitations

This repository does not prove Azure Policy compliance, RBAC effectiveness, managed-identity token access, private connectivity, or security certification. It documents a baseline design and validates its local source contracts only.
