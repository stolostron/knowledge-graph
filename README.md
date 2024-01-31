# Knowledge Graph

## Motivation
ACM is a complex product that is split into many components.  Many components are optional and need to be installed separately.  While we have a lot of good documentation, there are plenty of areas which we do not document well.
1. product documentation does not include certain kinds of details because they are out of scope
1. documentation/training materials by nature are siloed because each team produces there own
1. so we usually do not have good grasp of flows that span teams
1. these interconnected flows can be better expressed using Knowledge Graphs (they are simply understood by the human brain because this is usually how we draw it on a white board!)

This will allow:
1. support team to resolve problems faster without having to call the domain experts
1. domain experts if called in will have a easier time to recall complex things they have done in the past because Knowledge graphs helps speedy recollection
1. QE teams can raise defects which are more finely directed because they understand the problem much better
1. and hopefully, customers are able to sort problems out themselves - if we give access to these.
1. and if LLMs can query Knowledge graphs, [see this repo](), this could evolve to a question answering system.

Bottomline - make all the players happy and reduce subscription costs. The goal for the knowledge graph is to provide domain insights that eliminate the need to go to the experts directly. 

BTW there is nothing in this proposal that cannot be extended to other areas of Red Hat.


## Fundamental Questions
1. What are knowledge graphs (KG) ?
    - A KG is a directed labeled graph in which domain-specific meanings are associated with nodes and edges. A node could represent any real-world entity, for example, people, companies, and computers. An edge label captures the relationship of interest between the two nodes. For example, a friendship relationship between two people; a customer relationship between a company and person; or a network connection between two computers.
