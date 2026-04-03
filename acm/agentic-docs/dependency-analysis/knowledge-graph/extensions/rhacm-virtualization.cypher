// ============================================================================
// RHACM Knowledge Graph Extension: Virtualization, MTV, CCLM, Fine-Grained RBAC
// ============================================================================
// Generated: 2026-01-30
// Source: Deep investigation of kubevirt, kubev2v, stolostron repos and JIRA
// Components: 72 components across 9 feature areas (46 virt/RBAC + 11 Hive + 8 Klusterlet + 3 Addon + 4 HyperShift)
// Relationships: 102 relationships (56 virt/RBAC + 20 Hive + 14 Klusterlet + 6 Addon + 6 HyperShift)
// ============================================================================
//
// VERIFICATION STATUS: VERIFIED (Accuracy Audit 2026-04-02)
// Audit Date: 2026-04-02
// Audit Cluster: ashafi-acm-216-ga.az.dev09.red-chesterfield.com (ACM 2.16 GA)
// Audit Sources: Live cluster (CNV 4.21.1, MTV 2.11.2), ACM Console source
//   code (stolostron/console release-2.16), kubevirt-plugin (release-4.20),
//   Neo4j database queries
//
// Audit Fixes Applied:
// - Removed ACM_HUB_KUBEVIRT_ROLES and ACM_MANAGED_KUBEVIRT_ROLES (fabricated)
// - Fixed CLUSTER_PERMISSION_CRD ON MATCH SET (base graph ID collision)
// - Fixed ContainerDisks: CDI does not provide them; KubeVirt uses them
// - Fixed Forklift Console Plugin: OCP plugin, not ACM Console
// - Deprecated NODE_MAINTENANCE_OPERATOR (removed from HCO in CNV 4.18+)
// - Fixed MTV_INTEGRATIONS type: Controller, not Operator
// - Added featureGated metadata to optional components
// - Removed incorrect MTV_INTEGRATIONS->Migration Planner relationship
//
// Previous Verification:
// - 2026-02-02: slot-03.dev09 (CNV 4.20.3, MTV 2.10.3)
// - Fixed MCRA naming, added 12 orphan-fix relationships
//
// Key Verified Resources (2026-04-02):
// - HCO: kubevirt-hyperconverged-operator.v4.21.1
// - CDI: cdi-kubevirt-hyperconverged (Deployed)
// - SSP: ssp-kubevirt-hyperconverged (Deployed)
// - MTV: mtv-operator.v2.11.2, forklift-controller (Running)
// - CCLM: kubevirt-migration-operator/controller (Running)
// - Addons: kubevirt-hyperconverged, mtv-operator ClusterManagementAddons
// - RBAC: ClusterPermission CRD, MCRA CRD, kubevirt.io:admin/edit/view/migrate
// - Console: kubevirt-plugin, forklift-console-plugin (OCP-level)
// ============================================================================

// ============================================================================
// SECTION 1: CNV/KUBEVIRT CORE STACK (OpenShift Virtualization)
// ============================================================================

// --- HyperConverged Cluster Operator (Meta-Operator) ---
MERGE (hco:RHACMComponent {id: 'HCO_OPERATOR'})
ON CREATE SET 
  hco.label = 'HyperConverged Cluster Operator',
  hco.subsystem = 'Cluster',
  hco.type = 'Operator',
  hco.description = 'Meta-operator that deploys and manages all CNV components (KubeVirt, CDI, SSP, CNAO)';

// --- KubeVirt Core ---
MERGE (kubevirt:RHACMComponent {id: 'KUBEVIRT_OPERATOR'})
ON CREATE SET 
  kubevirt.label = 'KubeVirt Operator',
  kubevirt.subsystem = 'Cluster',
  kubevirt.type = 'Operator',
  kubevirt.description = 'Core virtualization operator providing VirtualMachine and VirtualMachineInstance CRDs';

MERGE (kubevirt_api:RHACMComponent {id: 'KUBEVIRT_API'})
ON CREATE SET 
  kubevirt_api.label = 'KubeVirt API',
  kubevirt_api.subsystem = 'Cluster',
  kubevirt_api.type = 'API',
  kubevirt_api.description = 'KubeVirt API definitions for VirtualMachine, VMI, DataVolume resources';

// --- Containerized Data Importer (CDI) ---
MERGE (cdi:RHACMComponent {id: 'CDI_OPERATOR'})
ON CREATE SET 
  cdi.label = 'Containerized Data Importer Operator',
  cdi.subsystem = 'Cluster',
  cdi.type = 'Operator',
  cdi.description = 'Manages persistent storage for VMs, populates PVCs with VM disk images';

MERGE (cdi_controller:RHACMComponent {id: 'CDI_CONTROLLER'})
ON CREATE SET 
  cdi_controller.label = 'CDI Controller',
  cdi_controller.subsystem = 'Cluster',
  cdi_controller.type = 'Controller',
  cdi_controller.description = 'Handles DataVolume creation and disk image import operations';

// --- SSP Operator (Scheduling, Scale, Performance) ---
MERGE (ssp:RHACMComponent {id: 'SSP_OPERATOR'})
ON CREATE SET 
  ssp.label = 'SSP Operator',
  ssp.subsystem = 'Cluster',
  ssp.type = 'Operator',
  ssp.description = 'Deploys VM templates, instance types, console proxy, and template validator';

MERGE (common_templates:RHACMComponent {id: 'COMMON_TEMPLATES'})
ON CREATE SET 
  common_templates.label = 'Common Templates',
  common_templates.subsystem = 'Cluster',
  common_templates.type = 'Component',
  common_templates.description = 'Pre-defined VM templates for common operating systems';

MERGE (common_instancetypes:RHACMComponent {id: 'COMMON_INSTANCETYPES'})
ON CREATE SET 
  common_instancetypes.label = 'Common Instance Types',
  common_instancetypes.subsystem = 'Cluster',
  common_instancetypes.type = 'Component',
  common_instancetypes.description = 'Predefined VM instance types and preferences (CPU, memory profiles)';

MERGE (vm_console_proxy:RHACMComponent {id: 'VM_CONSOLE_PROXY'})
ON CREATE SET 
  vm_console_proxy.label = 'VM Console Proxy',
  vm_console_proxy.subsystem = 'Cluster',
  vm_console_proxy.type = 'Component',
  vm_console_proxy.description = 'Provides VNC/serial console access to VMs',
  vm_console_proxy.featureGated = true;

// --- Cluster Network Addons Operator (CNAO) ---
MERGE (cnao:RHACMComponent {id: 'CNAO_OPERATOR'})
ON CREATE SET 
  cnao.label = 'Cluster Network Addons Operator',
  cnao.subsystem = 'Cluster',
  cnao.type = 'Operator',
  cnao.description = 'Deploys networking components for VM connectivity (Multus, bridges, MacVTap)';

MERGE (macvtap_cni:RHACMComponent {id: 'MACVTAP_CNI'})
ON CREATE SET 
  macvtap_cni.label = 'MacVTap CNI',
  macvtap_cni.subsystem = 'Cluster',
  macvtap_cni.type = 'Component',
  macvtap_cni.description = 'CNI plugin for MacVTap networking for VM workloads',
  macvtap_cni.featureGated = true;

MERGE (linux_bridge_cni:RHACMComponent {id: 'LINUX_BRIDGE_CNI'})
ON CREATE SET 
  linux_bridge_cni.label = 'Linux Bridge CNI',
  linux_bridge_cni.subsystem = 'Cluster',
  linux_bridge_cni.type = 'Component',
  linux_bridge_cni.description = 'CNI plugin for Linux bridge networking';

MERGE (kubesecondarydns:RHACMComponent {id: 'KUBESECONDARYDNS'})
ON CREATE SET 
  kubesecondarydns.label = 'KubeSecondaryDNS',
  kubesecondarydns.subsystem = 'Cluster',
  kubesecondarydns.type = 'Component',
  kubesecondarydns.description = 'DNS service for VM secondary network interfaces',
  kubesecondarydns.featureGated = true;

// --- Other CNV Components ---
MERGE (hostpath_provisioner:RHACMComponent {id: 'HOSTPATH_PROVISIONER_OPERATOR'})
ON CREATE SET 
  hostpath_provisioner.label = 'HostPath Provisioner Operator',
  hostpath_provisioner.subsystem = 'Cluster',
  hostpath_provisioner.type = 'Operator',
  hostpath_provisioner.description = 'Provides local storage for VMs using hostPath volumes';

MERGE (node_maintenance:RHACMComponent {id: 'NODE_MAINTENANCE_OPERATOR'})
ON CREATE SET 
  node_maintenance.label = 'Node Maintenance Operator',
  node_maintenance.subsystem = 'Cluster',
  node_maintenance.type = 'Operator',
  node_maintenance.description = 'Manages node maintenance operations for VM workloads',
  node_maintenance.deprecated = true,
  node_maintenance.deprecatedSince = 'CNV 4.18';

