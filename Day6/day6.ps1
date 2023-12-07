using namespace System.Collections.Generic
$data = Get-Content .\Day6\input.txt

$raceinfo = @{}
$race2 = @{}
$data | ForEach-Object {
    $label, $times = $_ -split ':'
    [int[]]$timesint = $times.trim() -split '\s+'
    [int64]$race2time = $times -replace '\s+'
    $race2.add($label, $race2time)
    $raceinfo.add($label, $timesint)
}

$raceinfo = [pscustomobject]$raceinfo
$raceinfo2 = [pscustomobject]$race2

$press = 0

function get-numways {
    [cmdletbinding()]
    param(
        [int64]$time,
        [int64]$distance,
        [int64]$press,
        [switch]$first,
        [switch]$backward
    )
    begin {
        [stack[int64]]$stack = @($press)
    }
    process {
        while ($stack.count -gt 0) {
            $press = $stack.pop()
            $racetime = [math]::abs($press - $time)
            if ($press -gt $time) { return }
            Write-Verbose "Press: [$press], Racetime: [$racetime], Distance: [$distance]"
            if ($press * $racetime -gt $distance) {
                
                if ($first) {
                    return $press
                }
                else { 1 }
            }
            if ($backward) {
                $press--
                $stack.Push($press)
            }
            else {
                $press++
                $stack.Push($press)
            }
        }
    }
}

$result = for ($i = 0; $i -lt $raceinfo.time.count; $i++) {
    get-numways -time $raceinfo.time[$i] -distance $raceinfo.distance[$i] -press 0 | Measure-Object -Sum | ForEach-Object sum
}
$sum = 1
$result | ForEach-Object {
    $sum *= $_
}

$first = get-numways -time $raceinfo2.time -distance $raceinfo2.distance -press 0 -first
$last = get-numways -time $raceinfo2.time -distance $raceinfo2.distance -press $raceinfo2.time -first -backward

$sum2 = $last - $first + 1

[pscustomobject]@{
    Part1 = $sum
    Part2 = $sum2
}