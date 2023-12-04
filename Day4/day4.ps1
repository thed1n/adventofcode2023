$scratchcards = Get-Content .\Day4\input.txt

#wanted to do it with binary and made it work but left the decimal solution to.
$sum = 0
$scratchcards | ForEach-Object {
    $result = ''
    # $dec = 0
    $drawnNumbers, $card = $_ -replace 'Card\s+.+?\:' -split '\|'

    [int32[]]$cardNr = $card -replace '^\s+|\s+$' -split '\s+'
    [int32[]]$drawnNr = $drawnNumbers -replace '^\s+|\s+$' -split '\s+' #splitting went haywire and produced zeroes at first.

    # $hit = $false
    foreach ($nr in $cardNr) {
        if ($nr -in $drawnNr) {
            # $hit = $true
            $result += '1'
            # $dec *=2
        }
        # if ($dec -eq 0 -and $hit -eq $true) {$dec = 1}
    }

    if (-not [string]::IsNullOrWhiteSpace($result)) {
        if ($result -eq '1') {
            $sum += 1
        }
        else {
            $result = $result[0..($result.Length - 2)] -join ''
            $sum += ([System.Convert]::ToInt32($result, 2) + 1)
            # $dec
        }
    }
    
}