MERGE (containerdisks:RHACMComponent {id: 'CONTAINERDISKS'})
ON CREATE SET 
  containerdisks.label = 'ContainerDisks',
  containerdisks.subsystem = 'Cluster',
  containerdisks.type = 'Component',
  containerdisks.description = 'Official container disk images for KubeVirt VMs';

// ============================================================================
// SECTION 2: MTV/FORKLIFT STACK (Migration Toolkit for Virtualization)
// ============================================================================

// --- MTV Operator ---
MERGE (mtv_operator:RHACMComponent {id: 'MTV_OPERATOR'})
ON CREATE SET 
  mtv_operator.label = 'MTV Operator',
  mtv_operator.subsystem = 'Cluster',
  mtv_operator.type = 'Operator',
  mtv_operator.description = 'Forklift operator for migrating VMs from VMware, oVirt, OpenStack to KubeVirt';

// --- Forklift Controllers ---
MERGE (forklift_controller:RHACMComponent {id: 'FORKLIFT_CONTROLLER'})
ON CREATE SET 
  forklift_controller.label = 'Forklift Controller',
  forklift_controller.subsystem = 'Cluster',
  forklift_controller.type = 'Controller',
  forklift_controller.description = 'Main migration controller managing Plans, Migrations, Providers';

MERGE (plan_controller:RHACMComponent {id: 'MTV_PLAN_CONTROLLER'})
ON CREATE SET 
  plan_controller.label = 'Plan Controller',
  plan_controller.subsystem = 'Cluster',
  plan_controller.type = 'Controller',
  plan_controller.description = 'Manages migration Plan resources and lifecycle';

MERGE (migration_controller:RHACMComponent {id: 'MTV_MIGRATION_CONTROLLER'})
ON CREATE SET 
  migration_controller.label = 'Migration Controller',
  migration_controller.subsystem = 'Cluster',
  migration_controller.type = 'Controller',
  migration_controller.description = 'Executes active VM migrations';

MERGE (provider_controller:RHACMComponent {id: 'MTV_PROVIDER_CONTROLLER'})
ON CREATE SET 
  provider_controller.label = 'Provider Controller',
  provider_controller.subsystem = 'Cluster',
  provider_controller.type = 'Controller',
  provider_controller.description = 'Manages source Provider resources (VMware, oVirt, OpenStack, OVA)';

MERGE (network_map_controller:RHACMComponent {id: 'MTV_NETWORK_MAP_CONTROLLER'})
ON CREATE SET 
  network_map_controller.label = 'NetworkMap Controller',
  network_map_controller.subsystem = 'Cluster',
  network_map_controller.type = 'Controller',
  network_map_controller.description = 'Manages network mapping between source and target';

MERGE (storage_map_controller:RHACMComponent {id: 'MTV_STORAGE_MAP_CONTROLLER'})
ON CREATE SET 
  storage_map_controller.label = 'StorageMap Controller',
  storage_map_controller.subsystem = 'Cluster',
  storage_map_controller.type = 'Controller',
  storage_map_controller.description = 'Manages storage mapping between source and target';

MERGE (hook_controller:RHACMComponent {id: 'MTV_HOOK_CONTROLLER'})
ON CREATE SET 
  hook_controller.label = 'Hook Controller',
  hook_controller.subsystem = 'Cluster',
  hook_controller.type = 'Controller',
  hook_controller.description = 'Manages pre/post migration hooks';

// --- Forklift API and Tools ---
MERGE (forklift_api:RHACMComponent {id: 'FORKLIFT_API'})
ON CREATE SET 
  forklift_api.label = 'Forklift API',
  forklift_api.subsystem = 'Cluster',
  forklift_api.type = 'API',
  forklift_api.description = 'REST API for Forklift/MTV operations';

MERGE (virt_v2v:RHACMComponent {id: 'VIRT_V2V'})
ON CREATE SET 
  virt_v2v.label = 'virt-v2v',
  virt_v2v.subsystem = 'Cluster',
  virt_v2v.type = 'Component',
  virt_v2v.description = 'Guest conversion tool for transforming VM disk formats';

// --- Volume Populators ---
MERGE (ovirt_populator:RHACMComponent {id: 'OVIRT_VOLUME_POPULATOR'})
ON CREATE SET 
  ovirt_populator.label = 'oVirt Volume Populator',
  ovirt_populator.subsystem = 'Cluster',
  ovirt_populator.type = 'Component',
  ovirt_populator.description = 'Populates PVCs with disk data from oVirt/RHV';

MERGE (openstack_populator:RHACMComponent {id: 'OPENSTACK_VOLUME_POPULATOR'})
ON CREATE SET 
  openstack_populator.label = 'OpenStack Volume Populator',
  openstack_populator.subsystem = 'Cluster',
  openstack_populator.type = 'Component',
  openstack_populator.description = 'Populates PVCs with disk data from OpenStack';

MERGE (vsphere_xcopy_populator:RHACMComponent {id: 'VSPHERE_XCOPY_VOLUME_POPULATOR'})
ON CREATE SET 
  vsphere_xcopy_populator.label = 'vSphere XCOPY Volume Populator',
  vsphere_xcopy_populator.subsystem = 'Cluster',
  vsphere_xcopy_populator.type = 'Component',
  vsphere_xcopy_populator.description = 'Storage offload populator using XCOPY for VMware migrations';

// --- Provider Servers ---
MERGE (ova_provider:RHACMComponent {id: 'OVA_PROVIDER_SERVER'})
ON CREATE SET 
  ova_provider.label = 'OVA Provider Server',
  ova_provider.subsystem = 'Cluster',
  ova_provider.type = 'Component',
  ova_provider.description = 'Handles OVA file imports as migration source';

MERGE (hyperv_provider:RHACMComponent {id: 'HYPERV_PROVIDER_SERVER'})
ON CREATE SET 
  hyperv_provider.label = 'Hyper-V Provider Server',
  hyperv_provider.subsystem = 'Cluster',
  hyperv_provider.type = 'Component',
  hyperv_provider.description = 'Handles Hyper-V as migration source';

// --- MTV Console Plugin ---
MERGE (forklift_console:RHACMComponent {id: 'FORKLIFT_CONSOLE_PLUGIN'})
ON CREATE SET 
  forklift_console.label = 'Forklift Console Plugin',
  forklift_console.subsystem = 'Console',
  forklift_console.type = 'Component',
  forklift_console.description = 'OpenShift Console plugin for MTV migration UI';

// --- Migration Planner (standalone Red Hat service, not part of MTV operator deployment) ---
MERGE (migration_planner:RHACMComponent {id: 'MIGRATION_PLANNER'})
ON CREATE SET 
  migration_planner.label = 'Migration Planner',
  migration_planner.subsystem = 'Cluster',
  migration_planner.type = 'Component',
  migration_planner.description = 'Standalone VMware assessment SaaS for migration readiness (external to MTV)',
  migration_planner.external = true;

// ============================================================================
// SECTION 3: CCLM (Cross-Cluster Live Migration)
// ============================================================================

MERGE (cclm:RHACMComponent {id: 'CCLM'})
ON CREATE SET 
  cclm.label = 'Cross-Cluster Live Migration',
  cclm.subsystem = 'Cluster',
  cclm.type = 'Component',
  cclm.description = 'Live migration of running VMs between OpenShift clusters';

MERGE (kubevirt_migration_operator:RHACMComponent {id: 'KUBEVIRT_MIGRATION_OPERATOR'})
ON CREATE SET 
  kubevirt_migration_operator.label = 'KubeVirt Migration Operator',
  kubevirt_migration_operator.subsystem = 'Cluster',
  kubevirt_migration_operator.type = 'Operator',
  kubevirt_migration_operator.description = 'Operator for cross-cluster VM migration (CCLM)';

MERGE (kubevirt_migration_controller:RHACMComponent {id: 'KUBEVIRT_MIGRATION_CONTROLLER'})
ON CREATE SET 
  kubevirt_migration_controller.label = 'KubeVirt Migration Controller',
  kubevirt_migration_controller.subsystem = 'Cluster',
  kubevirt_migration_controller.type = 'Controller',
  kubevirt_migration_controller.description = 'Controller managing cross-cluster VM migration execution';

// ============================================================================
// SECTION 4: ACM INTEGRATION LAYER (MTV Integrations, Fleet Virtualization)
// ============================================================================

// --- MTV Integrations ---
MERGE (mtv_integrations:RHACMComponent {id: 'MTV_INTEGRATIONS'})
ON CREATE SET 
  mtv_integrations.label = 'MTV Integrations',
  mtv_integrations.subsystem = 'Cluster',
  mtv_integrations.type = 'Controller',
  mtv_integrations.description = 'ACM MTV integration controller, webhooks, and addon management';

MERGE (provider_manager_controller:RHACMComponent {id: 'PROVIDER_MANAGER_CONTROLLER'})
ON CREATE SET 
  provider_manager_controller.label = 'Provider Manager Controller',
  provider_manager_controller.subsystem = 'Cluster',
  provider_manager_controller.type = 'Controller',
  provider_manager_controller.description = 'Integrates ACM managed clusters as MTV providers';

