## Quality attributes


### Performance

TODO


### Testability or sth?

TODO


### Availability

- masking problems
- repairing problems
- detecting faults & failures
    - není třeba mít monitor, protože máme liveness probes in k8s (už ho máme)

- possible avail. req. scenarios ("něco spadne")
    - ?
    - ?

- what is the function that absolutely HAS to work?
    - ????


- System functions:
    - assing new patients to beds (not absolutely crucial - may wait 1 day)
    - viewing patients condition (SUPER IMPORTANT - being not available impacts department's workflow dramatically and immediately)
    - drug prescription is equally as important
        - co když vypadne drug monitoring systém? -> pozdržíme prescription.


- Super, že to běží na kubernetes (liveness probe, replica redundancy)
- Super že replikují databázi
    - není jasné, jestli lze přeponout do read-only když master spadne
        (degraded mode)


-------------------------

The system provides multiple functionalities and not all of them are equally important
for the department's operation. Here is a short assessment of functionalities and their importance:

- **Assignment of new patients to beds** Patients typically come from a different department and thus a delay of up to 1 day due to software system availability problems is acceptable.
- **Viewing patient's condition** This is a typical action, performed very often. Having this functionality unavailable would severely disturb the department's operation. However, having this functionality unavailable does not directly threaten patient's health.
- **Drug usage** This system is of equal importance.
- **Device management** Adding, modifying or configuring bed devices usually takes couple of hours and is performed by the technical staff. A temporary outage here is not very costly.


### Internal fault tolerance

The presentation layer is implement as two web applications. These applications run in the client's browser which can be considered a robust environment. Moreover this gives the user the ability to use a different device in case of a device failure. Since there are many devices available to the department, this transitioning process is quick and has only local effects.

The business layer (PMC Server, Drugs Usage Web API, Devices Web API) are all deployed to a kubernetes cluster, each in one replica. The cluster, however, consists of only one node (Ubuntu 18.04 LTS). This is a single point of failure for the entire system and if this node goes down, so does the kubernetes control plane (which is missing in the deployment diagram). Recovering such a failure wold take couple of hours because a technician neets to (re)start the physical machine manually. A solution would be to add a second machine and have the kubernetes control plane run on both of them.

The software system containers run only in one replica each, but since they run on kubernetes, liveness probes can be setup to automatically monitor their status. Kubernetes will then restart any service that becomes unavailable. This causes couple seconds of downtime, but that is acceptable given our requirements.

The database layer is designed very well, with replication in mind. The two database instances run on different machines and they both hold the latest data. The documentation doesn't state their relationship in regards to failure, but a reasonable option is to have the database cluster perform an automatic failover.


### External fault tolerance

...


### Availability requirement scenarios

...
