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

Since *medical devices* are independent of each other we can read in parallel from them with multiple *Device web API*. We would need a new controller to keep track of registered devices, remove them from individual web APIs and keep the number of device handled by individual web APIs balanced

> Medical staff request patient medical data

- **Source:** *Medical staff*
- **Stimulus:** Sporadically checks patients medical data during the entire day
- **Artifact:** *PMC Server* container
- **Environment:** Normal operation
- **Response:** All requests processed
- **Measure:** With average latency of 1 seconds

This scenario presents a standard operation of the software system and the system should be able to accomodate such requests. The requests, while sporadic, will mostly be sparse. No alteration to the system is thus needed

### Testability or sth?

TODO


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
