
## Development Documentation

Following sections contains further technical details for each application in PMC software system.

#### Note on terminology
For clarity, in the PMC Core Application Container, there are only **Controller components** which, however, encompass both public (pre-generated, Swagger-like) web API **and business logic**. In other components the Controller's role is to provide only the public API and redirect requests to business-logic-related components.

In the entirety of the documentation, whenever you see a **persistence layer**, keep in mind that this component includes both the collection of **data models** for individual business logic components and separated & flexible **means of communication with the underlying database** system. 

### PMC Core Application

The main purpose of the PMC Core Application is to bring the whole system together by connecting all the other parts and provide the system's services to users (except for the medical support staff, that should use the *Devices Application* instead). It also directly handles patients' history and the allocation of hospital beds.

![](embed:Level_3_central)

Looking at the diagram horizontally, you may see that the server is composed mainly of two different layers - *Controllers* and the *Persistence Layer*. The web application communicates with the controllers (their API), which contain the business logic and store or retrieve data through the persistence layer (see [Note on terminology](#1.2.1)).

Vertically though, the diagram is divided into four separate units, each handling a different set of tasks the PMC Server needs to carry out. These tasks are primarily the prescription of drugs, managing patients' history, the allocation of beds to patients and monitoring the patients' condition.

#### New-patient detector

In order to notify users of the application (the medical personnel) that a new patient does not have a bed allocated to them, the list of new patients is needed. The *New-patient detector* component is used to obtain this list using the *Patient registry*. It expects that the *Patient registry* provides data that are sufficient to determine this information.

#### Patient Condition Controller

Short history records about a patient's condition (the results measured by devices at a particular bed) are stored within the *Devices Application*. The *Patient Condition Controller* fetches them periodically and ensures the data about the current hospitalization are available in the *Persistence Layer* of the *PMC Server*.

#### Patient History Controller

All the other controllers in the *PMC Server* use models concerning the current hospitalization of patients. When a patient leaves the hospital, the *Patient History Controller* takes all the data collected during the hospitalization and stores them via the *Persistence Layer*.

#### Related workflows

In this workflow, we provide a detailed look at how new patients are discovered and displayed to the user. [New-patient detector](#2.1.1) provides only a list of new patients. It is up to the Patient Location Controller to filter only those, who don't have a bed assigned yet and respond to the frontend's request with the correct list. 

![](embed:PatientDiscoveryWorkflow)

In this workflow, we provide a detailed look at how patients are assigned to a bed. Patient location controller verifies if such change can be done and writes the change via the persistence layer. In the case another patient (who has departed) already occupied the same bed as requested, that patient's data is requested to be moved to history data models via the patient history controller.

![](embed:AddPatientWorkflow)


### Devices Application

Devices application handles management and communication with medical devices. Devices Web API makes requests to devices on behalf of another services. Devices Web App allows medical support staff to manage medical devices.

![](embed:Level_3_devices)

#### Devices Web App

Devices Web App allows medical support staff to register, move and unregister devices to hospital beds. In case of a device malfunction, users can see latest communication with the device.

#### Devices Web API

Devices Web API solves problems regarding non-uniformity in communication with medical devices -- each device is possibly communicating via different communication protocol and provides data in different data formats. Consumers of Devices Web API uses REST/Json API which returns device data in unified device model, with provided schemas for each device type. Consumers can request data from all devices registered under bed which ID is provided in request.

The differences are internally managed by adapters registered for each device type. When API receives a request to pull data from device, the request is delegated to device's adapter which directly contacts the device and converts device's response to unified data model of device data. The model is then serialized to JSON available to consumers of the API. When system needs to communicate with new type of devices (e.g. new type of temperature sensors), new adapter needs to be developed.

#### Managing Devices

Devices Web API application handles most of the implementation logic in component Devices Management, containing core logic for devices management and communication. Each Spring Boot controller executes granular steps defined in this Devices Management controller. Metadata, such as device configuration and their allocations to beds, are stored in the persistent storage. The communication with persistent storage is managed by persistance layer, which contains definitions of ORM data model used by application's internal logic. Devices Management stores latest requests activity for diagnostics.

#### Handling Device Malfunctions

When adapter fails to communicate with device or device returns invalid state, Devices Management component receives error based on type of failure. Devices Management stores error in communication under latest requests for the device and contacts Devices Notifications component to inform users via email and notification is sent to Slack application.

![](embed:DeviceFailureWorkflow)


#### Related Workflows

This workflow describes how the real-time *patient's condition* is checked and communicated by and within the system. This diagram requires you to know the workings of the [PMC Core Application](#2.1), be sure to read through that section first. After the frontend's request, the PMC core application requests data from [Devices Web API](#2.2.2) which sees the request though and returns data in a unified format as described in [it's documentation section and the following sections.](#2.2.2) 

![](embed:PatientConditionCheckWorkflow)

### Drugs Application

Takes care of all drug related problems and communications with *Drug Monitoring*.

All actions are taken as responses to requests from *PMC Server*, there is no active local loop.

Possible requests from *PMC Server* are:
- drug information query from drug catalog
- change of patient's prescriptions
- notification of used drugs

![](embed:Level_3_drugs)

#### Drug Controller

Interface to be accessed by *PMC Server*, simply relays requests translated into local format of *Drug Application*.

#### Drug Delivery Manager

Interface accessing *Drug Monitoring* to request delivery of needed drugs and to report consumed drug packages.

#### Drug Catalog Manager

Queries drug information from *Drug Monitoring*. It is separated from core of *Drugs Application*, because this feature is completely orthogonal. Rest of *Drug Application* can work purely with drug ID and *Catalog Manager* does not need any drug storage or prescription information or any kind of local persistent storage. Furthermore, conceptually it is not even necessary to use *Drug Monitoring* and rather directly access some kind of national drug catalog.

#### Drug Management

Main logic of *Drugs Application*, handles patients' prescriptions and local drug storage. Based on those it communicates through *Drug Delivery Management* to request reasonable amount of drugs for near future.

#### Related Workflows

The following workflow diagram elaborates on how drugs are prescribed to a patient. You can read about the [simplified version](#1.4.2) in a previous section. Notice that drug prescriptions are stored within the [Drugs Application](#2.3) and a request of a new delivery may be sent to the *Drug Monitoring* system in case the prescribed drugs are not available.

![](embed:DrugsManagementWorkflow)

### Deployment

To comply with safety requirements, deployments are being accessible only in hospital intranet (in diagrams denoted as base-intranet-url). As a microservices architecture, each application in PMC software system is deployed independently on another application as a single service.

#### Application deployment

Applications are managed by Kubernetes in k8-med-apps instance, each application running in own docker container. Applications scaling can be allowed by requesting DevOps managing k8-med-apps server. Users access Devices application under devices.pmc and PMC application under app.pmc in hospital's intranet.

#### Storage deployment

Each application uses its own database in Primary Oracle instance on med-db01 database server. To comply with regulations, storage is replicated to secondary storage on med-db03 database server.

![](embed:Prod)
