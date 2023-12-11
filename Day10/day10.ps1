using namespace System.Collections.Generic
<#
| is a vertical pipe connecting north and south.
- is a horizontal pipe connecting east and west.
L is a 90-degree bend connecting north and east.
J is a 90-degree bend connecting north and west.
7 is a 90-degree bend connecting south and west.
F is a 90-degree bend connecting south and east.
. is ground; there is no pipe in this tile.
S is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.
#>

$sewersystem = Get-Content .\Day10\input.txt

function get-possibleneigh {
    param (
        [int]$x,
        [int]$y,
        [string]$pipe
    )
    $ErrorActionPreference = 2
    $nodes = @()
    #write-host $PSBoundParameters
    switch ($pipe) {
        '|' {
            $nodes += "$x,$($y+1)"
            $nodes += "$x,$($y-1)"
        }
        '-' {
            $nodes += "$($x-1),$y"
            $nodes += "$($x+1),$y"
        }
        'L' {
            $nodes += "$x,$($y-1)"
            $nodes += "$($x+1),$y"
        }
        'J' {
            $nodes += "$x,$($y-1)"
            $nodes += "$($x-1),$y"
        }
        '7' {
            $nodes += "$x,$($y+1)"
            $nodes += "$($x-1),$y"
        }
        'F' {
            $nodes += "$x,$($y+1)"
            $nodes += "$($x+1),$y"
        }
        'S' {
            #nord
            if ([string]$sewersystem[$($y - 1)][$x] -in '|', '7', 'F', 'S') {
                $nodes += "$x,$($y-1)"
            }
            #syd
            if ([string]$sewersystem[$($y + 1)][$x] -in '|', 'L', 'J', 'S') {
                $nodes += "$x,$($y+1)"
            }
            #Väst
            if ([string]$sewersystem[$y][$($x - 1)] -in 'L', 'F', '-', 'S') {
                $nodes += "$($x-1),$y"
            }
            #Öst
            if ([string]$sewersystem[$y][$($x + 1)] -in '-', '7', 'J', 'S') {
                $nodes += "$($x+1),$y"
            }
        }
    }
    $ErrorActionPreference = 2
    return $nodes
}

$sewer = [ordered]@{}
$start = ''

for ($y = 0; $y -lt $sewersystem.count; $y++) {

    for ($x = 0; $x -lt $sewersystem[0].Length; $x++) {
        if ([string]$sewersystem[$y][$x] -eq 'S') {
            $start = "$x,$y"
        }
        if ([string]$sewersystem[$y][$x] -eq '.') { continue }
        $nodes = get-possibleneigh -x $x -y $y -pipe $([string]$sewersystem[$y][$x])
        $sewer.add("$x,$y", @{
                neigh = $nodes | Where-Object { $_ -notmatch '\-1|141' }
                pipe  = [string]$sewersystem[$y][$x]
            })
    }

}


[queue[hashtable]]$queue = @{}

[hashset[string]]$visited = @{}
$result = [ordered]@{}

$result.add($start, @{
        Parent = $null
        Cost   = 0
    })

$i = 1
[void]$visited.add($start)

foreach ($v in $sewer[$start].neigh) {
    if (-not $visited.Contains($v)) {
    
        $queue.Enqueue(
            @{
                Parent = $start
                To     = $v
                Cost   = $i
            }
        )
    }
}

Do {
    $dequeue = $queue.Dequeue()
    $start = $dequeue.To
    [void]$visited.add($start)

    If (-not $result[$start]) {
        $result.add($start, @{
                Parent = $dequeue.Parent
                Cost   = $dequeue.Cost
            })
    }
    
    foreach ($v in $sewer[$start].neigh) {

        if (-not $visited.Contains($v)) {
            $queue.Enqueue(
                @{
                    Parent = $start
                    To     = $v
                    Cost   = $dequeue.Cost + 1
                })
        }
    }
    

} while ($queue.count -ne 0)

$cost = 0
$last = ''
$result.keys | ForEach-Object { 
    if ( $result[$_].cost -gt $cost) {
        $cost = $result[$_].cost
        $last = $_
    }
}


$cost