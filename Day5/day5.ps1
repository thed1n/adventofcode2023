using namespace System.Collections.Generic
$seeddata = get-content .\Day5\input.txt

$soildata = [ordered]@{}

for ($i=0;$i -lt $seeddata.Count;$i++) {

    if ($seeddata[$i] -match '^seeds:') {
        $seeds = ($seeddata[$i] -split ':')[1].trim() -split '\s+'
        continue
}

    if ($seeddata[$i] -match '\-to\-') {
        $type = $seeddata[$i] -replace '.+-(.+) map\:$','$1'
        $soildata.add($type,[ordered]@{})
        $i++
    }

    $row = 1
    while (-not [string]::IsNullOrWhiteSpace($seeddata[$i])) {
        [int64]$destination,[int64]$source,[int64]$range = $seeddata[$i] -split '\s+'

        $soildata[$type].add($row,@{
            sourcestart= $source
            sourceend = $source+($range)
            destinationstart = $destination
            destinationend = $destination+($range)
        })
        $row++
        $i++
    }

}

$low = 10000000000
$seeds | % {
    [int64]$singleseed = $_
    $soildata.keys | % {
        $key = $_
        $lowestplace = $singleseed
        $found = $false
        $soildata[$key].keys | % {
            
            $row = $_-1
            if ($singleseed -gt $soildata[$key][$row].sourcestart -and $singleseed -lt $soildata[$key][$row].sourceend) {
                #write-host "[true] [$singleseed]"
                $pos = $singleseed - $soildata[$key][$row].sourcestart
                $destpos = $soildata[$key][$row].destinationstart + $pos

                if ($found -eq $false) {
                    $lowestplace = $destpos
                    $found = $true
                }
                if ($found -eq $true) {
                    if ($lowestplace -gt $destpos) {
                        $lowestplace = $destpos
                    }
                }
                #kolla vilken rad som har lägst destination.
            }
        }
        #write-host "[$key] [$lowestplace]"
        $singleseed = $lowestplace
    }
    if ($singleseed -lt $low) {
        $low = $singleseed
    }
} 
$low
