using namespace System.Collections.Generic
$galaxychart = Get-Content .\Day11\input.txt
class matte {
    static [int] manhattan ([string]$cord1,[string]$cord2) {
        [int]$x1,[int]$y1 = $cord1 -split ','
        [int]$x2,[int]$y2 = $cord2 -split ','

        return [math]::abs($x1 - $x2)+[math]::abs($y1-$y2)
    }
}
$galaxy = [list[list[string]]]::new()

for ($y = 0; $y -lt $galaxychart.count; $y++) {
    $galaxy.add(@())
    for ($x = 0; $x -lt $galaxychart[0].Length; $x++) {
        $galaxy[$y].add([string]$galaxychart[$y][$x])
    }
}

$galaxies = [ordered]@{}

$gal = 1
for ($y = 0; $y -lt $galaxy.count; $y++) {
    for ($x = 0; $x -lt $galaxy[0].count; $x++) {
        if ($galaxy[$y][$x] -eq '#') {
            $galaxies.add("$x,$y",@{Galax = $gal; X = [int64]$x; Y= [int64]$y})
            $gal++
        }
    }
}


$rowv = [ordered]@{}
$rowh = [ordered]@{}
for ($x = 0; $x -lt $galaxychart[0].Length; $x++) {
    $nogalaxy = $true
    for ($y = 0; $y -lt $galaxychart.count; $y++) {
        if ($galaxychart[$y][$x] -eq '#') {
            $nogalaxy = $false
        }
    }

    if ($nogalaxy -eq $true) {
        $rowv["$x"] = 'vertical'
    }
}
for ($y = 0; $y -lt $galaxychart.count; $y++) {
    $nogalaxy = $true
    for ($x = 0; $x -lt $galaxychart[0].Length; $x++) {
        
        if ($galaxychart[$y][$x] -eq '#') {
            $nogalaxy = $false
        }
    }

    if ($nogalaxy -eq $true) {
        $rowh["$y"] = 'horizontal'
    }
}

[int64]$increment = 1000000-1

[int64]$multiplier = $increment

[int64]$shift = 0

$rowh.keys | % {
    [int64]$yg = $_
    $yg += $shift
    $galaxies.keys | % {
        $key = $_
        if ($galaxies[$key].y -gt $yg) {
            #write-host "$key multiplying"
            $galaxies[$key].y += $multiplier
        }
    }
    $shift += $increment
}

[int64]$multiplier = $increment
$shift = 0
$rowv.keys | % {
    [int64]$xg = $_
    $xg += $shift
    $galaxies.keys | % {
        $key = $_
        if ($galaxies[$key].x -gt $xg) {
            #write-host "$key multiplying"
            $galaxies[$key].x += $multiplier
        }
    }
    $shift += $increment
}


[list[string]]$cords = @()
$galaxies.keys | % {
    $cords.add("$($galaxies[$_].x),$($galaxies[$_].y)")
}

$summa = 0
for ($i = 0;$i -lt $cords.count-1;$i++) {
    for ($j = $i+1;$j -lt $cords.count;$j++) {
    $summa += [matte]::manhattan($cords[$i],$cords[($j)])
    }
}

$summa
