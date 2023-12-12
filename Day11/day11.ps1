using namespace System.Collections.Generic
$galaxychart = Get-Content .\Day11\input.txt

$galaxy = [list[list[string]]]::new()

for ($y = 0; $y -lt $galaxychart.count; $y++) {
    $galaxy.add(@())
    for ($x = 0; $x -lt $galaxychart[0].Length; $x++) {
        $galaxy[$y].add([string]$galaxychart[$y][$x])
    }
}

$rowv = @{}
$rowh = @{}
for ($x = 0; $x -lt $galaxychart[0].Length; $x++) {
    $nogalaxy = $true
    for ($y = 0; $y -lt $galaxychart.count; $y++) {
        if ($galaxychart[$y][$x] -eq '#') {
            $nogalaxy = $false
        }
    }

    if ($nogalaxy -eq $true) {
        $rowv["$x,$y"] = 'vertical'
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
        $rowh["$x,$y"] = 'horizontal'
    }
}

$rowh.keys | ForEach-Object {
    [int]$x, [int]$y = $_ -split ','
    $galaxy.Insert($y, [list[string]]::new())

    for ($x = 0; $x -lt $galaxychart[0].Length; $x++) {
        $galaxy[$y].Add('.')
    }
    
}

$shift = 0
$rowv.keys | ForEach-Object {
    [int]$x, [int]$y = $_ -split ','
    $x+=$shift
    for ($y = 0; $y -lt $galaxy.count; $y++) {
        $galaxy[$y].Insert($x, '.')
    }
    $shift++
    
}
#render
for ($y = 0; $y -lt $galaxy.count; $y++) {
    for ($x = 0; $x -lt $galaxy[0].count; $x++) {
        Write-Host $($galaxy[$y][$x]) -NoNewline
    }
    Write-Host
}

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

$galaxies = [ordered]@{}
$gal = 1
for ($y = 0; $y -lt $galaxy.count; $y++) {
    for ($x = 0; $x -lt $galaxy[0].count; $x++) {
        if ($galaxy[$y][$x] -eq '#') {
            $galaxies.add("$x,$y",$gal)
            $gal++
        }
    }
}
$pt1.galaxynumber = $galaxies

$galaxies.keys | % {
    $pt1.findpaths($_,$galaxies[$_])
}

# $pt1.findpaths("4,0",1)
# $pt1.tempresult.clear()
# $pt1.findpaths("62,0",2)
$pt1.sum
#$pt1.tempresult.keys | % {if ($pt1.tempresult[$_].galaxy -eq $true) {[pscustomobject]$pt1.tempresult[$_]}} | ft -autosize

# [list[string]]$paths = @()

# $curr = '10,1'
# $paths.add('10,1')

# while ($pt1.tempresult[$curr].parent) {

#     $paths.add($pt1.tempresult[$curr].parent)
#     $curr = $pt1.tempresult[$curr].parent
# }
# [array]::Reverse($paths)
# $paths -join ' -> '
# $pt1.tempresult['10,1']