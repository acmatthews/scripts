# Hosted Zone ID in Route53
$HostedZoneID = 'Z08511741V9XRRAF23LZ1'
# URL to update -- including the trailing '.'
$RecordName = 'lan.6ixnet.com.'
# Record Type
$RecordType = 'A'
# AWS Credential Profile Name - credential profiles are stored in C:\Users\spartauser\.aws\credentials
$Credentials = '6ixNet-AWS-Route53FullAccess'

# Set up the credentials
Set-AWSCredentials -ProfileName $Credentials
# Get this machine's public IP address
Write-Host "Getting public IP address..."
$PublicIP = (New-Object System.Net.WebClient).DownloadString("http://ifconfig.me/ip").Trim()
Write-Host "Getting resource records for $HostedZoneID"
$ResourceRecords = Get-R53ResourceRecordSet -HostedZoneId $HostedZoneID
$RecordSet = $ResourceRecords.ResourceRecordSets | Where-Object {$_.Name -eq $RecordName -AND $_.Type -eq $RecordType}
$RecordValue = $RecordSet.ResourceRecords[0].Value.Trim()
Write-Host "Current Value: $RecordValue"
Write-Host "Desired Value: $PublicIP"
If($RecordValue -ne $PublicIP)
{
    Write-Host "Records don't match." -ForegroundColor Red
    $Action = New-Object -TypeName Amazon.Route53.Model.Change
    $Action.Action = "DELETE"
    $Action.ResourceRecordSet = $RecordSet
    Write-Host "Deleting old record."
    $Change = Edit-R53ResourceRecordSet -HostedZoneId $HostedZoneID -ChangeBatch_Change $Action
    Write-Host "Allowing change to be applied."
    Start-Sleep -Seconds 10
    $NewRecordSet = New-Object -TypeName Amazon.Route53.Model.ResourceRecordSet
    $NewRecordSet.Name = $RecordName
    $NewRecordSet.Type = $RecordType
    $NewRecordSet.TTL = $RecordSet.TTL
    $NewRecordSet.ResourceRecords.Add($PublicIP)
    $Action = New-Object -TypeName Amazon.Route53.Model.Change
    $Action.Action = "CREATE"
    $Action.ResourceRecordSet = $NewRecordSet
    Write-Host "Adding new record..."
    $Change = Edit-R53ResourceRecordSet -HostedZoneId $HostedZoneID -ChangeBatch_Change $Action
    Write-Host "Completed." -ForegroundColor Green
}
Else
{
    Write-Host "Records match!" -ForegroundColor Green
}
