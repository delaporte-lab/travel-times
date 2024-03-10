$fuzzyUrl = "https://atlas.microsoft.com/search/fuzzy/json?&api-version=1.0&subscription-key={Your-Azure-Maps-Subscription-key}&language=en-US&query=pizza"

<#
.SYNOPSIS

Used by other functions in this module.
#>
function Get-MapAddress() {
    param(
        [string]$address
    )
    $subKey = $env:AzMapsSubKey
    $addyUrl = "https://atlas.microsoft.com/search/address/json?&subscription-key=$subKey&api-version=1.0&language=en-US&query=$address"
    $result = Invoke-WebRequest $addyUrl
    if($result.StatusCode -Eq 200){
        return $result.Content | ConvertFrom-Json
    }
    return $result.StatusDescription
}

<#
.SYNOPSIS

Get map coordinates from an address, using the Azure maps API
Used by other functions in this module.

#>
function Get-MapCoords() {
    param(
        [string]$address
    )
    $subKey = $env:AzMapsSubKey
    $result = Get-MapAddress -Address $address
    return $result.results.entryPoints[0].position
}

<#

Get a route between two locations, using the Azure maps API

#>
function Get-MapTravelPlan() {
    param(
        [string]$from_address,
        [string]$to_address
    )
    $subKey = $env:AzMapsSubKey
    $pos1 = Get-MapCoords -Address $from_address
    $lat1 = $pos1.lat
    $lon1 = $pos1.lon

    $pos2 = Get-MapCoords -Address $to_address
    $lat2 = $pos2.lat
    $lon2 = $pos2.lon

    $query = "$lat1,$($lon1):$lat2,$lon2"
    # Write-Host $query
    $travelUrl = "https://atlas.microsoft.com/route/directions/json?subscription-key=$subKey&api-version=1.0&query=$query&travelMode=car&traffic=true&departAt=2025-03-29T08:00:20&computeTravelTimeFor=all"
    $result = Invoke-WebRequest $travelUrl
    if($result.StatusCode -Eq 200){
        $content = $result.Content | ConvertFrom-Json
        if($content.formatVersion -Ne "0.0.12"){
            Write-Warning "BEWARE Format has updated! BEWARE"
        }
        return $content.routes
    }
    return $result.StatusDescription
}


<# 
.SYNOPSIS

Get the total travel time for a route between two locations, using the Azure maps API

.DESCRIPTION

Get the total travel time for a route between two locations, using the Azure maps API
I'm from Chicago. We measure distance in minutes.

#>
function Get-MapTravelMinutes() {
    param(
        [string]$from_address,
        [string]$to_address
    )
    $routes = Get-MapTravelPlan -from_address $from_address -to_address $to_address
    $seconds = $routes.summary.travelTimeInSeconds
    return $seconds/60
}


$fuzzyUrl = "https://atlas.microsoft.com/search/fuzzy/json?&api-version=1.0&subscription-key={Your-Azure-Maps-Subscription-key}&language=en-US&query=pizza"

<# 
.SYNOPSIS

Helper to make sure you set your Azure subscription key.

#>
function Invoke-SubKeyCheck {
    if($env:AzMapsSubKey -Eq $null) {
        Write-Error "Please set env:AzMapsSubKey"
        Exit
    }
}

<#
.SYNOPSIS

Helper function to add any missing addresses that are present in the input file,
 and missing in the output file.

#>

function Add-Addresses(){
    Param(
        [string]$addressFile = "Addresses.csv",
        [string]$locationFile="Locations.csv",
        [string]$outFile= "Address_Details.csv"
    )
    Copy-Item $outFile "$outFile.backup"
    $addressList = Get-Content $addressFile | ConvertFrom-Csv
    $details = Get-Content $outFile| ConvertFrom-Csv
    $locations = Get-Content $locationFile | ConvertFrom-Csv
    # TODO: Add location keys to the file...

    $results = [System.Collections.ArrayList]@()
    $known = [System.Collections.ArrayList]@()

    $details | ForEach-Object {
        $idx = $results.Add($_)
        $known.Add($_.Address)
    }


    $addressList | ForEach-Object {
        if($known -NotContains $_.Address)
        {
            $idx = $results.Add($_)
            $idx = Write-Host "Aadded " + $_.Address
        }
    }
    $results | Format-Table
    $answer = Read-Host -Prompt "Write updated file? y/N"
    if($answer -Eq "y") {
        $results | Export-Csv -NoTypeInformation -Path $outFile
        Write-Host "Updated $outFile"
    }
}
Export-ModuleMember Add-Addresses

<#
.SYNOPSIS

Add any missing map coordinates to Address_Details.csv, 
based on the provided address.

#>
function Add-AddressLocations(){
    Param(
        [string]$outFile= "Address_Details.csv"
    )
    Copy-Item $outFile "$outFile.backup"
    $details = Get-Content $outFile| ConvertFrom-Csv

    $results = [System.Collections.ArrayList]@()

    $details | ForEach-Object {
        $updated = $_
        if($_.lat -Eq $null)
        {
            Write-Host "Looking up position of " $_.Address
            $coords= Get-MapCoords -Address $_.Address
            $coords | Format-List
            $updated.lat = $coords.lat
            $updated.lon = $coords.lon
            $updated | Format-List
        }
        $idx = $results.Add($updated)
    }
    $results | Select-Object Address, lat, lon | Format-List
    $answer = Read-Host -Prompt "Write updated file? y/N"
    if($answer -Eq "y") {
        $results | Export-Csv -NoTypeInformation -Path $outFile
        Write-Host "Updated $outFile"
    }
}
Export-ModuleMember -Function Add-AddressLocations

<#

.SYNOPSIS

Add travel times to any rows in Address_Details.csv,
based on coordinates added previously with `Add-AddressLocations`

.INPUTS

locationFile - as descrbied in README.md
key - which row of locationFile to lookup
outFile - the file to update. each row will be updated. key will become a new column, containing travel time in minutes

.EXAMPLE

Add-TravelTimes -key school -locationFile "Locations.csv" -outFile "Address_Details.csv"

#>
function Add-TravelTimes() {
    Param(
        [string]$key,
        [string]$locationFile="Locations.csv",
        [string]$outFile="Address_Details.csv"
    )
    # TODO: Maybe do one key at a time, for now...
    $details = Get-Content $outFile| ConvertFrom-Csv
    $locations = Get-Content $locationFile | ConvertFrom-Csv
    "Locations of Interest:"
    $locations | Format-List

    $loc = $locations | ? { $_.Key -eq $key }
    $from_address = $loc.Address
    "Selected Location is '$from_address'"

    $results = [System.Collections.ArrayList]@()
    $details | Format-Table

    $details | ForEach-Object {
        $updated = $_
        # $_.psobject.properties | Foreach { $updated[$_.Name] = $_.Value }
        $to_address = $_.Address
        "Fetching travel time for $to_address ..."
        $dist = Get-MapTravelMinutes -from_address $from_address -to_address $to_address
        $updated."$key" = [math]::ceiling($dist)
        $idx = $results.Add($updated)
    }
    $results | Select-Object Address, $key | Format-List
    # $results | Format-List
    $answer = Read-Host -Prompt "Write updated file? y/N"
    if($answer -Eq "y") {
        $results | Export-Csv -NoTypeInformation -Path $outFile
        # $results | Export-Csv -Path $outFile
        Write-Host "Updated $outFile"
    }


}
Export-ModuleMember -Function Add-TravelTimes