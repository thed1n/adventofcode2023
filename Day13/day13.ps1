using namespace System.Collections.Generic
$lava = get-content .\day13\input.txt
[System.Collections.Generic.list[string[]]]$lavafloors = @()

[list[string]]$lf = @()
for($i = 0; $i -lt $lava.count; $i++) {

    if ($i -eq $lava.count-1) {
        $lf.add($lava[$i])
        $lavafloors.add($lf)
    }
    if ([string]::IsNullOrEmpty($lava[$i])) {
        $lavafloors.add($lf)
        $lf.clear()
        continue
    }

    $lf.add($lava[$i])

}


[list[string[]]]$lavafloorsvertical = @()


#called transpose? 
foreach ($floor in $lavafloors) {
    [list[string]]$verticallines = @()

    for ($x=0;$x -lt $floor[0].Length;$x++) {
        $vertical = ''
        for ($y=0;$y -lt $floor.count; $y++) {
            $vertical += $floor[$y][$x]
        }
        $verticallines.add($vertical)
    }
    $lavafloorsvertical.add($verticallines)
    $verticallines.clear()
}

function walk-lines {
    [CmdletBinding()]
    param(
    [list[string]]$area,
    [switch]$horizontal,
    [switch]$totalreflection
    )

    [list[int[]]]$lines = @()
    for ($i = 0; $i -lt $area.count;$i++) {

        if ($area[$i] -eq $area[$i+1]) {
            $lines.add(@($i,$($i+1)))
        }
    }
    write-verbose "Found $($lines.count)"

    [list[pscustomobject]]$firsts = @()

    foreach ($line in $lines) {
    $pairs = 0
    $max = [math]::abs(0-$line[0])+1
    $low = [math]::abs($line[1] - $area.count)
    $up = $line[0]
    $down = $line[1]

    while($true) {

        if ($up -lt 0) {
            break
        }
        if ($down -gt $area.count) {
            break
        }
        if ($area[$up] -eq $area[$down]) {
            $pairs++
        }

        $up--
        $down++

    }
    
#    if ($pairs -gt 1) {
    #to find total reflections.
   #if ($pairs -eq $max -or $pairs -eq $low) {

        $firsts.add([pscustomobject]@{
            pairs = $pairs
            sum = & {if ($horizontal) {([math]::abs(0-$line[0])+1)*100} else {[math]::abs(0-$line[0])+1} }
            lines = $line -join ','
            min = 0
            max = $area.count-1
            totalreflection = if ($pairs -eq $max -or $pairs -eq $low ) {$true} else {$false}
        })
   #} 
    }
    if ($totalreflection) {
        return $firsts | where-object totalreflection -eq $true
    }
    return $firsts
}

$sum = 0
for ($i=0;$i -lt $lavafloors.count;$i++) {
    $h = walk-lines $lavafloors[$i] -horizontal -totalreflection
    $v = walk-lines $lavafloorsvertical[$i] -totalreflection
    write-host "$i H: $($h |convertto-json -compress)" -ForegroundColor Green
    write-host "$i V: $($v |convertto-json -compress)" -ForegroundColor Yellow


    #if both exist 
    if ($v -and $h) {
        $sum += $v.sum
    }
    elseif (-not $v) {
        $sum += $h.sum
    }
    else {
        $sum += $v.sum
    }

}




function walk-linespt2 {
    [CmdletBinding()]
    param(
    [list[string]]$area,
    [switch]$horizontal,
    [switch]$totalreflection
    )
    $found1row = ''
    [list[int[]]]$lines = @()
    for ($i = 0; $i -lt $area.count-1;$i++) {

        if ($area[$i] -eq $area[$i+1]) {
            $lines.add(@($i,$($i+1)))
        }
        else {
            for ($c = 0; $c -lt $area[0].length;$c++) {
                if ($area[$i][$c] -ne $area[$i+1][$c]) {
                    $difference++
                }
            }
            if ($difference -gt 1) {
                $difference = 0
            } elseif ($difference -eq 1) {
                $lines.add(@($i,$($i+1)))
                write-verbose "Found difference at [$i,$($i+1)]"
                $found1row = "$i,$($i+1)"
            }
            else {$difference = 0}
        }
    }

    write-verbose "Found $($lines.count)"

    [list[pscustomobject]]$firsts = @()

    foreach ($line in $lines) {
    $pairs = 0
    $max = [math]::abs(0-$line[0])+1
    $low = [math]::abs($line[1] - $area.count)
    $up = $line[0]
    $down = $line[1]
    $difference = 0
    $found = $false
    while($true) {

        if ($up -lt 0) {
            break
        }
        if ($down -ge $area.count) {
            break
        }
        if ($area[$up] -eq $area[$down]) {
            $pairs++
        }
        if ($difference -eq 0 -and $found -eq $false) {
            for ($c = 0; $c -lt $area[0].length;$c++) {
                if ($area[$up][$c] -ne $area[$down][$c]) {
                    $difference++
                }
            }
            if ($difference -eq 1) {
                $pairs++
                $found = $true
            }
        }

        $up--
        $down++

    }
        if ($found -or ($line -join ',' -eq $found1row)) {
        $firsts.add([pscustomobject]@{
            pairs = $pairs
            sum = & {if ($horizontal) {([math]::abs(0-$line[0])+1)*100} else {[math]::abs(0-$line[0])+1} }
            lines = $line -join ','
            min = 0
            max = $area.count-1
            totalreflection = if ($pairs -eq $max -or $pairs -eq $low ) {$true} else {$false}
        })
    }

    }
    if ($totalreflection) {
        return $firsts | where-object totalreflection -eq $true
    }
    return $firsts
}

$sum2 = 0
for ($i=0;$i -lt $lavafloors.count;$i++) {
    $h = walk-linespt2 $lavafloors[$i] -horizontal -totalreflection #-Verbose
    $v = walk-linespt2 $lavafloorsvertical[$i] -totalreflection #-Verbose
    write-host "$i H: $($h |convertto-json -compress)" -ForegroundColor Green
    write-host "$i V: $($v |convertto-json -compress)" -ForegroundColor Yellow
    #if both exist 
    if ($v -and $h) {
        $sum2 += $v.sum
    }
    elseif (-not $v) {
        $sum2 += $h.sum
    }
    else {
        $sum2 += $v.sum
    }
}

[pscustomobject]@{
    part1 = $sum
    part2 = $sum2
}