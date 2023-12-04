$scratchcards = Get-Content .\Day4\input.txt

$allcards = [ordered]@{}


$scratchcards | ForEach-Object {
    $nr = $_ -replace 'card\s+(\d+):.+', '$1'
    $drawnNumbers, $card = $_ -replace 'Card\s+.+?\:' -split '\|'
    [int32[]]$cardNr = $card -replace '^\s+|\s+$' -split '\s+'
    [int32[]]$drawnNr = $drawnNumbers -replace '^\s+|\s+$' -split '\s+' #splitting went haywire and produced zeroes at first.
    
    $winnings = 0
    foreach ($num in $cardNr) {
        if ($num -in $drawnNr) {
            $winnings++
        }
    }
    $allcards.add($nr, @{
            Nr        = $nr
            Amount    = 1
            Cardnr    = $cardNr
            WinningNr = $drawnNr
            Victories = $winnings
        })
}

$allcards.keys | ForEach-Object {
    $key = $_
        [int]$workingnr = $key
        if ($allcards[$key].victories -gt 0) {

            for ($i = 0; $i -lt $allcards[$key].victories; $i++) {
                $workingnr++
                $allcards[[string]$workingnr].amount += $allcards[$key].amount
            }

        }
}

$sum = 0
$allcards.keys | ForEach-Object {
    $key = $_
    $sum += $allcards[$key].amount
}
$sum