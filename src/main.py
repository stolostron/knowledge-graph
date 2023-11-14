    

import sys
from datetime import datetime
import matplotlib.pyplot as plt
import networkx as nx
import os
from neo4j import GraphDatabase, RoutingControl


from dotenv import load_dotenv, find_dotenv




def main():

    print("************************************************************************************************")
    now = datetime.now()
    print("Hello, welcome to the world of ACM Knowledge Graph: ", now)
    print("************************************************************************************************")

    #current_dir = os.getcwd()
    current_dir = os.path.dirname(os.path.abspath(__file__))
    print("Processing files: ")

    graphList=  []
    for filename in os.listdir(os.path.join(current_dir,"..","input")):
          
          # TODO: VALIDATE XML AND MAKE SURE IT FOLLOWS OUR GUIDELINES
          propGraph = loadGraph(filename)
          graphList.append(propGraph)
          saveGraph(propGraph,filename)

    try:
        _ = load_dotenv(find_dotenv(raise_error_if_not_found=True)) 
        PWD  = os.getenv('NEO4J_PASSWORD')
        URI = os.getenv('NEO4J_URL')
        DB= os.getenv('NEO4J_DB')
        AUTH= (DB, PWD) 

        with GraphDatabase.driver(URI, auth=AUTH) as driver:
              driver.verify_connectivity()
              #print_graph(driver)
              add_graph(driver,graphList)
              driver.close()
    except:
        print("Error: No .env file found - Therefore cannot connect to neo4j. However, we will continue to process the graph.")
        #sys.exit(1)   
         

# Refer: https://github.com/neo4j/neo4j-python-driver#quick-example
def print_graph(driver):
    records, summary, keys = driver.execute_query(
    #"MATCH (p:Person {age: $age}) RETURN p.name AS name",
    "match(p:Deployment) return p",
    #age=42,
    database_="neo4j",routing_=RoutingControl.READ,
    )
    print("Printing Graph from neo4j: ###########################################")
    for record in records:
        print(record["p"])
    print("######################################################################")

def create_node_tx(driver, entityName, name,id,params):
    params["id"] = id
    # Creating all inclusive properties that also has the id
    # Cypher will take it
    # CREATE (n:Person $props) RETURN n
    # The above query will work and that is what we emulate here
    props = {"props": params}

    #query = ("CREATE (n:"+entityName+" {name: $name, id: $id}) "
    query = ("CREATE (n:"+entityName+" $props) "                              
            "RETURN n.id AS node_id")
    records = driver.execute_query(query, name=name,id=id,props=props["props"])
    #record = result.single()
    for record in records:
            print(record)
    #return record["node_id"]



def create_edge_tx(driver, sourceNode, destNode, sourceNodeName, destNodeName, edgeLabel):
    query = ("MATCH (sourceNode {id: $sourceNode, name:$sourceNodeName}), (destNode {id: $destNode, name:$destNodeName}) "
            "CREATE (sourceNode)-[:" + edgeLabel + "]->(destNode) ")
    records = driver.execute_query(query, sourceNode=sourceNode,destNode=destNode,
                                   sourceNodeName=sourceNodeName,destNodeName=destNodeName)
    for record in records:
            print(record)
     

def get_node_name(sourceNode, destNode, propGraph):
    sourceNodeName = ""
    destNodeName = ""
    for node in propGraph.nodes(data=True):
        if node[1].get("id") == sourceNode:
            #print(node[1].get("name"))
            sourceNodeName = node[1].get("name")
        if node[1].get("id") == destNode:
            #print(node[1].get("name"))
            destNodeName = node[1].get("name")
         
         
    #print(sourceNodeName,destNodeName)
    return sourceNodeName, destNodeName

          

def add_graph(driver,graphList):
    for propGraph in graphList:
        print("Adding Graph to neo4j: ###########################################")
        #print(type(propGraph))
        for node in propGraph.nodes(data=True):
            #print(node)
            #print(type(node))
            #print(node[1])
            #print(node[0])
            ename = ""
            if "label" in node[1]:
                #print(node[1]['label'])
                ename = node[1]['label']
            else:
                #print(node[1]['entity']) 
                ename = node[1]['entity']
            print(ename)
            create_node_tx(driver, ename,node[1]['name'],node[0],node[1])


        for edge in propGraph.edges(data=True):
            #print(edge)
            #print(type(edge))
            sourceNode=edge[0]
            destNode=edge[1]
            #print(sourceNode,"->",destNode)
            edgeLabel = list(edge[2].values())[0]
            #print(edgeLabel)
            sourceNodeName, destNodeName = get_node_name(sourceNode, destNode, propGraph)
            create_edge_tx(driver, sourceNode, destNode, sourceNodeName, destNodeName, edgeLabel)
            print("")
        print("######################################################################")
            


def loadGraph(filename):
        
        #current_dir = os.getcwd()
        current_dir = os.path.dirname(os.path.abspath(__file__))
        print(current_dir)
        file_path = os.path.join(current_dir,"..","input",filename)
        print(file_path)
        
        # Importing graphs from the file
        propGraph = nx.read_graphml(file_path)

        # Print the graph info
        print(list(propGraph.nodes(data=True)))
        print("Number of Nodes: ",propGraph.number_of_nodes())
        print("Size of Graph: ",propGraph.size())
        print("")
        return propGraph

def saveGraph(propGraph,filename):
        
        #current_dir = os.getcwd()
        current_dir = os.path.dirname(os.path.abspath(__file__))
        #pos = nx.spectral_layout(propGraph) 
        #pos = nx.shell_layout(propGraph)
        #pos = nx.spring_layout(propGraph)
        pos = nx.planar_layout(propGraph)

        plt.figure(1, figsize=(12,10), dpi=100)
        nx.draw(
            propGraph, pos, node_size=800,arrows=True,node_color="skyblue"
        )  

        # Draw node labels
        node_labels = nx.get_node_attributes(propGraph, "name")
        nx.draw_networkx_labels(propGraph, pos,labels=node_labels,  font_size=16)

        # Draw edge labels
        nx.draw_networkx_edge_labels(propGraph, pos)

        fname=filename+".png"
        fqfname=os.path.join(current_dir,"..","output",fname)

        plt.savefig(fqfname)
        #plt.show()
        plt.close('all')



    
if __name__ == "__main__":
    main()