MERGE (mtv_plan_webhook:RHACMComponent {id: 'MTV_PLAN_WEBHOOK'})
ON CREATE SET 
  mtv_plan_webhook.label = 'MTV Plan Webhook',
  mtv_plan_webhook.subsystem = 'Cluster',
  mtv_plan_webhook.type = 'Component',
  mtv_plan_webhook.description = 'Validating admission webhook for MTV Plan resources';

// --- ACM Addons for Virtualization ---
MERGE (mtv_addon:RHACMComponent {id: 'MTV_ADDON'})
ON CREATE SET 
  mtv_addon.label = 'MTV Addon',
  mtv_addon.subsystem = 'Cluster',
  mtv_addon.type = 'Addon',
  mtv_addon.description = 'ClusterManagementAddon for deploying MTV operator on spoke clusters';

MERGE (cnv_addon:RHACMComponent {id: 'CNV_ADDON'})
ON CREATE SET 
  cnv_addon.label = 'CNV Addon',
  cnv_addon.subsystem = 'Cluster',
  cnv_addon.type = 'Addon',
  cnv_addon.description = 'ClusterManagementAddon for deploying OpenShift Virtualization on spoke clusters';

// --- Fleet Virtualization UI ---
MERGE (fleet_virtualization:RHACMComponent {id: 'FLEET_VIRTUALIZATION'})
ON CREATE SET 
  fleet_virtualization.label = 'Fleet Virtualization',
  fleet_virtualization.subsystem = 'Console',
  fleet_virtualization.type = 'Component',
  fleet_virtualization.description = 'Multi-cluster VM management UI in ACM Console';

MERGE (vm_tree_view:RHACMComponent {id: 'VM_TREE_VIEW'})
ON CREATE SET 
  vm_tree_view.label = 'VM Tree View',
  vm_tree_view.subsystem = 'Console',
  vm_tree_view.type = 'Component',
  vm_tree_view.description = 'Hierarchical VM navigation across clusters in Console';

MERGE (vm_actions:RHACMComponent {id: 'VM_ACTIONS'})
ON CREATE SET 
  vm_actions.label = 'VM Actions',
  vm_actions.subsystem = 'Console',
  vm_actions.type = 'Component',
  vm_actions.description = 'VM lifecycle actions: Start, Stop, Restart, Pause, Unpause, Snapshot';

MERGE (vm_search_integration:RHACMComponent {id: 'VM_SEARCH_INTEGRATION'})
ON CREATE SET 
  vm_search_integration.label = 'VM Search Integration',
  vm_search_integration.subsystem = 'Search',
  vm_search_integration.type = 'Component',
  vm_search_integration.description = 'Search indexing for VirtualMachine resources across clusters';

// --- KubeVirt Console Plugin (kubevirt-ui) ---
MERGE (kubevirt_plugin:RHACMComponent {id: 'KUBEVIRT_PLUGIN'})
ON CREATE SET 
  kubevirt_plugin.label = 'KubeVirt Console Plugin',
  kubevirt_plugin.subsystem = 'Console',
  kubevirt_plugin.type = 'Component',
  kubevirt_plugin.description = 'OpenShift Console dynamic plugin for VM management UI';

// ============================================================================
// SECTION 5: FINE-GRAINED RBAC
// ============================================================================

// --- MultiClusterRoleAssignment Operator ---
MERGE (mcra_operator:RHACMComponent {id: 'MCRA_OPERATOR'})
ON CREATE SET 
  mcra_operator.label = 'MultiClusterRoleAssignment Operator',
  mcra_operator.subsystem = 'Cluster',
  mcra_operator.type = 'Operator',
  mcra_operator.description = 'Fine-Grained RBAC operator creating role bindings on managed clusters';

MERGE (mcra_crd:RHACMComponent {id: 'MCRA_CRD'})
ON CREATE SET 
  mcra_crd.label = 'MultiClusterRoleAssignment CRD',
  mcra_crd.subsystem = 'Cluster',
  mcra_crd.type = 'CRD',
  mcra_crd.description = 'API for assigning cluster roles to users/groups on managed clusters';

// --- ClusterPermission ---
MERGE (cluster_permission:RHACMComponent {id: 'CLUSTER_PERMISSION_CRD'})
ON CREATE SET 
  cluster_permission.label = 'ClusterPermission CRD',
  cluster_permission.subsystem = 'Cluster',
  cluster_permission.type = 'CRD',
  cluster_permission.description = 'API for creating role/clusterrole bindings on managed clusters'
ON MATCH SET
  cluster_permission.label = 'ClusterPermission CRD',
  cluster_permission.subsystem = 'Cluster',
  cluster_permission.type = 'CRD',
  cluster_permission.description = 'API for creating role/clusterrole bindings on managed clusters';

// --- Fine-Grained RBAC Search Integration ---
MERGE (rbac_fg_search:RHACMComponent {id: 'RBAC_FINE_GRAINED_SEARCH'})
ON CREATE SET 
  rbac_fg_search.label = 'Fine-Grained RBAC Search Integration',
  rbac_fg_search.subsystem = 'Search',
  rbac_fg_search.type = 'Component',
  rbac_fg_search.description = 'RBAC-aware search results filtering based on MCRA permissions';

// --- KubeVirt Standard Roles ---
MERGE (kubevirt_roles:RHACMComponent {id: 'KUBEVIRT_STANDARD_ROLES'})
ON CREATE SET 
  kubevirt_roles.label = 'KubeVirt Standard Roles',
  kubevirt_roles.subsystem = 'Cluster',
  kubevirt_roles.type = 'Component',
  kubevirt_roles.description = 'Standard ClusterRoles: kubevirt.io:admin, kubevirt.io:edit, kubevirt.io:view';

// --- RBAC UI Components ---
MERGE (rbac_ui:RHACMComponent {id: 'RBAC_UI'})
ON CREATE SET 
  rbac_ui.label = 'RBAC UI',
  rbac_ui.subsystem = 'Console',
  rbac_ui.type = 'Component',
  rbac_ui.description = 'Access Control UI for managing MCRA and ClusterPermission';

MERGE (access_management_ui:RHACMComponent {id: 'ACCESS_MANAGEMENT_UI'})
ON CREATE SET 
  access_management_ui.label = 'Access Management UI',
  access_management_ui.subsystem = 'Console',
  access_management_ui.type = 'Component',
  access_management_ui.description = 'Console UI for role assignment and permission management';

// ============================================================================
// SECTION 6: ADDITIONAL COMPONENTS (Tekton, Backup, Monitoring)
// ============================================================================

// --- Tekton Integration ---
MERGE (kubevirt_tekton:RHACMComponent {id: 'KUBEVIRT_TEKTON_TASKS'})
ON CREATE SET 
  kubevirt_tekton.label = 'KubeVirt Tekton Tasks',
  kubevirt_tekton.subsystem = 'Cluster',
  kubevirt_tekton.type = 'Component',
  kubevirt_tekton.description = 'VM-specific tasks for Tekton Pipelines (create VM, disk operations)',
  kubevirt_tekton.featureGated = true;

// --- Backup Integration ---
MERGE (kubevirt_velero:RHACMComponent {id: 'KUBEVIRT_VELERO_PLUGIN'})
ON CREATE SET 
  kubevirt_velero.label = 'KubeVirt Velero Plugin',
  kubevirt_velero.subsystem = 'Cluster',
  kubevirt_velero.type = 'Component',
  kubevirt_velero.description = 'Velero plugin for backup/restore of KubeVirt/CDI resources';

// --- Cluster API Provider ---
MERGE (capi_kubevirt:RHACMComponent {id: 'CLUSTER_API_PROVIDER_KUBEVIRT'})
ON CREATE SET 
  capi_kubevirt.label = 'Cluster API Provider KubeVirt',
  capi_kubevirt.subsystem = 'Cluster',
  capi_kubevirt.type = 'Component',
  capi_kubevirt.description = 'CAPI provider for provisioning clusters using KubeVirt VMs';

// ============================================================================
// SECTION 7: RELATIONSHIPS
// ============================================================================

// --- HCO manages CNV components ---
MATCH (hco:RHACMComponent {id: 'HCO_OPERATOR'})
MATCH (kubevirt:RHACMComponent {id: 'KUBEVIRT_OPERATOR'})
MERGE (hco)-[:MANAGES]->(kubevirt);

MATCH (hco:RHACMComponent {id: 'HCO_OPERATOR'})
MATCH (cdi:RHACMComponent {id: 'CDI_OPERATOR'})
MERGE (hco)-[:MANAGES]->(cdi);

MATCH (hco:RHACMComponent {id: 'HCO_OPERATOR'})
MATCH (ssp:RHACMComponent {id: 'SSP_OPERATOR'})
MERGE (hco)-[:MANAGES]->(ssp);

MATCH (hco:RHACMComponent {id: 'HCO_OPERATOR'})
MATCH (cnao:RHACMComponent {id: 'CNAO_OPERATOR'})
MERGE (hco)-[:MANAGES]->(cnao);

MATCH (hco:RHACMComponent {id: 'HCO_OPERATOR'})
MATCH (hostpath:RHACMComponent {id: 'HOSTPATH_PROVISIONER_OPERATOR'})
MERGE (hco)-[:MANAGES]->(hostpath);

