workspace {

    model {
        drugMonitoring = softwareSystem "Drug Monitoring" "" "" {
            //
        }
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
        }
    }

}
