
#Author: Jonathan Parrilla
#Created: 5/14/2015

#Dot source Write-To-Log
. C:\Write-To-Log.ps1

Function Start-Services-On-Server
{
<#
.SYNOPSIS
This will stop and start a hung service on a server. It will accept only one server, but can accept from one to many services.

.PARAMETER serverName
This is the server that the user will provided.

.PARAMETER ListOfServices
This is a string array that will consist of one or more services. Separate each service with a comma (,).

.EXAMPLE
Start-Services-On-Server -serverName [COMPUTERNAME] -ListOfServices [SERVICENAME]

.EXAMPLE
Start-Services-On-Server -serverName [COMPUTERNAME] -ListOfServices [SERVICENAME],[SERVICENAME]

#>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True)]
        [String]$serverName,
        [Parameter(Mandatory = $True)]
        [String[]]$ListOfServices
    )


    BEGIN
    {
        Write-Verbose "Starting services on a server function was successfully called."
    }

    PROCESS
    {
        
        Write-Verbose "Gathering data for logging purposes..."

        #Grab the user running the script.
        $user = $env:USERNAME

        #Grab the Script Name (hard coded)
        $scriptName = "Start-Services-On-Server"

        $ListOfServices -split (',')

        Write-Verbose "Iterating throught the list of services provided."
        
        try
        {

            #Iterate through each service in the list of services
            Foreach($service in $ListOfServices)
            {
                $logName = "General-Log"
            
                #Update the console pane, update the final output variable, stop the service, and set it to disabled.
                Write-Host "Stopping $service on $serverName"

                #Get the current service by finding the current server and set the startup type to Disabled.
                Set-Service -ComputerName $serverName -Name $service –StartupType "Disabled"

                #Get the current service by finding the current server and stop the service.
                Get-Service -ComputerName $serverName -Name $service | Stop-Service -Verbose

                $message = "Stopping $service on $serverName"

                Write-To-Log $user $scriptName $logName $serverName $message

                #Update the console pane, update the final output variable, set the service to auto and start it.
                Write-Host "Starting $service on $serverName"

                #Get the current service by finding the current server and set the startup type to automatic.
                Set-Service -ComputerName $serverName -Name $service –StartupType "Automatic"

                #Get the current service by finding the current server and start the service.
                Get-Service -ComputerName $serverName -Name $service | Start-Service -Verbose

                $message = "Started $service on $serverName"

                Write-To-Log $user $scriptName $logName $serverName $message

            }

            #Update console pane, update final output variable, and assign output to the result label.
            Write-host Started all provided services.
        }
        catch
        {
            $logName = "Error-Log"

            $message = "Could not start $service on $serverName"

            Write-To-Log $user $scriptName $logName $serverName $message
            
            $anyError = $True
            
            $continue = $True
        }
    }

    END
    {

        if($anyError)
        {
            return "Services were started, but there were some errors. Please check Error-Logs."
        }
        else
        {
            return "Services were started successfully with no errors."
        }
    }

}