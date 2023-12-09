using namespace System.Collections.Generic
$sequences = [list[int[]]]::new()
Get-Content .\Day9\input.txt | ForEach-Object {
    $ints = $_ -split ' '
    $sequences.add($ints)
}

[stack[int[]]]$stack = @()

$sum = 0
$sum2 = 0
for ($arr = 0; $arr -lt $sequences.count; $arr++) {

    [Dictionary[int, list[int]]]$workingsequence = @{}
    $stack.push($sequences[$arr])
    $reducenumber = 0
    $workingsequence.add($reducenumber, $sequences[$arr])

    while (($stack | ForEach-Object { $_ } | Measure-Object -Sum | ForEach-Object sum) -ne 0) {
        $currentsequence = $stack.pop()
        
        $reduce = for ($i = 0; $i -lt ($currentsequence.count - 1); $i++) {
            $currentsequence[($i + 1)] - $currentsequence[$i]
        }
        $reducenumber++
        $workingsequence.add($reducenumber, $reduce)
        $stack.push($reduce)
    }
    $stack.Clear()

    $workingsequence.keys | Sort-Object -Descending | ForEach-Object {
        $key = $_
        if ($workingsequence.containskey($key + 1)) {
            $scale = $workingsequence[($key + 1)][-1] + $workingsequence[$key][-1]
            $workingsequence[$key].add($scale)

            $downwardscale = $workingsequence[$key][0] - $workingsequence[($key + 1)][0]
            $workingsequence[$key].Insert(0,$downwardscale)
        }
        else {
            $workingsequence[$key].add(0)
            $workingsequence[$key].Insert(0,0)
        }
    }

    $sum+=$workingsequence[0][-1]
    $sum2+=$workingsequence[0][0]
}

[pscustomobject]@{
    Part1 = $sum
    Part2 = $sum2
}