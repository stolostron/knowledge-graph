# Naming

## Overview

To have consistent naming not only do we need some controls but we need agreement on what naming in the knowledge graph means.  
This guide provides some details on our naming strategy.

## Components

A knowledge graph consists of nodes and edges.  The nodes have names and multiple key attributes.  The edges are a verb that
relates one node to another node.  For example, Node A "creates" Node B.  The edge between Node A and Node B is the "creates"
verb.  

## Nodes

The nodes are entities in the knowledge graph system.  An entity key is required to be specified for each node that you define
in the knowledge graph and it is expected these entity names will be re-used many times.  Examples of entities are given below,
and each entity must also define a name key that further clarifies the unique characteristic of that entity so you know which 
entity type is being referred to.

- Users: A resource representing users within the knowledge domain.
  - name: Which sets of users is being identified. Could be User for a generic user or Admin, SecOps, etc
- API: A resource in the system that implements an API.  This could be a deployment/pod/controller resource or it could be the
  API definition (CRD).
  - name: Which API is being referred to.  This could be Policy since Policy is an API in the ACM kubernetes installations.
  - 
- Processor: An entity focused on performing tasks of some form.  Such as a pod/container/deployment.
  - name: The well known name for the entity agreed upon in the glossary of names.
  - 
- Custom Resource: An entity that is an instance of an API that may be directly created and used in various ways.
  - name: the custom resource name
- Intermediate Resource: An entity that is an instance of an API that is indirectly created and the use is not the focus of
  the creating entity.
  - name: this is also the custom resource name but it's an intermediate resource and needs a better explanation.  
  -


## Edges

The relation between nodes is the edge.  Ideally I think we want to keep edges structured so common verbs/relations are 
re-used as much as possible.  Examples of edges are:

- Creates
- Reads
- Updates
- Deletes
- Patches
- Forwards
- Refers
- Watches
- Configures
- Tests

Etc
