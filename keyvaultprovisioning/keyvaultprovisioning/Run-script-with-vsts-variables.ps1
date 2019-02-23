param(
	[string]$ScriptPath,
	[hashtable]$secretVariables 	
)

Set-Location $PSScriptRoot

$rawParams = @{}
$params = @{}
Write-Host @secretVariables
# Add all environment variables to the parameters hashtable
$envs = (Get-ChildItem env:)

foreach ($env in $envs)
{
	$bool = $null
	if ([bool]::TryParse($env.Value, [ref] $bool))
	{ 
		$rawParams[$env.Name] = $bool 
	}
	else 
	{
		$rawParams[$env.Name] = $env.Value 
	}
}

# Add all secret variables to the parameters hashtable
$secretVariables.GetEnumerator() | Foreach-Object { $rawParams[$_.Name] = (convertto-securestring $_.Value -asplaintext -force) }

Write-Host $rawParams['serviceprincipalpassword']
# Strip the parameters hashtable down to the required set of parameters for the script
$scriptParameters = (Get-Command $ScriptPath).Parameters.GetEnumerator() | Select Key
$rawParams.GetEnumerator() | Foreach-Object { if ($scriptParameters.Key -contains $_.Name) { $params.Add($_.Name, $_.Value) } }

$azureRmModule = Get-InstalledModule AzureRM

if($azureRmModule)
{
Write-Host 'AzureRM module exists. Removing it'
Uninstall-Module -Name AzureRM -AllVersions
Write-Host 'AzureRM module removed'
}
Install-Module Az -Force -confirm:$false -AllowClobber

$cred = New-Object System.Management.Automation.PSCredential($rawParams['serviceprincipalid'], $rawParams['serviceprincipalpassword'])

Login-AzureRMAccount -Credential $cred -ServicePrincipal -SubscriptionId $rawParams['subscriptionid'] -TenantId $rawParams['tenantid']


Write-Host ($params | Out-String)
Write-Host ($rawParams | Out-String)

& $ScriptPath @params