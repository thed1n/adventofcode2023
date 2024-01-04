using namespace System.Collections.Generic
$platform = Get-Content .\Day14\input.txt

$grid = [ordered]@{}


for ($y=0;$y-lt$platform.count; $y++) {
    for ($x=0; $x -lt $platform[0].length;$x++) {
        $grid.add("$x,$y",[string]$platform[$y][$x])
    }
}

[PriorityQueue[string,int32]]$queue = @{}
$score = 0
#if # increase prio 2 to accomodate . and O
for ($x=0; $x -lt $platform[0].length;$x++) {
    $prio = 0
    for ($y=$platform.count-1;$y-ge 0; $y--) {
        
        switch ($grid["$x,$y"]) {
            '#' {$queue.Enqueue('#',($prio+3)); $prio+=3; break}
            '.' {$queue.Enqueue('.',($prio+1)); break}
            'O' {$queue.Enqueue('O',($prio+2)); break}
        }
    }
    #dequeue fill bottom up

    for ($y=$platform.count-1;$y-ge 0; $y--) {
        $grid["$x,$y"]= $queue.Dequeue()
        if ($grid["$x,$y"] -eq 'O') {
            $score += ($platform.count - $y)
        }
    }
    
}



#draw
for ($y=0;$y-lt$platform.count; $y++) {
    for ($x=0; $x -lt $platform[0].length;$x++) {
        write-host $grid["$x,$y"] -NoNewline
    }
    write-host
}

[pscustomobject]@{
    Part1 = $score
}