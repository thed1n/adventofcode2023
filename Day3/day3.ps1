using namespace system.collections.generic
$data = Get-Content .\Day3\input.txt

function check-grid {
    
    param(
        [string]$x,
        [string]$y,
        [switch]$gear
    )

    begin { $visited = [hashset[string]]@{} }
    process {
        $xvector = @(
            [int]$x - 1
            [int]$x
            [int]$x + 1
        )
        $yvector = @(
            [int]$y - 1    
            [int]$y
            [int]$y + 1
        )

        foreach ($yv in $yvector) {

            foreach ($xv in $xvector) {
                if ($grid.contains("$xv,$yv")) {
                    [void]$visited.add($grid["$xv,$yv"])
                }
            }

        }
        if ($gear) {
            if ($visited.count -eq 2) {
                return $visited
            }
            else {
                return
            }
        }
        return $visited

    }
}
$special = @{}

$grid = [ordered]@{}

for ($y = 0; $y -lt $data.count; $y++) {

    for ($x = 0; $x -lt $data.Length; $x++) {
        if ($data[$y][$x] -eq '.') { continue }
        $numstring = ''
        [list[object]]$tmpgrid = @()
        while ($data[$y][$x] -match '\d') {
            $tmpgrid.add(@($x, $y))
            $numstring += $data[$y][$x]
            $x++
        }
        if ($tmpgrid.count -ge 1) {
            foreach ($cord in $tmpgrid) {
                $grid[($cord -join ',')] = $numstring
            }
        }
        if ($data[$y][$x] -match '\#|\$|\%|\&|\*|\+|\-|\/|\=|\@') {
            if ($special.ContainsKey($data[$y][$x]) -eq $false) {
                $special[$data[$y][$x]] = [list[object]]@()
            }
            $special[$data[$y][$x]].add(@($x, $y))
        }
    }

}

$sum = 0
$special.Keys | ForEach-Object {

    $special[$_] | ForEach-Object {
        $x, $y = $_
        check-grid -x $x -y $y | ForEach-Object {
            $sum += $_
        }
    }
}

$gearcheck = 0
$special[[char]'*'] | ForEach-Object {
    $x, $y = $_
    [int]$gear1, [int]$gear2 = check-grid -x $x -y $y -gear
    $gearcheck += $gear1 * $gear2
}

[pscustomobject]@{
    part1 = $sum
    part2 = $gearcheck
}