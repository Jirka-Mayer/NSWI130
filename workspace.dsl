workspace {

    model {
        supplier = softwareSystem "Supplier" "External system used for ordering drugs" "Existing System"

        storekeeper = person "Storekeeper" "Makes sure the warehouse has drugs on stock"
        warehouseWorker = person "Warehouse Worker" "Stocks and unstocks packgages"
        wardWorker = person "Ward Worker" "Records drug arrival and depletion"
        employee = person "Hospital Employee" "Any employee, can view package lifecycle"
        headNurse = person "Head Nurse" "Head nurse makes drug requests to the warehouse"
        
        drugMonitoring = softwareSystem "Drug Monitoring" "" "" {

            group "Warehouse" {
                warehouseManagementApp = container "Warehouse Management App" "Provides warehouse overview and allows drug ordering" "Web application" "Website"

                stockingCounter = container "Stocking Counter" "Records new packages as being stocked" "Native application" ""
                unstockingCounter = container "Unstocking Counter" "Records packages as leaving the warehouse" "Native application" ""
            }

            lifecycleMonitoringApp = container "Lifecycle Monitoring App" "Displays package lifecycle" "Mobile application" "Mobile"

            group "Hospital Ward" {
                wardCounter = container "Ward Counter" "Allows drug requests and arrival and depletion recording" "Native application" ""
                requestManagementApp = container "Request Management App" "Allows drug requests" "Web application" "Website"
            }

            database = container "Database" "Stores state for the entire system" "Relational databse" "Database"

            backendServer = container "Backend Server" "Handles business logic" "PHP" "" {
                orderingController = component "Ordering Controller" "Allows users to place drug orders" "Laravel REST Controller" "Controller"
                orderingComponent = component "Ordering Component" "Handles drug orders" "Laravel REST Controller" 
                stockingController = component "Stocking Controller" "Handles stocking/unstocking requests" "Laravel REST Controller" "Controller"
                stockingComponent = component "Stocking Component" "Modifies stocking status"
                lifecycleController = component "Lifecycle Controller" "Provides information about package lifecycle" "Laravel REST Controller" "Controller"
                drugRequestController = component "Drug Request Controller" "Handles drug requests" "Laravel REST Controller" "Controller"
                drugRequestComponent = component "Drug Request Component" "Inserts request" 
                arrivalController = component "Arrival Controller" "Records package arrivals" "Laravel REST Controller" "Controller"
                arrivalComponent = component "Arrival Component" "Handles arrival events"
                depletionController = component "Depletion Controller" "Records package depletion" "Laravel REST Controller" "Controller"
                packageLifecycleComponent = component "Package Lifecycle Component" "Updates package lifecycle status" 
                warehouseManagementController = component "Warehouse Management Controller" "Returns warehouse state and drug requests" "Laravel REST Controller" "Controller"
                warehouseManagementComponent = component "Warehouse Management Component" "Summarizes warehouse state and lists drug requests"
            }
        }

        // software system relationships
        drugMonitoring -> supplier "Orders drugs"
        storekeeper -> drugMonitoring "Orders drugs"
        warehouseWorker -> drugMonitoring "Stocks and unstocks packages"
        wardWorker -> drugMonitoring "Records arrival and depletion of packages"
        headNurse -> drugMonitoring "Requests drug packages"
        employee -> drugMonitoring "Views drug package lifecycle"

        // external to container relationships
        storekeeper -> warehouseManagementApp "Oversees warehouse and orders drugs"
        warehouseWorker -> stockingCounter "Stocks new packages"
        warehouseWorker -> unstockingCounter "Unstocks packages to be sent to wards"
        wardWorker -> wardCounter "Requests packages, records their arrival and depletion"
        employee -> lifecycleMonitoringApp "Views lifetime of a package"
        headNurse -> requestManagementApp "Requests drug packages"
        backendServer -> supplier "Makes drug orders"

        // container to container relationships
        warehouseManagementApp -> backendServer "Sends ordering requests"
        backendServer -> database "Uses"
        stockingCounter -> backendServer "Sends stocking request"
        unstockingCounter -> backendServer "Sends unstocking request"
        lifecycleMonitoringApp -> backendServer "Requests package lifecycle"
        wardCounter -> backendServer "Records drug arrival and depletion"
        requestManagementApp -> backendServer "Records drug requests"

        // backend Component relationships
        warehouseManagementApp -> orderingController "Makes API calls to" "JSON/HTTPS"
        orderingController -> orderingComponent "Uses" 
        orderingComponent -> supplier "Sends orders" "SOAP"
        orderingComponent -> database "Records orders"
        warehouseManagementApp -> warehouseManagementController "Makes API calls to" "JSON/HTTPS"
        warehouseManagementController -> warehouseManagementComponent "Uses"
        warehouseManagementComponent -> database "Reads warehouse state and drug requests" "SQL"
        stockingCounter -> stockingController "Makes API calls to" "JSON/HTTPS"
        stockingController -> stockingComponent "Uses"
        stockingComponent -> packageLifecycleComponent "Reports changes to"
        stockingComponent -> database "Modifies warehouse state" "SQL"
        unstockingCounter -> stockingController "Makes API calls to" "JSON/HTTPS"
        lifecycleMonitoringApp -> lifecycleController "Makes API calls to" "JSON/HTTPS"
        lifecycleController -> packageLifecycleComponent "Reads from"
        requestManagementApp -> drugRequestController "Makes API calls to" "JSON/HTTPS"
        drugRequestController -> drugRequestComponent "Uses"
        drugRequestComponent -> database "Writes" "SQL"
        packageLifecycleComponent -> database "Reads/modifies package lifecycle state" "SQL"
        wardCounter -> arrivalController "Makes API calls to" "JSON/HTTPS"
        wardCounter -> depletionController "Makes API calls to" "JSON/HTTPS"
        depletionController -> packageLifecycleComponent "Reports depletions to"
        arrivalController -> arrivalComponent "Uses"
        arrivalComponent -> packageLifecycleComponent "Reports arrivals to"
        arrivalComponent -> database "Acknowledges package arrivals" "SQL"

        deploymentEnvironment "Production" {
            deploymentNode "Hospital server" "" "" {

                deploymentNode "Nginx" "Nginx 1.18.*" "" {
                    deploymentNode "PHP" "PHP FPM 7.4.*" "" {
                        containerInstance backendServer
                    }
                }

                deploymentNode "MySQL" "MySQL Community Server 8.0.*" "" {
                    containerInstance database
                }
            }

            deploymentNode "Storekeeper's computer" "" "" {
                deploymentNode "Web browser" "" "" {
                    containerInstance warehouseManagementApp
                }
            }

            deploymentNode "Stocking counter machine" "" "" {
                deploymentNode ".NET" ".NET Core 5.0.*" "" {
                    containerInstance stockingCounter
                }
            }

            deploymentNode "Unstocking counter machine" "" "" {
                deploymentNode ".NET" ".NET Core 5.0.*" "" {
                    containerInstance unstockingCounter
                }
            }

            deploymentNode "Hospital employee's work phone" "" "" "" 250 {
                deploymentNode "Android/iOS" "Android >=7.* / iOS >=12.*" "" {
                    containerInstance lifecycleMonitoringApp
                }
            }

            deploymentNode "Head nurse's computer" "" "" "" 20 {
                deploymentNode "Web browser" "" "" {
                    containerInstance requestManagementApp
                }
            }

            deploymentNode "Ward counter machine" "" "" "" 20 {
                deploymentNode ".NET" ".NET Core 5.0.*" "" {
                    containerInstance wardCounter
                }
            }
        }
    }

    views {
        systemContext drugMonitoring "drugMonitoringContextDiagram" {
            include *
        }

        container drugMonitoring "drugMonitoringContainerDiagram" {
            include *
        }

        component backendServer "backendServerComponentDiagram" {
            include *
        }

        component backendServer "WarehouseOrderingComponentDiagram" {
            title "Warehouse Ordering/Management Component Diagram"

            include warehouseManagementApp
            include orderingController
            include orderingComponent
            include warehouseManagementController
            include warehouseManagementComponent
            include database
            include supplier
        }

        component backendServer "WarehouseStockingComponentDiagram" {
            title "Warehouse Stocking Component Diagram"

            include stockingCounter
            include unstockingCounter
            include stockingController
            include stockingComponent
            include packageLifecycleComponent
            include database
        }

        component backendServer "PackageLifecycleComponentDiagram" {
            title "Package Lifecycle Component Diagram"

            include stockingCounter
            include unstockingCounter
            include stockingController
            include stockingComponent

            include lifecycleMonitoringApp
            include lifecycleController

            include wardCounter
            include arrivalController
            include arrivalComponent
            include depletionController

            include packageLifecycleComponent
            include database
        }

        component backendServer "WardComponentDiagram" {
            title "Ward Component Diagram"

            include requestManagementApp
            include drugRequestController
            include drugRequestComponent

            include wardCounter
            include arrivalController
            include arrivalComponent
            include depletionController

            include packageLifecycleComponent
            include database

        }
        
        deployment drugMonitoring "Production" "productionDeploymentDiagram" {
            include *
        }

        theme default

        styles {
            element "Existing System" {
                background #999999
                color #ffffff
            }

            element "Gateway" {
                shape Pipe
            }

            element "Database" {
                shape Cylinder
            }

            element "Website" {
                shape WebBrowser
            }

            element "Mobile" {
                shape MobileDevicePortrait
            }

            element "Controller" {
                shape Pipe
            }
        }
    }

}
