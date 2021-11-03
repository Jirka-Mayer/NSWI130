workspace {

    model {
        supplier = softwareSystem "Supplier" "External system used for ordering drugs" "Existing System"

        storekeeper = person "Storekeeper" "Makes sure the warehouse has drugs on stock"
        warehouseWorker = person "Warehouse Worker" "Stocks and unstocks packgages"
        wardWorker = person "Ward Worker" "Requests drugs, records their arrival and depletion"
        employee = person "Hospital Employee" "Any employee, can view package lifecycle"
        
        drugMonitoring = softwareSystem "Drug Monitoring" "" "" {

            warehouseManagement = container "Warehouse Management" "Provides warehouse overview and allows drug ordering" "Web application" "Website"

            stockingCounter = container "Stocking Counter" "Records new packages as being stocked" "Native application" ""
            unstockingCounter = container "Unstocking Counter" "Records packages as leaving the warehouse" "Native application" ""

            wardAccess = container "Ward Access" "Allows drug requests and arrival and depletion recording" "Mobile application" "Mobile"

            somethingSomething = container "Lifetime Monitoring App" "Displays package lifecycle" "Mobile application" "Mobile"
            
            database = container "Database" "Stores state for the entire system" "Relational databse" "Database"

        }

        // software system relationships
        drugMonitoring -> supplier "Orders drugs"
        storekeeper -> drugMonitoring "Orders drugs"
        warehouseWorker -> drugMonitoring "Stocks and unstocks packages"
        wardWorker -> drugMonitoring "Requests drugs, records arrival and depletion"
        employee -> drugMonitoring "Views drug package lifecycle"

        // external to container relationships
        storekeeper -> warehouseManagement "Oversees warehouse and orders drugs"
        warehouseWorker -> stockingCounter "Stocks new packages"
        warehouseWorker -> unstockingCounter "Unstocks packages to be sent to wards"
        wardWorker -> wardAccess "Requests packages, records their arrival and depletion"
        employee -> somethingSomething "Views lifetime of a package"
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
