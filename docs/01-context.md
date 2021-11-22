## Context

Drug monitoring is a hospital system which enables the monitoring of drug lifecycle and provides the neccessary functionalities to manage the drug flow in the hospital which includes:

- Ordering of drugs from an external supplier
- Stocking drug packages into warehouse when they come from the external supplier
- Receiving drug orders from various hospital wards in the warehouse
- Unstocking drug packages that are a part of the drug order from ward
- Stocking drug packages into the ward drug store
- Accepting the delivery of drugs from the warehouse at the ward drug store
- Making new drug orders to the warehouse from the hospital ward
- Recording drug package depletion at the ward drug store

Drug Monitoring system is used by five persons and communicates with one external system.

![](embed:drugMonitoringContextDiagram)

### System interactions

#### Storekeeper

Storekeeper represents a person, who is responsible for managing the hospital drug warehouse. He has the access to the drug supply overview. He uses the overview to manage ordering new drug supply in time to keep the drug flow in the hospital running. Storekeeper is a unique person. He has his own workstation with his work computer which has the required apps running.

#### Warehouse Worker

Warehouse Worker is responsible for stocking arriving drug packages entering the warehouse and unstocking drug packages that leave the warehouse after they have been ordered from a hospital ward. The person performing stocking can be different from the one unstocking the drug packages. To enable this, warehouse workers can use scanners that read the drug bar codes to do their job. 

### 

## Container Context

--The container context documentation goes here--



![](embed:drugMonitoringContainerDiagram)


## Overview of Component Context

--The Overview of Component Context documentation goes here--



![](embed:backendServerComponentDiagram)