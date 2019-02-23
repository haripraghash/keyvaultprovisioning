Param (
	# Resource group
	[Parameter(Mandatory=$true)]
	[string] $ResourceGroupLocation,

    [string] $ResourceGroupName = 'acme-product-eun-dev-shared-resgrp',

    [string] $TemplateFile = 'azuredeploy.json',
	[Parameter(Mandatory=$true)]
	 [string] $KeyVaultName,
	 [Parameter(Mandatory=$true)]
	 [string] $KeyVaultServicePrincipalObjectId,

	# General
	[Parameter(Mandatory=$true)]
	[string] $Environment = 'dev'
)
$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot

$AadTenantId = (Get-AzContext).Tenant.Id
$ArtifactsStorageAccountName = $ResourceNamePrefix + $Environment + 'artifacts'
$ArtifactsStorageContainerName = 'artifacts'
$ArtifactsStagingDirectory = '.'

function CreateResourceGroup() {
	$parameters = New-Object -TypeName Hashtable

	# product sql db	
	$parameters['keyVaultName'] = $KeyVaultName
	$parameters['objectId'] = $KeyVaultServicePrincipalObjectId
	
	 Write-Host ($parameters | Out-String)
	 Deploy-AzureResourcegroup.ps1 `
	    -resourcegrouplocation $ResourceGroupLocation `
		-resourcegroupname $ResourceGroupName `
		-uploadartifacts `
		-storageaccountname $ArtifactsStorageAccountName `
		-storagecontainername $ArtifactsStorageContainerName `
		-artifactstagingdirectory $ArtifactsStagingDirectory `
		-templatefile $TemplateFile `
		-templateparameters $parameters
}

function Main() {
	$deployment = CreateResourceGroup
	$deployment

	if ($deployment.ProvisioningState -eq 'Failed'){
		throw "Deployment was unsuccessful"
	}
	
	
	$keyVaultName = $deployment.outputs.keyVaultName.Value
	
	#Write-Host "##vso[task.setvariable variable=SqlServerAppAdminLoginPassword;issecret=true;]$sqlServerAdminLoginPasswordPlain"
}

Main