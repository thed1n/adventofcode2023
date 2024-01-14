using namespace System.Collections.Generic
<#
$lava = @'
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#

...#.###...
###.##.##.#
#...#.##.#.
.####..####
##..###.#..
.#.#..#.#.#
#....####.#
#....####.#
.#.#..#.#.#
##..###.#..
.####..#.##
#...#.##.#.
###.##.##.#
...#.###...
...#.###...
'@ -split '\r?\n'
#>

$lava = get-content .\day13\input.txt
[System.Collections.Generic.list[string[]]]$lavafloors = @()
[hashset[string]]$visitedlines = @{}
[list[string]]$lf = @()
for($i = 0; $i -lt $lava.count; $i++) {

    if ($i -eq $lava.count-1) {
        $lf.add($lava[$i])
        $lavafloors.add($lf)
    }
    if ([string]::IsNullOrEmpty($lava[$i])) {
        #$lf.add($lava[$i+1])
        $lavafloors.add($lf)
        $lf.clear()
        continue
    }

    $lf.add($lava[$i])

}


[list[string[]]]$lavafloorsvertical = @()



foreach ($floor in $lavafloors) {
    [list[string]]$verticallines = @()

    for ($x=0;$x -lt $floor[0].Length;$x++) {
        $vertical = ''
        for ($y=0;$y -lt $floor.count; $y++) {
            $vertical += $floor[$y][$x]
            #write-host $($floor[$y][$x])
        }
        #write-host $vertical
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
        [void]$visitedlines.add("v,$i,$($v.lines)")
    }
    elseif (-not $v) {
        $sum += $h.sum
        [void]$visitedlines.add("h,$i,$($h.lines)")
    }
    else {
        $sum += $v.sum
        [void]$visitedlines.add("v,$i,$($v.lines)")
    }
    # if ($h.pairs -gt $v.pairs) {
    #     $sum+= $h.sum
    # } else {$sum += $v.sum}
}
$sum


function find-smudge {
    [CmdletBinding()]
    param(
        [list[string]]$area,
        [string]$lines,
        [switch]$total,
        [switch]$vertical
    )

    if ($PSBoundParameters.ContainsKey('lines')){

        [int]$up,[int]$down = $lines -split ','

        $found = 0
        while ($true) {
        #for ($r=0;$r -lt $area.count;$r++) {
            $difference = 0
            for ($c = 0; $c -lt $area[0].length;$c++) {
    
                if ($area[$up][$c] -ne $area[$down][$c]) {
                    $difference++
                    $found = $c
                }
            }
    
            if ($difference -eq 1) {
                write-verbose "found on $up position $found"
                $tmp = $area[$up] -as [char[]]
                $tmp[$found] = $area[$down][$found]
                $area[$up] = $tmp -join ''
                
                #$area[$down][$found]
                if ($vertical) {
                    $reflection =  walk-lines $area -totalreflection
                } else {
                    $reflection =  walk-lines $area -horizontal -totalreflection
                }
                if ($reflection) {
                    return $reflection
                }
                #break
            }
            $up--
            $down++
            if ($down -ge $area.count -or $up -lt 0) {
                break
            }
        }

    }

    else {

    #check closes rows
    $found = 0
    $row = 0
    for ($r=0;$r -lt $area.count;$r++) {
        $difference = 0
        for ($c = 0; $c -lt $area[0].length;$c++) {

            if ($r -ge $area.count-1) {
                break
            }
            
            if ($area[$r][$c] -ne $area[$r+1][$c]) {
                $difference++
                $found = $c
                $row = $r
            }
        }

        if ($difference -eq 1) {
            if ($total) {
                write-verbose "found on $row position $found"
                $tmp = $area[$row+1] -as [char[]]
                $tmp[$found] = $area[$row][$found]
                $area[$row+1] = $tmp -join ''
            }
            else {
                $tmp = $area[$row] -as [char[]]
                $tmp[$found] = $area[$row+1][$found]
                $area[$row] = $tmp -join ''
            }
            #$area
            if ($vertical) {
                $reflection =  walk-lines $area -totalreflection
            } else {
                $reflection =  walk-lines $area -horizontal -totalreflection
            }
            if ($reflection) {
                return $reflection
            }
        }
    }

    }


}

$pt2sum = 0
for ($i=0;$i -lt $lavafloors.count;$i++) {
    $vert = $false
    try {Clear-Variable first -ErrorAction SilentlyContinue} catch {}
    $first = find-smudge $lavafloors[$i] -total

    if (!$first) {
        $h = walk-lines $lavafloors[$i] -horizontal
        :outer while ($true) {
            foreach($res in $h) {
                $first = find-smudge $lavafloors[$i] -lines $res.lines -total
                if ($first.totalreflection -eq $true -and !$visitedlines.contains("v,$i,$($first.lines)")) {
                    #$vert = $true
                    break outer 
                }
            }
            break
        }
    }
    if ($first) {
        #if multiple results
        foreach ($f in $first) {
            if (!$visitedlines.contains("h,$i,$($f.lines)")) {
            write-host "$i H: $($f |convertto-json -compress)" -ForegroundColor Green
            $pt2sum +=  $f.sum
            $vert = $true
            }
        }
    }

    if (!$vert) {

        try {Clear-Variable first -ErrorAction SilentlyContinue} catch {}
        $first = find-smudge $lavafloorsvertical[$i] -total -vertical

        if(!$first) {
            $v = walk-lines $lavafloorsvertical[$i]
    
            :outer while ($true) {
                foreach($res in $v) {
                    $first = find-smudge $lavafloorsvertical[$i] -lines $res.lines -vertical -total
                    if ($first.totalreflection -eq $true) {
                        break outer
                    }
                }
                break
            }
        }

        if ($first) {
            foreach ($f in $first) {
            if (!$visitedlines.contains("v,$i,$($f.lines)")){
            write-host "$i V: $($f |convertto-json -compress)" -ForegroundColor Yellow
            $pt2sum +=  $f.sum
        }
    }
    }
}
    
}

[pscustomobject]@{
part1 = $sum
part2 = $pt2sum
}