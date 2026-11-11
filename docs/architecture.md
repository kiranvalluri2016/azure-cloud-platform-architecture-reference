# Architecture and deployment boundaries

## Design intent

The reference separates logical cloud-platform responsibilities from the Azure deployment scopes capable of expressing them. It provides deployable-shape Bicep and static checks, but intentionally makes no Azure API call.

```mermaid
flowchart LR
  T[Tenant entry point] --> Root[Root management group]
  Root --> PlatformMG[Platform management group]
  Root --> WorkloadsMG[Workload management group]
  WorkloadsMG --> DevMG[DEV workload management group]
  WorkloadsMG --> ProdMG[PROD workload management group]
  Root --> P[Management-group policy entry point]
  PlatformMG --> S[Existing subscription entry point]
  S --> RG[Resource-group entry point]

  P --> Tags[Ownership tag policy]
  P --> Regions[Allowed region policy]
  S --> Budget[Subscription budget]
  RG --> Hub[Hub VNet option]
  RG --> Spoke[Spoke VNet option]
  RG --> DNS[Private DNS zone]
  RG --> MI[Managed identity pattern]
  RG --> RBAC[Reader RBAC pattern]
  RG --> Diag[Diagnostic-setting input contract]
```

## Deployment hierarchy

| Layer | Valid Bicep `targetScope` | Purpose | Not implied |
|---|---|---|---|
| Tenant | `tenant` | Creates one hierarchy: root, platform, workload, DEV workload, and PROD workload management groups | Subscription creation, subscription movement, tenant configuration |
| Management group | `managementGroup` | Defines and assigns generic tag/region policies | Universal resource-provider security enforcement |
| Subscription | `subscription` | Creates a named workload resource-group baseline and a budget shape | New subscription placement or billing configuration |
| Resource group | `resourceGroup` | Expresses network, identity, RBAC, and diagnostics contracts | Connectivity, identity authorization, or logging-category success |

### Existing subscription boundary

The subscription template is deployed only after a caller selects an existing target subscription in a separately approved deployment operation. Parameter files use a descriptive boundary label rather than a subscription ID. The tenant template does not use subscription-alias resources, subscription APIs, or a subscription-placement mechanism.

## Network and security topology

```mermaid
flowchart TB
  Internet[Approved ingress and egress controls] --> Hub[Hub VNet]
  Hub --> Shared[Shared services subnet]
  Hub --> PE[Private endpoint subnet]
  Hub --> DNS[Azure Blob Private Link DNS zone]
  SpokeDev[DEV spoke VNet 10.10.0.0 slash 16] --> Hub
  SpokeProd[PROD spoke VNet 10.20.0.0 slash 16] --> Hub
  DNS -. name resolution contract .-> SpokeDev
  DNS -. name resolution contract .-> SpokeProd
  Entra[Microsoft Entra groups] --> RBAC[Least privilege RBAC assignment]
  MI[User-assigned managed identity] --> Workload[Future workload]
```

The Bicep parameter fixtures represent one hub (`10.0.0.0/16`) and separate DEV (`10.10.0.0/16`) and PROD (`10.20.0.0/16`) spokes. The hub owns the service-specific Azure Blob Storage Private Link DNS example, `privatelink.blob.core.windows.net`. Peering, route tables, firewall appliances, private endpoint resources, and DNS links remain deployment-specific because they require validated resource IDs, network ownership, and provider constraints.

## Operations and diagnostics boundary

The diagnostic-setting module is an explicit input contract: target-resource ID plus Log Analytics workspace ID. It does not create a `Microsoft.Insights/diagnosticSettings` resource because log categories and valid diagnostic targets differ by provider. Before a real deployment, the owning team must validate category names, destination retention, network access, and data-residency requirements.

## Transaction and recovery model

Bicep deployments are Azure Resource Manager operations, but this repository does not invoke them. Local compilation is stateless and produces generated JSON under `/tmp/azure-cloud-platform-architecture-reference-validation/` by default. Therefore there is no local deployment state, rollback, or Azure resource recovery claim. A future controlled deployment must define its own change window, deployment history, rollback strategy, and validation evidence.
