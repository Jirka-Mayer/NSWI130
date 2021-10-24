workspace "Czech National Open Data Catalog (NODC) workspace" "This workspace documents the architecture of the National Open Data Catalog (NODC) which serves as a catalog of all open data sets published by public institutions in Czechia." {

    model {
        nodc = softwareSystem "Czech National Open Data Catalog (NODC)" "Stores and presents metadata records about data sets and harvests meta data from local open data catalogs."    {
            webFrontend = container "NODC Web Front-end" "Provides all functionality for browsing and viewing metadata records to open data consumers." "TypeScript" "Web Front-End"

            server = container "NODC Server" "Implements all business functionality for browsing and viewing metadata records and provides it via API." "Node.js"   {
                group "Infrastructure"  {
                    listAPI = component "Record List API" "Provides API for getting a list of metadata records according to specified search parameters via API." "" "Infrastructure"
                    detailAPI = component "Record Detail API" "Provides API for getting a detail of a given metadata record via API." "" "Infrastructure"
                    recordIndexGateway = component "Metadata Index Gateway" "Provides access to a metadata records index." "" "Infrastructure"
                    recordDetailGateway = component "Metadata Detail Gateway" "Provides access to a metadata records store." "" "Infrastructure"
                    codeListAccess = component "Code List Gateway" "Provides access to code lists and their items via HTTPS dereferencing Web IRIs." "" "Infrastructure"
                }
                group "Business Logic"  {
                    searchController = component "Records Search Controller" "Implements and provides business functionality related to searching for metadata records." "" "Logic"
                    detailController = component "Record Detail Controller" "Implements and provides business functionality related to viewing details of metadata records." "" "Logic"
                }
                group "Domain Model"    {
                    datasetModel = component "Dataset" "Internal domain model of dataset metadata." "" "Model"
                    distributionModel = component "Distribution Model" "Internal domain model of distribution metadata." "" "Model"
                }

            }

            recordIndex = container "Metadata Index" "Index for fast searching in metadata records." "Apache SOLR configuration and schema"
            recordStorage = container "Metadata Storage" "Storage of metadata records." "Apache CouchDB database"
            harvestor = container "Metadata Harvestor" "Harvests metadata records from local open data catalogs." "LinkedPipes ETL pipeline"

            !docs docs
        }

        lodc = softwareSystem "Local Open Data Catalog" "Stores and presents metadata records about data sets and harvests meta data from local open data catalogs." "Existing System"
        lodcRegistry = softwareSystem "Registry of local open data catalogs" "SPARQL endpoint for reading locations of registered local open data catalogs which need to be harvested." "Existing System"

        consumer = person "Consumer" "A person from the public who searches for data sets and accesses them for various purposes." "Public"
        gov = person "Government" "A person from a government institution who searches for data sets and accesses them for various purposes." "Gov"

        consumer -> nodc "Searchers for metadata records in" "HTTPS"
        gov -> nodc "Searchers for metadata records in" "HTTPS"

        nodc -> lodc "Harvests metada records from" "HTTPS"

        consumer -> webFrontend "Searches for metadata records and views their details with" "HTTPS"
        gov -> webFrontend "Searches for metadata records and views their details with" "HTTPS"
        deliveryToFrontend = webFrontend -> server "Uses to deliver functionality" "HTTPS"
        server -> recordIndex "Uses for fast retrieval of metadata records lists" "HTTPS"
        server -> recordStorage "Uses for fast retrieval of metadata records details" "HTTPS"
        harvestor -> lodc "Harvests metadata records from" "HTTPS"
        harvestor -> recordIndex "Uses to reset metadata records index. The whole index is always replaced" "HTTPS"
        harvestor -> recordStorage "Uses to persists harvested metadata records. All records are always replaced" "HTTPS"
        harvestor -> lodcRegistry "Uses to read locations of registered local open data catalogs" "HTTPS"


        webFrontend -> listAPI "Makes API calls to" "JSON/HTTPS"
        webFrontend -> detailAPI "Makes API calls to" "JSON/HTTPS"

        listAPI -> searchController "Uses to access search business functionality"
        detailAPI -> detailController "Uses to access detail business functionality"

        searchController -> datasetModel "Uses to access metadata about datasets"
        detailController -> datasetModel "Uses to access metadata about datasets"
        detailController -> distributionModel "Uses to access metadata about distributions"

        searchController -> recordIndexGateway "Uses to retrieve list of metadata records with given values of selected properties"
        detailController -> recordDetailGateway "Uses to retrieve detailed metadata"
        detailController -> codeListAccess "Uses to retrieve code list items labels and descriptions"

        deploymentEnvironment "Server Development"   {
            deploymentNode "Developer Laptop" "" "Microsoft Windows 11"  {
                deploymentNode "Web Browser" "" "Chrome, Firefox or Edge"   {
                    containerInstance webFrontend
                }
                deploymentNode "Node.js" "" "Node.js 14.*"  {
                    containerInstance server
                }
            }
            deploymentNode "NODC develop" "" "NODC development infrastructure"  {
                deploymentNode "NODC-dev-data" "" "Ubuntu 18.04 LTS"  {
                    deploymentNode "Apache Solr" "" "Apache Solr 8.*"   {
                        containerInstance recordIndex
                    }
                    deploymentNode "Apache CouchDB" "" "Apache CouchDB 3.*"   {
                        containerInstance recordStorage
                    }
                }
                // harvestor instance is not present in the server development deployment
            }
        }

        deploymentEnvironment "Live"   {
            deploymentNode "Gov User's device" "" "Microsoft Windows or Android"  {
                deploymentNode "Web Browser" "" "Chrome, Firefox or Edge"   {
                    govClientInstance = containerInstance webFrontend
                }
            }
            deploymentNode "Public User's device" "" "Microsoft Windows or Android"  {
                deploymentNode "Web Browser" "" "Chrome, Firefox or Edge"   {
                    pubClientInstance = containerInstance webFrontend
                }
            }
            deploymentNode "NODC UPAAS" "" "NODC eGov unified runtime environment (UPAAS)"  {
                deploymentNode "NODC-upaas-balancer" "" "Ubuntu 18.04 LTS" {
                    balancer = infrastructureNode "Load balancer" "" "NGINX" "Infrastructure"
                }
                deploymentNode "NODC-upaas-app-gov" "" "Ubuntu 18.04 LTS" "" 3 {
                    deploymentNode "Node.js" "" "Node.js 14.*" {
                        govServerInstance = containerInstance server
                    }
                }
                deploymentNode "NODC-upaas-app-public" "" "Ubuntu 18.04 LTS" "" 1 {
                    deploymentNode "Node.js" "" "Node.js 14.*" {
                        pubServerInstance = containerInstance server
                    }
                }
                deploymentNode "NODC-upaas-index" "" "Ubuntu 18.04 LTS"  {
                    deploymentNode "Apache Solr" "" "Apache Solr 8.*"   {
                        containerInstance recordIndex
                    }
                }
                deploymentNode "NODC-upaas-storage" "" "Ubuntu 18.04 LTS"  {
                    deploymentNode "Apache CouchDB" "" "Apache CouchDB 3.*"   {
                        containerInstance recordStorage
                    }
                }
                deploymentNode "LODC-upaas-etl" "" "Ubuntu 18.04 LTS" "" 4 {
                    deploymentNode "LinkedPipes ETL"   {
                        containerInstance harvestor
                    }
                }
                deploymentNode "LODC-registry" {
                    softwareSystemInstance lodcRegistry
                }
            }
            deploymentNode "External open data provider"    {
                softwareSystemInstance lodc
            }
            balancer -> govServerInstance "Forwards requests to" "HTTPS"
            govClientInstance -> balancer "Requests NODC functionality from" "HTTPS"
            //pubClientInstance -> pubServerInstance "Requests NODC functionality from" "HTTPS"
        }

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

        deployment nodc "Server Development" "Server_Development_Deployment" {
            include *
        }

        deployment nodc "Live" "Live_Deployment" {
            include *
            //exclude deliveryToFrontend
            exclude govClientInstance -> pubServerInstance
            exclude govClientInstance -> govServerInstance
            exclude pubClientInstance -> govServerInstance
        }

        dynamic * "Harvesting_System_Dynamic_View" "Local Open Data Catalog Harvesting Scenario - Software System Dynamics"  {
            nodc -> lodcRegistry
            nodc -> lodc
        }

        dynamic nodc "Harvesting_Container_Dynamic_View" "Local Open Data Catalog Harvesting Scenario - Container Dynamics"  {
            harvestor -> recordIndex "Clears index"
            harvestor -> recordStorage "Clears storage"
            harvestor -> lodcRegistry
            harvestor -> lodc
            harvestor -> recordStorage "Stores metadata records from LODC"
            harvestor -> recordIndex "Indexes metadata records from LODC"
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