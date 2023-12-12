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
$shift = 0
$rowh.keys | ForEach-Object {
    [int]$y = $_ 
    $y+=$shift
    $galaxy.Insert($y, [list[string]]::new())

    for ($x = 0; $x -lt $galaxy[0].count; $x++) {
        $galaxy[$y].Add('.')
    }
    $shift++
}

$shift = 0
$rowv.keys | ForEach-Object {
    [int]$x = $_
    $x+=$shift
    for ($y = 0; $y -lt $galaxy.count; $y++) {
        $galaxy[$y].Insert($x, '.')
    }
    $shift++
    
}

$galaxies = [ordered]@{}
[list[string]]$cords = @()
$gal = 1
for ($y = 0; $y -lt $galaxy.count; $y++) {
    for ($x = 0; $x -lt $galaxy[0].count; $x++) {
        if ($galaxy[$y][$x] -eq '#') {
            $galaxies.add("$x,$y",$gal)
            $cords.add("$x,$y")
            $gal++
        }
    }
}

#render
# for ($y = 0; $y -lt $galaxy.count; $y++) {
#     for ($x = 0; $x -lt $galaxy[0].count; $x++) {
#         Write-Host $($galaxy[$y][$x]) -NoNewline
#     }
#     Write-Host
# }

$summa = 0
for ($i = 0;$i -lt $cords.count-1;$i++) {
    for ($j = $i+1;$j -lt $cords.count;$j++) {
    $summa += [matte]::manhattan($cords[$i],$cords[($j)])
    }
}

$summa

<#
BFS Way
class galaxy {
    static [list[list[string]]]$galaxy
    static [queue[hashtable]]$queue = @{}
    #[string]$start
    [int]$sum = 0
    [hashset[string]]$pairs = @{}
    [ordered]$tempresult = @{}
    $galaxynumber = [ordered]@{}

    galaxy () {

    }

    [void] findpaths ([string]$startgalaxy,[int]$galaxynum) {

        [int]$x, [int]$y = $startgalaxy -split ','
        [hashset[string]]$visited = @{}

        $this.tempresult.add($startgalaxy, @{
                Node   = $startgalaxy
                Parent = $null
                Cost   = 0
                Galaxy = if ([galaxy]::galaxy[$y][$x] -eq '#') { $true } else { $false }
                GalaxyNumber = $galaxynum
            })
        [void]$visited.add($startgalaxy)
        
        $paths = @(@(0, 1), @(0, -1), @(1, 0), @(-1, 0))

        foreach ($p in $paths) {
            $newx = $x + $p[0]
            $newy = $y + $p[1]
            if ($newx -lt 0 -or $newx -gt ([galaxy]::galaxy[0].count-1)) { continue }
            if ($newy -lt 0 -or $newy -gt ([galaxy]::galaxy.count-1)) { continue }
            [galaxy]::queue.Enqueue(@{
                    Parent = $startgalaxy
                    To     = "$newx,$newy"
                    Cost   = 1
                })

        }


        do {

            $currentpos = [galaxy]::queue.Dequeue()
            #write-host $($currentpos | convertto-json -Compress)
            $start = $currentpos.to
            $cost = $currentpos.cost
            $parent = $currentpos.parent
            if ($visited.contains($start)) { continue }
            
            [int]$x, [int]$y = $start -split ','
            [void]$visited.add($start)
            #write-host "$x,$y"
            $this.tempresult.add($start, @{
                    Node   = $start
                    Parent = $parent
                    Cost   = $cost
                    Galaxy = if ([galaxy]::galaxy[$y][$x] -eq '#') { $true } else { $false }
                    GalaxyNumber = if ([galaxy]::galaxy[$y][$x] -eq '#') { $this.galaxynumber["$x,$y"] }
                })
            #if ([galaxy]::galaxy[$y][$x] -eq '#' -and $this.pairs.contains("$x,$y") -eq $false) {write-host "visiting $($this.galaxynumber["$x,$y"]) from $($this.galaxynumber[$startgalaxy])";$this.sum += $cost;write-host "currentsum [$($this.sum)] added [$cost]" }
            if ([galaxy]::galaxy[$y][$x] -eq '#' -and $this.pairs.contains("$x,$y") -eq $false) {$this.sum += $cost}

            foreach ($p in $paths) {
                $newx = $x + $p[0]
                $newy = $y + $p[1]
                if ($newx -lt 0 -or $newx -ge [galaxy]::galaxy[0].count) { continue }
                if ($newy -lt 0 -or $newy -gt ([galaxy]::galaxy.count-1)) { continue }
                #write-host "$newx,$newy"

                [galaxy]::queue.Enqueue(@{
                        Parent = $start
                        To     = "$newx,$newy"
                        Cost   = $cost + 1
                    })
            } 

        }   while ([galaxy]::queue.count -gt 0)
        [void]$this.pairs.add($startgalaxy)
        $this.tempresult.clear()

    }


}


$pt1 = [galaxy]::new()
[galaxy]::galaxy = $galaxy


$pt1.galaxynumber = $galaxies

$galaxies.keys | % {
    $pt1.findpaths($_,$galaxies[$_])
}

$pt1.sum
#>