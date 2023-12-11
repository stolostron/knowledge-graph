    

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
    except IOError as e :
        print("Exception encountered: ",e)
        print("Error: No .env file found - Therefore cannot connect to neo4j. However, we will continue to process the graph.")
       
    except Exception as e :
        print("Exception encountered: ",e)
        #print("Error: No .env file found - Therefore cannot connect to neo4j. However, we will continue to process the graph.")
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

def regenrate_param_string(params):
     # Creating a new string-dictionary with unquoted keys
    param_string = ""
    for key,value in params.items():
        if type(value) != str:
            value = str(value)
            param_string += key + ": " + value + ", "
        else:
            param_string += key + ": '" + value + "', "
    #to remove the last comma and space
    return param_string[:-2]

def create_node_tx(driver, entityName, name,id,params):

    #params["id"] = id
    # Creating all inclusive properties that also has the id
    # Cypher will take it
    # CREATE (n:Person $props) RETURN n
    # The above query will work and that is what we emulate here
    props = {"props": params}

    paramString = regenrate_param_string(params)
    #print('######',paramString)

    #query = ("CREATE (n:"+entityName+" {name: $name, id: $id}) "
    # Exception encountered:  {code: Neo.ClientError.Statement.SyntaxError} 
    # {message: Parameter maps cannot be used in `MERGE` patterns (use a literal map instead, e.g. `{id: $props.id}`)
    
    #query = ("CREATE (n:"+entityName+" $props) "                              
    #        "RETURN n.id AS node_id")
    #records = driver.execute_query(query, name=name,id=id,props=props["props"])

    query = ("MERGE (n:"+entityName+" {"+paramString+"}) "                              
            "RETURN n.name")
    records,summary, key = driver.execute_query(query, name=name,id=id)

    #record = result.single()
    for record in records:
            print(record)
    #print(summary)
    #print(key)
    #return records



def create_edge_tx(driver, sourceProp, destProp,edgeLabel):
    
    query = ("MATCH (sourceNode "+sourceProp+"), (destNode "+destProp+") "      
                "MERGE (sourceNode)-[r:" + edgeLabel + "]->(destNode) "
                "RETURN sourceNode.name, destNode.name,type(r)")
    #records,summary, key = driver.execute_query(query, sourceNode=sourceNode,destNode=destNode)
    records,summary, key = driver.execute_query(query)
    
    for record in records:
            print(record)
    #print(summary)
    #print(key)
     

def get_node_name(sourceNode, destNode, propGraph):
    sourceNodeName = ""
    destNodeName = ""
    sourceEntityName = ""
    destEntityName = ""
    for node in propGraph.nodes(data=True):
        #print(node)
        #if node[0].get("id") == sourceNode:
        if node[0] == sourceNode:    
            #print(node[1].get("name"))
            sourceNodeName = node[1].get("name")
            sourceEntityName = node[1].get("entity")
            #print(sourceNode,sourceNodeName, sourceEntityName)
        #if node[0].get("id") == destNode:
        if node[0] == destNode:
            #print(node[1].get("name"))
            destNodeName = node[1].get("name")
            destEntityName = node[1].get("entity")
            #print(destNode,destNodeName,destEntityName)
         
         
    #print("-------",sourceNodeName,destNodeName,sourceEntityName, destEntityName)
    return sourceNodeName, destNodeName, sourceEntityName, destEntityName

          

def add_graph(driver,graphList):
    lookupDict = {}
    for propGraph in graphList:
        print("Adding Graph to neo4j: ###########################################")
        #print(type(propGraph))
        for node in propGraph.nodes(data=True):
            print(node)
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
            print(ename,"-",node[1]['name'])
            create_node_tx(driver, ename,node[1]['name'],node[0],node[1])
            lookupDict[node[0]] = "{"+regenrate_param_string(node[1])+"}"

        for edge in propGraph.edges(data=True):
            #print(edge)
            #print(type(edge))
            sourceNode=edge[0]
            destNode=edge[1]
            print(sourceNode,"->",destNode)
            edgeLabel = list(edge[2].values())[0]
            #print(edgeLabel)
            #sourceNodeName, destNodeName,sourceEntityName, destEntityName = get_node_name(sourceNode, destNode, propGraph)
            create_edge_tx(driver, lookupDict[sourceNode],lookupDict[destNode],edgeLabel)
            #print("")
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
        # param_string += key + ": '" + value + "', "print("")
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
