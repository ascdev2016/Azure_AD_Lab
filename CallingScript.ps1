<#
break

 Shout out to @brwilkinson for assistance with some of this.


# Install the Azure Resource Manager modules from PowerShell Gallery
# Takes a while to install 28 modules
Install-Module AzureRM -Force -Verbose
Install-AzureRM

# Install the Azure Service Management module from PowerShell Gallery
Install-Module Azure -Force -Verbose

# Import AzureRM modules for the given version manifest in the AzureRM module
Import-AzureRM -Verbose

# Import Azure Service Management module
Import-Module Azure -Verbose

# Authenticate to your Azure account #>
Login-AzureRmAccount

# Adjust the 'yournamehere' part of these three strings to
# something unique for you. Leave the last two characters in each.
$URI       = 'https://raw.githubusercontent.com/ascdev2016/Azure_AD_Lab/master/azuredeploy.json'
$Location  = 'West Europe'
$rgname    = 'ASCLab'
$saname    = 'asclabsa'     # Lowercase required
$dcdnsName = 'asclabdc'     # Lowercase required
$sqldnsname = 'asclabsql'   # Lowercase required
$spdnsname = 'asclabsp'   # Lowercase required
<#
$string1 ='{
	"Name": "ascad.local",
	"User": "adAdministrator",
	"Restart": "true",
	"Options": "3"
		}'
$string2 ='{"Password": "Herzblut$$16@dg"}'
#>


# Check that the public dns $addnsName is available
if (Test-AzureRmDnsAvailability -DomainNameLabel $dcdnsName -Location $Location)
{ 'Available' } else { 'Taken. addnsName must be globally unique.' }

if (Test-AzureRmDnsAvailability -DomainNameLabel $sqldnsName -Location $Location)
{ 'Available' } else { 'Taken. addnsName must be globally unique.' }

if (Test-AzureRmDnsAvailability -DomainNameLabel $spdnsName -Location $Location)
{ 'Available' } else { 'Taken. addnsName must be globally unique.' }

# Create the new resource group. Runs quickly.
New-AzureRmResourceGroup -Name $rgname -Location $Location

# Parameters for the template and configuration
$MyParams = @{
    newStorageAccountName = $saname
    location              = 'West Europe'
    domainName            = 'ascad.local'
    dcdnsName             = $dcdnsName
    sqldnsName            = $sqldnsname
    spdnsName            = $spdnsname
	nodename = "SP-SQL"
   }

# Splat the parameters on New-AzureRmResourceGroupDeployment  
$SplatParams = @{
    TemplateUri             = $URI 
    ResourceGroupName       = $rgname 
    TemplateParameterObject = $MyParams
    Name                    = 'ascad'
   }

# This takes ~30 minutes
# One prompt for the domain admin password
New-AzureRmResourceGroupDeployment @SplatParams -Verbose

#Set-AzureRmVMExtension -ResourceGroupName $rgname -ExtensionType "JsonADDomainExtension" -Name "joinDomain" -Publisher "Microsoft.Compute" -TypeHandlerVersion "1.3" -VMName "SP-SQL" -Location $Location -SettingString $string1 -ProtectedSettingString $string2

Get-AzureRMVM -Name -ResourceGroupName


# Find the VM IP and FQDN
$PublicAddress = (Get-AzureRmPublicIpAddress -ResourceGroupName $rgname)[1]
$IP   = $PublicAddress.IpAddress
$FQDN = $PublicAddress.DnsSettings.Fqdn

# RDP either way
Start-Process -FilePath mstsc.exe -ArgumentList "/v:$FQDN"
Start-Process -FilePath mstsc.exe -ArgumentList "/v:$IP"

# Login as:  alpineskihouse\adadministrator
# Use the password you supplied at the beginning of the build.

# Explore the Active Directory domain:
#  Recycle bin enabled
#  Admin tools installed
#  Five new OU structures
#  Users and populated groups within the OU structures
#  Users root container has test users and populated test groups

# Delete the entire resource group when finished
Remove-AzureRmResourceGroup -Name $rgname -Force -Verbose
