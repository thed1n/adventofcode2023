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
    [hashtable]$specvisited = @{}
    [list[int]]$results = @()
    [list[int]]$clusters = @()
    [object[]]$lookaround = @(@(-1, 0), @(1, 0), @(0, -1), @(0, 1))
    static [stack[hashtable]]$stack = @{}
    [stack[hashtable]]$backtrackstack = @{}
    [int]$maxX
    [int]$maxY

    trail ($gridmap, $end) {
        $this.map = $gridmap
        $this.end = $end
    }
    
    traverse ($start) {
        [trail]::stack.push(
            @{
                node = $start
                cost = 0
            }
        )

        Do {
            #write-host "$([trail]::stack.Peek() | convertto-json -depth 2)"
            $pos = [trail]::stack.pop()
            Write-Verbose "$($pos.node) $($pos.cost)"
            [int]$x, [int]$y = $pos.node -split ','
            $cost = $pos.cost
            $this.visited.add("$x,$y", $cost)
            
            foreach ($dir in $this.lookaround) {
                #x new , y new
                $xn = $dir[0] + $x
                $yn = $dir[1] + $y
                if ($this.visited.ContainsKey("$xn,$yn")) { continue }
                
                if ("$xn,$yn" -eq $this.end) {
                    $this.results.add(($cost + 1))
                    return
                }
                
                switch -Regex ($this.map["$xn,$yn"]) {
                    '#' { break }
                    '<|>|\.|v' {
                        [trail]::stack.push(
                            @{
                                node = "$xn,$yn"
                                cost = $cost + 1
                            }
                        )
                    }
                    default {
                    }
                }
            }
        } While ([trail]::stack.count -gt 0)
    }

    traverse () {

        $isVisited = @{}

        while ($true) {

            if ([trail]::stack.count -eq 0) { return }
            $peek = [trail]::stack.peek()

            if ($this.map["$($peek.node)"] -eq '.') {
                #write-host 'popping .' 
                [void][trail]::stack.pop()
            } 
            elseif ($this.map["$($peek.node)"] -eq '>') {
                [int]$xt, [int]$yt = $peek.node -split ','
                $xt -= 1
                if ($this.visited.ContainsKey("$xt,$yt") -eq $false) {
                    #write-host "popping >"
                    [void][trail]::stack.pop()
                }
                else {break}
            }
            elseif ($this.map["$($peek.node)"] -eq 'v') {
                [int]$xt, [int]$yt = $peek.node -split ','
                $yt += 1
                if ($this.visited.ContainsKey("$xt,$yt") -eq $false) {
                    #write-host 'popping v'
                    [void][trail]::stack.pop()
                }
                else {break}
            }
            else {
                break
            }
        }

        $peek = [trail]::stack.peek()
        #Write-Host "$($peek.node) $($peek.cost) "

        if ($this.specvisited.ContainsKey($($peek.node))) {
            [void][trail]::stack.pop()
            return
        }
        else {
            $this.specvisited.add($($peek.node), $this.map[$($peek.node)])
        }


        Do {
            #write-host "$([trail]::stack.Peek() | convertto-json -depth 2)"
            $pos = [trail]::stack.pop()
            #Write-host "$($pos.node) $($pos.cost)"
            [int]$x, [int]$y = $pos.node -split ','


            $cost = $pos.cost
            try { $this.visited.add("$x,$y", $cost) } catch {}
            $isVisited.add("$x,$y", $cost)
            
            foreach ($dir in $this.lookaround) {
                #x new , y new
                $xn = $dir[0] + $x
                $yn = $dir[1] + $y
                if ($isVisited.ContainsKey("$xn,$yn")) { continue }
                
                if ("$xn,$yn" -eq $this.end) {
                    $this.results.add(($cost + 1))
                    #$this.draw($isVisited)
                    return
                }
                
                switch -Regex ($this.map["$xn,$yn"]) {
                    '#' { break }
                    '<|>|\.|v' {
                        [trail]::stack.push(
                            @{
                                node = "$xn,$yn"
                                cost = $cost + 1
                            }
                        )
                    }
                    default {
                    }
                }
            }

        } While ([trail]::stack.count -gt 0)

    }

    traverseall () {
        # Do{
        #     $s = [trail]::stack.pop()
        #     $this.backtrackstack.push($s)
        # }  While ([trail]::stack.count -gt 0) 
        
        # do {
        #     $s = $this.backtrackstack.pop()
        # [trail]::stack.push($s)
        # } while ($this.backtrackstack.count -gt 0)

        Do {
            $this.traverse()
        }  While ([trail]::stack.count -gt 0) 
    }
    draw($maxx, $maxy) {
        for ($y = 0; $y -lt $maxy; $y++) {
            for ($x = 0; $x -lt $maxx; $x++) {
                if ($this.visited.ContainsKey("$x,$y")) {
                    Write-Host "0" -NoNewline -ForegroundColor 'RED'
                }
                else {
                    Write-Host $this.map["$x,$y"] -NoNewline
                }
            }
            Write-Host
        }
    }
    draw([hashtable]$visited) {
        for ($y = 0; $y -lt $this.maxy; $y++) {
            for ($x = 0; $x -lt $this.maxx; $x++) {
                if ($visited.ContainsKey("$x,$y")) {
                    Write-Host "0" -NoNewline -ForegroundColor Green
                }
                elseif ($this.visited.ContainsKey("$x,$y")) {
                    Write-Host "0" -NoNewline -ForegroundColor Red
                }
                else {
                    Write-Host $this.map["$x,$y"] -NoNewline
                }
            }
            Write-Host
        }
        Write-Host
        Write-Host
    }

}


$trail = [trail]::new($gridmap, $end)
$trail.maxX = $map[0].Length
$trail.maxY = $map.count
$trail.traverse($start)
#$trail.traverse()
$trail.traverseall()

$trail.draw($map.count, $map[0].Length)

$trail.results | Sort-Object | Select-Object -Last 1

[trail]::stack
$trail.backtrackstack