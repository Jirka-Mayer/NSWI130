## Views

### How are the views documented?

The software architecture of DM is further documented according to the [C4 model](https://c4model.com/) using its 2 levels - [container](https://c4model.com/#ContainerDiagram) level and [component](https://c4model.com/#ComponentDiagram) level.
The documentation also uses supplementary diagrams - [deployment diagrams](https://c4model.com/#DeploymentDiagram) and [dynamic diagrams](https://c4model.com/#DynamicDiagram).

### DM Container View

Every container that is used by system user communicates with Backend Server. 
Backend Server gathers data from connected Database. Apart from user applications and Database, only Supplier is connected to the Backend Server to receive drug packages orders.

![](embed:drugMonitoringContainerDiagram)

#### System interactions

**Storekeeper**

Storekeeper represents a person, who is responsible for managing the hospital drug warehouse. He uses Warehouse Management App, which is used to access the drug supply overview and manage the ordering of new drugs from the Supplier. Storekeeper is a unique person. He has his own workstation with his own work computer which has the required app running. But given the app is a web application, he can order the drugs from elsewhere as long as he has the needed credentials to do so.

**Warehouse Worker**

Warehouse Worker is responsible for stocking arriving drug packages entering the warehouse and unstocking drug packages that leave the warehouse after they have been ordered from a hospital ward. The person performing stocking can be different from the one unstocking the drug packages. To enable this, warehouse workers can use scanners that read the drug bar codes to do their job. On those devices, Stocking Counter container must be running.

**Ward Worker**

Ward Worker is a person who records the arrival of the drug packages requested from the Warehouse. When the arrival of drug packages is recorded by the Hospital Ward Worker, the Warehouse transfers its responsiblity for the drug package onto the receiving Hospital Ward. Once the drug package is wholly consumed, the Ward Worker records its depletion.
To record the arrival and depletion, the Ward Worker can use a designated device, which has Ward Counter container running. The devices can be of the same type as the ones Warehouse Workers use in Warehouse.

**Head Nurse**

Head Nurse is responsible for requesting drug packages from the Warehouse. For that she uses the Request Management App which can be run in any internet browser allowing her to be mobile and not dependent on her work computer. Head Nurse is a unique person for a Hospital Ward who needs a special authentication to order the drugs from the Warehouse.

**Hospital Employee**

Any Hospital Employee that is connected to the Hospital private network can track the lifecycle of individual drug packages on his/her mobile phone given they have the Lifecycle Monitoring App installed on their device. 
Application can provide information about the drug package whereabouts in the given moment or when did the package changed its location. Basically any change of location is recorded and this App enables the viewer to see its flow through the hospital.

**Supplier**

Supplier is an external system, which receives drug orders from the Storekeeper. The system confirms the order once it has been processed. 

#### Inside the DM system

The DM system can be intuitively separted to the "Warehouse" part and "Hospital Ward" part. Those two parts respectively provide functionalities to handle jobs in those two parts of hospital. The rest of the containers are complements of the system to support the Warehouse and Hospital Ward parts and the last functionality, which is to provide drug package lifecycle overview.

**Warehouse functionalities**

- Order drug packages from the Supplier
- Stock the drug packages upon their arrival to the hospital
- Manage drug requests from the Hospital Wards
- Unstock the drug packages from the warehouse

**Hospital Ward functionalities**

- Order drug packages from the Warehouse
- Stock the drug packages upon their arrival at the Hospital Ward
- Unstock the drug packages from the Hospital Ward upon their depletion 

**Other functionalities**

- View the drug package lifecycle in a mobile application

### Complete DM Component View

Backend Server implements the backbone functionality of DM. 
Because the component view is quite complex, it is better to read the documentation of separate component diagram parts and then view the Complete Component diagram shown below for reference.

![](embed:backendServerComponentDiagram)

#### Warehouse Ordering/Management Component Diagram

The Warehouse Management App allows the Storekeeper to do two different things:

- View the drug packages supply in the Warehouse
- Order new drug packages from the Supplier when needed
  
For this the App uses two different Controllers. 

The Ordering Controller receives API calls from the APP and forwards them to Ordering Component, which handles drug orders. The Ordering Component sends the actual order to supplier and records the order details in the local hospital database. To do that, the data are first run through the Warehouse Object Model to allow easier data manipulation and possible transformation.

The Warehouse Controller receives API calls from the WArehouse Management App when the Storekeeper wants to see the current numbers of drug supplies present in the Warehouse. It is also used for viewing drug requests fom the Hospital Wards. Warehouse Controller forwards the call to Warehouse Management Component which aggregates data gathered from the local hospital database. Between the database and the Warehouse Management Component there is again Warehouse Object model for easy data manipulation and possible future transformation.
![](embed:WarehouseOrderingComponentDiagram)

#### Warehouse Stocking Component Diagram

Stocking Counter makes API calls to Stocking Controller with the input it has been given. The Controller then forwards the call to Stocking Component which modifies the warehouse state of the drug package through the Warehouse Object Model. The Stocking omponent also reports state changes to Package Lifecycle Component which then makes needed updates in the database through the Package Lifecycle Object Model.

Models serve for easier data manipulation and easy possible future data transformation.

![](embed:WarehouseStockingComponentDiagram)

#### Package Lifecycle Component Diagram

Lifecycle Monitoring App makes API calls to Lifecycle Controller which forwards the call to Package Lifecycle Component and then reads requested data from the database using the Package Lifecycle Object Model for better data manipulation and interpretation.

Package Lfecycle Component is also notified by Stocking, Arrival and Depletion Components whenever a drug package changes state. Details of these Components are described in their diagrams.

![](embed:PackageLifecycleComponentDiagram)

#### Ward Component Diagram

Ward Counter can make API calls to two different Controllers. Which one is used is determined by the action Ward Counter is performing. 

Upon drug package arrival, the call is made to Arrival Controller which forwards the call to Arrival Component. There the data are recorded to database through the Ward Object Model and it also notifies the Package Lifecycle Component that the drug package has changed its state. The change is then recorded to the Database through Package Lifecycle Object Model.

Upon drug package depletion, a similar path is taken but the Ward Counter makes call to Depletion Controller which then only communicates with Package Lifecycle Component which makes updates in the database using Package Lifecycle Object Model. There is no need for Depletion Controller to communicate with more components because there is no other administration behind the package depletion than only the change of state. 

Request Management App makes API calls to Drug Request Controller which forwards the call to Drug Request Component. It then records the request to the database with the help of the Ward Object Model.

The acknowledgement of package arrivals at the Arrival Component is neccessary to keep track of the drugs after they left the Warehouse and safely arrived to Ward. If there is no acknowledgement of package arrivals, we have no guarantee that the requested drugs really arrived to the right Ward or that they arrived at all. 

![](embed:WardComponentDiagram)

### Drug package ordering in DM Dynamic View

![](embed:OrderingDynamicView)

### DM Deployments

There exists only one deployment environment for DM system.

#### DM System Production Deployment

This deployment is the current production environment of DM.

It is worth mentioning that warehouse stocking and unstocking posts use the same container, only deployed on different hardwares as the stocking and unstocking workers in the warehouse are expected to be posted in different parts of the warehouse. Those native applications are deployed on only two devices (each in different part of the warehouse) because the drug flow path in the warehouse is one-way.

The Lifecycle Monitoring App is expected to be installed on every work mobile phone device owned by a hospital employee so the number of deployments is higher.

Request Management App as well as Ward Counter are needed in every hospital ward so their deployment number depends on the number of hospital wards in given hospital.

The data load on the database in one particular moment is not expected to be higher than units of requests per second. Because of that the Database has no load balancer and is run in unique deployment.

![](embed:productionDeploymentDiagram)
