#!/bin/bash

rc=0
files=$(ls input)
for file in $files; do
	label=$(xmllint --nocdata --xpath "//*[local-name()='graphml']/*[local-name()='key'][@for='node'][@attr.name='label']/@id" input/$file | awk -F\" '{print $2}')
	#echo "Label=$label"
	nodes=$(xmllint --nocdata --xpath "//*[local-name()='graph']/*[local-name()='node']/*[local-name()='data'][@key=\"$label\"]/text()" "input/$file" | sort | uniq)

	for node in $nodes; do
		grep -q "^$node\$" glossary.txt
		if [ $? -ne 0 ]; then
			rc=1
			echo "Error: Node not in glossary: $node"
		fi
	done
done

exit $rc
