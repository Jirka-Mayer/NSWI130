## Quality attributes


### Performance

#### Performance requirement scenarios

>  *Patient Condition Controller* of *PMC server* periodically fetches medical device data for long-term storage

- **Source:** *PMC server* container
- **Stimulus:** Periodic read of device information from every device (~5000) every 30 seconds
- **Artifact:** *Device web API* container
- **Environment:** Normal operations
- **Response:** All fetch request processed
- **Measure:** With latency no larger than 30 seconds

Since *medical devices* are independent of each other we can read in parallel from them with multiple *Device web API*. We would need a new controller to keep track of and manage registered devices, and keep the number of device handled by individual web APIs balanced

Upon every request the new controller would hand of the request to a specific web API along with information on which device to read from. The list of registered devices is thus kept only with the new controller.

![](embed:Level_3_devices)

> Medical staff request patient medical data

- **Source:** *Medical staff*
- **Stimulus:** Sporadically checks patients medical data during the entire day
- **Artifact:** *PMC Server* container
- **Environment:** Normal operation
- **Response:** All requests processed
- **Measure:** With average latency of 1 seconds

This scenario presents a standard operation of the software system and the system should be able to accomodate such requests. The requests, while sporadic, will mostly be sparse. No alteration to the system is thus needed

### Usability

The system provides various functionalities. Every one of them supports different kinds of tasks. The system is mainly used for *reading* acquired data, but
some parts can be changed while interacting with the user.

Main use cases are:
- **Assignment of new patients to beds** 
- **Viewing bed distribution among patients** 
- **Viewing patient's condition** 
- **Viewing and assigning drug usage** 
- **Device management** Reading data acquired from devices connected to patient's bed (reading patient's condition if working properly, otherwise reporting to Medical support staff). Installing and setting the devices to a different bed.

**Learning system features**

The system should be intuitive and easy to use for everyday use in the hospital. Every task should be done swiftly and without big delays. Every person in the hospital should be learning how to use only the part of the system they will be actively using. Therefore there is no need for doctors to learn how to use Device Management App and for Medical Support Staff there is no need to learn how to order drugs or prescribe drugs to a speific patient or how to allocate the patients to the hospital beds.

**Using system efficiently**

To be able to use the system efficiently, it should be intuitive, clearly organised and allowing the aggregation of data while reading or changing them. User initiative support should be implemented in order to ease the use of the system. Features of User Initiative Support is described further below.

**Minimizing the impact of errors**

As with efficiency, for minimizing the impact of errors, user initiative support should be in place, mainly mechanisms of *Cancel* and *Undo*.

**Adapting the system to user needs**

For proper adaptation of user needs, basic User initiative support should be in place and for more efficient system using, System Initiative Support can be implemented. Read about suggestions down below.

**Increasing confidence and satisfaction**

For proper confidence in the system, any failure or success of functionality should be reported to the user. When a drug prescription is changed, the system should inform us whether the change got through to the database or whether there was any error along the way. No failure should be left unreported. It should not be the responsibility of the hospital staff to manually check every device if it is currently properly working. Any suspicious behavior should be immediately reported to authorised problem solving personnel.

#### User Initiative Support

**Cancel** Cancelling an action in PMC is not needed very often. 

> Drug order is suddenly redundant.

Imagine a situation when one patient who had a drug prescribed is released to home care. The drugs are no longer needed for his treatment and can be reallocated to other patients. Suddenly a shortage of a drug is no longer in place. What more, there may be not enough space to store the incoming shipment. Therefore it is useful to be able to cancel once issued drug order.

**Pause/Resume** The only functionality that may need this mechanism is the device management - of one specific device.

> A patient is being moved by the medical staff.

The device on patients bed may be paused to stop it from triggering an alarm. Then it may be resumed to its previous function without long setting after manipulation with the patient is done.

**Undo** Is one of two most needed activities that may be needed in the PMC system. It may be needed in a device installing or wrong drug prescription.

> Doctor prescribes s new drug to a patient. Then he is warned by a system, that the drug can't be prescribed with the already prescribed drugs. 

The change should be therefore undone with ease. This should be allowed by undo mechanic. Its implementation is possible because the system persists the drug prescription data.

**Aggregate** Is the second of the two most needed activities that may be needed in the PMC system. Since there are many of the same or very similar entities in the system (hospital beds, drugs, patients, devices) it is mandatory to enable the users to treat them in groups. 

