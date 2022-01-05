workspace {

    model {
        medicalStaff = person "Medical Staff"
        technicalSupportStaff = person "Medical Support Staff"

        medicalDevice = softwareSystem "Medical Device" "Hardware" "Specific type of medical device containing health sensors"

        pmc = softwareSystem "Patient Monitoring and Control (PMC)" {
            !docs docs

            group "Medical Devices Management" {
                devicesWebAPI = container "Devices Web API" "Manages medical devices" "Java Spring Boot" {
                    devicesDataController = component "Devices Data Controller" "Endpoints to get device data"
                    devicesManagementController = component "Devices Registration Controller" "Endpoints to (de)register devices"
                    devicesManagement = component "Devices Management" "Implementation logic of devices application"
                    devicesPersistence = component "Devices Persistence" "DB operations ORMs"
                    devicesNotifications = component "Devices Notifications" "Sends e-mail / sms notification to users"
                }
                devicesAdapter = container "Devices Adapter" "Resolves communication differences of devices as adapter" "" "devicesAdapter"
                devicesWebApp = container "Devices Web App" "Provides UI to manage and allocate medical devices" "React TS" "webApp"
                devicesDB = container "Devices Data Storage" "Persists medical devices configurations" "Relational DB"
                secondaryDevicesDB = container "Devices Data Secondary Storage" "Persists medical devices configurations" "Relational DB"
            }

            group "Patient Monitoring and Control" {
                pmcBackend = container "PMC Server" "Manages allocation of patients, gathering monitoring data and drugs usage" "Java Spring Boot" {
                    locationCtrl = component "Patient Location Controller" "implements the logic related to getting and setting the location of a patient" ""

                    hospitalBedCtrl = component "Hospital Bed Controller" "implements the logic related to getting and setting the hospital bed availability" ""

                    vec = component "New-patient detector" "implements the logic behind detecting new patients" ""

                    historyCtrl = component "Patient History Controller" "implements the logic related to getting and persisting patient's history" ""

                    drugCtrl = component "Drug Controller" "implements the logic related to getting patient's drug data" ""
                    
                    conditionCtrl = component "Patient Condition Controller" "implements the logic related to getting patient's current condition" ""

                    persistanceLayer = component "Persistance Layer" "Provides data mapping (in the form of many ORM classes) to the storage" ""
                }

                pmcFrontend = container "PMC Web App" "Allows to manage patient' allocation, view monitoring data and set records of drug usage" "React TS" "webApp"
                pmcDB = container "PMC Data Storage" "Persists patient history, allocation of devices to beds, available beds configuration" "Relational DB"
                secondaryPmcDB = container "PMC Data Secondary Storage" "Persists medical devices configurations" "Relational DB"
            }

            group "Drugs Usage" {
                drugsUsageWebAPI = container "Drugs Usage Web API" "Allocates drugs and reports depletion of drugs" "Java Spring Boot" {
                    drugDeliveryMan = component "Drug Delivery Manager" "Implements logic related to requesting drug delivery"

                    drugCatalogMan = component "Drug Catalog Manager" "Implements logic related to querying drug information"

                    drugUsageCtrl = component "Drug Controller" "Endpoint for drug management and info"

                    drugManagement = component "Drug Management" "Manages drug needs"

                    drugPersistanceLayer = component "Persistance layer"

                }
                drugsUsageDB = container "Drugs Usage Data Storage" "Stores available drugs allocation (balance)" "Relational DB"
                drugsUsageSecondaryDB = container "Drugs Usage Data Secondary Storage" "Stores available drugs allocation (balance)" "Relational DB"
            }
        }

        dm = softwareSystem "Drug Monitoring (DM)" "Software System"
        patientsRegistryAPI = softwareSystem "Patient registry" "Software System"
        oathUserAuthorization = softwareSystem "OAuth Authorization Server" "Software System"

        medicalStaff -> pmc "Uses PMC to manage patient health data and bed allocations"
        technicalSupportStaff -> pmc "Uses PMC to register or replace medical device to hospital beds"
        pmc -> dm "Uses DM to monitor drug usage"
        pmc -> oathUserAuthorization "Uses OAuth to authorize medical and technical staff"

        devicesWebAPI -> technicalSupportStaff "Reports device malfunctions"

        technicalSupportStaff -> devicesWebApp "Registers or replaces medical device"
        devicesWebAPI -> oathUserAuthorization "Authorizes medical support staff"
        medicalStaff -> pmcFrontend "Uses"
        pmcBackend -> oathUserAuthorization "Authorizes medical staff"

        devicesWebAPI -> pmcBackend "Requests beds data from PMC, sends new device's allocation device to PMC"
        pmcBackend -> devicesWebAPI "Queries data from medical devices"

        drugsUsageWebAPI -> dm "Reports drugs depletion"
        dm -> drugsUsageWebAPI "Allocates drugs"

        drugsUsageWebAPI -> drugsUsageDB "Uses"
        pmcBackend -> pmcDB "Uses"
        devicesWebAPI -> devicesDB "Uses"
        pmcFrontend -> pmcBackend "Uses"
        devicesWebApp -> devicesWebAPI "Uses"

        pmcBackend -> drugsUsageWebAPI "Request allocation of drugs to patient"
        pmcBackend -> patientsRegistryAPI "Fetches patients data"

        devicesManagement -> devicesAdapter "Retrieves devices data"
        devicesAdapter -> medicalDevice "Makes call to unique API"

        // PMC BACKEND L3
        locationCtrl -> persistanceLayer "Uses to access patient location data"
        vec -> patientsRegistryAPI "Queries"
        locationCtrl -> vec "Querries for new patients"
        pmcFrontend -> locationCtrl "Makes API calls to get/assign patients' locations" "JSON/HTTP"

        hospitalBedCtrl -> locationCtrl "Provides data bout available hospital beds" "JSON/HTTP"
        locationCtrl -> hospitalBedCtrl "Writes changes in hospital bed availiability" "JSON/HTTP"

        hospitalBedCtrl -> persistanceLayer "Uses to access hospital bed availability data" "JSON/HTTP"

        historyCtrl -> drugUsageCtrl "Fetches data to persist from"

        pmcFrontend -> historyCtrl "Makes API calls to get patient history" "JSON/HTTP"
        historyCtrl -> persistanceLayer "Uses to access patient history data"

        pmcFrontend -> drugCtrl "Makes API calls to get patient's drug usage data" "JSON/HTTP"
        drugCtrl -> drugUsageCtrl "Uses to access patient-drug data"

        pmcFrontend -> conditionCtrl "Makes API calls to get patient's current condition" "JSON/HTTP"

        drugCtrl -> oathUserAuthorization "Uses to authorize requests"
        conditionCtrl -> oathUserAuthorization "Uses to authorize requests"
        historyCtrl -> oathUserAuthorization "Uses to authorize requests"
        locationCtrl -> oathUserAuthorization "Uses to authorize requests"

        conditionCtrl -> devicesWebAPI "Queries sensor data from" ""
        conditionCtrl -> persistanceLayer "Uses to persists/access sensor data (during a single hospitalization)" ""
        historyCtrl -> persistanceLayer "Uses to persist data from" "various ORMs related to controllers"

        persistanceLayer -> pmcDB "Reads data from, writes data to"

        pmcBackend -> devicesDataController "Makes API calls to" "JSON/HTTPS"
        devicesDataController -> devicesManagement "Gets devices data processed by application logic"
        devicesManagement -> devicesPersistence "Stores devices data and metadata"
        devicesManagement -> devicesNotifications "Reports device's fault/failure to external services"
        devicesManagementController -> devicesManagement "(De)registers devices"

        devicesWebApp -> devicesDataController "Makes call to"
        devicesWebApp -> devicesManagementController "Makes call to"

        devicesPersistence -> devicesDB "Uses ORM to persist data"
        devicesNotifications -> technicalSupportStaff "Reports device's fault/failure to"


        drugUsageCtrl -> drugCatalogMan "Relays queries about drug information"
        drugCatalogMan -> dm "Makes API call to"
        drugCatalogMan -> drugPersistanceLayer "Caches drug information" "" "newRelationship"
        drugUsageCtrl -> drugManagement "Relays info about drug prescriptions"
        drugManagement -> drugPersistanceLayer "Stores drug prescriptions and local storage"
        drugPersistanceLayer -> drugsUsageDB "Uses to persist data"
        drugManagement -> drugDeliveryMan "Requests drug delivery"
        drugDeliveryMan -> dm "Makes API call to"
        drugDeliveryMan -> drugPersistanceLayer "Queues drug requests" "" "newRelationship"

        deploymentEnvironment "Production" {
            deploymentNode "Technical User's Workstation" "" "Microsoft Windows 10" {
                deploymentNode "Web Browser" "" "Chrome, Firefox, Safari, or Edge" {
                    devicesWebAppInstance = containerInstance devicesWebApp
                }
            }

            deploymentNode "Medical Staff's Workstation" "" "Microsoft Windows 10" {
                deploymentNode "Web Browser" "" "Chrome, Firefox, Safari, or Edge" {
                    pmcFrontendInstance = containerInstance pmcFrontend
                }
            }

            deploymentNode "On-premises Datacenter" {
                deploymentNode "k8-med-apps.[base-intranet-url]" "" "Ubuntu 18.04 LTS" {
                    deploymentNode "Container #1" "" "Docker" {
                        deploymentNode "app.pmc.[base-intranet-url]" "" "Apache Tomcat 8.x" {
                            pmcBackendInstance = containerInstance pmcBackend
                        }
                    }
                    deploymentNode "Container #2" "" "Docker" {
                        deploymentNode "devices.pmc.[base-intranet-url]" "" "Apache Tomcat 8.x" {
                            devicesWebAPIInstance = containerInstance devicesWebAPI
                        }     
                    }
                    deploymentNode "Container #4" "" "Docker" {
                        deploymentNode "devices-adapter.pmc.[base-intranet-url]" "" "Apache Tomcat 8.x" {
                            devicesAdapterInstance = containerInstance devicesAdapter
                        }     
                    }
                    deploymentNode "Container #3" "" "Docker" {
                        deploymentNode "drug-usage.pmc.[base-intranet-url]" "" "Apache Tomcat 8.x" {
                            drugsUsageWebAPIInstance = containerInstance drugsUsageWebAPI
                        }
                    }
                }

                deploymentNode "med-db01.[base-intranet-url]" "" "Ubuntu 18.04 LTS" {
                    primaryDatabaseServer = deploymentNode "Oracle - Primary" "" "Oracle 19c" {
                        primaryDevicesDBInstance = containerInstance devicesDB
                        primaryDrugsDBInstance = containerInstance drugsUsageDB
                        primaryPmcDBInstance = containerInstance pmcDB
                    }
                }

                deploymentNode "med-db03.[base-intranet-url]" "" "Ubuntu 18.04 LTS" "Failover" {
                    secondaryDatabaseServer = deploymentNode "Oracle - Secondary" "" "Oracle 19c" "Failover" {
                        secondaryDevicesDBInstance = containerInstance secondaryDevicesDB
                        secondaryDrugsDBInstance = containerInstance drugsUsageSecondaryDB
                        secondaryPmcDBInstance = containerInstance secondaryPmcDB
                    }
                }

                primaryDatabaseServer -> secondaryDatabaseServer "Replicates data to"
            }
        }
    }

    views {
        systemContext pmc "Level_1" {
            include *
        }

        container pmc "Level_2" {
            include *
            exclude secondaryDevicesDB
            exclude drugsUsageSecondaryDB
            exclude secondaryPmcDB
        }

        component pmcBackend "Level_3_central" {
            include *
            exclude devicesWebAPI -> oathUserAuthorization

        }
        
        component devicesWebAPI "Level_3_devices" {
            include *
        }

        component drugsUsageWebAPI "Level_3_drugs" {
            include *
        }


        dynamic pmc "SimplePatientDiscoveryWorkflow" "Summarises how new and unassigned patients are discovered." {
            medicalStaff -> pmcFrontend "Displays the unassigned-patient view / page"
            pmcFrontend -> pmcBackend "Requests incoming unassigned patient list"
            pmcBackend -> patientsRegistryAPI "Requests information to determine new patients"
            patientsRegistryAPI -> pmcBackend "Responds with the required information"
            pmcBackend -> pmcFrontend "Returns list of incoming unassigned patients"
            autolayout
        }

        dynamic pmcBackend "PatientDiscoveryWorkflow" "Summarises how new and unassigned patients are discovered." {
            medicalStaff -> pmcFrontend "Displays the unassigned-patient view / page"
            pmcFrontend -> locationCtrl "Requests incoming unassigned patient list"
            locationCtrl -> vec "Requests new-patient list"
            vec -> patientsRegistryAPI "Requests patient data to determine new patients"
            patientsRegistryAPI -> vec "Returns patient data"
            vec -> locationCtrl "Returns incoming patient list"
            locationCtrl -> persistanceLayer "Filter unassigned patients using"
            persistanceLayer -> locationCtrl "Returns list of filtered unassigned patients"
            locationCtrl -> pmcFrontend "Returns list of incoming unassigned patients"
            pmcFrontend -> medicalStaff "Displays unassigned patients"
        }

        dynamic pmc "SimpleAddPatientWorkflow" "Summarises how the assigning of patients works." {
            medicalStaff -> pmcFrontend "Assigns an unassigned patient to a bed"
            pmcFrontend -> pmcBackend "Requests the assignment of a patient to a bed"
            pmcBackend -> pmcFrontend "Signals success/failure"
            pmcFrontend -> medicalStaff "Signals success/failure"
        }

        dynamic pmcBackend "AddPatientWorkflow" "Summarises how the assigning of patients works." {
            medicalStaff -> pmcFrontend "Assigns an unassigned patient to a bed"
            pmcFrontend -> locationCtrl "Requests the assignment of a patient to a bed"
            locationCtrl -> persistanceLayer "Validates & writes data using"
            persistanceLayer -> locationCtrl "Signals success / failure"
            // alternativni navrh nasledujiciho 1 kroku:
            // historyCtrl ma pomoci persistance layer event listener na kazdem "luzku"
            //      callback: zmena pacienta na luzku 
            //                (puvodni_pacient, luzko) => vykonny kod historyCtrl
            // pri zmene luzka by se dalo napsat, ze historyctrl si vsimne zmeny a zareaguje
            locationCtrl -> historyCtrl "If an old patient was overwritten, trigger patient history persistance for overwritten patient"
            locationCtrl -> pmcFrontend "Signals success / failure"
        }

        dynamic pmc "SimplePatientConditionCheckWorkflow" "Summarises how the medical staff can access patient's current condition" {
            medicalStaff -> pmcFrontend "Displays patient's condition view / page"
            pmcFrontend -> pmcBackend "Requests patient's condition"
            pmcBackend -> devicesWebAPI "Requests sensor data related to patient's bed"
            devicesWebAPI -> medicalDevice "Requests device data"
            medicalDevice -> devicesWebAPI "Returns device data"
            devicesWebAPI -> pmcBackend "Returns device data"
            pmcBackend -> pmcFrontend "Returns patient's condition"
            pmcFrontend -> medicalStaff "Displays patietn's condition"
        }

        dynamic pmcBackend "PatientConditionCheckWorkflow" "Summarises how the medical staff can access patient's current condition" {
            medicalStaff -> pmcFrontend "Displays patient's condition view / page"
            pmcFrontend -> conditionCtrl "Requests patient's condition"
            conditionCtrl -> persistanceLayer "Requests patient's bed"
            persistanceLayer -> conditionCtrl "Returns patient's bed"
            conditionCtrl -> devicesDataController "Requests sensor data related to patient's bed"
            devicesDataController -> devicesManagement "Requests sensor data related to the bed"
            devicesManagement -> devicesAdapter "Request fresh device data using"
            devicesAdapter -> medicalDevice "Fetches device data"
            medicalDevice -> devicesAdapter "Returns device data"
            devicesAdapter -> devicesManagement "Sends back sensor data"
            devicesManagement -> devicesDataController "Returns device data"
            devicesDataController -> conditionCtrl "Sends device data in response"
            conditionCtrl -> pmcFrontend "Sends current patient condition data"
        }

        dynamic pmc "SimpleDrugsManagementWorkflow" "Summarises how medical staff allocates drugs to a patient." {
            medicalStaff -> pmcFrontend "Assigns a drug to a patient"
            pmcFrontend -> pmcBackend "Requests the assignment of the drug to the patient"
            pmcBackend -> drugsUsageWebAPI "Relays the request of the assignment of the drug to the patient"
            drugsUsageWebAPI -> dm "In case the drug is not available, requests delivery"
            autolayout
        }

        dynamic drugsUsageWebAPI "DrugsManagementWorkflow" "Summarises how medical staff allocates drugs to a patient." {
            medicalStaff -> pmcFrontend "Assigns a drug to a patient"
            pmcFrontend -> drugCtrl "Requests the assignment of the drug to the patient"
            drugCtrl -> drugUsageCtrl "Relays the request of the assignment of the drug to the patient"
            drugUsageCtrl -> drugManagement "Requests prescription of the drug to the patient"
            drugManagement -> drugPersistanceLayer "Writes information about the prescription of the drug to the patient"
            drugManagement -> drugPersistanceLayer "Checks the availability of the drug"
            drugManagement -> drugDeliveryMan "In case the drug is not available, requests delivery"
            drugDeliveryMan -> dm "Requests delivery of the drug"
        }

        dynamic devicesWebAPI "DeviceFailureWorkflow" "Summarises how technical staff is informed about device malfunction." {
            devicesManagement -> devicesAdapter "Requests data from a device"
            devicesAdapter -> devicesManagement "Signifies invalid data"
            devicesManagement -> devicesNotifications "Requests to notify users of the failure"
            devicesManagement -> devicesPersistence "Stores failure details"
            devicesNotifications -> technicalSupportStaff "Notifies of the failure"
            technicalSupportStaff -> devicesWebApp "Reviews failure details for diagnostics"
            autolayout
        }

        dynamic pmc "SimpleDeviceFailureWorkflow" "Summarises how technical staff is informed about device malfunction." {
            pmcBackend -> devicesWebAPI "Requests devices data for hospital bed"
            devicesWebAPI -> medicalDevice "Requests device data"
            medicalDevice -> devicesWebAPI "Malfunction in device"
            devicesWebAPI -> pmcBackend "Returns generic non-technical error message"
            devicesWebAPI -> technicalSupportStaff "Sends notification"
            technicalSupportStaff -> devicesWebApp "Can review malfunction details"
            autolayout
        }

        dynamic pmc "SimpleDeviceAssignmentWorkflow" "Summarises how devices app is utilized with pmc application." {
            technicalSupportStaff -> medicalDevice "Installs device to hospital bed"
            technicalSupportStaff -> devicesWebApp "Makes request to register device for hospital bed"
            devicesWebApp -> devicesWebAPI "Registers device for hospital bed"
            medicalStaff -> pmcFrontend "Wants to see medical data for patient"
            pmcFrontend -> pmcBackend "Requests data for patient"
            pmcBackend -> devicesWebAPI "Requests devices data for bed where patient is allocated"
            devicesWebAPI -> medicalDevice "Requests device data for each device on bed"
            medicalDevice -> devicesWebAPI "Returns device data"
            devicesWebAPI -> pmcBackend "Returns device data"
            pmcBackend -> pmcFrontend "Returns device data"
            pmcFrontend -> medicalStaff "User can see medical data"
        }

        deployment pmc "Production" "Prod" {
            include *
        }

        theme default
        
        styles {
            element "webApp" {
                    shape "WebBrowser" 
                }

            element "mobileApp" {
                shape "MobileDevicePortrait" 
            }
            element "Failover" {
                opacity 25
            }
            element "devicesAdapter" {
                background #FF0000
            }
            relationship "newRelationship" {
                color #FF0000
                thickness 3
            }
        }
    }

    
}
