#!/bin/bash

#
# This script only created some of the grc tests knowledge graph, many aspects were manually added after running it.
#

upstream="open-cluster-management-io/config-policy-controller,KinD Tests (minimum),KinD Tests (latest)
open-cluster-management-io/governance-policy-addon-controller,KinD Tests (minimum true),KinD Tests (latest true),KinD Tests (minimum false),KinD Tests (latest false),Linting and Unit Tests
open-cluster-management-io/governance-policy-framework-addon,KinD Tests (minimum),KinD Tests (latest)
open-cluster-management-io/governance-policy-propagator,KinD Tests (minimum),KinD Tests (latest),KinD Tests PolicyAutomation,KinD Tests Unit Tests
open-cluster-management-io/policy-collection,Validation Tests"

midstream="stolostron/cert-policy-controller,KinD Tests (minimum),KinD Tests (latest),Framework KinD Tests (minimum true),Framework KinD Tests (latest true),Framework KinD Tests (minimum false),Framework KinD Tests (latest false),Upstream reference checks,Code scanning results,SonarCloud Code Analysis
stolostron/config-policy-controller,KinD Tests (minimum),KinD Tests (latest),Framework KinD Tests (minimum true),Framework KinD Tests (latest true),Framework KinD Tests (minimum false),Framework KinD Tests (latest false),Upstream reference checks,Code scanning results,SonarCloud Code Analysis
stolostron/go-template-utils
stolostron/governance-policy-addon-controller,KinD Tests (minimum true),KinD Tests (latest true),KinD Tests (minimum false),KinD Tests (latest false),Linting and Unit Tests,Upstream reference checks,Code scanning results,SonarCloud Code Analysis
stolostron/governance-policy-framework,E2E Framework KinD Tests (minumum true),E2E Framework KinD Tests (minumum false),E2E Framework KinD Tests (latest false),E2E Framework KinD Tests (latest true),E2E Framework KinD Tests (latest false hosted)
stolostron/governance-policy-framework-addon,KinD Tests (minimum),KinD Tests (latest),Framework KinD Tests (minimum true),Framework KinD Tests (latest true),Framework KinD Tests (minimum false),Framework KinD Tests (latest false),Upstream reference checks,Code scanning results,SonarCloud Code Analysis
stolostron/governance-policy-propagator,KinD Tests (minimum),KinD Tests (latest),Framework KinD Tests (minimum true),Framework KinD Tests (latest true),Framework KinD Tests (minimum false),Framework KinD Tests (latest false),Upstream reference checks,Code scanning results,SonarCloud Code Analysis
stolostron/go-template-utils,Linting,Unit Tests,Code scanning results,SonarCloud Code Analysis
stolostron/iam-policy-controller,KinD Tests (minimum),KinD Tests (latest),Framework KinD Tests (minimum true),Framework KinD Tests (latest true),Framework KinD Tests (minimum false),Framework KinD Tests (latest false),Upstream reference checks,Code scanning results,SonarCloud Code Analysis
stolostron/policy-collection,Validation Tests"

e2e="stolostron/governance-policy-framework,Policy Framework e2e Suite,Policy Framework e2e Suite deployOnHub,GRC framework integration test suite"
product="stolostron/canary,BVT GRC framework integration test suite,SVT GRC framework integration test suite"

#
# Using the metadata defined above -- which can probably be calculated -- generate a knowledge graph showing the GRC test architecture
#

echo "<?xml version='1.0' encoding='utf-8'?>
<graphml xmlns=\"http://graphml.graphdrawing.org/xmlns\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd\">
  <key id=\"verb\" for=\"edge\" attr.name=\"verb\" attr.type=\"string\" />
  <key id=\"name\" for=\"node\" attr.name=\"name\" attr.type=\"string\" />
  <key id=\"entity\" for=\"node\" attr.name=\"entity\" attr.type=\"string\" />
  <key id=\"type\" for=\"node\" attr.name=\"type\" attr.type=\"string\" />
  <graph edgedefault=\"directed\">
"

IFS="
"
node=1
for keys in $upstream $midstream $e2e $product; do
	repository=$(echo $keys | awk -F, '{print $1}')
	echo "    <node id=\"$node\">
      <data key=\"entity\">Repository</data>
      <data key=\"name\">$repository</data>
      <data key=\"type\">github</data>
    </node>"

	reponode=$node
	x=1
#	for test in $(echo $keys | awk  -F, "{print \$$x}"); do
	for test in $(echo $keys | sed 's/,/\n/g'); do
		if [ $x -gt 1 ]; then
			let node=$node+1
			echo "    <node id=\"$node\">
      <data key=\"entity\">Test</data>
      <data key=\"name\">$test</data>
      <data key=\"type\">prow</data>
    </node>"

			echo "    <edge source=\"$node\" target=\"$reponode\">
      <data key=\"verb\">Test</data>
    </edge>"
		fi
		let x=$x+1
	done
	let node=$node+1
done

echo "  </graph>
</graphml>"

