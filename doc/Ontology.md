# ACM Knowledge Graph Ontology

## Overview

For details on Knowledge Graphs you can reference other resources.  Perhaps
start with the [README.md](../README.md) in this repository to begin 
learning more.

To get started with Knowledge Graphs in ACM, we want our nodes to consist
of clearly defined entities.  Where possible we want to always re-use the
existing entities that have been defined instead of creating new ones.
Validation is being put in place to help prevent too many entities from
being created.  Too many entity types will make knowledge graph contributions 
and maintenance more difficult.

## Entities

The list of entities are validated from the [Glossary](../glossary.txt) file
and consist of the common resources shown below.

![](./ontology.png)

See the examples in the [input](../input) folder for examples on how this
ontology is being used.

## Entity Descriptions

Entities are the nodes in the knowledge graph.  The following is a list of the
main entities that are being used in the samples.  While more entities can
be added, they must not duplicate the ones that already exist.

Entity | Description | Samples | Challenges 
---    | ---         | ---     | ---
Users | This represents any resource that uses entities in the knowledge graph. Currently no distinction is being made regarding different types of users. | Users | In the future we could enhance Users to be more specific and account for different types of users.
API | A public facing API for the system. Commonly this is the ACM Custom Resource Definitions.  This can also be extended to other APIs such as OpenShift APIs or Non K8S APIs like REST, Ansible and cloud platforms. | ManagedCluster, Policy, Placement, Ansible Playbook | This can seem to overlap with Intermediate Resource which is also API based. Use the API entity when there is the possibility for an entity to be either an API or an Intermediate Resource.
Intermediate Resource | An instance of a resource that was not directly created by a User. | Pods, Deployments, Secrets, ConfigurationPolicy | 
Processor | A running process that manipulates resources | Any pod or operator or even an external rest server/engine. | 
Gateway | A route that allows external access to the system | An OpenShift route, A port on a node, a service that is accessible | This is currently intended to be an OpenShift route resource.  Extend as necessary.
Repository | A storage mechanism for code or other resources such as policies or applications. | github.com/organization/repository-name is a full path to a particular project or repository |

## Attributes of Entities

Each entity (node) in the graph will have multiple attributes to help clarify the details
of the node.  The tables below list the attributes for each entity.  You should use all
of the attributes to help make sure your entities are uniquely defined if they
are unique from other entities that share the same name. Be careful to define your
attributes accurately so merges across knowledge graphs will map equivalent resources
to each other.  This means all attributes must match for two nodes to be considered the
same resource.

### Attributes of the Users Entity

Attribute | Description | Sample | Challenges
---       | ---         | ---    | ---
entity | Users |  | 
name | The name should simply be User | `User` | Considerations for different types of users is not being made. Groups are also not being considered.


### Attributes of the API Entity

Attribute | Description | Sample | Challenges
---       | ---         | ---    | ---
entity | The entity is defined above. | API | 
type | The platform type of the resource or controller. | Kubernetes, REST, Ansible, vSphere | For most ACM resources, the type should be `Kubernetes`.
group | For the Kubernetes type, this is the kube group value.  For other types it is TBD and will be defined by those domain experts | policy.open-cluster-management.io, cluster.open-cluster-management.io |  
kind | The kubernetes kind when the type is Kubernetes. When using other types it will be defined by those domain experts. | Policy, ManagedCluster, TBD: Playbook | 
name | The name that identifies this entity | Pod name, policy name | If the name can be variable use the syntax `{cluster-name}` or `insights-client-{unique-id}` or `{user-defined}`.
namespace | The k8s namespace of the resource | default | Do not include this attribute for cluster scoped resources.
onHub | Boolean that is true if this entity exists on the ACM hub | true/false | If the namespace can be variable use the syntax `{cluster-name}`.
onManaged | Boolean that is true if this entity is on managed clusters | true/false |

### Attributes of the Intermediate Resource Entity

Attribute | Description | Sample | Challenges
---       | ---         | ---    | ---
entity | The Intermediate Resource Entity. | Intermediate Resource | 
type | The platform type of the resource or controller. | Kubernetes, REST, Ansible, vSphere | For most ACM resources, the type should be `Kubernetes`.
group | For the Kubernetes type, this is the kube group value.  For other types it is TBD and will be defined by those domain experts | policy.open-cluster-management.io, cluster.open-cluster-management.io |  
kind | The kubernetes kind when the type is Kubernetes. When using other types it will be defined by those domain experts. | ConfigurationPolicy, Pod, Secret, ConfigMap | 
name | The name that identifies this entity | Pod name, ConfigurationPolicy name | If the name can be variable use the syntax `{cluster-name}` or `insights-client-{unique-id}`.
namespace | The k8s namespace of the resource | default | Do not include this attribute for cluster scoped resources.
onHub | Boolean that is true if this entity exists on the ACM hub | true/false | If the namespace can be variable use the syntax `{cluster-name}`.
onManaged | Boolean that is true if this entity is on managed clusters | true/false |

### Attributes of the Processor Entity

