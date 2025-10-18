#Script demonstrating how to assign a Microsoft Intune device to a device category
#2025-10-17
 
#Define Tenant ID and Client ID variables for MS Graph connection
$tenantId="[YOUR-TENANT-ID]"
$clientId="[YOUR-CLIENT-ID]"

#Define the device category Id and Name
$deviceCategoryId = "[YOUR-CATEGORY-ID]"
$deviceCategoryName = "[YOUR-CATEGORY-NAME]"

#Connect to MS Graph
Connect-MgGraph -TenantId $TenantId -ClientId $ClientId -Scopes DeviceManagement.ReadWrite.All

#Get all devices in Intune
$allDevices = Get-MgDeviceManagementManagedDevice -All

#Filter devices not assigned to category
$unassignedDevices = $allDevices | Where-Object {$_.DeviceCategoryDisplayName -ne "$deviceCategoryName"}

#Preview results if desired
$unassignedDevices | Select-Object Id,DeviceName,OperatingSystem,DeviceCategoryDisplayName | Out-GridView

#Define headers for the Invoke-MgGraphRequest below
$headers = @{
    "Content-Type" = "application/json"
}

#Define the JSON body for the Invoke-MgGraphRequest
$body = @{
    '@odata.id' = "https://graph.microsoft.com/beta/deviceManagement/deviceCategories/$deviceCategoryId"
} | ConvertTo-Json -Depth 3

foreach ($device in $unassignedDevices){
    $deviceId = $device.Id

    #Send the PUT request to assign the category
    try{
        Write-Output "Assigning category to device: $($device.DeviceName)"

        Invoke-MgGraphRequest -Method PUT `
            -Uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$deviceId/deviceCategory/`$ref" `
            -Headers $headers `
            -Body $body
    }

    catch{
        Write-Warning "Failed to assign category to device: $($device.Devicename)"
    }
}

#Disconnect from MS Graph
Disconnect-MgGraph
