using namespace System.Collections.Generic
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
'@ -split '\r?\n'

$lava = get-content .\desktop\input.txt
[System.Collections.Generic.list[string[]]]$lavafloors = @()

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

# $lavafloors[0] | group
# $lavafloors[1] | group

# $lavafloorsvertical[0] | group
# $lavafloorsvertical[1] | group

function walk-lines {
    param(
    [list[string]]$area,
    [switch]$horizontal
    )

    [list[int[]]]$lines = @()
    for ($i = 0; $i -lt $area.count;$i++) {

        if ($area[$i] -eq $area[$i+1]) {
            $lines.add(@($i,$($i+1)))
        }
    }
    write-host "Found $($lines.count)"
  
    [list[pscustomobject]]$results = @()

    foreach ($line in $lines) {
    $pairs = 0

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
       
    if ($pairs -gt 1) {
        $results.add([pscustomobject]@{
            pairs = $pairs
            sum = & {if ($horizontal) {([math]::abs(0-$line[0])+1)*100} else {[math]::abs(0-$line[0])+1} }
            lines = $line -join ','
            min = 0
            max = $area.count-1
            
        })
    } 
    }

    return $results | sort pairs | select -last 1
}

$sum = 0
for ($i=0;$i -lt $lavafloors.count;$i++) {
    $h = walk-lines $lavafloors[$i] -horizontal
    $v = walk-lines $lavafloorsvertical[$i]
    write-host "$i H: $($h |convertto-json -compress)" -ForegroundColor Green
    write-host "$i V: $($v |convertto-json -compress)" -ForegroundColor Yellow

    if ($h.pairs -gt $v.pairs) {
        $sum+= $h.sum
    } else {$sum += $v.sum}
}
$sum
