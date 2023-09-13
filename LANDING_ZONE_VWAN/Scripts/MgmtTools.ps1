Configuration WebServerConfiguration
{  
  Node "localhost"
  {        
    WindowsFeature WebServer
    {
      Name = "Web-Server"
      Ensure = "Present"
    }

    WindowsFeature ManagementTools
    {
      Name = "Web-Mgmt-Tools"
      Ensure = "Present"
    }

    WindowsFeature DefaultDoc
    {
      Name = "Web-Default-Doc"
      Ensure = "Present"
    }
  }
}

#Publish-AzVMDscConfiguration .\LANDING_ZONE\Scripts\MgmtTools.ps1 -OutputArchivePath .\LANDING_ZONE\Scripts\MgmtTools.ps1.zip
