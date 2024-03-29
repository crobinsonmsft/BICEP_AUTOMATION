

Configuration WebsiteTest {

    # Import the module that contains the resources we're using.
    #Import-DscResource -ModuleName PsDesiredStateConfiguration

    # The Node statement specifies which targets this configuration will be applied to.
    Node 'localhost' {

        # The first resource block ensures that the Web-Server (IIS) feature is enabled.
        WindowsFeature WebServer {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        # The second resource block ensures that the website content copied to the website root folder.
        #File WebsiteContent {
         #   Ensure = 'Present'
          #  SourcePath = 'c:\test\index.htm'
           # DestinationPath = 'c:\inetpub\wwwroot'
        #}
    }
}

#Publish-AzVMDscConfiguration .\LANDING_ZONE\Scripts\IIS_DSC.ps1 -OutputArchivePath .\LANDING_ZONE\Scripts\IIS_DSC.ps1.zip