// NMO removed from HCO management in CNV 4.18+; node retained as deprecated for historical reference

// --- SSP deploys templates ---
MATCH (ssp:RHACMComponent {id: 'SSP_OPERATOR'})
MATCH (templates:RHACMComponent {id: 'COMMON_TEMPLATES'})
MERGE (ssp)-[:DEPLOYS]->(templates);

MATCH (ssp:RHACMComponent {id: 'SSP_OPERATOR'})
MATCH (instancetypes:RHACMComponent {id: 'COMMON_INSTANCETYPES'})
MERGE (ssp)-[:DEPLOYS]->(instancetypes);

MATCH (ssp:RHACMComponent {id: 'SSP_OPERATOR'})
MATCH (console_proxy:RHACMComponent {id: 'VM_CONSOLE_PROXY'})
MERGE (ssp)-[:DEPLOYS]->(console_proxy);

// --- CNAO deploys network components ---
MATCH (cnao:RHACMComponent {id: 'CNAO_OPERATOR'})
MATCH (macvtap:RHACMComponent {id: 'MACVTAP_CNI'})
MERGE (cnao)-[:DEPLOYS]->(macvtap);

MATCH (cnao:RHACMComponent {id: 'CNAO_OPERATOR'})
MATCH (bridge:RHACMComponent {id: 'LINUX_BRIDGE_CNI'})
MERGE (cnao)-[:DEPLOYS]->(bridge);

MATCH (cnao:RHACMComponent {id: 'CNAO_OPERATOR'})
MATCH (dns:RHACMComponent {id: 'KUBESECONDARYDNS'})
MERGE (cnao)-[:DEPLOYS]->(dns);

// --- CDI relationships ---
MATCH (cdi:RHACMComponent {id: 'CDI_OPERATOR'})
MATCH (cdi_ctrl:RHACMComponent {id: 'CDI_CONTROLLER'})
MERGE (cdi)-[:MANAGES]->(cdi_ctrl);

MATCH (kubevirt:RHACMComponent {id: 'KUBEVIRT_OPERATOR'})
MATCH (cdi:RHACMComponent {id: 'CDI_OPERATOR'})
MERGE (kubevirt)-[:INTEGRATES_WITH]->(cdi);

// --- MTV Operator manages controllers ---
MATCH (mtv:RHACMComponent {id: 'MTV_OPERATOR'})
MATCH (forklift:RHACMComponent {id: 'FORKLIFT_CONTROLLER'})
MERGE (mtv)-[:MANAGES]->(forklift);

MATCH (forklift:RHACMComponent {id: 'FORKLIFT_CONTROLLER'})
MATCH (plan:RHACMComponent {id: 'MTV_PLAN_CONTROLLER'})
MERGE (forklift)-[:CONTAINS]->(plan);

MATCH (forklift:RHACMComponent {id: 'FORKLIFT_CONTROLLER'})
MATCH (migration:RHACMComponent {id: 'MTV_MIGRATION_CONTROLLER'})
MERGE (forklift)-[:CONTAINS]->(migration);

MATCH (forklift:RHACMComponent {id: 'FORKLIFT_CONTROLLER'})
MATCH (provider:RHACMComponent {id: 'MTV_PROVIDER_CONTROLLER'})
MERGE (forklift)-[:CONTAINS]->(provider);

MATCH (forklift:RHACMComponent {id: 'FORKLIFT_CONTROLLER'})
MATCH (netmap:RHACMComponent {id: 'MTV_NETWORK_MAP_CONTROLLER'})
MERGE (forklift)-[:CONTAINS]->(netmap);

MATCH (forklift:RHACMComponent {id: 'FORKLIFT_CONTROLLER'})
MATCH (storagemap:RHACMComponent {id: 'MTV_STORAGE_MAP_CONTROLLER'})
MERGE (forklift)-[:CONTAINS]->(storagemap);

MATCH (forklift:RHACMComponent {id: 'FORKLIFT_CONTROLLER'})
MATCH (hook:RHACMComponent {id: 'MTV_HOOK_CONTROLLER'})
MERGE (forklift)-[:CONTAINS]->(hook);

// --- MTV depends on KubeVirt ---
MATCH (mtv:RHACMComponent {id: 'MTV_OPERATOR'})
MATCH (kubevirt:RHACMComponent {id: 'KUBEVIRT_OPERATOR'})
MERGE (mtv)-[:DEPENDS_ON]->(kubevirt);

MATCH (mtv:RHACMComponent {id: 'MTV_OPERATOR'})
MATCH (cdi:RHACMComponent {id: 'CDI_OPERATOR'})
MERGE (mtv)-[:DEPENDS_ON]->(cdi);

// --- Volume populators ---
MATCH (forklift:RHACMComponent {id: 'FORKLIFT_CONTROLLER'})
MATCH (ovirt:RHACMComponent {id: 'OVIRT_VOLUME_POPULATOR'})
MERGE (forklift)-[:USES]->(ovirt);

MATCH (forklift:RHACMComponent {id: 'FORKLIFT_CONTROLLER'})
MATCH (openstack:RHACMComponent {id: 'OPENSTACK_VOLUME_POPULATOR'})
MERGE (forklift)-[:USES]->(openstack);

MATCH (forklift:RHACMComponent {id: 'FORKLIFT_CONTROLLER'})
MATCH (vsphere:RHACMComponent {id: 'VSPHERE_XCOPY_VOLUME_POPULATOR'})
MERGE (forklift)-[:USES]->(vsphere);

MATCH (forklift:RHACMComponent {id: 'FORKLIFT_CONTROLLER'})
MATCH (v2v:RHACMComponent {id: 'VIRT_V2V'})
MERGE (forklift)-[:USES]->(v2v);

// --- CCLM relationships ---
MATCH (cclm:RHACMComponent {id: 'CCLM'})
MATCH (cclm_op:RHACMComponent {id: 'KUBEVIRT_MIGRATION_OPERATOR'})
MERGE (cclm)-[:USES]->(cclm_op);

MATCH (cclm_op:RHACMComponent {id: 'KUBEVIRT_MIGRATION_OPERATOR'})
MATCH (cclm_ctrl:RHACMComponent {id: 'KUBEVIRT_MIGRATION_CONTROLLER'})
MERGE (cclm_op)-[:MANAGES]->(cclm_ctrl);

MATCH (cclm:RHACMComponent {id: 'CCLM'})
MATCH (kubevirt:RHACMComponent {id: 'KUBEVIRT_OPERATOR'})
MERGE (cclm)-[:DEPENDS_ON]->(kubevirt);

// --- ACM MTV Integrations ---
MATCH (mtv_int:RHACMComponent {id: 'MTV_INTEGRATIONS'})
MATCH (provider_mgr:RHACMComponent {id: 'PROVIDER_MANAGER_CONTROLLER'})
MERGE (mtv_int)-[:CONTAINS]->(provider_mgr);

MATCH (mtv_int:RHACMComponent {id: 'MTV_INTEGRATIONS'})
MATCH (webhook:RHACMComponent {id: 'MTV_PLAN_WEBHOOK'})
MERGE (mtv_int)-[:CONTAINS]->(webhook);

MATCH (mtv_int:RHACMComponent {id: 'MTV_INTEGRATIONS'})
MATCH (mtv_addon:RHACMComponent {id: 'MTV_ADDON'})
MERGE (mtv_int)-[:DEPLOYS]->(mtv_addon);

MATCH (mtv_int:RHACMComponent {id: 'MTV_INTEGRATIONS'})
MATCH (cnv_addon:RHACMComponent {id: 'CNV_ADDON'})
MERGE (mtv_int)-[:DEPLOYS]->(cnv_addon);

// --- Addons manage operators on spokes ---
MATCH (mtv_addon:RHACMComponent {id: 'MTV_ADDON'})
MATCH (mtv:RHACMComponent {id: 'MTV_OPERATOR'})
MERGE (mtv_addon)-[:MANAGES]->(mtv);

MATCH (cnv_addon:RHACMComponent {id: 'CNV_ADDON'})
MATCH (hco:RHACMComponent {id: 'HCO_OPERATOR'})
MERGE (cnv_addon)-[:MANAGES]->(hco);

// --- Fleet Virtualization relationships ---
MATCH (fleet:RHACMComponent {id: 'FLEET_VIRTUALIZATION'})
MATCH (search:RHACMComponent {label: 'Search & Discovery'})
MERGE (fleet)-[:USES]->(search);

MATCH (console:RHACMComponent {label: 'Web Console'})
MATCH (fleet:RHACMComponent {id: 'FLEET_VIRTUALIZATION'})
MERGE (console)-[:PROVIDES_UI_FOR]->(fleet);

MATCH (fleet:RHACMComponent {id: 'FLEET_VIRTUALIZATION'})
MATCH (tree:RHACMComponent {id: 'VM_TREE_VIEW'})
MERGE (fleet)-[:CONTAINS]->(tree);

