using namespace System.Collections.Generic
$lensboxes = (Get-Content .\day15\input.txt -Raw) -split ',' 
function get-hashposition {
    param (
        [Parameter(ValueFromPipeline)]
        [string]$boxhash
    )
    process {
        $sum = 0
        foreach ($c in [char[]]$boxhash) {
            $sum += [int]$c
            $sum = ([int]$sum * 17)
            if ($sum -ge 256) { $sum = $sum % 256 }
        }
    
        return $sum
    }
}

class lensbox {
    [list[psobject]]$slots = @()
    hidden [hashset[string]]$lenses = @{}
    hidden [queue[pscustomobject]]$queue = @{}

    lensbox () {}

    add ([string]$lens, [int]$focal, [string]$action) {
        if ($action -eq '=') {
            if ($this.lenses.Contains($lens)) {
                $this.replace($lens, $focal)
            }
            else {
        
                $lensobj = [pscustomobject]@{
                    Lens  = $lens
                    Focal = $focal
                }

                [void]$this.lenses.add($lens)
                $this.slots.add($lensobj)
            }
        }
        else {
            [void]$this.lenses.remove($lens)
            $this.remove($lens)
        }
    }
    add ([string]$lens, [string]$action) {
        [void]$this.lenses.remove($lens)
        $this.remove($lens)
    }

    remove ([string]$lens) {
        $tmplens = $this.slots | Where-Object Lens -EQ $lens
        $this.slots.Remove($tmplens)
        $this.reorder()
    }

    replace ([string]$lens, [int]$focal) {
        $tmplens = $this.slots | Where-Object Lens -EQ $lens
        $index = $this.slots.IndexOf($tmplens)
        $this.slots[$index] = [pscustomobject]@{
            Lens  = $lens
            Focal = $focal
        }

    }

    reorder () {
        foreach ($lens in $this.slots) {
            #write-host "found $lens"
            $this.queue.Enqueue($lens)
        }
        $this.slots.Clear()
        
        while ($this.queue.count -gt 0) {
            $this.slots.add($this.queue.Dequeue())
        } 
    }

    print () {
        for ($i = 0; $i -lt $this.slots.count; $i++) {
            Write-Host "$i [$($this.slots[$i].Lens)] [$($this.slots[$i].Focal)]"
        }
    }
    [int32] calculate () {
        $sum = 0
        for ($i=0 ; $i -lt $this.slots.count; $i++) {
            $sum += $this.slots[$i].focal * ($i+1)
        }
        return $sum
    }
}

class Lensboxes {
    $boxes
    Lensboxes () {
        $this.boxes = 1..256 | ForEach-Object {
            [lensbox]::new()
        }
    }
    add ([string]$box) {
        $box -match '(\w+?)(-|=)(\d?)'
        
        $boxname = $matches[1]
        $boxposition = $matches[1] | get-hashposition
        $action = $matches[2]
        [int32]$focal = $matches[3]
        #write-host "$box [$boxname] [$boxposition] [$action] [$focal]"
        if ($action -eq '-') {
            $this.boxes[$boxposition].add($boxname, $action)
        }
        else {
            $this.boxes[$boxposition].add($boxname, $focal, $action)
        }

    }
    [int32] calculate () {
        # ot: 4 (box 3) * 1 (first slot) * 7 (focal length) = 28
        # i=3
        # i+1 * 1*7 = 28
        [int32]$sum = 0
        for ($i=0;$i -lt $this.boxes.count;$i++) {
            write-host "Box $i [$(($i+1) *$this.boxes[$i].calculate())]"
            $sum += (($i+1) *$this.boxes[$i].calculate())
        }
        return $sum
    }
}

$lightbox = [Lensboxes]::new()
$lensboxes | ForEach-Object {
    $lightbox.add($_)
}

$lightbox.calculate()

