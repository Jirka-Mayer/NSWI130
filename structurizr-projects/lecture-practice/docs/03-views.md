## Views

### How are the views documented?

The software architecture of NODC is further documented according to the [C4 model](https://c4model.com/) using its 2 levels - [container](https://c4model.com/#ContainerDiagram) level and [component](https://c4model.com/#ComponentDiagram) level.
The documentation also uses supplementary diagrams - [deployment diagrams](https://c4model.com/#DeploymentDiagram) and [dynamic diagrams](https://c4model.com/#DynamicDiagram).

### NODC Decomposition View

NODC business functionality is implemented by the NODC Server container.
Human users interact with a web application provided by NODC Web Front-end container.
The server container uses two supplemental containers Metadata Index and Metadata Storage for fast search and retrieval of catalog records, respectivelly.
The index and storage are filled by another supplemental container Metadata Harvestor responsible for harvesting local open data catalogs.

![](embed:NODC_Container_View)

### NODC Server Decomposition View

NODC Server implements the business functionality of NODC.
Its internal architecture comprises 3 layers:
* Domain Model represents the business domain of NODC which is data sets and their distributions. Its components represent the domain as a basic object model with simple get/set operations.
* Business Logic implements all the business logic on top of the domain model.
* Infrastructure implements the interaction with the other containers through APIs and gateways.

![](embed:Server_Component_View)

### Harvesting LODC by NODC Dynamic View

To harvest local open data catalogs, NODC first requests the registry to get the list of registered local open data catalogs.
It then accessed the individual local open data catalogs and reads their content.

![](embed:Harvesting_System_Dynamic_View)

In a more detail, the communication with the registry and local open data catalogs is done by the Metadata Harvestor.
First, the harvestor clears the metadata index and storage.
It then reads the list of registered local open data catalog from the registry.
For each local open data catalog, it reads its content and stores it to the storage.
Finally, it reindexes the stored metadata records from the local open data catalogs.

![](embed:Harvesting_Container_Dynamic_View)

### NODC Deployments

There exist various NODC deployment environments.

#### NODC Server Development Deployment

This deployment is mandatory for all NODC Server developers and their unit tests.

![](embed:Server_Development_Deployment)

#### NODC Live Deployment

This deployment is the current production environment of NODC.

![](embed:Live_Deployment)