MATCH (fleet:RHACMComponent {id: 'FLEET_VIRTUALIZATION'})
MATCH (actions:RHACMComponent {id: 'VM_ACTIONS'})
MERGE (fleet)-[:CONTAINS]->(actions);

MATCH (fleet:RHACMComponent {id: 'FLEET_VIRTUALIZATION'})
MATCH (vm_search:RHACMComponent {id: 'VM_SEARCH_INTEGRATION'})
MERGE (fleet)-[:USES]->(vm_search);

// --- Fine-Grained RBAC relationships ---
MATCH (mcra:RHACMComponent {id: 'MCRA_OPERATOR'})
MATCH (mcra_crd:RHACMComponent {id: 'MCRA_CRD'})
MERGE (mcra)-[:MANAGES]->(mcra_crd);

MATCH (mcra:RHACMComponent {id: 'MCRA_OPERATOR'})
MATCH (mc:RHACMComponent {label: 'Managed Clusters'})
MERGE (mcra)-[:MANAGES]->(mc);

MATCH (rbac_search:RHACMComponent {id: 'RBAC_FINE_GRAINED_SEARCH'})
MATCH (mcra:RHACMComponent {id: 'MCRA_OPERATOR'})
MERGE (rbac_search)-[:DEPENDS_ON]->(mcra);

MATCH (fleet:RHACMComponent {id: 'FLEET_VIRTUALIZATION'})
MATCH (mcra:RHACMComponent {id: 'MCRA_OPERATOR'})
MERGE (fleet)-[:INTEGRATES_WITH]->(mcra);

MATCH (rbac_ui:RHACMComponent {id: 'RBAC_UI'})
MATCH (mcra:RHACMComponent {id: 'MCRA_OPERATOR'})
MERGE (rbac_ui)-[:PROVIDES_UI_FOR]->(mcra);

MATCH (rbac_ui:RHACMComponent {id: 'RBAC_UI'})
MATCH (cluster_perm:RHACMComponent {id: 'CLUSTER_PERMISSION_CRD'})
MERGE (rbac_ui)-[:PROVIDES_UI_FOR]->(cluster_perm);

MATCH (access_ui:RHACMComponent {id: 'ACCESS_MANAGEMENT_UI'})
MATCH (rbac_ui:RHACMComponent {id: 'RBAC_UI'})
MERGE (access_ui)-[:CONTAINS]->(rbac_ui);

// --- KubeVirt roles ---
MATCH (mcra:RHACMComponent {id: 'MCRA_OPERATOR'})
MATCH (kv_roles:RHACMComponent {id: 'KUBEVIRT_STANDARD_ROLES'})
MERGE (mcra)-[:USES]->(kv_roles);

// --- Console plugin relationships ---
MATCH (console:RHACMComponent {label: 'Web Console'})
MATCH (kv_plugin:RHACMComponent {id: 'KUBEVIRT_PLUGIN'})
MERGE (console)-[:USES]->(kv_plugin);

// Forklift Console Plugin is an OCP console plugin (not ACM console), part of MTV stack
MATCH (forklift_console:RHACMComponent {id: 'FORKLIFT_CONSOLE_PLUGIN'})
MATCH (mtv:RHACMComponent {id: 'MTV_OPERATOR'})
MERGE (forklift_console)-[:INTEGRATES_WITH]->(mtv);

// --- API relationships (added 2026-02-02) ---
// KubeVirt Operator provides KubeVirt API (VM, VMI, DataVolume CRDs)
MATCH (kubevirt:RHACMComponent {id: 'KUBEVIRT_OPERATOR'})
MATCH (api:RHACMComponent {id: 'KUBEVIRT_API'})
MERGE (kubevirt)-[:PROVIDES_API]->(api);

// Forklift Controller provides Forklift API (Migration, Plan, Provider CRDs)
MATCH (forklift:RHACMComponent {id: 'FORKLIFT_CONTROLLER'})
MATCH (api:RHACMComponent {id: 'FORKLIFT_API'})
MERGE (forklift)-[:PROVIDES_API]->(api);

// --- ContainerDisks relationship ---
// KubeVirt uses ContainerDisks as bootable OCI disk images (bypasses CDI/PVC)
MATCH (kubevirt:RHACMComponent {id: 'KUBEVIRT_OPERATOR'})
MATCH (disks:RHACMComponent {id: 'CONTAINERDISKS'})
MERGE (kubevirt)-[:USES]->(disks);

// --- Provider Server relationships ---
// Provider Controller uses OVA Provider Server for OVA file imports
MATCH (provider:RHACMComponent {id: 'MTV_PROVIDER_CONTROLLER'})
MATCH (ova:RHACMComponent {id: 'OVA_PROVIDER_SERVER'})
MERGE (provider)-[:USES]->(ova);

// Provider Controller uses Hyper-V Provider Server for Hyper-V migrations
MATCH (provider:RHACMComponent {id: 'MTV_PROVIDER_CONTROLLER'})
MATCH (hyperv:RHACMComponent {id: 'HYPERV_PROVIDER_SERVER'})
MERGE (provider)-[:USES]->(hyperv);

// Migration Planner is a standalone Red Hat SaaS, not directly integrated with MTV Integrations controller

// --- Tekton Tasks relationships ---
// SSP Operator deploys KubeVirt Tekton Tasks
MATCH (ssp:RHACMComponent {id: 'SSP_OPERATOR'})
MATCH (tekton:RHACMComponent {id: 'KUBEVIRT_TEKTON_TASKS'})
MERGE (ssp)-[:DEPLOYS]->(tekton);

// Tekton Tasks integrate with KubeVirt for VM automation
MATCH (tekton:RHACMComponent {id: 'KUBEVIRT_TEKTON_TASKS'})
MATCH (kubevirt:RHACMComponent {id: 'KUBEVIRT_OPERATOR'})
MERGE (tekton)-[:INTEGRATES_WITH]->(kubevirt);

// --- Velero Plugin relationships ---
// OADP Operator uses KubeVirt Velero Plugin for VM backup
MATCH (oadp:RHACMComponent {id: 'OADP_OPERATOR'})
MATCH (velero_plugin:RHACMComponent {id: 'KUBEVIRT_VELERO_PLUGIN'})
MERGE (oadp)-[:USES]->(velero_plugin);

// Velero Plugin integrates with KubeVirt for backup/restore
MATCH (velero_plugin:RHACMComponent {id: 'KUBEVIRT_VELERO_PLUGIN'})
MATCH (kubevirt:RHACMComponent {id: 'KUBEVIRT_OPERATOR'})
MERGE (velero_plugin)-[:INTEGRATES_WITH]->(kubevirt);

// --- CAPI KubeVirt relationships ---
// CAPI Provider Integration contains Cluster API Provider KubeVirt
MATCH (capi:RHACMComponent {id: 'CAPI_PROVIDER_INTEGRATION'})
MATCH (capi_kv:RHACMComponent {id: 'CLUSTER_API_PROVIDER_KUBEVIRT'})
MERGE (capi)-[:CONTAINS]->(capi_kv);

// CAPI KubeVirt uses KubeVirt to provision VMs as cluster nodes
MATCH (capi_kv:RHACMComponent {id: 'CLUSTER_API_PROVIDER_KUBEVIRT'})
MATCH (kubevirt:RHACMComponent {id: 'KUBEVIRT_OPERATOR'})
MERGE (capi_kv)-[:USES]->(kubevirt);

// ============================================================================
// SECTION 8: HIVE / CLUSTER PROVISIONING SUBSYSTEM
// ============================================================================
// Added: 2026-04-02 (Knowledge Graph Expansion - Rank 1)
// Verified: ACM 2.16 GA cluster (CNV 4.21.1) + stolostron/console release-2.16
// Verification: oc get crd (26 Hive CRDs), oc get pods -n hive (5 pods),
//   7 validating webhooks, ACM Console source code (20+ files per CRD)
// Components: 11 new | Relationships: 20 new
// ============================================================================

// --- Hive Controllers (main reconciliation engine) ---
MERGE (hive_controllers:RHACMComponent {id: 'HIVE_CONTROLLERS'})
ON CREATE SET
  hive_controllers.label = 'Hive Controllers',
  hive_controllers.subsystem = 'Cluster',
  hive_controllers.type = 'Controller',
  hive_controllers.description = 'Main Hive reconciliation engine managing ClusterDeployment, MachinePool, DNSZone, and ClusterDeprovision lifecycle';

// --- Hive Admission (webhook validation) ---
MERGE (hiveadmission:RHACMComponent {id: 'HIVEADMISSION'})
ON CREATE SET
  hiveadmission.label = 'Hive Admission Controller',
  hiveadmission.subsystem = 'Cluster',
  hiveadmission.type = 'Component',
  hiveadmission.description = 'Validating admission webhooks for Hive CRDs (ClusterDeployment, ClusterImageSet, MachinePool, SyncSet, DNSZone)';

// --- Hive ClusterSync (SyncSet delivery) ---
MERGE (hive_clustersync:RHACMComponent {id: 'HIVE_CLUSTERSYNC'})
ON CREATE SET
  hive_clustersync.label = 'Hive ClusterSync',
  hive_clustersync.subsystem = 'Cluster',
  hive_clustersync.type = 'Controller',
  hive_clustersync.description = 'Syncs SyncSet and SelectorSyncSet resources to managed clusters via ClusterSync';

