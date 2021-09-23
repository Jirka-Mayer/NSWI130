workspace "Public Data Space" "This workspace documents the architecture of the Public Data Space which enables public institutions in Czechia to share public data among each other in a guaranteed way." {

    model {
        enterprise "Public Data Space" {
            storage = softwaresystem "Content Storage" "Stores content of data sets of one or more data providers and enables data consumers to access the content (download or query)."    {
                fileStorage = container "File Storage" "Stores the content of data sets as individual data files in different formats defined by Formal Open Specifications." "Unix file system" "Storage"  {
                    
                }
                rdfDatabase = container "Database" "Stores the content of data sets represented as RDF triples and provides a SPARQL endpoint for querying the data sets." "RDF triple store" "Storage" {
                    
                }
                queryEditor = container "Query Editor" "Provides a user interface for writing and executing SPARQL queries on the SPARQL endpoint and for viewing the query results." "Yasgui SPARQL editor" "Web Browser"  {
                    
                }
                transformator = container "Content Transformator" "Transforms the content of data sets sent by data publishing systems to data formats defined by Formal Open Specifications." "LinkedPipes ETL" "ETL" {
                    
                }
                contentManagementApp = container "Content Management Application" "Provides all the Data set storage functionality to data publishing and consumption systems."  {
                    contentUploadController = component "Content Upload Controller" "Allows data publishing systems to upload and store content of new data sets or update the existing ones."
                    contentRemovalController = component "Content Removal Controller" "Allows data publishing systems to remove stored content."
                    
                    contentValidationComponent = component "Content Validation Component" "Performs validation of supplied content of data sets in supported data formats"
                    validator = component "Content Validator" "Validates the content of data sets sent by data publishing systems."
                    xmlValidator = component "XML Content Validator" "Validates XML content."
                    jsonValidator = component "JSON Content Validator" "Validates JSON content."
                    csvValidator = component "CSV Content Validator" "Validates CSV content."
                    
                    fosModel = component "Formal Open Specifications Model" "Enables other components to access to formal open specifications."
                    
                    tempFileStorage = component "Temporary File Storage" "Stores received content of data sets in temporary files before they are validated and transformed." "UNIX file system"
                    
                    fileStorageAPI = component "File Storage API" "Enables to save/replace/remove files in the file storage."
                    databaseAPI = component "Database API" "Enables to load/remove RDF triples in the database."
                    
                    contentUploadController -> fosModel "Uses to check existence of Formal Open Specifications"
                    contentUploadController -> tempFileStorage "Uses to store received content"
                    contentUploadController -> contentValidationComponent "Uses to validate content of data sets"
                    contentUploadController -> fileStorageAPI "Uses to save/replace files in the file storage"
                    contentUploadController -> databaseAPI "Uses to load RDF triples in the database"
                    
                    contentRemovalController -> fileStorageAPI "Uses to remove files from the file storage"
                    contentRemovalController -> databaseAPI "Uses to remove RDF triples from the database"
                    
                    contentValidationComponent -> validator "Uses to validate XML, JSON or CSV content"
                    validator -> xmlValidator "Generalizes"
                    validator -> jsonValidator "Generalizes"
                    validator -> csvValidator "Generalizes"
                    validator -> tempFileStorage "Uses to read file for validation"
                    validator -> fosModel "Uses to read data schema from"
                    
                    contentUploadController -> transformator "Uses to transform content to output formats"
                    
                    fileStorageAPI -> fileStorage "Uses to store content of data sets as files" "SCP"
                    databaseAPI -> rdfDatabase "Uses to store content of data sets as RDF triples to" "SPARQL Graph Store HTTPS"
                }
                
                
                queryEditor -> rdfdatabase "Uses to execute queries"
                
                
            }
            catalog = softwaresystem "National Open Data Catalog" "Stores and presents metadata records about data sets and harvests meta data from local open data catalogs."  {
                
            }
            registry = softwaresystem "Registry of Rights and Obligations" "Manages entity types and their properties registered in governmental information systems and their public availability in data sets."   {
                
            }
            fosRepository = softwaresystem "Formal Open Specifications Repository" "Stores and provides access to Formal Open Specifications (metadata, data schemas, transformation and mapping definitions)."    {
                
            }
            consumerCatalog = softwaresystem "Data Consumer Catalog" "Stores and presents registrations of government organizations to data set consumption."   {
                
            }
            routingService = softwaresystem "Routing Service" "Redirects requests on global IRIs to local IRIs."    {
                
            }
            notificationHub = softwaresystem "Notification Hub" "Enables to register changes in data sets and registers data set consumers about changes"   {
                
            }
            
            registry -> catalog "Uses to read data set metadata"

            catalog -> storage "Uses to check existence and availability of data set distributions"

            transformator -> fosRepository "Uses to read data transformations and mapping definitions"
            
            fosModel ->  fosRepository "Uses to read Formal Open Specifications (metadata, schemas, transformations and mappings)"

        }
        
        consumer = person "Consumer" "An actor who searches for data sets and accesses them for various purposes." "Consumer"
        publisher = person "Publisher" "An actor who is responsible for a data publishing system and for the content of published data sets." "Publisher"
        
        publishingSystem = softwaresystem "Data publishing system" "Information system for the management of the source data which is published to the Public Data Space." "Existing System"
        consumptionSystem = softwaresystem "Data consumption system" "System which consumes data from the Public Data Space." "Existing System"
    
        publisher -> catalog "Registers a data publishing system in"
        publisher -> publishingSystem "Is responsible for"
        publisher -> registry "Registers data sets to data properties"
        
        publishingSystem -> contentUploadController "Uses to upload stored content of data sets" "JSON/HTTPS"
        publishingSystem -> contentRemovalController "Uses to remove stored content of data sets" "JSON/HTTPS"
        publishingSystem -> fosRepository "Uses to read data schemas"
        publishingSystem -> notificationHub "Uses to register changes in data sets"
        catalog -> publishingSystem "Uses to harvests data set metadata"
        
        consumptionSystem -> storage "Uses to read distributions"
        consumptionSystem -> catalog "Uses to read data set metadata"
        consumptionSystem -> registry "Uses to read entity types, their properties and references to data set metadata records"
        consumptionSystem -> fosRepository "Uses to read schemas"
        consumptionSystem -> rdfdatabase "Uses to execute queries"
        notificationHub -> consumptionSystem "Calls to notify about data set changes"
    }
    
    views {
        systemlandscape "publishing"   {
            include storage catalog notificationHub registry fosRepository publishingSystem publisher
        }
        
        systemcontext storage   {
            include *
        }
        
        container storage {
            include *
        }
        
        component contentManagementApp {
            include *
        }
        
        theme default
        
        styles {
            element "Person" {
                color #ffffff
                fontSize 22
                shape Person
            }
            element "Consumer" {
                background #2B5564
            }
            element "Publisher" {
                background #2B5564
            }
            element "Existing System" {
                background #999999
                color #ffffff
            }
            element "Software System" {
                background #62A4BC
                color #FFFFFF
            }
            element "Web Browser" {
                shape WebBrowser
            }
            element "Container" {
                background #62A4BC
                color #FFFFFF
            }
            element "Component" {
                background #62A4BC
                color #FFFFFF
            }
            element "Storage" {
                shape Cylinder
            }
            element "ETL" {
                shape Pipe
            }
        }
    }

}