#
# localdeploy.ps1
# script can be used for deployment from local pc to Azure
clear
#Clear-AzureRmContext -Scope Process

if ((Get-AzureRmContext).Subscription.Name -ne "Visual Studio Enterprise")
{
    Login-AzureRmAccount

    Set-AzureRmContext -Subscription Visual Studio Enterprise
}

$KeyVaultName = "acmeproducteundevsharedvault"
$KeyVaultServicePrincipalObjectId = "a5604756-6f41-45d7-93d1-abcd5ccf7ca1"
$ResourceGroupLocation = "northeurope"
$Environment = "dev"

.\deploy-keyvault.ps1 -KeyVaultName $KeyVaultName `
   -KeyVaultServicePrincipalObjectId $KeyVaultServicePrincipalObjectId `
   -ResourceGroupLocation $ResourceGroupLocation `
   -environment $Environment