Attribute | Description | Sample | Challenges
---       | ---         | ---    | ---
entity | The entity is defined above. | Processor | 
type | The platform type of the resource or controller. | Kubernetes, REST, Ansible, vSphere | For most ACM resources, the type should be `Kubernetes`.
name | The name that identifies this entity | Controller name, process name | If the name can be variable use the syntax `{user-defined}` or `insights-client-{unique-id}`.
namespace | The k8s namespace of the processor | default |
onHub | Boolean that is true if this entity exists on the ACM hub | true/false | If the namespace can be variable use the syntax `{cluster-name}`.
onManaged | Boolean that is true if this entity is on managed clusters | true/false |

### Attributes of the Gateway Entity

Attribute | Description | Sample | Challenges
---       | ---         | ---    | ---
entity | The entity is defined above. | Gateway | 
type | The platform type of the resource or controller. | Kubernetes, REST, Ansible, vSphere | For most ACM resources, the type should be `Kubernetes`.
group | For the Kubernetes type, this is the kube group value.  For other types it is TBD and will be defined by those domain experts | `route.openshift.io` |  
kind | The kubernetes kind when the type is Kubernetes. When using other types it will be defined by those domain experts. | `Route` | 
name | The name that identifies this entity | Route name | If the name can be variable use the syntax `{user-defined}` or `insights-client-{unique-id}`.
namespace | The k8s namespace of the processor | default |
onHub | Boolean that is true if this entity exists on the ACM hub | true/false | If the namespace can be variable use the syntax `{cluster-name}`.
onManaged | Boolean that is true if this entity is on managed clusters | true/false |

### Attributes of the Repository Entity

Attribute | Description | Sample | Challenges
---       | ---         | ---    | ---
entity | The entity is defined above. | Gateway | 
type | The type of the repository. | github, bitbucket, objectstore, gitlab | 
branch | The branch of the repository | `main`, `development` |  
path | The location in the repository that is the focus of this resource, if a path is applicable. | test/e2e, stable/policies | Do not include this attribute if it doesn't apply to this entity.
name | The name of the repository.  For github this would be github.com followed by the organization and then the repository name | github.com/open-cluster-management-io/policy-collection | 


### Notes:

Some notes about the ontology:
- A resource can be treated as Intermediate Resource in one procedure 
  (graphml file) because it is created by a Processor, while the same 
  resource could be an API node in another procedure (graphml file) 
  where the User is able to update it. In this situation, it’s better 
  to capture this resource with the same entity, either API or 
  Intermediate Resource, in those two procedures to make sure they 
  can be treated as a single node in the graph database.
- There may be a desire to adds tags as attributes to entities to help
  add additional query options that are valuable for a team.  Currently we
  want to refrain from adding additional attributes not defined above so
  we can ensure resources that should match to each other in different graphs
  will have the same attributes. Extra attributes would prevent matching.
  **NOTE** We could find ways to accomodate this better in the future. See the next
  section as a possible alternative.

## Inheritance

Each team will work in depth with the resources they own and have knowledge about.
Other teams will have a basic/generic reference to resources they don't own. One
way to expand on a resource that does not use tagging is to define the resource
multiple times with different names.  Example: One of the core resources in ACM is
the `ManagedCluster`.  Most knowledge graphs will define a `ManagedCluster` API 
entity with attributes that are expected:

- entity: API
- type: Kubernetes
- kind: ManagedCluster
- name: {cluster-name}
- group: cluster.open-cluster-management.io

The above entity will be the base ManagedCluster resource all teams expect to
see and use, but the Server Foundation team has more in depth knowledge to 
share in this area.  The Server Foundation team would also define the "generic" ManagedCluster resource as described above, but also additional ManagedCluster resources
with names that are more specific to different scenarios.  Some of those scenarios could be:

- Cloud specific ManagedCluster
- Kubernetes vs OpenShift ManagedCluster
- Hosted, bare metal, virtualized ManagedCluster

These additional entities would inherit from the generic ManagedCluster using 
an `is-a` relationship.  An AWS ManagedCluster `is-a` public cloud ManagedCluster which `is-a`
generic ManagedCluster for example.

The Server Foundation team can define additional entities that inherit from the generic
ManagedCluster definition.  These entities would need to follow some special rules:

1. The attributes for the child ManagedCluster should match the parent except for the name
2. There could be extra attributes defined if there is no intention of other teams matching
   these resources.

   
## Edges

The relationship between nodes is shown in a knowledge graph by defining edges.  
Each edge defines one verb that describes one relationship between two nodes.  We will
capitalize all letters in the edge name as our default convention.  Below is a list of
edges but it is not a complete list.  

**Note** You can usually describe any edge in two ways where the only difference is the
direction of the relationship between the nodes.  We want to consistently use one way to
describe the relationship.  For example, I can say Node A was `CREATEDBY` Node B or I can say
Node B `CREATES` Node A.  We want to use the `CREATES` verb instead of `CREATEDBY` as our
default convention.

### List of Edges

- APPROVES
- CONFIGURES
- CREATES
- DELETES
- FORKS
- FORWARDS
- MIRRORS
- PATCHES
- PUBLISHES
- QUERIES
- READS
- REFERS
- SIGNS
- STARTS
- TESTS
- UPDATES
- USES
- VALIDATES
- WATCHES
