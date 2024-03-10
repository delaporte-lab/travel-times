
function Get-TravelTimes() {


}

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