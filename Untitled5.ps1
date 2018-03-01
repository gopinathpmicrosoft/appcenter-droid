$azureAccountName ="949384c7-17be-4dc0-90fa-1ba17c7af451"
$azurePassword = ConvertTo-SecureString "Password~1" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)

Add-AzureRmAccount -Credential $psCred -TenantId '72f988bf-86f1-41af-91ab-2d7cd011db47' -ServicePrincipal

Select-AzureRmSubscription -SubscriptionName 'Marketplace - UAT'

$resourceGroup='Marketplace - UAT'
$containerName='prssinput'

$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName 'VASC-PRSS-RG' -AccountName "anprsscodesignstorage"

$ctx = $storageAccount.Context

$path= $args[0] + 'APKS'
New-Item -ItemType directory -Path $path -Force

# download first blob
Get-AzureStorageBlobContent -Container $containerName -Blob "app-release.apk"  -Destination $path -Context $ctx -Force