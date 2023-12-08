$nodedata = get-content .\Day8\input.txt

class matte {
    [int64] static lcm ([int64]$a,[int64]$b) {
        return ([math]::abs($a)*[math]::abs($b)) / [bigint]::GreatestCommonDivisor($a,$b)
    }
}

$instructions = [char[]]$nodedata[0] | % {[string]$_}

$nodes = @{}
$childtoparent= @{}
foreach ($node in $nodedata[2..($nodedata.count-1)]) {
    $parent,$children = $node -split ' = ' -replace '\(|\)','' -replace '\s+',''
    $childs = $children -split ','

    $nodes.add($parent,$childs)
    $childs|%{
        if ($childtoparent.ContainsKey($_)) {
            if ($parent -notin ($childtoparent[$_])) {
                $childtoparent[$_] += $parent
            }
    }
        $childtoparent[$_] = @($parent)
    }
}

$start = 'AAA'
$steps = 0
$found = $false
while ($found -eq $false) {

$currentnode = $nodes[$start]

    foreach ($move in $instructions) {

        if ($move -eq 'L') {
            $start = $nodes[$start][0]
        }
        else {
            $start = $nodes[$start][1]
        }
        $steps++
        if ($start -eq 'ZZZ') {
            $found = $true
        }
    }
}

#part2
$startnodes = $nodes.keys | % { if($_ -match 'A$') {$_}}
$childnodes = $childtoparent.keys | % { if($_ -match 'Z$') {$_}}

class nodes {
    [string]$start
    [int]$steps = 0
    [int]$inst = 0
    [int[]]$found = @()
    static [string[]]$instructions
    static [hashtable]$nodes

    nodes ([string]$startnode) {
        $this.start = $startnode
    }

    [void] move() {
        while ($this.found.count -lt 1) {
        $currentstart = $this.start
        $move = [nodes]::instructions[$this.inst]
        if ($this.inst -eq [nodes]::instructions.count-1) {
            $this.inst = 0
        } else {$this.inst++}
        #write-host "moving [$move] ; from [$currentstart]"
            if ($move -eq 'L') {
                $this.start = [nodes]::nodes[$currentstart][0]
            }
            else {
                $this.start = [nodes]::nodes[$currentstart][1]
            }
            $this.steps++
            if ($this.start -match 'Z$') {

                $this.found += @($this.steps)
            }
        }
        }

}
[nodes]::instructions = $instructions
[nodes]::nodes = $nodes

$pt2nodes = foreach ($sn in $startnodes) {
    [nodes]::new($sn)
}
for ($i=0; $i-lt $pt2nodes.count; $i++) {
    $pt2nodes[$i].move()
}

$firstlcm = $pt2nodes[0].found[-1]
for ($i=1; $i-lt $pt2nodes.count; $i++) {
    $firstlcm = [matte]::lcm($firstlcm,$pt2nodes[$i].found[-1])
}


[PSCustomObject]@{
    part1 = $steps
    part2 = $firstlcm
}