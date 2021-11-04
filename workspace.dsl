workspace {

    model {
        supplier = softwareSystem "Supplier" "External system used for ordering drugs" "Existing System"

        storekeeper = person "Storekeeper" "Makes sure the warehouse has drugs on stock"
        warehouseWorker = person "Warehouse Worker" "Stocks and unstocks packgages"
        wardWorker = person "Ward Worker" "Requests drugs, records their arrival and depletion"
        employee = person "Hospital Employee" "Any employee, can view package lifecycle"
        headNurse = person "Head Nurse" "Head nurse makes drug requests to the warehouse"
        
        drugMonitoring = softwareSystem "Drug Monitoring" "" "" {

            warehouseManagementApp = container "Warehouse Management App" "Provides warehouse overview and allows drug ordering" "Web application" "Website"

            stockingCounter = container "Stocking Counter" "Records new packages as being stocked" "Native application" ""
            unstockingCounter = container "Unstocking Counter" "Records packages as leaving the warehouse" "Native application" ""

            wardAccess = container "Ward Access" "Allows drug requests and arrival and depletion recording" "Mobile application" ""

            lifecycleMonitoringApp = container "Lifecycle Monitoring App" "Displays package lifecycle" "Mobile application" "Mobile"
            
            database = container "Database" "Stores state for the entire system" "Relational databse" "Database"

            backendServer = container "Backend Server" "Handles business logic" "PHP" ""

            requestManagementApp = container "Request Management App" "Allows drug requests" "Web application" "Website"


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
        wardWorker -> wardAccess "Requests packages, records their arrival and depletion"
        employee -> lifecycleMonitoringApp "Views lifetime of a package"
        headNurse -> requestManagementApp "Requests drug packages"
        backendServer -> supplier "Makes drug orders"


        // container to container relationship
        backendServer -> warehouseManagementApp "Serves"
        backendServer -> database "Uses"
        stockingCounter -> backendServer "Sends stocking request"
        unstockingCounter -> backendServer "Sends unstocking request"
        lifecycleMonitoringApp -> backendServer "Requests package lifecycle"
        wardAccess -> backendServer "Records drug arrival and depletion"
        requestManagementApp -> backendServer "Records drug requests"


    }

    views {
        systemContext drugMonitoring "drugMonitoringContextDiagram" {
            include *
        }

        container drugMonitoring "drugMonitoringContainerDiagram" {
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
        }
    }

}
