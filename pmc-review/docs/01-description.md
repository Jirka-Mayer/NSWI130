## Project Description

### Overview
**Patient monitoring and control** is a software system which provides medical personnel with the means to (de)allocate patients and view patient's condition as well as the patient's history within a medical facility. All this functionality is provided to users (medical (support) personnel) via web/mobile applications.

The system integrates with and is dependent on existing physical devices (sensors) and other software systems of the medical facility. The system is a **read-only** application with the exception of device management done by the *medical support staff*, allocation of patients and prescribing drugs. This means that apart from the device management, patient allocation and drug prescription, the data is only to be viewed by the personel. Patient allocation and drug prescription is on a facility-department basis. This means that only *medical staff* from department A (further denoted as *authorized*) can modify data related to a patient situated in the department A. 

#### Definitions
* from now on, these definitions will be used and *emphasized* wherever used

**Medical staff/personnel** - a doctor or otherwise authorized person who is permitted to view and modify a treatment of a patient, belongs to a hospital department

**(Medical) device** - a real-time physical device used to monitor physical properties of human body (internal processes, external phenomena, fluid analysis, ...)

**Medical support staff/personnel** - a technician or otherwise authorized person who is permitted to attach and physically maintain *devices*  

**Patient's condition** - a collection of the data from *devices* attached to a bed occupied by a *patient*

**Patient's hospitalization history** - a collection of data spanning all the time periods the *patient* has been hospitalized in the current medical facility, includes *patient's condition* recordings, drug usage.

#### Constraints & Requirements
* inaccessible from the Internet, local access only
* authorize *medical (support) staff* and detect new *patients* using the data provided by external software systems
* allow **authorized** *medical personnel* to 
  * allocate a patient to a particular bed
  * prescribe medication which will be automatically fetched from existing drug system
  * view patient's *current condition*
  * view patient's drug prescriptions
  * view *patient's hospitalization history*
* provide automatic *patient history* persistence and store patient-related data (*condition*, allocation, drug usage) for patient's current hospitalization
* manage communication with *devices*
* allow *medical support staff* to
  * manage *device* allocation to a bed
  * react to *device* malfunction
* manage drug allocation
  * request a drug package from external software systems
  * report depletion of a drug package to external software systems

### Role of the PMC system within the hospital network
In addition to the requirements, the system also provides *medical support staff* with notifications about device malfunction.
Following systems are expected to be operational and reachable within the hospital network:
* Drug Monitoring - takes care of drug allocation & delivery
* Patient Registry - a system providing simple information for all patients hospitalized
* Authorization Server
* Medical Devices - see definition of *(Medical) device*

![](embed:Level_1)

### System Design

Based on requirements, PMC software system consists of three main parts:
- PMC Application
- Devices Application
- Drugs Usage Application

Medical staff access the system via PMC Application, medical support staff manages devices via Devices Application -- users access the application via browser. Each application is designed following four-tier architecture. Structure of PMC Application is described in further details in section [PMC Core Application](#2.1), similarly Devices Application in [Devices Application](#2.2) and Drugs Usage application in [Drugs Application](#2.3). Following [Workflows section](#1.4) describes workflows in PMC software system from users and external systems perspective.

![](embed:Level_2)

### Workflows

Following diagrams describes how PMC software system is utilized in workflows with medical users and external systems. It is assumed that users are already authenticated via OAuth Authorization server.

#### Patient management

Following diagram describes the process of new patient discovery. If *medical staff* wishes to see incoming patients without a bed assignment, they interact with the web application. The PMC server, which forms a proper list of desired patients, requests data about new patients from the Patient registry and filters out those, who do not have a bed assigned. Such list is then formatted and displayed by the frontend to be seen by medical staff.

![](embed:SimplePatientDiscoveryWorkflow)

Following diagram describes the workflow of assigning a patient to a bed. *Medical staff* interacts with the web application, assigning a patient to a bed. The PMC server saves this change and responds by signaling success or failure. The response is displayed as a notification or an announcement window (possibly describing an error in a non-technical way).

![](embed:SimpleAddPatientWorkflow)

Following diagram describes the workflow how the PMC system provides current *patient's condition* data. *Medical staff* requests patient condition data via the web application. The PMC system then requests the current data of the devices attached to the patient's bed. This data is interpreted and displayed to the user in the web application. 

![](embed:SimplePatientConditionCheckWorkflow)

#### Drugs management

The following diagram describes how drugs are prescribed to a patient. *Medical staff* assigns new drugs to a patient using the web application. The *PMC server* relays this request to the *Drugs Application*, whose task is to store the data about prescriptions. If the drug is not available, the *Drugs Application* sends a request of a new delivery to the *Drug Monitoring* system.

![](embed:SimpleDrugsManagementWorkflow)

#### Devices management

Following diagram describes regular workflow how PMC software system manages medical device data. Medical support staff register medical devices to hospital beds in Devices Application. PMC Application then sends periodical requests to Devices Application to fetch new devices data for each hospital bed.

![](embed:SimpleDeviceAssignmentWorkflow)

Following diagram describes workflow in case of device malfunction. In case of malfunction, medical support staff is notified via e-mail and Slack app notification. Medical support staff can view device malfunction details in Devices Application. Response to PMC Application then contains generic non-technical notification available to medical staff. 

![](embed:SimpleDeviceFailureWorkflow)
