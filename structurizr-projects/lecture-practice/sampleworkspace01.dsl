workspace "Czech National Open Data Catalog (NODC) workspace" "This workspace documents the architecture of the National Open Data Catalog (NODC) which serves as a catalog of all open data sets published by public institutions in Czechia." {

    model {
        nodc = softwareSystem "Czech National Open Data Catalog (NODC)" "Stores and presents metadata records about data sets and harvests meta data from local open data catalogs."

        consumer = person "Consumer" "A person from the public who searches for data sets and accesses them for various purposes." "Public" {
            -> nodc "Searchers for metadata records in"
        }

        gov = person "Government" "A person from a government institution who searches for data sets and accesses them for various purposes." "Gov"
        
        gov -> nodc "Searchers for metadata records in"

    }

    views   {
        systemContext nodc "NODC_SystemContext_View" {
            include *
        }
    }

}