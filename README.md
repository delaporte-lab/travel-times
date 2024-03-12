# travel-times
Compute travel times between addresses

## Setup

Make sure that PowerShell 7 or higher is installed:

```powershell
if($PSVersionTable.PSVersion.Major < 7) {
    winget install --id Microsoft.Powershell --source winget
}

Then inside PowerShell 7, install the Az module:

```powershell
Install-Module -Name Az -Repository PSGallery -Force
```

Now put this module on your PowerShell path, and then import this module.

```powershell
$module="traveltimes.psm1"
remove-module 'TravelTimes'; import-module $module; get-command $module
```

### Subscription Key

Set your subscription key:
```powershell
$env:AzMapsSubKey="<your key here>"
```

## How to Use

1. Populate `LocationsOfInterest.csv` with locations to calculate travel times to/from. 

It must have at least two columns `Key` and `Address`. `Key` may be displayed later.

| Key | Address | Comment |
|-|-|-|
| School | 123 Seasame Street, NY, 55555 | This column is ignored. |
| Work | 500 Serious Business Lane, NY, 55555 | Business! |

2. Populate `Addresses.csv` with addresses of interest.

Only the `Address` column is used by these scripts.

| Address | Comments | Cost |
|-|-|-|
| 1234 Basic Home Lane, NY, 55555 | Nice option. | $$ |
| 9999 Expensive Drive, NY, 55555 | The kitchen is too small. | $$$$$$ |

### Running the Scripts

These scripts will populate `Address_Details.csv` with travel times.

1.  Call `Add-Addresses` to copy records from `Addresses.csv` to `Address_Dedtails.csv`.

> Work-around: Add any locations of Interest to Address_Details.csv as empty columns.

2. Call `Add-AddressLocations` to fetch latitude and longitude for all addresses in `Address_Details.csv`.

3. Call `Add-TravelTimes` to add travel times.

> Coming soon...calculate cost per square foot and add that as well.

## Endpoints and Data

| Data Source | Information | 
|-|-|
| Azure Maps API | [Azure Maps API][41], [How to Search for Addresses][44] |
| CSV Input Files  | Comma searpated value files passed into scripts as inputs and outputs. Start by populating `Addresses.csv` |
