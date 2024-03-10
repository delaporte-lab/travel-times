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

### Subscription Key

Set your subscription key:
```powershell
$env:AzMapsSubKey="<your key here>"
$env:TravelDataFolder="<your data folder here>"
```

## How to Use

It's a mystery.

## Endpoints and Data

| Data Source | Information | 
|-|-|
| Azure Maps API | [Azure Maps API][41], [How to Search for Addresses][44] |
[ CSV Input Files ] Set `$env:TravelDataFolder` to the data folder |
