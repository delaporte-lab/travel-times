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

``powershell
Import-Module travel-times.psm1
```


### Subscription Key

Set your subscription key:
```powershell
$env:AzMapsSubKey="<your key here>"
```

## How to Use

It's a mystery.

Populate `LocationsOfInterest.csv` with locations to calculate travel times to/from. It must have at least two columns `Key` and `Address`. `Key` may be displayed later.

| Key | Address | Comment |
|-|-|-|
| School | 123 Seasame Street, NY, 55555 | This column is ignored. |
| Work | 500 Serious Business Lane, NY, 55555 | Business! |

Populate `Addresses.csv` with addresses of interest. Only the `Address` column is used by these scripts.

| Address | Comments | Cost |
|-|-|-|
| 1234 Basic Home Lane, NY, 55555 | Nice option. | $$ |
| 9999 Expensive Drive, NY, 55555 | The kitchen is too small. | $$$$$$ |


## Endpoints and Data

| Data Source | Information | 
|-|-|
| Azure Maps API | [Azure Maps API][41], [How to Search for Addresses][44] |
| CSV Input Files  | Comma searpated value files passed into scripts as inputs and outputs. Start by populating `Addresses.csv` |
