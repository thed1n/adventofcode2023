using namespace System.Collections.Generic
$data = Get-Content .\Day19\input.txt

$workflows = @{}
$functiondef = [list[string]]@()
$inputdef = [list[string]]@()
$data | ForEach-Object {
    if ([string]::IsNullOrWhiteSpace($_)) {
        return
    }

    if ($_ -match '^\{') {
        $inputdef.add($_)
    } 
    else { $functiondef.add($_) }
}

$functiondef | ForEach-Object {
    $pos = $_.indexof('{')
    $name = $_.substring(0, $pos)

    $commandstring = 'param([int]$x,[int]$m,[int]$a,[int]$s)
'
    $commandstring += ($_ -replace '^.+{(.+)}$', '$1' -split ',') | ForEach-Object {

        if ($_ -notmatch '[<>:]') {
            "return '$_'"
        }
        else {
            $result = $_ -replace '^.+:(.+)', '$1'
            $commandline = $_ -replace '^(\w{1})', '$1' -replace '>', ' -gt ' -replace '<', ' -lt ' -replace ':(.+)$'

            'if (${0}) {{return "{1}"}};' -f $commandline, $result
        }
    }
    $workflows.add($name, [scriptblock]::Create($commandstring))
}

[int]$sum = 0
$inputdef | % {
    [int]$x,[int]$m,[int]$a,[int]$s = $_ -replace '{|}' -split ',' -replace '\w='

$result = [list[string]]@()

$start = 'in'
while ($true) {
    if ($start -eq 'A') {
        $result.add($start)
        $sum+= ($x+$m+$a+$s)
        break
    }
    if ($start -eq 'R' ) {
        $result.add($start)
        break
    }
    $result.add($start)
    $start = & $workflows[$start] -x $x -m $m -a $a -s $s
}
#$result -join ' -> '

}
$sum