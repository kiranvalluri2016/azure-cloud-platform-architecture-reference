# Operations and local validation

## Environment contract

| Concern | DEV | PROD |
|---|---|---|
| Policy effect | `Audit` | `Deny` |
| Subscription label | Existing DEV boundary placeholder | Existing PROD boundary placeholder |
| Budget value | Lower illustrative amount | Higher illustrative amount |
| Network role fixture | DEV spoke `10.10.0.0/16` | PROD spoke `10.20.0.0/16` |
| Tags | `development`, `platform-engineering`, `reference-dev`, `internal` | `production`, `platform-engineering`, `reference-prod`, `confidential` |

The platform parameter fixture separately represents the hub at `10.0.0.0/16` and the Azure Blob Storage Private Link DNS example `privatelink.blob.core.windows.net`. DEV and PROD parameter files deliberately differ in policy effect, tag values, and boundary labels. They do not identify a real tenant or subscription.

## Local validation procedure

```bash
az bicep install
export BICEP_COMMAND="$HOME/.azure/bin/bicep"
./scripts/validate-local.sh
```

The script:

1. Builds every `.bicep` file.
2. Runs `bicep lint` against every `.bicep` file.
3. Compiles each DEV and PROD `.bicepparam` file.
4. Runs Python static contract tests.

Generated JSON goes only to `/tmp/azure-cloud-platform-architecture-reference-validation/` by default. The script does not authenticate, create resources, deploy templates, or query an Azure subscription.

## Future deployment prerequisites

Before any controlled Azure deployment, obtain and independently validate:

- Approved target tenant, management group, subscription, and resource-group scopes.
- Entra principal or managed-identity object IDs.
- Provider-specific Azure Policy aliases and diagnostic categories.
- Existing Log Analytics workspace, private DNS, VNet, and connectivity ownership.
- Budget contact recipients and cost-accountability tags.
- Change approval, rollback plan, deployment-history retention, and post-deployment checks.

Those prerequisites are deliberately outside this POC.
