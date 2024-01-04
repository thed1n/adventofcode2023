$cards = Get-Content .\day7\input.txt

function get-rank {
    param(
        [Parameter(ValueFromPipeline)]
        [string]$hand
    )
    process {
        switch ($hand) {
            '11111' { 1 }
            '1112' { 2 }
            '122' { 3 }
            '113' { 4 }
            '23' { 5 }
            '14' { 6 }
            '5' { 7 }
        }
    }
}

<#
$cards = @'
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
'@ -split '\r?\n' 
#>

$allcards = $cards  | ForEach-Object {

    $hand = @{}
    $jokerhand = @{}
    $card, $bet = $_ -split ' '

    $card1 = $card -replace 'a', 'f' -replace 'k', 'e' -replace 'q', 'd' -replace 'j', 'c' -replace 't', 'b'
    $card2 = $card -replace 'a', 'f' -replace 'k', 'e' -replace 'q', 'd' -replace 'j', '0' -replace 't', 'b'

    [char[]]$card1 | ForEach-Object {
        $hand[$_]++
    }

    [char[]]$card2 | ForEach-Object {
        $jokerhand[$_]++
    }

    $highvalue = 0
    $key = ''
    if ($jokerhand.ContainsKey([char]'0')) {
        $jokerhand.keys | ForEach-Object {
            if ($_ -eq '0') { return }
            if ($highvalue -lt $jokerhand[$_]) {
                $highvalue = $jokerhand[$_]
                $key = $_
            }
        }

        $jokerhand[$key] += $jokerhand[[char]'0']
        $jokerhand.remove([char]'0')

    }

   
    $cardhand = $hand.keys | ForEach-Object {
        $hand[$_]
    }
    $johand = $jokerhand.keys | ForEach-Object {
        $jokerhand[$_]
    }

    $handvalue = ($cardhand | Sort-Object) -join '' | get-rank
    $jokervalue = ($johand | Sort-Object) -join '' | get-rank


    [pscustomobject]@{
        Hand       = $card1
        Jokerhand  = $card2
        Bet        = [int]$bet
        Jokervalue = [int]$jokervalue
        Handvalue  = [int]$handvalue
    }
}

$sortedhands = $allcards | Sort-Object handvalue, hand
$sortedjokerhands = $allcards | Sort-Object jokervalue, Jokerhand


$sum = 0
for ($i = 0; $i -lt $sortedhands.count; $i++) {
    #write-host "[$($sortedhands[$i].hand)] Rank: [$($i+1)] Value: [$($sortedhands[$i].handvalue)]"
    $sum += $sortedhands[$i].Bet * ($i + 1)
}

$sum2 = 0
for ($i = 0; $i -lt $sortedjokerhands.count; $i++) {
    #write-host "[$($sortedjokerhands[$i].jokerhand)] Rank: [$($i+1)] Value: [$($sortedjokerhands[$i].jokervalue)]"
    $sum2 += $sortedjokerhands[$i].Bet * ($i + 1)
}

[pscustomobject]@{
    Part1 = $sum
    Part2 = $sum2
}