// --- ClusterDeployment CRD ---
MERGE (cluster_deployment:RHACMComponent {id: 'CLUSTER_DEPLOYMENT_CRD'})
ON CREATE SET
  cluster_deployment.label = 'ClusterDeployment CRD',
  cluster_deployment.subsystem = 'Cluster',
  cluster_deployment.type = 'CRD',
  cluster_deployment.description = 'Core Hive API for cluster creation, representing a desired managed cluster with platform, networking, and install config';

// --- ClusterImageSet CRD ---
MERGE (cluster_imageset:RHACMComponent {id: 'CLUSTER_IMAGE_SET_CRD'})
ON CREATE SET
  cluster_imageset.label = 'ClusterImageSet CRD',
  cluster_imageset.subsystem = 'Cluster',
  cluster_imageset.type = 'CRD',
  cluster_imageset.description = 'Available OCP release versions for cluster provisioning, referenced by ClusterDeployment';

// --- MachinePool CRD ---
MERGE (machine_pool:RHACMComponent {id: 'MACHINE_POOL_CRD'})
ON CREATE SET
  machine_pool.label = 'MachinePool CRD',
  machine_pool.subsystem = 'Cluster',
  machine_pool.type = 'CRD',
  machine_pool.description = 'Worker node pool definition for Hive-provisioned clusters with scaling (min/max replicas, autoscaling)';

// --- ClusterProvision CRD ---
MERGE (cluster_provision:RHACMComponent {id: 'CLUSTER_PROVISION_CRD'})
ON CREATE SET
  cluster_provision.label = 'ClusterProvision CRD',
  cluster_provision.subsystem = 'Cluster',
  cluster_provision.type = 'CRD',
  cluster_provision.description = 'Tracks individual provisioning attempts for a ClusterDeployment including install log and status';

// --- SyncSet CRD ---
MERGE (syncset:RHACMComponent {id: 'SYNCSET_CRD'})
ON CREATE SET
  syncset.label = 'SyncSet CRD',
  syncset.subsystem = 'Cluster',
  syncset.type = 'CRD',
  syncset.description = 'Day-2 configuration delivery to specific Hive-provisioned clusters (resources, patches, secrets)';

// --- SelectorSyncSet CRD ---
MERGE (selector_syncset:RHACMComponent {id: 'SELECTOR_SYNCSET_CRD'})
ON CREATE SET
  selector_syncset.label = 'SelectorSyncSet CRD',
  selector_syncset.subsystem = 'Cluster',
  selector_syncset.type = 'CRD',
  selector_syncset.description = 'Label-selector-based SyncSet applying day-2 config to all matching ClusterDeployments';

// --- DNSZone CRD ---
MERGE (dnszone:RHACMComponent {id: 'DNS_ZONE_CRD'})
ON CREATE SET
  dnszone.label = 'DNSZone CRD',
  dnszone.subsystem = 'Cluster',
  dnszone.type = 'CRD',
  dnszone.description = 'Cloud DNS zone management for cluster domains (AWS Route53, Azure DNS, GCP Cloud DNS)';

// --- ClusterDeprovision CRD ---
MERGE (cluster_deprovision:RHACMComponent {id: 'CLUSTER_DEPROVISION_CRD'})
ON CREATE SET
  cluster_deprovision.label = 'ClusterDeprovision CRD',
  cluster_deprovision.subsystem = 'Cluster',
  cluster_deprovision.type = 'CRD',
  cluster_deprovision.description = 'Tracks cloud resource cleanup when a ClusterDeployment is deleted';

// --- Hive Operator manages its controllers ---
MATCH (hive:RHACMComponent {id: 'HIVE'})
MATCH (hive_ctrl:RHACMComponent {id: 'HIVE_CONTROLLERS'})
MERGE (hive)-[:MANAGES]->(hive_ctrl);

MATCH (hive:RHACMComponent {id: 'HIVE'})
MATCH (hiveadm:RHACMComponent {id: 'HIVEADMISSION'})
MERGE (hive)-[:MANAGES]->(hiveadm);

MATCH (hive:RHACMComponent {id: 'HIVE'})
MATCH (hive_cs:RHACMComponent {id: 'HIVE_CLUSTERSYNC'})
MERGE (hive)-[:MANAGES]->(hive_cs);

// --- Hive Controllers reconcile CRDs ---
MATCH (hive_ctrl:RHACMComponent {id: 'HIVE_CONTROLLERS'})
MATCH (cd:RHACMComponent {id: 'CLUSTER_DEPLOYMENT_CRD'})
MERGE (hive_ctrl)-[:MANAGES]->(cd);

MATCH (hive_ctrl:RHACMComponent {id: 'HIVE_CONTROLLERS'})
MATCH (mp:RHACMComponent {id: 'MACHINE_POOL_CRD'})
MERGE (hive_ctrl)-[:MANAGES]->(mp);

MATCH (hive_ctrl:RHACMComponent {id: 'HIVE_CONTROLLERS'})
MATCH (cp:RHACMComponent {id: 'CLUSTER_PROVISION_CRD'})
MERGE (hive_ctrl)-[:MANAGES]->(cp);

MATCH (hive_ctrl:RHACMComponent {id: 'HIVE_CONTROLLERS'})
MATCH (dnsz:RHACMComponent {id: 'DNS_ZONE_CRD'})
MERGE (hive_ctrl)-[:MANAGES]->(dnsz);

MATCH (hive_ctrl:RHACMComponent {id: 'HIVE_CONTROLLERS'})
MATCH (deprov:RHACMComponent {id: 'CLUSTER_DEPROVISION_CRD'})
MERGE (hive_ctrl)-[:MANAGES]->(deprov);

// --- Hive ClusterSync manages SyncSet delivery ---
MATCH (hive_cs:RHACMComponent {id: 'HIVE_CLUSTERSYNC'})
MATCH (ss:RHACMComponent {id: 'SYNCSET_CRD'})
MERGE (hive_cs)-[:MANAGES]->(ss);

MATCH (hive_cs:RHACMComponent {id: 'HIVE_CLUSTERSYNC'})
MATCH (sss:RHACMComponent {id: 'SELECTOR_SYNCSET_CRD'})
MERGE (hive_cs)-[:MANAGES]->(sss);

// --- Hive Admission validates CRDs ---
MATCH (hiveadm:RHACMComponent {id: 'HIVEADMISSION'})
MATCH (cd:RHACMComponent {id: 'CLUSTER_DEPLOYMENT_CRD'})
MERGE (hiveadm)-[:VALIDATES_VIA]->(cd);

MATCH (hiveadm:RHACMComponent {id: 'HIVEADMISSION'})
MATCH (cis:RHACMComponent {id: 'CLUSTER_IMAGE_SET_CRD'})
MERGE (hiveadm)-[:VALIDATES_VIA]->(cis);

// --- ClusterDeployment depends on ClusterImageSet for OCP release ---
MATCH (cd:RHACMComponent {id: 'CLUSTER_DEPLOYMENT_CRD'})
MATCH (cis:RHACMComponent {id: 'CLUSTER_IMAGE_SET_CRD'})
MERGE (cd)-[:DEPENDS_ON]->(cis);

// --- ClusterDeployment uses Cloud Provider Secrets ---
MATCH (cd:RHACMComponent {id: 'CLUSTER_DEPLOYMENT_CRD'})
MATCH (creds:RHACMComponent {label: 'Cloud Provider Secrets'})
MERGE (cd)-[:USES]->(creds);

// --- ClusterPools creates ClusterDeployments ---
MATCH (pools:RHACMComponent {id: 'CLUSTER_POOLS'})
MATCH (cd:RHACMComponent {id: 'CLUSTER_DEPLOYMENT_CRD'})
MERGE (pools)-[:USES]->(cd);

// --- ClusterImageSet controller syncs to ClusterImageSet CRD ---
MATCH (cis_ctrl:RHACMComponent {id: 'CLUSTER_IMAGESET_CTRL'})
MATCH (cis:RHACMComponent {id: 'CLUSTER_IMAGE_SET_CRD'})
MERGE (cis_ctrl)-[:MANAGES]->(cis);

// --- ClusterDeployment creates ClusterProvision attempts ---
MATCH (cd:RHACMComponent {id: 'CLUSTER_DEPLOYMENT_CRD'})
MATCH (cp:RHACMComponent {id: 'CLUSTER_PROVISION_CRD'})
MERGE (cd)-[:CREATES]->(cp);

// --- ClusterDeployment contains MachinePool for worker scaling ---
MATCH (cd:RHACMComponent {id: 'CLUSTER_DEPLOYMENT_CRD'})
MATCH (mp:RHACMComponent {id: 'MACHINE_POOL_CRD'})
MERGE (cd)-[:CONTAINS]->(mp);

