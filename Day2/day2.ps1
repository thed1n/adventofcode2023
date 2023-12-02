$data = Get-Content .\input.txt

$limits = [ordered]@{
    red   = 12
    green = 13
    blue  = 14
}
[system.collections.generic.list[pscustomobject]]$part2result = @()
$sumofids = $data | ForEach-Object {
    $part2 = [ordered]@{
        gameid = 0
        red    = 0
        green  = 0
        blue   = 0
    }
    [int]$gameid = $_ -replace 'Game (\d+):.+', '$1'
    $result = [PSCustomObject]@{
        Game   = $gameid
        Result = $true
    }
    $part2['gameid'] = $gameid
    $_ -replace 'Game .+?: (.+)', '$1' -split ';' -replace '^\s+|\s+$' | ForEach-Object {
        $_ -split ',' -replace '^\s+|\s+$' | ForEach-Object {
            [int]$amount, $color = $_ -split ' '
            if ($part2[$color] -lt $amount) { $part2[$color] = $amount }
            if ($amount -gt $limits[$color]) {
                $result.result = $false
            }
        }
    }
    $result
    $part2['pow'] = $part2['red'] * $part2['green'] * $part2['blue']
    $part2result.add([pscustomobject]$part2)
}

[pscustomobject]@{
    Part1 = [int]$($sumofids | Where-Object result -EQ $true | Select-Object -expand game | Measure-Object -Sum | ForEach-Object sum)
    Part2 = [int]$($part2result.pow | Measure-Object -Sum | ForEach-Object sum)
}