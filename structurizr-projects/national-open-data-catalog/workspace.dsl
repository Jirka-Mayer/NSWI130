workspace "Public Data Space" "This workspace documents the architecture of the Public Data Space which enables public institutions in Czechia to share public data among each other in a guaranteed way." {

    model {
        nationalCatalog = softwareSystem "Czech National Open Data Catalog (NODC)" "Stores and presents metadata records about data sets and harvests meta data from local open data catalogs."  {
            webFrontend = container "NODC Web Front-end" "Provides all functionality for browsing and viewing metadata records to open data consumers via their web browser"  {

            }
            server = container "NODC Server" "Implements all business functionality for browsing and viewing metadata records and provides it via a JSON/HTTPS API."    {
                listAPI = component "Record List API" "Provides API for getting a list of metadata records according to specified search parameters via a JSON/HTTPS API."
                detailAPI = component "Record Detail API" "Provides API for getting a detail of a given metadata record via a JSON/HTTPS API."
                searchController = component "Records Search Controller" "Implements and provides business functionality related to searching for metadata records"
                detailController = component "Record Detail Controller" "Implements and provides business functionality related to viewing details of metadata records"
                distributionModel = component "Distribution Model" "Internal model of distribution metadata"
                datasetModel = component "Dataset Model" "Internal model of dataset metadata"
                recordIndexGateway = component "Metadata Index Gateway" "Provides access to a metadata records index"
                recordDetailGateway = component "Metadata Detail Gateway" "Provides access to a metadata records store"
                codeListAccess = component "Code List Gateway" "Provides access to code lists and their items via HTTPS dereferencing Web IRIs."
            }
            
            recordIndex = container "Metadata Index" "Index for fast searching in metadata records" "Apache SOLR via JSON/HTTPS"
            recordStorage = container "Metadata Storage" "Storage of metadata records" "CouchDB via JSON/HTTPS"

            harvestor = container "Metadata Harvestor" "Harvests metadata records from local open data catalogs" "LinkedPipes ETL"

            !docs docs

        }

        localCatalog = softwareSystem "Local Open Data Catalog" "Stores metadata records about data sets of a given provider and provides API for national open data catalog." "Existing System"

        euCatalog = softwareSystem "European Open Data Catalog" "Stores and presents metadata records about data sets from different EU countires and harvests meta data from national open data catalogs." "Existing System"

        localCatalogRegistry = softwareSystem "Registry of local open data catalogs" "SPARQL endpoint for reading locations of registered local open data catalogs which need to be harvested." "Existing System"
        
        consumer = person "Consumer" "An actor who searches for data sets and accesses them for various purposes." "Consumer"
        

        # relationships to/from software systems
        consumer -> nationalCatalog "Searchers for metadata records in"
        consumer -> euCatalog "Searchers for metadata records in"

        nationalCatalog -> localCatalog "Harvests metada records from"
        euCatalog -> nationalCatalog "Harvests metadata records from"

        nationalCatalog -> localCatalogRegistry "Reads registered local open data catalogs from"

        localCatalog -> localCatalogRegistry "Is registered in"

        # relationships to/from containers
        consumer -> webFrontend "Searches for metadata records and views their details with"
        webFrontend -> server "Uses to deliver functionality"
        server -> recordIndex "Uses for fast retrieval of metadata records lists"
        server -> recordStorage "Uses for fast retrieval of metadata records details"
        harvestor -> localCatalog "Harvests metadata records from"
        harvestor -> recordIndex "Uses to reset metadata records index. The whole index is always replaced"
        harvestor -> recordStorage "Uses to persists harvested metadata records. All records are always replaced"
        harvestor -> localCatalogRegistry "Uses to read locations of registered local open data catalogs"

        # relationships to/from components
        webFrontend -> listAPI "Makes API calls to" "JSON/HTTPS"
        webFrontend -> detailAPI "Makes API calls to" "JSON/HTTPS"

        listAPI -> searchController "Uses to access search business functionality"
        detailAPI -> detailController "Uses to access detail business functionality"

        searchController -> datasetModel "Uses to access metadata about datasets"
        detailController -> datasetModel "Uses to access metadata about datasets"
        detailController -> distributionModel "Uses to access metadata about distributions"

        datasetModel -> recordIndexGateway "Uses to retrieve list of metadata records with given values of selected properties"
        datasetModel -> recordDetailGateway "Uses to retrieve detailed metadata"
        distributionModel -> recordDetailGateway "Uses to retrieve detailed metadata"
        datasetModel -> codeListAccess "Uses to retrieve code list items labels and descriptions"
        distributionModel -> codeListAccess "Uses to retrieve code list items labels and descriptions"

        recordIndexGateway -> recordIndex "Provides access to"
        recordDetailGateway -> recordStorage "Provides access to"
    }
    
    views {
        
        systemContext nationalCatalog "nationalCatalogSystemContextDiagram" {
            include *
        }

        container nationalCatalog "nationalCatalogContainerDiagram" {
            include *
        }

        component server "serverComponentDiagram" {
            include *
        }

        theme default

        styles {
            element "Existing System" {
                background #999999
                color #ffffff
            }

            element "Consumer" {
                background #999999
                color #ffffff
            }
        }

}