1. Why do we need KG ?
    - We need this to express complex relationships elegantly.They are hard to express clearly in words because of the complexity. 
    - Knowledge graphs (KGs) have emerged as a compelling abstraction for organizing the world's structured knowledge and for integrating information extracted from multiple data sources. They are also beginning to play a central role in representing information extracted by AI systems, and for improving the predictions of AI systems by giving them knowledge expressed in KGs as input. 
    - [Detailed discussion on Knowledge Graph and documentation](#detailed-discussion-on-knowledge-graph-and-documentation) has much more details on this.
1. Are there any open KG that exists today?
    - Yes! Wikidata is a collaboratively edited open KG that provides data for Wikipedia and for other uses on the web.    
    - Another openly accessible KG is from the Data Commons9 effort whose goal is to make publicly available data readily accessible and usable. Data Commons performs the necessary cleaning and joining of data from a variety of publicly available government and other authoritative data sources and provides access to the resulting KG. It currently incorporates data on demographics (US Census, Eurostat), economics (World Bank, Bureau of Labor Statistics, Bureau of Economic Analysis), health (World Health Organization, Center for Disease Control), climate (Intergovernmental Panel on Climate Change, National Oceanic and Atmospheric Administration), and sustainability.

1. Is RDF, Property Graphs, Sparql related to this ?
    - Yes. Resource Description Framework (RDF) triple stores and labeled property graphs both provide ways to explore and graphically depict connected data. But the two are very different – and each have different strengths in different use cases. RDF data can be queried using Sparql. Property Graphs are queried using Graph Query Languages. [This](https://neo4j.com/blog/rdf-triple-store-vs-labeled-property-graph-difference/#brief-history) is a good article that talks about the subject.

1. How are we going to input Knowledge Graphs and how are we going to store it ?
    - Input: as of now, input will be in [GraphML](http://graphml.graphdrawing.org/) is XML based format for describing graphs. This schema is understood by chat-gpt. So if we were to give chat-gpt data input compliant to GraphML, it can answer questions around it. GraphML XML-based syntax supports the entire range of possible graph structure constellations including directed, undirected, mixed graphs, hypergraphs, and application-specific attributes. We could take a CSV input - but that does not help much. Ideally a custom UI in which the graphs could be created would be ideal.
    - Store: as of now, they are stored in a Graph database.

1. But we already know this - why do we need to put in extra effort and express it here ?
    - Think!! Unless we externalize this knowledge, we will be called routinely to solve the same problem again and again. And that starts to be wastage of our time.
1. But is that not already covered in our documentation ?
    - No! As mentioned earlier, we tend to avoid these generally. 
    - If they were already there -- all troubleshooting could be solved from our documentation.
    - And even for arguements sake, let us assume we try to extract KG from the documents. We can use existing `NLP models` to help us. We will see that these extracted KG will be dirty and incomplete. They will be need to be reviewed by developers and cleansed and more information added. It will be huge expenditure of time and resources.

## To run:

### Optional but highly recommended Step
1. Download the docker for Neo4j Graph database on your machine and start it
    ```
    docker pull neo4j:5.13.0-community-ubi8
    ```
1. And then start the Neo4j DB
    ```
    docker run \
        --restart always \
        --publish=7474:7474 --publish=7687:7687 \
        neo4j:5.13.0-community-ubi8
    ```
1. Finally log into Ne04j and change the [password](https://neo4j.com/docs/operations-manual/current/docker/introduction/#docker-image) . As explained in the link
    1. Log into http://localhost:7474
    1. Log in using usernname/password neo4j/neo4j
    1. Changethe password. We need to use it in the .env file as explained below.
1. Create a `.env` file under the root dir. It should contain
    ```
    NEO4J_PASSWORD="put your password"
    NEO4J_URL="neo4j://localhost:7687"
    NEO4J_DB="neo4j"
    ```
### Run the code
1. `git clone` this repo.
1. Put your xml file describing the relationship in `knowledge-graph/input` dir. This currently has a few samples to test out the process. Follow the conventions as [outlined](./doc/naming.md) here.
1. ```cd knowledge-graph```
1. ```python src/main.py```
1. This will create the graphs in knowledge-graph/output dir
1. If Neo4j is running on your laptop, these graphs will also be saved into the Neo4j graph DB. Remember, the local docker is stateless. So it will lose all when restarted. However, when you run the code again, it will be populated.

### Visualizing in Neo4j
1. Log into http://localhost:7474 using your new password.
1. Type in this query in the command prompt
    ```
    match(p) return(p)

    ```
    This essenntially is equivalent to `show all`. A read of [this](https://neo4j.com/docs/cypher-manual/current/queries/concepts/) will not take more than a few minutes but will be of immense help.
1. Now you can zoom into the graph and click on each node and relationships to make sure they are what you want it to be.
1. If not, delete the data by running this query in the command prompt
    ```
    match(p) detach delete(p)

    ```
    - Then change your xml.
    - Run the main.py again. 
    - And examine the new data in Neo4j browser.


## Guidelines for conventions to be followed for ACM

Refer [here](./doc/naming.md)

## Detailed discussion on Knowledge Graph and documentation
[Knowledge graphs: Introduction, history, and perspectives](https://onlinelibrary.wiley.com/doi/10.1002/aaai.12033) - a very easy to read and good paper.

*This section is Generated by ChatGPT*

|Category|Knowledge Graphs|Documentation|
|---|---|---|
|Semantic Relationships|Capture semantic relationships between entities. They represent not just the information itself but also the relationships between different pieces of information. This allows for a more nuanced and context-aware understanding.|Often presents information in a linear or hierarchical fashion, lacking the ability to represent complex semantic connections between different concepts.|
|Flexibility and Scalability|Are flexible and can accommodate new information and relationships easily. They scale well as the amount of information grows, providing a dynamic and adaptable structure.|May become cumbersome and less flexible as the volume of information increases. Maintaining and updating documentation can be time-consuming.
Facilitates Discovery and Exploration|Facilitate exploration and discovery by allowing users to traverse relationships and uncover hidden connections between entities. This interactive exploration can lead to new insights.|Requires users to follow a predefined structure, and discovering non-linear relationships can be challenging.|
|Machine Reasoning and Inference|Enable machine reasoning and inference. Algorithms can traverse the graph, infer new relationships, and make logical deductions based on the existing knowledge.|Primarily relies on human interpretation, and automated reasoning is limited.|
|Natural Language Understanding|Can be used to enhance natural language understanding by providing a structured representation of concepts and their relationships. This is particularly valuable for applications like chatbots and virtual assistants|Relies on users to interpret and understand information in natural language without the benefit of explicit semantic connections.|

*In summary, knowledge graphs provide a richer, more interconnected representation of information compared to traditional documentation. They excel in capturing complex relationships, supporting scalability, and enabling both human and machine understanding of knowledge.*





