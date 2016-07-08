Login-AzureRmAccount

$subs = Get-AzureRmSubscription 
Select-AzureRmSubscription -TenantId $subs[0].TenantId -SubscriptionId $subs[0].SubscriptionId

$rgName ='ASC_Lab'
$location = 'West Europe'
$domainPassword = 'Herzblut$$16@dg'
$vmPassword = 'Herzblut$$16@dg'
$vmNames = @('sqlserverasc','spserverasc')

# Check availability of DNS name
foreach ($vm in $vmNames){
    If ((Test-AzureRmDnsAvailability -DomainQualifiedName sqlserverasc -Location $location) -eq $false) {
            Write-Host 'The DNS label prefix for the VM is already in use' -foregroundcolor yellow -backgroundcolor red
            throw 'An error occurred'
    }

    # Create New Resource Group
    # Checks to see if RG exists
    # -ErrorAction Stop added to Get-AzureRmResourceGroup cmdlet to treat errors as terminating

    try {
        Get-AzureRmResourceGroup -Name $rgName -Location $location -ErrorAction Stop
    } catch {
        Write-Host "Resource Group doesn't exist" -foregroundcolor yellow -backgroundcolor red
        throw 'An error occurred'
    }
}
foreach ($vm in $vmNames){
    $newVMParams = @{
        'ResourceGroupName' = $rgName
        'TemplateURI' = 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vm-domain-join/azuredeploy.json'
        'existingVNETName' = 'adVNET'
        'existingSubnetName' = 'adSubnet'
        'dnsLabelPrefix' = $vm
        'vmSize' = 'Standard_A2'
        'domainToJoin' = 'ascad.local'
        'domainUsername' = 'adadministrator'
        'domainPassword' = convertto-securestring $domainPassword -asplaintext -force
        'ouPath' = ''
        'domainJoinOptions' = 3
        'vmAdminUsername' = 'adm.dgadmin'
        'vmAdminPassword' = convertto-securestring $vmPassword -asplaintext -force
    }
    New-AzureRmResourceGroupDeployment @newVMParams -Verbose
}