> Orthopedic wing is flooded by water due to broken water pipes. Patients need to be moved to another hospital wing. 

If the capacities allow it, don't move them in the system one by one but all at once. They are all ungoing the same change.

#### System Initiative Support
Models which could be useful in our Patient Monitoring and Control system, but are not currently supported by specific modules:

**Task model** 

> When receiving new patient, if diagnosis is available, recommend available hospital bed in suitable hospital wing.

Instead of just filtering patients without assigned hospital bed, recommend a solution if diagnosis data are available.
No hospital wing / diagnosis recommender map is available at the moment, however if it was to be implemented, the bed database is already available so only mapping of diagnosis-hopital wings would be needed to succesfully make a suitable new module for handling this kind of recommendations.

**User model**

> Drug recommendation based on previous patients' diagnosis and drug prescription.

If a patient has the same diagnosis as a patient treated before him, the same drugs may be used in his treatment. Recommend the combinations to save the time and just ask for doctor's agreement. If the drugs shall be for any reason different, let the doctor prescribe custom drugs.
However, patient history is stored in the system and if the component for recommending was to be implemented, it has the data it needs.

**System model**

> Show estimated time to arrival of demanded drugs.

The hospital wing may be in serious time pressing need of specific drugs (a rare case of illness/injury). If the system shows higher estimated arrival time than is acceptable, it can react by dispatching an emergency courrier to acquire them in a faster way not going through the Drug monitoring system warehouse order management. The drug package shall be then received as usual but without the delay at the supllier's side.
There is currently no way to bypass the drug management ordering process conducted by Drug management external system. It obviously should not be bypassed in most of ordinary scenarios. However if drugs were to get to hospital the unofficial way, the systems would struggle to handle them properly without their proper registration to the package system.

#### Usability requirement scenarios

From the analysis above we extracted requirement scenarios:

> Medical support staff receives notification about device failure. Find out where the device is.

- **Source:** Medical support staff
- **Stimulus:** Device Failure Notification received
- **Artifact:** Device Web API (Devices Notification Component)
- **Environment:** Normal operation
- **Response:** The notification/e-mail contains link to the affected device, saving the worker the need to open Device Web App manually
- **Measure:** 1 click to read the failed device specification (location, brief error message)

In current system architecture, it is possible to implement this feature. Devices Management Component is able to gather data about failed device. Through the Devices Data Component it is able to load the device endpoint used in the Devices Web App. No change in the architecture is needed to implement this feature.

> A new enhanced brand of drugs is operating on the market. Hospital wants to use it instead of its old corresponding drugs.

- **Source:** Head nurse
- **Stimulus:** Change currently used brand of drugs in all affected patients' drug prescriptions
- **Artifact:** PMC Web App
- **Environment:** Normal operation
- **Response:** The system changes prescribed drug brand for another in all ongoing prescriptions, saving the old brand to history
- **Measure:** In 1 minute without manually searching for every individual affected patient

Drug Controller implements the logic related to getting patient's drug data. If it is implemented in a way that it can get more data at once, there can be a function that filters the data by a given criterion. Then it should be possible to have those filtering options implemented also in the PMC Web App. Therefore no architecture change should be neccessary.

> In case of catastrophy, we need to get the number and placement of *all* available beds for incoming injured people.

- **Source:** Hospital capacity manager
- **Stimulus:** Search for number and placement of available beds
- **Artifact:** PMC Web App
- **Environment:** Normal operation
- **Response:** The system gives number and placement of available beds
- **Measure:** Manager is able to tell a contact person from emergency services their current bed capacity

In the specification it is stated that the patients data should be available only for the specific hospital wing staff. However, given that the system is only running once, it can be assumed that there is some implicit filtering done by the user's allocation. If we accept that a director of the hospital should be able to oversee all allocations and patients and devices in the hospital, it can be possible to make a superuser or a superuser for a specific functionality, that would return records from *all* hospital wings, not just one. So we have PMC Data Storage which has available beds configuration, the Persistance Layer above with Patient Location Controller. 
Either the Patient Location Controller includes overview of available hospital beds, or a new Controller must be introduced that would be providing data of available beds, and the Controller should communicate with the Patient Location Controller to provide possible allocations for patients.

If the new Hospital Bed Controller is needed, the Component Diagram for PMC Server would look like this:

