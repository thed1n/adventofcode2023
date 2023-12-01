$day = get-content .\input.txt

$calibrationvalues = $day | foreach-object {
[string]$numb = $_ -replace '[a-z]'
$numb = $numb[0]+$numb[-1]
$numb -as [int]
}

$calibrationvalues2 = $day | foreach-object {
    $currentday = $_
    $m = for ($i=0;$i -lt $currentday.length;){

        $text = $currentday.substring($i)
        switch -regex ($text) {
            '^one' {'1';$i+=2}
            '^two' {'2';$i+=2}
            '^three' {'3';$i+=4}
            '^four' {'4';$i+=4}
            '^five' {'5';$i+=3}
            '^six' {'6';$i+=3}
            '^seven'{'7';$i+=4}
            '^eight'{'8';$i+=4}
            '^nine'  {'9';$i+=3}
            '^\d' {[string]$_[0];$i++}
            default {$i++}
        }
        }
    $p2numb = $m[0] + $m[-1]
    $p2numb -as [int]

    }

[pscustomobject]@{
    Part1 = [int]($calibrationvalues | measure-object -sum | % sum)
    Part2 = [int]($calibrationvalues2 | measure-object -sum | % sum)
}