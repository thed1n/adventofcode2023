using namespace System.Collections.Generic
$map = Get-Content .\day23\input.txt

[object[]]$lookaround = @(@(-1, 0), @(1, 0), @(0, -1), @(0, 1))

$grid = [ordered]@{}
$nodes = @{}
$points = [ordered]@{}
[hashset[string]]$visited = @{}
[queue[hashtable]]$queue = @()

for ($y = 0; $y -lt $map.count; $y++) {
    for ($x = 0; $x -lt $map[0].length; $x++) {
        if ($y -eq 0 -and $map[$y][$x] -eq '.') { $start = "$x,$y" }
        if ($y -eq $map.count - 1 -and $map[$y][$x] -eq '.') { $end = "$x,$y" }
        switch ($map[$y][$x]) {
            '#' { $grid.add("$x,$y", '#') }
            default { $grid.add("$x,$y", '.') }
        }
    }
}

$queue.enqueue( @{
        node        = $start
        parent      = $null
        cost        = 0
        currentnode = $start
    })
[void]$visited.add($start)
$points.add($start,$null)

Do {
    [list[object]]$neigh = @()

    $obj = $queue.dequeue()
    [int]$x, [int]$y = $obj.node -split ','
    $cost = $obj.Cost
    $currentnode = $obj.currentnode

    foreach ($dir in $lookaround) {
        $xn = $x + $dir[0]
        $yn = $y + $dir[1]

        if ($grid["$xn,$yn"] -eq '#' -or $xn -lt 0 -or $yn -lt 0 -or $visited.Contains("$xn,$yn")) {
            continue
        }

        if ($grid["$xn,$yn"] -eq '.') {
            $neigh.add(@{
                    node   = "$xn,$yn"
                    parent = $currentnode
                    cost   = $cost + 1
                })
        }
    }

    [void]$visited.add("$x,$y")

    if ($neigh.count -ge 2 -or "$x,$y" -eq $end) {
        #Write-Host "Found two neighbours at '$x,$y' with parent $currentnode"
        $points.add("$x,$y",$null)
        $currentnode = "$x,$y"

        foreach ($n in $neigh) {
            $queue.Enqueue(@{
                    node        = $n.node
                    parent      = "$x,$y"
                    cost        = $n.cost
                    neigh       = $null
                    currentnode = $currentnode
                })
        }
    } else {
        foreach ($n in $neigh) {
            $queue.Enqueue(@{
                    node        = $n.node
                    parent      = "$x,$y"
                    cost        = $n.cost
                    neigh       = $null
                    currentnode = $currentnode
                })
        }
    }

} while ($queue.count -ne 0)


#Find all cluster and cost to nodes
foreach ($key in $points.keys) {
    $visited.clear()

    $queue.enqueue( @{
        node        = $key
        parent      = $null
        cost        = 0
        currentnode = $key
    })
[void]$visited.add($key)

    Do {
        [list[object]]$neigh = @()

        $obj = $queue.dequeue()
        [int]$x, [int]$y = $obj.node -split ','
        $cost = $obj.Cost
        $currentnode = $obj.currentnode

        if ($currentnode -ne $key) {
            continue
        }

        foreach ($dir in $lookaround) {
            $xn = $x + $dir[0]
            $yn = $y + $dir[1]

            if ($grid["$xn,$yn"] -eq '#' -or $xn -lt 0 -or $yn -lt 0 -or $visited.Contains("$xn,$yn")) {
                continue
        }

        if ($grid["$xn,$yn"] -eq '.') {
            $neigh.add(@{
                    node   = "$xn,$yn"
                    parent = $currentnode
                    cost   = $cost + 1
                })
        }
    }

    [void]$visited.add("$x,$y")

    if (($neigh.count -ge 2 -or "$x,$y" -eq $end) -and "$x,$y" -ne $key) {
       # Write-Host "Found two neighbours at '$x,$y' with parent $currentnode"

        if ($nodes.ContainsKey($currentnode)) {
            if ("$x,$y" -notin $nodes[$currentnode].node) {
                $nodes[$currentnode].add(
                    [pscustomobject]@{
                        node = "$x,$y"
                        cost = $cost
                    }
                )
            }
        } else {
            $nodes.add($currentnode, [list[pscustomobject]]@(
                [pscustomobject]@{
                    node = "$x,$y"
                    cost = $cost
            }))
        }
        if ($nodes.ContainsKey("$x,$y")) {
            if ($currentnode -notin $nodes["$x,$y"].node) {
            $nodes["$x,$y"].add(
                [pscustomobject]@{
                    node = $currentnode
                    cost = $cost
                }
            )
            }
        } else {
            $nodes.add("$x,$y", [list[pscustomobject]]@(
                [pscustomobject]@{
                    node = $currentnode
                    cost = $cost
            }))
        }

        $currentnode = "$x,$y"

        foreach ($n in $neigh) {
            $queue.Enqueue(@{
                    node        = $n.node
                    parent      = "$x,$y"
                    cost        = $n.cost
                    neigh       = $null
                    currentnode = $currentnode
                })
        }
    } else {
        foreach ($n in $neigh) {
            $queue.Enqueue(@{
                    node        = $n.node
                    parent      = "$x,$y"
                    cost        = $n.cost
                    neigh       = $null
                    currentnode = $currentnode
                })
        }
    }

} while ($queue.count -ne 0)

}

#find all paths
[list[string]]$results = @()
[list[int]]$resint = @()

[stack[hashtable]]$stack = @()

$stack.push(
    @{
        node = $start
        cost = 0
        path = $start
        parent = $start
        visited = [hashset[string]]$start
    }
    )

do {

    $currentitem = $stack.pop()
    

    foreach ($n in $nodes[$currentitem.node]) {

        if ($currentitem.visited.contains($n.node)) {
            #write-host "found $($n.node)"
            continue
        }

        if ($n.node -eq $end) {
            #write-host "found end"
            # write-host ""$($currentitem.path) -> $($n.node)""
            $results.add("$($currentitem.path) -> $($n.node)")
            $resint.add($($currentitem.cost + $n.cost))
            #$($currentitem.cost + $n.cost)
            continue
        }
        [void]$currentitem.visited.add($currentitem.node)
        $stack.Push(
            @{
                node = $n.node
                path = "$($currentitem.path) -> $($n.node)"
                cost = $currentitem.cost + $n.cost
                parent = $currentitem.node
                visited = [hashset[string]]::new($currentitem.visited)
            }
        )
        #write-host ""$($currentitem.path) -> $($n.node)""
        #write-host $($stack.peek()|convertto-json -depth 3)
    }

} while ($stack.count -ne 0)

$resint | sort | select -last 1