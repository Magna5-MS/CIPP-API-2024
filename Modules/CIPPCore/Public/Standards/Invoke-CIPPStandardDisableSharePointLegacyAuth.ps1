function Invoke-CIPPStandardDisableSharePointLegacyAuth {
    <#
    .FUNCTIONALITY
    Internal
    #>
    param($Tenant, $Settings)
    
    $CurrentInfo = New-GraphGetRequest -Uri 'https://graph.microsoft.com/beta/admin/sharepoint/settings?$select=isLegacyAuthProtocolsEnabled' -tenantid $Tenant -AsApp $true
    
    If ($Settings.remediate) {

        if ($CurrentInfo.isLegacyAuthProtocolsEnabled) {
            try {
                $body = '{"isLegacyAuthProtocolsEnabled": "false"}'
                $null = New-GraphPostRequest -tenantid $tenant -Uri 'https://graph.microsoft.com/beta/admin/sharepoint/settings' -AsApp $true -Type patch -Body $body -ContentType 'application/json'
                Write-LogMessage -API 'Standards' -tenant $tenant -message 'Disabled SharePoint basic authentication' -sev Info
                $CurrentInfo.isLegacyAuthProtocolsEnabled = $false
            } catch {
                Write-LogMessage -API 'Standards' -tenant $tenant -message "Failed to disable SharePoint basic authentication. Error: $($_.exception.message)" -sev Error
            }
        } else {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'SharePoint basic authentication is already disabled' -sev Info
        }
    }
    if ($Settings.alert) {

        if ($CurrentInfo.isLegacyAuthProtocolsEnabled) {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'SharePoint basic authentication is enabled' -sev Alert
        } else {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'SharePoint basic authentication is disabled' -sev Info
        }
    }
    if ($Settings.report) {

        Add-CIPPBPAField -FieldName 'SharePointLegacyAuthEnabled' -FieldValue [bool]$CurrentInfo.isLegacyAuthProtocolsEnabled -StoreAs bool -Tenant $tenant
    }
}