// --- ClusterDeployment creates DNSZone for domain ---
MATCH (cd:RHACMComponent {id: 'CLUSTER_DEPLOYMENT_CRD'})
MATCH (dnsz:RHACMComponent {id: 'DNS_ZONE_CRD'})
MERGE (cd)-[:CREATES]->(dnsz);

// --- Cluster Provisioning Engine uses ClusterDeployment ---
MATCH (cpe:RHACMComponent {id: 'CLUSTER_PROVISIONING_ENGINE'})
MATCH (cd:RHACMComponent {id: 'CLUSTER_DEPLOYMENT_CRD'})
MERGE (cpe)-[:USES]->(cd);

// ============================================================================
// SECTION 9: KLUSTERLET / SPOKE AGENT SUBSYSTEM
// ============================================================================
// Added: 2026-04-02 (Knowledge Graph Expansion - Rank 2)
// Verified: ACM 2.16 GA cluster + stolostron/console release-2.16
// Cluster: open-cluster-management-agent (4 pods), open-cluster-management-hub
//   (14 pods), open-cluster-management-agent-addon (9 addon agents)
// CRDs: klusterlets, klusterletconfigs, klusterletaddonconfigs,
//   appliedmanifestworks, manifestworkreplicasets
// Source code: klusterlet (20 files), KlusterletAddonConfig (resource file),
//   ManagedClusterCondition (20 files)
// Backend-only (verified on cluster, no console UI code):
//   registration-controller, work-webhook, addon-manager-controller, addon-webhook
// Components: 8 new | Relationships: 14 new
// ============================================================================

// --- Klusterlet Agent (combined registration+work agent on spoke) ---
MERGE (klusterlet_agent:RHACMComponent {id: 'KLUSTERLET_AGENT'})
ON CREATE SET
  klusterlet_agent.label = 'Klusterlet Agent',
  klusterlet_agent.subsystem = 'Cluster',
  klusterlet_agent.type = 'Component',
  klusterlet_agent.description = 'Combined registration and work agent running on managed clusters (3 replicas), handles cluster registration and ManifestWork application';

// --- Registration Controller (hub-side) ---
MERGE (registration_controller:RHACMComponent {id: 'REGISTRATION_CONTROLLER'})
ON CREATE SET
  registration_controller.label = 'Registration Controller',
  registration_controller.subsystem = 'Cluster',
  registration_controller.type = 'Controller',
  registration_controller.description = 'Hub-side controller managing managed cluster registration, CSR approval, and lease renewal';

// --- Work Webhook (hub-side) ---
MERGE (work_webhook:RHACMComponent {id: 'WORK_WEBHOOK'})
ON CREATE SET
  work_webhook.label = 'Work Webhook',
  work_webhook.subsystem = 'Cluster',
  work_webhook.type = 'Component',
  work_webhook.description = 'Hub-side validating webhook for ManifestWork resources';

// --- Klusterlet CRD ---
MERGE (klusterlet_crd:RHACMComponent {id: 'KLUSTERLET_CRD'})
ON CREATE SET
  klusterlet_crd.label = 'Klusterlet CRD',
  klusterlet_crd.subsystem = 'Cluster',
  klusterlet_crd.type = 'CRD',
  klusterlet_crd.description = 'Operator CR defining Klusterlet deployment mode (Default/Hosted), namespace, and feature gates on managed clusters';

// --- KlusterletAddonConfig CRD ---
MERGE (klusterlet_addon_config:RHACMComponent {id: 'KLUSTERLET_ADDON_CONFIG_CRD'})
ON CREATE SET
  klusterlet_addon_config.label = 'KlusterletAddonConfig CRD',
  klusterlet_addon_config.subsystem = 'Cluster',
  klusterlet_addon_config.type = 'CRD',
  klusterlet_addon_config.description = 'Per-cluster addon deployment configuration controlling which addons are enabled (search, policy, proxy, IAM)';

// --- AppliedManifestWork CRD ---
MERGE (applied_manifestwork:RHACMComponent {id: 'APPLIED_MANIFESTWORK_CRD'})
ON CREATE SET
  applied_manifestwork.label = 'AppliedManifestWork CRD',
  applied_manifestwork.subsystem = 'Cluster',
  applied_manifestwork.type = 'CRD',
  applied_manifestwork.description = 'Spoke-side record of ManifestWork resources applied by the work agent, tracking applied resources and status';

// --- Addon Manager Controller (hub-side) ---
MERGE (addon_manager_ctrl:RHACMComponent {id: 'ADDON_MANAGER_CONTROLLER'})
ON CREATE SET
  addon_manager_ctrl.label = 'Addon Manager Controller',
  addon_manager_ctrl.subsystem = 'Cluster',
  addon_manager_ctrl.type = 'Controller',
  addon_manager_ctrl.description = 'Hub-side controller deploying and managing addon agents on managed clusters via ManagedClusterAddon CRs';

// --- Addon Webhook (hub-side) ---
MERGE (addon_webhook:RHACMComponent {id: 'ADDON_WEBHOOK'})
ON CREATE SET
  addon_webhook.label = 'Addon Webhook',
  addon_webhook.subsystem = 'Cluster',
  addon_webhook.type = 'Component',
  addon_webhook.description = 'Hub-side validating webhook for ManagedClusterAddon and ClusterManagementAddon resources';

// --- Klusterlet operator manages its agent and CRD ---
MATCH (klusterlet:RHACMComponent {id: 'KLUSTERLET'})
MATCH (kl_agent:RHACMComponent {id: 'KLUSTERLET_AGENT'})
MERGE (klusterlet)-[:MANAGES]->(kl_agent);

MATCH (klusterlet:RHACMComponent {id: 'KLUSTERLET'})
MATCH (kl_crd:RHACMComponent {id: 'KLUSTERLET_CRD'})
MERGE (klusterlet)-[:MANAGES]->(kl_crd);

// --- Klusterlet Agent connects to hub registration and work services ---
MATCH (kl_agent:RHACMComponent {id: 'KLUSTERLET_AGENT'})
MATCH (reg:RHACMComponent {id: 'REGISTRATION'})
MERGE (kl_agent)-[:USES]->(reg);

MATCH (kl_agent:RHACMComponent {id: 'KLUSTERLET_AGENT'})
MATCH (work:RHACMComponent {id: 'WORK'})
MERGE (kl_agent)-[:USES]->(work);

MATCH (kl_agent:RHACMComponent {id: 'KLUSTERLET_AGENT'})
MATCH (reg_wh:RHACMComponent {id: 'REGISTRATION_WEBHOOK'})
MERGE (kl_agent)-[:USES]->(reg_wh);

// --- Klusterlet Agent creates AppliedManifestWork on spoke ---
MATCH (kl_agent:RHACMComponent {id: 'KLUSTERLET_AGENT'})
MATCH (amw:RHACMComponent {id: 'APPLIED_MANIFESTWORK_CRD'})
MERGE (kl_agent)-[:CREATES]->(amw);

// --- Registration Operator manages hub-side Registration Controller ---
MATCH (reg_op:RHACMComponent {id: 'REGISTRATION_OPERATOR'})
MATCH (reg_ctrl:RHACMComponent {id: 'REGISTRATION_CONTROLLER'})
MERGE (reg_op)-[:MANAGES]->(reg_ctrl);

// --- Registration Controller provides hub-side registration service ---
MATCH (reg_ctrl:RHACMComponent {id: 'REGISTRATION_CONTROLLER'})
MATCH (reg:RHACMComponent {id: 'REGISTRATION'})
MERGE (reg_ctrl)-[:MANAGES]->(reg);

// --- Work Management includes Work Webhook ---
MATCH (work:RHACMComponent {id: 'WORK'})
MATCH (work_wh:RHACMComponent {id: 'WORK_WEBHOOK'})
MERGE (work)-[:CONTAINS]->(work_wh);

// --- ManifestWork creates AppliedManifestWork on spoke ---
MATCH (mw:RHACMComponent {id: 'MANIFESTWORK'})
MATCH (amw:RHACMComponent {id: 'APPLIED_MANIFESTWORK_CRD'})
MERGE (mw)-[:CREATES]->(amw);

// --- Addon Framework manages hub controllers ---
MATCH (addon:RHACMComponent {id: 'ADDON'})
MATCH (addon_ctrl:RHACMComponent {id: 'ADDON_MANAGER_CONTROLLER'})
MERGE (addon)-[:MANAGES]->(addon_ctrl);

MATCH (addon:RHACMComponent {id: 'ADDON'})
MATCH (addon_wh:RHACMComponent {id: 'ADDON_WEBHOOK'})
MERGE (addon)-[:CONTAINS]->(addon_wh);

// --- Klusterlet Addon Controller uses KlusterletAddonConfig CRD ---
MATCH (kl_addon_ctrl:RHACMComponent {id: 'KLUSTERLET_ADDON_CTRL'})
MATCH (kl_addon_cfg:RHACMComponent {id: 'KLUSTERLET_ADDON_CONFIG_CRD'})
MERGE (kl_addon_ctrl)-[:MANAGES]->(kl_addon_cfg);

