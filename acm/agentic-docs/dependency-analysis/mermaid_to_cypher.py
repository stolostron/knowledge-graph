#!/usr/bin/env python3
"""
Mermaid to Neo4j Cypher Converter for RHACM Architecture
Converts Mermaid graph files to unified Neo4j Cypher import script
"""

import re
import os
import argparse
from pathlib import Path
from typing import Dict, List, Set, Tuple
from dataclasses import dataclass

@dataclass
class GraphNode:
    id: str
    label: str
    subsystem: str
    node_type: str = "Component"
    description: str = ""

@dataclass
class GraphRelationship:
    source: str
    target: str
    relationship_type: str
    subsystem: str
    is_cross_cluster: bool = False

class MermaidParser:
    def __init__(self):
        self.nodes: Dict[str, GraphNode] = {}
        self.relationships: List[GraphRelationship] = []
        self.class_definitions: Dict[str, str] = {}
        
    def parse_mermaid_file(self, file_path: Path, subsystem: str) -> None:
        """Parse a single Mermaid file and extract nodes and relationships"""
        print(f"Parsing {file_path.name} for {subsystem} subsystem...")
        
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
        
        # Extract node definitions
        self._extract_nodes(content, subsystem)
        
        # Extract relationships
        self._extract_relationships(content, subsystem)
        
        # Extract class definitions for styling
        self._extract_class_definitions(content)
    
    def _extract_nodes(self, content: str, subsystem: str) -> None:
        """Extract node definitions from Mermaid content"""
        # Pattern for node definitions: ID[Label] or ID[Label with spaces]
        node_pattern = r'(\w+)\[(.*?)\]'
        
        for match in re.finditer(node_pattern, content):
            node_id = match.group(1)
            node_label = match.group(2)
            
            # Skip if already exists (avoid duplicates across files)
            if node_id not in self.nodes:
                self.nodes[node_id] = GraphNode(
                    id=node_id,
                    label=node_label,
                    subsystem=subsystem,
                    node_type=self._determine_node_type(node_label),
                    description=self._generate_description(node_label, subsystem)
                )
    
    def _extract_relationships(self, content: str, subsystem: str) -> None:
        """Extract relationships from Mermaid content"""
        lines = content.split('\n')
        
        for line in lines:
            line = line.strip()
            
            # Skip comments and empty lines
            if line.startswith('%%') or not line or line.startswith('graph') or line.startswith('class'):
                continue
            
            # Parse different relationship types
            relationships = self._parse_relationship_line(line, subsystem)
            self.relationships.extend(relationships)
    
    def _parse_relationship_line(self, line: str, subsystem: str) -> List[GraphRelationship]:
        """Parse a single line for relationships"""
        relationships = []
        
        # Solid arrows with semantic labels: -->|LABEL|
        if '-->|' in line:
            relationships.extend(self._extract_semantic_relationships(line, '-->|', subsystem))
        # Regular solid arrows: -->
        elif '-->' in line:
            relationships.extend(self._extract_arrow_relationships(line, '-->', 'DEPENDS_ON', subsystem))
        
        # Dotted arrows with semantic labels: -.->|LABEL|
        if '-.->|' in line:
            relationships.extend(self._extract_semantic_relationships(line, '-.->|', subsystem, True))
        # Regular dotted arrows: -.->
        elif '-.-> ' in line:
            relationships.extend(self._extract_arrow_relationships(line, '-.-> ', 'COMMUNICATES_WITH', subsystem, True))
        
        return relationships
    
    def _extract_semantic_relationships(self, line: str, arrow_start: str, subsystem: str, cross_cluster: bool = False) -> List[GraphRelationship]:
        """Extract relationships with semantic labels from arrow notation"""
        relationships = []
        
        if arrow_start in line:
            # Split on the arrow start to get source and target parts
            parts = line.split(arrow_start)
            if len(parts) == 2:
                source = parts[0].strip()
                target_part = parts[1].strip()
                
                # Extract the semantic label and target
                if '|' in target_part:
                    label_and_target = target_part.split('|', 1)
                    if len(label_and_target) == 2:
                        semantic_label = label_and_target[0].strip()
                        target = label_and_target[1].strip()
                        
                        # Clean up node IDs (remove brackets and labels)
                        source = re.sub(r'\[.*?\]', '', source).strip()
                        target = re.sub(r'\[.*?\]', '', target).strip()
                        
                        if source and target and semantic_label:
                            relationships.append(GraphRelationship(
                                source=source,
                                target=target,
                                relationship_type=semantic_label,
                                subsystem=subsystem,
                                is_cross_cluster=cross_cluster
                            ))
        
        return relationships
    
    def _extract_arrow_relationships(self, line: str, arrow: str, rel_type: str, subsystem: str, cross_cluster: bool = False) -> List[GraphRelationship]:
        """Extract relationships from arrow notation"""
        relationships = []
        
        if arrow in line:
            parts = line.split(arrow)
            if len(parts) == 2:
                source = parts[0].strip()
                target = parts[1].strip()
                
                # Clean up node IDs (remove brackets and labels)
                source = re.sub(r'\[.*?\]', '', source).strip()
                target = re.sub(r'\[.*?\]', '', target).strip()
                
                if source and target:
                    relationships.append(GraphRelationship(
                        source=source,
                        target=target,
                        relationship_type=rel_type,
                        subsystem=subsystem,
                        is_cross_cluster=cross_cluster
                    ))
        
        return relationships
    
    def _extract_class_definitions(self, content: str) -> None:
        """Extract CSS class definitions for styling information"""
        class_pattern = r'class\s+([\w,\s]+)\s+(\w+)'
        
        for match in re.finditer(class_pattern, content):
            nodes = [n.strip() for n in match.group(1).split(',')]
            class_name = match.group(2)
            
            for node in nodes:
                if node:
                    self.class_definitions[node] = class_name
    
    def _determine_node_type(self, label: str) -> str:
        """Determine node type based on label content"""
        label_lower = label.lower()
        
        if 'operator' in label_lower:
            return 'Operator'
        elif 'controller' in label_lower:
            return 'Controller'
        elif 'api' in label_lower:
            return 'API'
        elif 'cluster' in label_lower:
            return 'Cluster'
        elif 'policy' in label_lower:
            return 'Policy'
        elif 'prometheus' in label_lower or 'grafana' in label_lower or 'thanos' in label_lower:
            return 'Observability'
        elif 'application' in label_lower or 'subscription' in label_lower:
            return 'Application'
        elif 'search' in label_lower:
            return 'Search'
        else:
            return 'Component'
    
    def _generate_description(self, label: str, subsystem: str) -> str:
        """Generate description based on label and subsystem"""
        return f"{subsystem} component: {label}"

