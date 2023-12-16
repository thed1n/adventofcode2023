(get-content .\day15\input.txt -Raw) -split ',' | % {
$sum = 0
foreach ($c in [char[]]$_) {
    $sum+=[int]$c
    $sum=([int]$sum*17)
    if ($sum -ge 256) {$sum = $sum%256}
    }
    $sum} | Measure-Object -sum | % sum