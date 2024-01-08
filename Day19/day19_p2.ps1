using namespace System.Collections.Generic
$data = Get-Content .\Day19\input.txt

$datastack = [stack[hashtable]]@{}
$workflows = @{}
$functiondef = [list[string]]@()
$inputdef = [list[string]]@()
function push-stack {
    $datastack.push(
                        [ordered]@{
                            xh = $currentItem.xh
                            xl = $currentItem.xl
                            mh= $currentItem.mh
                            ml = $currentItem.ml
                            ah = $currentItem.ah
                            al = $currentItem.al
                            sh = $currentItem.sh
                            sl = $currentItem.sl
                            next = $currentItem.next
                            sum = ($currentItem.xh - $currentItem.xl + 1) * ($currentItem.mh - $currentItem.ml + 1) * ($currentItem.ah - $currentItem.al + 1) * ($currentItem.sh - $currentItem.sl + 1) 
                            result = [list[string]]::new($currentItem.result)
                        }
                    )
}
$data | ForEach-Object {
    if ([string]::IsNullOrWhiteSpace($_)) {
        break
    }

    if ($_ -match '^\{') {
        $inputdef.add($_)
    } 
    else { $functiondef.add($_) }
}

$functiondef | ForEach-Object {
    $pos = $_.indexof('{')
    $name = $_.substring(0, $pos)

    $commandstring = ($_ -replace '^.+{(.+)}$', '$1' -split ',')
    $workflows.add($name, $commandstring)

}


$datastack.push(
    [ordered]@{
        xh = 4000
        xl = 1
        mh= 4000
        ml = 1
        ah = 4000
        al = 1
        sh = 4000
        sl = 1
        next = 'In'
        result = [list[string]]@('in')
    }
)


[int]$sum = 1

$allpossibleresults = Do {

    $currentItem = $datastack.pop()
    #if ($currentItem.next -notmatch 'A|R') {
    #write-host $(convertto-json $currentItem -Compress)
    #}
    if ($currentItem.next -eq 'A') {
        [pscustomobject]$currentItem
        continue
    }
    if ($currentItem.next -eq 'R') {
        continue
    }

    $workflows[$currentItem.next] | % {
        $string = $_
    
    
        if ($string -match ':') {
            $result = $string -replace '^.+:(.+)', '$1'
            [int]$number = $string -replace '^\w.(\d+).+', '$1'
        }
        switch -regex ($string) {
            
            '^x<' {
                if ($currentItem.xh -lt $number) {
                    $currentItem.next = $result
                    $currentItem.result.add($result)
                    push-stack
                }
                if ($currentItem.xl -lt $number -and $CurrentItem.xh -gt $number) {
                    $old = $currentItem.xh
                    $currentItem.xh = $number - 1
                    $currentItem.next = $result
                    $currentItem.result.add($result)
                    push-stack
                    $currentItem.xh = $old
                    $currentItem.xl = $number
                    [void]$currentItem.result.remove($result)
                }
                break
            }
            '^x>' {
                if ($currentItem.xl -gt $number) {
                    $currentItem.next = $result
                    $currentItem.result.add($result)
                    push-stack
                }
                if ($currentItem.xl -lt $number -and $CurrentItem.xh -gt $number) {
                    $old = $currentItem.xl
                    $currentItem.xl = $number + 1
                    $currentItem.next = $result
                    $currentItem.result.add($result)
                    push-stack
                    $currentItem.xl = $old
                    $currentItem.xh = $number
                    [void]$currentItem.result.remove($result)
                }
                break
            }
            '^m<' {
                if ($currentItem.mh -lt $number) {
                    $currentItem.next = $result
                    $currentItem.result.add($result)
                    push-stack
                }
                if ($currentItem.ml -lt $number -and $CurrentItem.mh -gt $number) {
                    $old = $currentItem.mh
                    $currentItem.mh = $number - 1
                    $currentItem.next = $result
                    $currentItem.result.add($result)
                    push-stack
                    $currentItem.mh = $old
                    $currentItem.ml = $number
                    [void]$currentItem.result.remove($result)
                }
                break
            }
            '^m>' {
                if ($currentItem.ml -gt $number) {
                    $currentItem.next = $result
                    $currentItem.result.add($result)
                    push-stack
                }
                if ($currentItem.ml -lt $number -and $CurrentItem.mh -gt $number) {
                    $old = $currentItem.ml
                    $currentItem.ml = $number + 1
                    $currentItem.next = $result
                    $currentItem.result.add($result)
                    push-stack
                    $currentItem.ml = $old
                    $currentItem.mh = $number
                    [void]$currentItem.result.remove($result)
                }
                break
            }
            '^a<' {     
                if ($currentItem.ah -lt $number) {
                $currentItem.next = $result
                $currentItem.result.add($result)
                push-stack
                }
                if ($currentItem.al -lt $number -and $CurrentItem.ah -gt $number) {
                    $old = $currentItem.ah
                    $currentItem.ah = $number - 1
                    $currentItem.next = $result
                    $currentItem.result.add($result)
                    push-stack
                    $currentItem.ah = $old
                    $currentItem.al = $number
                    [void]$currentItem.result.remove($result)
                }
                break
        }
            '^a>' {
                if ($currentItem.al -gt $number) {
                    $currentItem.next = $result
                    $currentItem.result.add($result)
                    push-stack
                }
                if ($currentItem.al -lt $number -and $CurrentItem.ah -gt $number) {
                    $old = $currentItem.al
                    $currentItem.al = $number + 1
                    $currentItem.next = $result
                    $currentItem.result.add($result)
                    push-stack
                    $currentItem.al = $old
                    $currentItem.ah = $number
                    [void]$currentItem.result.remove($result)
                }
                break
            }
            '^s<' {
                if ($currentItem.sh -lt $number) {
                    $currentItem.next = $result
                    $currentItem.result.add($result)
                    push-stack
                    }
                    if ($currentItem.sl -lt $number -and $CurrentItem.sh -gt $number) {
                        $old = $currentItem.sh
                        $currentItem.sh = $number - 1
                        $currentItem.next = $result
                        $currentItem.result.add($result)
                        push-stack
                        $currentItem.sh = $old
                        $currentItem.sl = $number
                        [void]$currentItem.result.remove($result)
                    }
                    break
            }
            '^s>' {
                if ($currentItem.sl -gt $number) {
                    $currentItem.next = $result
                    $currentItem.result.add($result)
                    push-stack
                }
                if ($currentItem.sl -lt $number -and $CurrentItem.sh -gt $number) {
                    $old = $currentItem.sl
                    $currentItem.sl = $number + 1
                    $currentItem.next = $result
                    $currentItem.result.add($result)
                    push-stack
                    $currentItem.sl = $old
                    $currentItem.sh = $number
                    [void]$currentItem.result.remove($result)
                }
                break
            }
            default {
                $currentItem.next = $_
                $currentItem.result.add($_)
                push-stack
            }
        
        }
    }

} While ($datastack.count -gt 0)
[bigint]$sum = 0
$allpossibleresults | % {
    [bigint]$intsum = 1

    $intsum *= ($_.xh - $_.xl+1) * ($_.mh - $_.ml+1) * ($_.ah - $_.al+1) * ($_.sh - $_.sl+1)
    $sum += $intsum
    
    # write-host "$intsum"
    # write-host $($_.result -join ' -> ')

}
$sum