class CypherGenerator:
    def __init__(self, nodes: Dict[str, GraphNode], relationships: List[GraphRelationship], class_definitions: Dict[str, str]):
        self.nodes = nodes
        self.relationships = relationships
        self.class_definitions = class_definitions
    
    def generate_cypher_script(self) -> str:
        """Generate complete Cypher import script"""
        cypher_parts = [
            self._generate_header(),
            self._generate_schema(),
            self._generate_nodes(),
            self._generate_relationships(),
            self._generate_verification_queries(),
            self._generate_footer()
        ]
        
        return '\n\n'.join(cypher_parts)
    
    def _generate_header(self) -> str:
        """Generate script header"""
        return """// RHACM Comprehensive Architecture Graph - Neo4j Import Script
// Generated from Mermaid dependency graphs
// 
// This script creates a unified graph of RHACM components and their dependencies
// across all major subsystems: Governance, Application Lifecycle, Observability,
// Cluster Management, Search, and Console
//
// Usage: 
//   1. Clear existing data: MATCH (n) DETACH DELETE n;
//   2. Run this script in Neo4j Browser or cypher-shell
//   3. Verify with queries at the end of this script

// Clear existing RHACM data (uncomment if needed)
// MATCH (n:RHACMComponent) DETACH DELETE n;"""
    
    def _generate_schema(self) -> str:
        """Generate schema constraints and indexes"""
        return """// Schema Setup: Constraints and Indexes
CREATE CONSTRAINT rhacm_component_id IF NOT EXISTS
FOR (n:RHACMComponent) REQUIRE n.id IS UNIQUE;

CREATE INDEX rhacm_subsystem_index IF NOT EXISTS
FOR (n:RHACMComponent) ON (n.subsystem);

CREATE INDEX rhacm_type_index IF NOT EXISTS
FOR (n:RHACMComponent) ON (n.type);

CREATE INDEX rhacm_label_index IF NOT EXISTS
FOR (n:RHACMComponent) ON (n.label);"""
    
    def _generate_nodes(self) -> str:
        """Generate node creation statements"""
        cypher_nodes = ["// Node Creation - RHACM Components"]
        
        for node in self.nodes.values():
            node_labels = self._get_node_labels(node)
            cypher_nodes.append(
                f"CREATE (:{':'.join(node_labels)} {{"
                f"id: '{node.id}', "
                f"label: {self._escape_string(node.label)}, "
                f"subsystem: '{node.subsystem}', "
                f"type: '{node.node_type}', "
                f"description: {self._escape_string(node.description)}"
                f"}});"
            )
        
        return '\n'.join(cypher_nodes)
    
    def _generate_relationships(self) -> str:
        """Generate relationship creation statements"""
        cypher_rels = ["// Relationship Creation - Component Dependencies"]
        
        # Group relationships by type for better organization
        rel_groups = {}
        for rel in self.relationships:
            if rel.relationship_type not in rel_groups:
                rel_groups[rel.relationship_type] = []
            rel_groups[rel.relationship_type].append(rel)
        
        for rel_type, rels in rel_groups.items():
            cypher_rels.append(f"\n// {rel_type} relationships")
            for rel in rels:
                cypher_rels.append(
                    f"MATCH (source {{id: '{rel.source}'}}), (target {{id: '{rel.target}'}}) "
                    f"CREATE (source)-[:{rel.relationship_type} {{"
                    f"subsystem: '{rel.subsystem}', "
                    f"cross_cluster: {str(rel.is_cross_cluster).lower()}"
                    f"}}]->(target);"
                )
        
        return '\n'.join(cypher_rels)
    
    def _generate_verification_queries(self) -> str:
        """Generate verification and analysis queries"""
        return """// Verification and Analysis Queries
// 
// 1. Component Count by Subsystem
// MATCH (n:RHACMComponent) 
// RETURN n.subsystem as Subsystem, count(n) as ComponentCount 
// ORDER BY ComponentCount DESC;
//
// 2. Dependency Analysis - Most Connected Components
// MATCH (n:RHACMComponent)
// OPTIONAL MATCH (n)-[r_out]->()
// OPTIONAL MATCH ()-[r_in]->(n)
// RETURN n.label as Component, n.subsystem as Subsystem,
//        count(DISTINCT r_out) as OutgoingDeps,
//        count(DISTINCT r_in) as IncomingDeps,
//        count(DISTINCT r_out) + count(DISTINCT r_in) as TotalConnections
// ORDER BY TotalConnections DESC LIMIT 20;
//
// 3. Cross-Subsystem Dependencies
// MATCH (source:RHACMComponent)-[r]->(target:RHACMComponent)
// WHERE source.subsystem <> target.subsystem
// RETURN source.subsystem as SourceSubsystem, 
//        target.subsystem as TargetSubsystem,
//        count(r) as Dependencies
// ORDER BY Dependencies DESC;
//
// 4. Hub-Spoke Communication Patterns
// MATCH (hub:RHACMComponent)-[r {cross_cluster: true}]->(spoke:RHACMComponent)
// RETURN hub.label as HubComponent, 
//        collect(DISTINCT spoke.label)[0..5] as SpokeComponents,
//        count(spoke) as SpokeCount
// ORDER BY SpokeCount DESC;
//
// 5. Critical Path Analysis - Find components with no incoming dependencies
// MATCH (n:RHACMComponent)
// WHERE NOT ()-[:DEPENDS_ON]->(n)
// RETURN n.subsystem as Subsystem, n.label as RootComponent, n.type as Type
// ORDER BY Subsystem, RootComponent;"""
    
    def _generate_footer(self) -> str:
        """Generate script footer with summary"""
        total_nodes = len(self.nodes)
        total_relationships = len(self.relationships)
        subsystems = set(node.subsystem for node in self.nodes.values())
        
        return f"""// Script Summary
// Total Components: {total_nodes}
// Total Dependencies: {total_relationships}
// Subsystems: {', '.join(sorted(subsystems))}
// 
// Generated from Mermaid files:
// - mermaid/rhacm-overview.mmd (High-level architecture)
// - mermaid/rhacm-governance.mmd (GRC policies and compliance)
// - mermaid/rhacm-application.mmd (Application lifecycle)
// - mermaid/rhacm-observability.mmd (Monitoring and metrics)
// - mermaid/rhacm-cluster.mmd (Cluster management)
// - mermaid/rhacm-search.mmd (Resource discovery)"""
    
    def _get_node_labels(self, node: GraphNode) -> List[str]:
        """Get Neo4j labels for a node"""
        labels = ['RHACMComponent']
        
        # Add subsystem-specific label
        labels.append(node.subsystem.replace(' ', ''))
        
        # Add type-specific label
        if node.node_type:
            labels.append(node.node_type)
        
        # Add class-based label if available
        if node.id in self.class_definitions:
            class_name = self.class_definitions[node.id]
            labels.append(class_name.title())
        
        return labels
    
    def _escape_string(self, text: str) -> str:
        """Escape string for Cypher query"""
        if not text:
            return "''"
        
        # Escape single quotes and backslashes
        escaped = text.replace("\\", "\\\\").replace("'", "\\'")
        return f"'{escaped}'"

