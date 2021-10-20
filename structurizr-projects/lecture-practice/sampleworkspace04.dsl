workspace "Czech National Open Data Catalog (NODC) workspace" "This workspace documents the architecture of the National Open Data Catalog (NODC) which serves as a catalog of all open data sets published by public institutions in Czechia." {

    model {
        nodc = softwareSystem "Czech National Open Data Catalog (NODC)" "Stores and presents metadata records about data sets and harvests meta data from local open data catalogs."    {
            webFrontend = container "NODC Web Front-end" "Provides all functionality for browsing and viewing metadata records to open data consumers." "TypeScript" "Web Front-End"

            server = container "NODC Server" "Implements all business functionality for browsing and viewing metadata records and provides it via API." "Node.js"   {
                listAPI = component "Record List API" "Provides API for getting a list of metadata records according to specified search parameters via API." "" "Infrastructure"
                searchController = component "Records Search Controller" "Implements and provides business functionality related to searching for metadata records" "" "Logic"
                datasetModel = component "Dataset" "Internal model of dataset metadata" "" "Model"
                recordIndexGateway = component "Metadata Index Gateway" "Provides access to a metadata records index" "" "Infrastructure"
            }
        }

        lodc = softwareSystem "Local Open Data Catalog" "Stores and presents metadata records about data sets and harvests meta data from local open data catalogs." "Existing System"

        consumer = person "Consumer" "A person from the public who searches for data sets and accesses them for various purposes." "Public"
        gov = person "Government" "A person from a government institution who searches for data sets and accesses them for various purposes." "Gov"

        // relationships between persons and systems
        consumer -> nodc "Searchers for metadata records in"
        gov -> nodc "Searchers for metadata records in"

        // relationships between systems
        nodc -> lodc "Harvests metada records from"

        // relationships between persons and containers
        consumer -> webFrontend "Searches for metadata records and views their details with"
        gov -> webFrontend "Searches for metadata records and views their details with"

        // relationships between containers
        webFrontend -> server "Uses to deliver functionality"
        webFrontend -> listAPI "Makes API calls to" "JSON/HTTPS"
        listAPI -> searchController "Uses to access search business functionality"
        searchController -> datasetModel "Uses to access metadata about datasets"
        searchController -> recordIndexGateway "Uses to retrieve list of metadata records with given values of selected properties"
    }

    views   {
        systemContext nodc "NODC_SystemContext_View" {
            include *
        }

        container nodc "NODC_Container_View" {
            include *
        }

        component server "Server_Component_View" {
            include *
        }

        styles {
            element "Software System" {
                background #32cd32
                color #ffffff
            }
            
            element "Container" {
                background #63cd32
                color #ffffff
            }

            element "Component" {
                background #92cd32
                color #ffffff
            }
            
            element "Existing System" {
                background #999999
                color #ffffff
            }

            element "Web Front-End"  {
                shape WebBrowser
            }

            element "Infrastructure"  {
                shape Pipe
            }

            element "Logic"  {
                shape Component
            }

            element "Model"  {
                shape RoundedBox
            }

            element "Person" {
                shape Person
            }

            element "Public" {
                background #999999
                color #ffffff
            }

            element "Gov" {
                background #006400
                color #ffffff
            }
        }

    }

}