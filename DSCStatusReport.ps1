function DSCStatusReport
{

      [CmdletBinding(SupportsShouldProcess=$True)]
param([Parameter(Mandatory=$false,
      ValueFromPIPeline=$true)]
      [string]$FilePath = "C:\temp\DSCStatusReport.html",
      [string[]]$Computername = $env:COMPUTERNAME,
$Css='table{margin:auto; width:95%}
              Body{background-color:SteelBlue; Text-align:Center;}
                th{background-color:black; color:white;}
                td{background-color:Grey; color:Black; Text-align:Center;}
     ' )

Begin{ Write-Verbose "HTML report will be saved $FilePath" }
Process{

Function GetDSCStatus
{


$Nodes = $null
$DSCStatus = $null
$DSCDate = $null
$DSCAll = $null

$Nodes = Get-ADComputer -SearchBase "OU=DSC Managed Nodes,OU=SERVERS,OU=NYC,OU=Americas,DC=lab2,DC=test,DC=com" -Filter * | Select-Object Name

$DSCStatus =  Foreach ($Node in $Nodes.name)
                        {
                            Try 
                            {
                                Test-DSCConfiguration -computername $Node –detailed -ErrorAction STOP  | select-object PSComputerName,InDesiredState,@{ Name = "Resources In Desired State" ; Expression = {$_.ResourcesInDesiredState}},@{ Name = "Resources Not In Desired State" ; Expression = {$_.ResourcesNotInDesiredState}}
                            }
                            Catch 
                            {
                                $_ | Select-Object @{ Name = "PSComputerName" ; Expression = {$($Node)}},@{ Name = "InDesiredState" ; Expression = {("$_.Exception").substring(0,170)}},@{ Name = "Resources In Desired State" ; Expression =  {"NA"}},@{ Name = "Resources Not In Desired State" ; Expression = {"NA"}}
                            }
                }
                        

                
                
            
              
                
                
           

$DSCData = if($DSCStatus.Exception -like "*") 
            {[pscustomobject]@{ 'PSComputerName' = "$($Node)"; "InDesiredSate"= "$($DSCStatus.Exception)";"Resources In Desired State" = "$($DSCStatus.Exception)";"Resources Not In Desired State" = "$($DSCStatus.Exception)" }}
            Else {$DSCStatus}
            
$DSCAll = $DSCData,$DSCStatus

#$DSCData | ConvertTo-Html -Fragment -PreContent "DSC Data" | Out-String
$DSCStatus | ConvertTo-Html -Fragment -PreContent "DSC Status" | Out-String
#$DSCAll | ConvertTo-Html -Fragment -PreContent "DSC All" | Out-String
}

$DSCOutput = GetDSCStatus

$Report = ConvertTo-Html -Title "DSC Status Check" `
                         -Head "PowerShell ReportingDSC Status ReportThis report was ran: $(Get-Date)" `
                         -Body "$DSCOutput $Css" }



End{ $Report | Out-File $Filepath ; Invoke-Expression $FilePath }



}

DSCStatusReport 

send-mailmessage -from "DSCAdmin@test.com" -to "edward_oconnor@test.com" -subject "Sample DSC Status Report" -body "Sample DSC Status Report attached! This is a sample of the report I have create that can run as a task and reports the status of DSC. Unlike the Pre-DSC check this one will report if DSC is functioning." -Attachments "C:\temp\DSCStatusReport.html" -smtpServer mailhub.test.com