// --- Addon Manager Controller uses KlusterletAddonConfig to deploy addons ---
MATCH (addon_ctrl:RHACMComponent {id: 'ADDON_MANAGER_CONTROLLER'})
MATCH (kl_addon_cfg:RHACMComponent {id: 'KLUSTERLET_ADDON_CONFIG_CRD'})
MERGE (addon_ctrl)-[:USES]->(kl_addon_cfg);

// ============================================================================
// SECTION 10: ADDON FRAMEWORK DEEP DIVE
// ============================================================================
// Added: 2026-04-03 (Knowledge Graph Expansion - Rank 3)
// Verified: ACM 2.16 GA cluster + stolostron/console release-2.16
// CRDs: clustermanagementaddons (17 instances), addontemplates (6 instances),
//   addondeploymentconfigs (1 instance)
// Source code: ClusterManagementAddOn (20 files, dedicated resource file),
//   ManagedClusterAddOn (20 files, dedicated resource file + backend lib),
//   AddOnTemplate (3 files), AddonDeploymentConfig (3 files)
// Cluster verification: CMA spec.defaultConfigs verified to reference
//   addontemplates (kubevirt-hyperconverged, managed-serviceaccount) and
//   addondeploymentconfigs (search-collector, managed-serviceaccount)
// Components: 3 new | Relationships: 6 new
// ============================================================================

// --- ClusterManagementAddOn CRD (global addon definition) ---
MERGE (cma_crd:RHACMComponent {id: 'CLUSTER_MANAGEMENT_ADDON_CRD'})
ON CREATE SET
  cma_crd.label = 'ClusterManagementAddOn CRD',
  cma_crd.subsystem = 'Cluster',
  cma_crd.type = 'CRD',
  cma_crd.description = 'Global addon definition specifying display name, install strategy (Manual/Placements), default configs, and template references';

// --- AddOnTemplate CRD ---
MERGE (addon_template:RHACMComponent {id: 'ADDON_TEMPLATE_CRD'})
ON CREATE SET
  addon_template.label = 'AddOnTemplate CRD',
  addon_template.subsystem = 'Cluster',
  addon_template.type = 'CRD',
  addon_template.description = 'Template-based addon deployment mechanism defining agent manifests and registration config for spoke clusters';

// --- AddonDeploymentConfig CRD ---
MERGE (addon_deploy_cfg:RHACMComponent {id: 'ADDON_DEPLOYMENT_CONFIG_CRD'})
ON CREATE SET
  addon_deploy_cfg.label = 'AddonDeploymentConfig CRD',
  addon_deploy_cfg.subsystem = 'Cluster',
  addon_deploy_cfg.type = 'CRD',
  addon_deploy_cfg.description = 'Addon deployment configuration for customizing nodeSelector, tolerations, proxy settings, and resource limits';

// --- Connect existing Addon Framework concept to addon-framework component ---
MATCH (addon:RHACMComponent {id: 'ADDON'})
MATCH (addon_fw:RHACMComponent {id: 'ADDON_FRAMEWORK'})
MERGE (addon)-[:CONTAINS]->(addon_fw);

// --- addon-framework manages ClusterManagementAddOn CRD ---
MATCH (addon_fw:RHACMComponent {id: 'ADDON_FRAMEWORK'})
MATCH (cma:RHACMComponent {id: 'CLUSTER_MANAGEMENT_ADDON_CRD'})
MERGE (addon_fw)-[:MANAGES]->(cma);

// --- Addon Manager Controller reconciles ClusterManagementAddOn ---
MATCH (addon_ctrl:RHACMComponent {id: 'ADDON_MANAGER_CONTROLLER'})
MATCH (cma:RHACMComponent {id: 'CLUSTER_MANAGEMENT_ADDON_CRD'})
MERGE (addon_ctrl)-[:MANAGES]->(cma);

// --- ClusterManagementAddOn auto-creates ManagedClusterAddOn per-cluster ---
MATCH (cma:RHACMComponent {id: 'CLUSTER_MANAGEMENT_ADDON_CRD'})
MATCH (mca:RHACMComponent {id: 'MANAGEDCLUSTER_ADDON'})
MERGE (cma)-[:CREATES]->(mca);

// --- ClusterManagementAddOn references AddOnTemplate for deployment ---
MATCH (cma:RHACMComponent {id: 'CLUSTER_MANAGEMENT_ADDON_CRD'})
MATCH (tmpl:RHACMComponent {id: 'ADDON_TEMPLATE_CRD'})
MERGE (cma)-[:USES]->(tmpl);

// --- ClusterManagementAddOn references AddonDeploymentConfig ---
MATCH (cma:RHACMComponent {id: 'CLUSTER_MANAGEMENT_ADDON_CRD'})
MATCH (cfg:RHACMComponent {id: 'ADDON_DEPLOYMENT_CONFIG_CRD'})
MERGE (cma)-[:USES]->(cfg);

// ============================================================================
// SECTION 11: HYPERSHIFT / HOSTED CONTROL PLANES
// ============================================================================
// Added: 2026-04-03 (Knowledge Graph Expansion - Rank 7)
// Verified: ACM 2.16 GA cluster + stolostron/console release-2.16
// Cluster: hypershift namespace (2 operator pods), 11 HyperShift CRDs
//   (hostedclusters, nodepools, hostedcontrolplanes, controlplanecomponents, etc.)
// Source code: HostedCluster (20 files, dedicated resource file),
//   NodePool (20 files, dedicated resource file, form/table/progress/modal),
//   HostedControlPlane (11 files), hypershift (20 files, wizard/template/status)
// Components: 4 new | Relationships: 6 new
// ============================================================================

// --- HyperShift Operator (manages hosted clusters) ---
MERGE (hypershift_op:RHACMComponent {id: 'HYPERSHIFT_OPERATOR'})
ON CREATE SET
  hypershift_op.label = 'HyperShift Operator',
  hypershift_op.subsystem = 'Cluster',
  hypershift_op.type = 'Operator',
  hypershift_op.description = 'Manages HostedCluster, NodePool, and HostedControlPlane lifecycle for hosted control plane clusters';

// --- HostedCluster CRD ---
MERGE (hosted_cluster:RHACMComponent {id: 'HOSTED_CLUSTER_CRD'})
ON CREATE SET
  hosted_cluster.label = 'HostedCluster CRD',
  hosted_cluster.subsystem = 'Cluster',
  hosted_cluster.type = 'CRD',
  hosted_cluster.description = 'Defines a hosted cluster with shared control plane, specifying platform (AWS, KubeVirt, Azure, Agent), release image, networking, and services';

// --- NodePool CRD ---
MERGE (node_pool:RHACMComponent {id: 'NODE_POOL_CRD'})
ON CREATE SET
  node_pool.label = 'NodePool CRD',
  node_pool.subsystem = 'Cluster',
  node_pool.type = 'CRD',
  node_pool.description = 'Worker node pool for hosted clusters with scaling (replicas, autoscaling), platform-specific config, and release image';

// --- HostedControlPlane CRD ---
MERGE (hosted_cp:RHACMComponent {id: 'HOSTED_CONTROL_PLANE_CRD'})
ON CREATE SET
  hosted_cp.label = 'HostedControlPlane CRD',
  hosted_cp.subsystem = 'Cluster',
  hosted_cp.type = 'CRD',
  hosted_cp.description = 'Internal representation of the hosted control plane components (API server, etcd, controllers) running on the management cluster';

// --- HyperShift addon agent deploys the operator ---
MATCH (hs_agent:RHACMComponent {id: 'HYPERSHIFT_ADDON_AGENT'})
MATCH (hs_op:RHACMComponent {id: 'HYPERSHIFT_OPERATOR'})
MERGE (hs_agent)-[:MANAGES]->(hs_op);

// --- HyperShift Operator manages its CRDs ---
MATCH (hs_op:RHACMComponent {id: 'HYPERSHIFT_OPERATOR'})
MATCH (hc:RHACMComponent {id: 'HOSTED_CLUSTER_CRD'})
MERGE (hs_op)-[:MANAGES]->(hc);

MATCH (hs_op:RHACMComponent {id: 'HYPERSHIFT_OPERATOR'})
MATCH (np:RHACMComponent {id: 'NODE_POOL_CRD'})
MERGE (hs_op)-[:MANAGES]->(np);

MATCH (hs_op:RHACMComponent {id: 'HYPERSHIFT_OPERATOR'})
MATCH (hcp:RHACMComponent {id: 'HOSTED_CONTROL_PLANE_CRD'})
MERGE (hs_op)-[:MANAGES]->(hcp);

// --- HostedCluster contains NodePools and HostedControlPlane ---
MATCH (hc:RHACMComponent {id: 'HOSTED_CLUSTER_CRD'})
MATCH (np:RHACMComponent {id: 'NODE_POOL_CRD'})
MERGE (hc)-[:CONTAINS]->(np);

MATCH (hc:RHACMComponent {id: 'HOSTED_CLUSTER_CRD'})
MATCH (hcp:RHACMComponent {id: 'HOSTED_CONTROL_PLANE_CRD'})
MERGE (hc)-[:CONTAINS]->(hcp);

// ============================================================================
// END OF SCRIPT
// ============================================================================
