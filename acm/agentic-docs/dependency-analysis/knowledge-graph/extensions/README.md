# RHACM Knowledge Graph Extensions

This directory contains extension Cypher files that add specialized subsystems to the base RHACM knowledge graph.

## Loading Order

Extensions are loaded AFTER the base graph:

```bash
# 1. Load base graph first
cypher-shell < ../rhacm_architecture_comprehensive_final.cypher

# 2. Load extensions
for ext in *.cypher; do
  cypher-shell < "$ext"
done
```

## Available Extensions

| File | Components | Relationships | Description |
|------|------------|---------------|-------------|
| `rhacm-virtualization.cypher` | 72 | 102 | OpenShift Virtualization, MTV, CCLM, Fine-Grained RBAC, Hive, Klusterlet, Addon Framework, HyperShift (audited 2026-04-02) |

## Extension Guidelines

### Use MERGE Statements
Extensions should use `MERGE` instead of `CREATE` to safely add components:

```cypher
// GOOD - Safe to run multiple times
MERGE (n:RHACMComponent {id: 'MY_COMPONENT'})
SET n.label = 'My Component', n.subsystem = 'Virtualization';

// BAD - Creates duplicates if run twice
CREATE (:RHACMComponent {id: 'MY_COMPONENT', label: 'My Component'});
```

### Handle Base Graph ID Collisions
If your extension MERGE matches a node already in the base graph, `ON CREATE SET` alone will NOT update the properties. Use `ON MATCH SET` to override:

```cypher
// GOOD - Updates properties even if node already exists in base graph
MERGE (n:RHACMComponent {id: 'EXISTING_BASE_NODE'})
ON CREATE SET n.label = 'My Label', n.subsystem = 'Cluster', n.type = 'CRD'
ON MATCH SET n.label = 'My Label', n.subsystem = 'Cluster', n.type = 'CRD';

// BAD - Properties silently ignored if node already exists
MERGE (n:RHACMComponent {id: 'EXISTING_BASE_NODE'})
ON CREATE SET n.label = 'My Label', n.subsystem = 'Cluster', n.type = 'CRD';
```

### Reference Base Graph Nodes
Extensions can reference nodes from the base graph:

```cypher
// Reference existing CONSOLE node from base graph
MATCH (console:RHACMComponent {id: 'CONSOLE'})
MATCH (plugin:RHACMComponent {id: 'MY_PLUGIN'})
MERGE (console)-[:CONTAINS]->(plugin);
```

### Include Verification Metadata
Document where components were verified:

```cypher
MERGE (n:RHACMComponent {id: 'MY_COMPONENT'})
SET n.verified_cluster = 'cluster-name',
    n.verification_date = '2026-02-02',
    n.namespace = 'openshift-my-namespace';
```

## Virtualization Extension Details

The `rhacm-virtualization.cypher` extension covers:

### CNV/KubeVirt Stack
- HyperConverged Cluster Operator (HCO)
- KubeVirt Operator
- CDI (Containerized Data Importer)
- SSP (Scheduling, Scale, Performance)

### MTV (Migration Toolkit for Virtualization)
- Forklift Operator
- Forklift Controller
- Provider Controller (vSphere, oVirt, OpenStack, OVA, Hyper-V)
- Validation Service

### CCLM (Cross-Cluster Live Migration)
- Multi-cluster VM migration components
- MTVAddon for managed clusters

### Fine-Grained RBAC
- ClusterPermission CRD
- ManagedClusterRoleAssignment (MCRA)
- RBAC Addon

### Fleet Virtualization
- Console plugins (kubevirt-plugin, forklift-console-plugin)
- Fleet Virtualization Tree View
- VM Actions and management

**Verification**: Audited 2026-04-02 against ACM 2.16 GA (CNV 4.21.1, MTV 2.11.2). See cypher file header for full audit details.

## Contributing

1. Create your extension as a `.cypher` file
2. Use `MERGE` statements for safety
3. Include verification metadata
4. Update this README with your extension details
5. Submit a PR