![](embed:Level_3_central)

### Availability

The system provides multiple functionalities and not all of them are equally important
for the department's operation. Here is a short assessment of functionalities and their importance:

- **Assignment of new patients to beds** Patients typically come from a different department and thus a delay of up to 1 day due to software system availability problems is acceptable.
- **Viewing patient's condition** This is a typical action, performed very often. Having this functionality unavailable would severely disturb the department's operation. However, having this functionality unavailable does not directly threaten patient's health.
- **Drug usage** This system is of equal importance.
- **Device management** Adding, modifying or configuring bed devices usually takes couple of hours and is performed by the technical staff. A temporary outage here is not very costly.


#### Internal fault tolerance

The presentation layer is implement as two web applications. These applications run in the client's browser which can be considered a robust environment. Moreover this gives the user the ability to use a different device in case of a device failure. Since there are many devices available to the department, this transitioning process is quick and has only local effects.

The business layer (PMC Server, Drugs Usage Web API, Devices Web API) are all deployed to a kubernetes cluster, each in one replica. The cluster, however, consists of only one node (Ubuntu 18.04 LTS). This is a single point of failure for the entire system and if this node goes down, so does the kubernetes control plane (which is missing in the deployment diagram). Recovering such a failure wold take couple of hours because a technician needs to (re)start the physical machine manually. A solution would be to add a second machine and have the kubernetes control plane run on both of them.

The software system containers run only in one replica each, but since they run on kubernetes, liveness probes can be setup to automatically monitor their status. Kubernetes will then restart any service that becomes unavailable. This causes couple seconds of downtime, but that is acceptable given our requirements.

The database layer is designed very well, with replication in mind. The two database instances run on different machines and they both hold the latest data. The documentation doesn't state their relationship in regards to failure, but a reasonable option is to have the database cluster perform an automatic failover.


#### External fault tolerance

There are many external software systems that may fail. The following is an assessment of the impact of such a failure:

- **Medical Device** Although viewing patient's condition is a primary functionality, having a single device fail does not impact the functionality of the entire system. Moreover, given the number of connected devices, having one failed is a usual event and the PMC system even incorporates functionality for reporting such failures to the department staff.
- **OAuth server** This external system is relied upon by many other software systems throughout the hospital. For this reason is this system designed to be highly available and thus very unlikely to fail.
- **Patient registry** An old system, prone to failure (approx. once a month for an hour). While this system may fail, our system relies on it only when accepting new patients. Since this process is already time consuming, a temporary external system failure does not slow it down substantially. For this reason we do not need to take any measures here (e.g. adding a local cache). Our system remains in a degraded state during the downtime of the patient registry.
- **Drug monitoring** While this system may go down occasionally, it is only used for requesting new drugs and reporting drug depletion. Our local drug usage system already stores information about lots of different drugs and their identification numbers are compatible with the external system. Therefore both drug requests and depletion reports may be queued locally during DM downtime. This will cause the local data (drug metadata, drug list, ...) to get stale over time, but they chage so rarely that it isn't a problem.

The architecture of the *Drug Usage Web API* container needs to be slightly modified. The *Drug Catalog Manager* needs to leverage the *Persistance layer* during DM outage. The *Drug Delivery Manager* needs to queue requests via the *Persistance layer* during DM downtime and also send these requests when DM becomes available.

![](embed:Level_3_drugs)


#### Availability requirement scenarios

From the analysis above we extracted requirement scenarios:

> External drug monitoring system is down and someone requests drugs.

- **Source:** *Drugs Usage Web API* container
- **Stimulus:** Unable to connect
- **Artifact:** *Drug Monitoring (DM)* external software system
- **Environment:** Normal operation
- **Response:** Mask fault (queue the request)
- **Measure:** No downtime

> Business logic container crashes, is restarted by kubernetes.

- **Source:** *PMC Server* container
- **Stimulus:** Unable to connect (omission)
- **Artifact:** *Devices Web API* container
- **Environment:** Normal operation
- **Response:** Mask fault (repeat after 10s)
- **Measure:** 10s downtime

> Patient registry is unavailable.

- **Source:** *PMC Server* container
- **Stimulus:** Unable to connect (omission)
- **Artifact:** *Patient registry* external software system
- **Environment:** Normal operation
- **Response:** Describes the problem to the user
- **Measure:** Degraded state
