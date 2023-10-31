    

import sys
from datetime import datetime
import matplotlib.pyplot as plt
import networkx as nx
import os


def main():

    print("************************************************************************************************")
    now = datetime.now()
    print("Hello, welcome to the world of ACM Knowledge Graph: ", now)
    print("************************************************************************************************")

    #current_dir = os.getcwd()
    current_dir = os.path.dirname(os.path.abspath(__file__))
    print("Processing files: ")

    for filename in os.listdir(os.path.join(current_dir,"..","input")):
          
          # TODO: VALIDATE XML AND MAKE SURE IT FOLLOWS OUR GUIDELINES
          propGraph = loadGraph(filename)
          saveGraph(propGraph,filename)
          

def loadGraph(filename):
        
        #current_dir = os.getcwd()
        current_dir = os.path.dirname(os.path.abspath(__file__))
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
        node_labels = nx.get_node_attributes(propGraph, "label")
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
