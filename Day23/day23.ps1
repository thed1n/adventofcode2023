using namespace System.Collections.Generic
$map = Get-Content .\day23\input.txt

$gridmap = [ordered]@{}
$start = ''
$end = ''
for ($y = 0; $y -lt $map.count; $y++) {
    for ($x = 0; $x -lt $map[0].length; $x++) {
        if ($y -eq 0 -and $map[$y][$x] -eq '.') { $start = "$x,$y" }
        if ($y -eq $map.count - 1 -and $map[$y][$x] -eq '.') { $end = "$x,$y" }
        $gridmap.add("$x,$y", $map[$y][$x])
    }
}

class trail {
    [ordered]$map
    [string]$start
    [string]$end
    [hashtable]$visited = @{}
    [list[int]]$results = @()
    [list[int]]$clusters = @()
    [object[]]$lookaround = @(@(-1, 0), @(1, 0), @(0, -1), @(0, 1))
    static [stack[hashtable]]$stack = @{}

    trail ($gridmap, $end) {
        $this.map = $gridmap
        $this.end = $end
    }
    
    traverse ($start) {
        [trail]::stack.push(
            @{
                node   = $start
                cost = 0
            }
            )

        Do {
            #write-host "$([trail]::stack.Peek() | convertto-json -depth 2)"
            $pos = [trail]::stack.pop()
            write-verbose "$($pos.node) $($pos.cost)"
            [int]$x, [int]$y = $pos.node -split ','
            $cost = $pos.cost
            $this.visited.add("$x,$y",$cost)
            
            $found = 0
            foreach ($dir in $this.lookaround) {
                #x new , y new
                $xn = $dir[0] + $x
                $yn = $dir[1] + $y
                if ($this.visited.ContainsKey("$xn,$yn")) { continue }
                
                if ("$xn,$yn" -eq $this.end) {
                    $this.results.add(($cost+1))
                    return
                }
                
                switch ($this.map["$xn,$yn"]) {
                    '#' { break }
                    '.' {
                        [trail]::stack.push(
                            @{
                                node = "$xn,$yn"
                                cost = $cost+1
                            }
                            )
                            $found++
                    }
                    '>' {
                        if ($xn -gt $x) {
                            [trail]::stack.push(
                                @{
                                    node = "$xn,$yn"
                                    cost = $cost+1
                                }
                                )
                            $found++
                        }
                        
                    }
                    '<' {
                        if ($xn -lt $x) {
                            [trail]::stack.push(
                                @{
                                    node = "$xn,$yn"
                                    cost = $cost+1
                                }
                                )
                            $found++
                        }
                    }
                    'v' {
                        if ($yn -gt $y) {
                            [trail]::stack.push(
                                @{
                                    node = "$xn,$yn"
                                    cost = $cost+1
                                }
                                )
                            $found++
                        }
                    }
                    default {}
                }
            }
            if ($found -gt 1) {
                $this.clusters.add($cost)
            }

        } While ([trail]::stack.count -gt 0)
    }

    traverse () {

        $isVisited = @{}
        while ($true) {
            if ([trail]::stack.count -eq 0) {return}
        $peek = [trail]::stack.peek()
        if ($this.map["$($peek.node)"] -eq '.') {
            [void][trail]::stack.pop()
        } else {
            break
        }
        }
        Do {
            #write-host "$([trail]::stack.Peek() | convertto-json -depth 2)"
            $pos = [trail]::stack.pop()
            write-verbose "$($pos.node) $($pos.cost)"
            [int]$x, [int]$y = $pos.node -split ','


            $cost = $pos.cost
            try {$this.visited.add("$x,$y",$cost)} catch {}
            $isVisited.add("$x,$y",$cost)
            
            $found = 0
            foreach ($dir in $this.lookaround) {
                #x new , y new
                $xn = $dir[0] + $x
                $yn = $dir[1] + $y
                if ($isVisited.ContainsKey("$xn,$yn")) { continue }
                
                if ("$xn,$yn" -eq $this.end) {
                    $this.results.add(($cost+1))
                    return
                }
                
                switch ($this.map["$xn,$yn"]) {
                    '#' { break }
                    '.' {
                        [trail]::stack.push(
                            @{
                                node = "$xn,$yn"
                                cost = $cost+1
                            }
                            )
                            $found++
                    }
                    '>' {
                        if ($xn -gt $x) {
                            [trail]::stack.push(
                                @{
                                    node = "$xn,$yn"
                                    cost = $cost+1
                                }
                                )
                            $found++
                        }
                    }
                    '<' {
                        if ($xn -lt $x) {
                            [trail]::stack.push(
                                @{
                                    node = "$xn,$yn"
                                    cost = $cost+1
                                }
                                )
                            $found++
                        }
                    }
                    'v' {
                        if ($yn -gt $y) {
                            [trail]::stack.push(
                                @{
                                    node = "$xn,$yn"
                                    cost = $cost+1
                                }
                                )
                            $found++
                        }

                    }
                    default {}
                }
            }
            if ($found -gt 1) {
                $this.clusters.add($cost)
            }

        } While ([trail]::stack.count -gt 0)

    }

    traverseall () {
        Do{
            $this.traverse()
        }  While ([trail]::stack.count -gt 0) 
    }
    draw($maxx,$maxy) {
        for ($y = 0; $y -lt $maxy; $y++) {
            for ($x = 0; $x -lt $maxx; $x++) {
                if ($this.visited.ContainsKey("$x,$y")) {
                    write-host "0" -NoNewline -ForegroundColor 'RED'
                }
                else {
                write-host $this.map["$x,$y"] -NoNewline
                }
            }
            write-host
        }
    }

}


$trail = [trail]::new($gridmap,$end)

$trail.traverse($start)
$trail.traverseall()

$trail.draw($map.count,$map[0].Length)

$trail.results | sort | select -last 1