def main():
    parser = argparse.ArgumentParser(description='Convert RHACM Mermaid graphs to Neo4j Cypher')
    parser.add_argument('--input-dir', default='.', help='Directory containing Mermaid files')
    parser.add_argument('--output', default='knowledge-graph/rhacm_architecture_enhanced.cypher', help='Output Cypher file')
    parser.add_argument('--verbose', '-v', action='store_true', help='Verbose output')
    
    args = parser.parse_args()
    
    # Define Mermaid files and their corresponding subsystems
    mermaid_files = {
        'mermaid/rhacm-overview.mmd': 'Overview',
        'mermaid/rhacm-governance.mmd': 'Governance',
        'mermaid/rhacm-application.mmd': 'Application',
        'mermaid/rhacm-observability.mmd': 'Observability',
        'mermaid/rhacm-cluster.mmd': 'Cluster',
        'mermaid/rhacm-search.mmd': 'Search',
        'mermaid/rhacm-console.mmd': 'Console'
    }
    
    # Initialize parser
    parser_instance = MermaidParser()
    
    # Parse each Mermaid file
    input_path = Path(args.input_dir)
    parsed_files = 0
    
    for filename, subsystem in mermaid_files.items():
        file_path = input_path / filename
        if file_path.exists():
            parser_instance.parse_mermaid_file(file_path, subsystem)
            parsed_files += 1
            if args.verbose:
                print(f"✓ Parsed {filename} ({subsystem})")
        else:
            print(f"⚠ Warning: {filename} not found in {input_path}")
    
    if parsed_files == 0:
        print("❌ Error: No Mermaid files found!")
        return 1
    
    # Generate Cypher script
    generator = CypherGenerator(
        parser_instance.nodes, 
        parser_instance.relationships,
        parser_instance.class_definitions
    )
    
    cypher_script = generator.generate_cypher_script()
    
    # Write output
    output_path = Path(args.output)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(cypher_script)
    
    # Summary
    print(f"\n✅ Conversion Complete!")
    print(f"📊 Parsed {parsed_files} Mermaid files")
    print(f"🔗 Found {len(parser_instance.nodes)} components")
    print(f"↔️  Found {len(parser_instance.relationships)} dependencies")
    print(f"💾 Generated {output_path}")
    
    # Check for extension Cypher files
    extensions_dir = output_path.parent / 'extensions'
    extension_files = []
    if extensions_dir.exists():
        extension_files = sorted(extensions_dir.glob('*.cypher'))
        if extension_files:
            print(f"\n📦 Extensions found ({len(extension_files)}):")
            for ext_file in extension_files:
                print(f"   • {ext_file.name}")
    
    print(f"\n🚀 Next steps:")
    print(f"   1. Start Neo4j database")
    print(f"   2. Open Neo4j Browser (http://localhost:7474)")
    print(f"   3. Run: :source {output_path}")
    if extension_files:
        print(f"   4. Load extensions:")
        for ext_file in extension_files:
            print(f"      :source {ext_file}")
        print(f"   5. Execute verification queries in the script")
    else:
        print(f"   4. Execute verification queries in the script")
    
    return 0

if __name__ == '__main__':
    exit(main())