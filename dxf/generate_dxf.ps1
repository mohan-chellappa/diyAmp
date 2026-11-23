# Complete DXF Generator for Copper Chimney V2 Amplifier Chassis
# Conforming to AutoCAD R12 / 2000 standard specification
param(
    [string]$OutputDir = "d:\Documents\DIY Amp\dxf"
)

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
}

class DxfModel {
    [System.Text.StringBuilder]$sb
    [string]$currentLayer

    DxfModel() {
        $this.sb = [System.Text.StringBuilder]::new()
        $this.currentLayer = "0"
        $this.WriteHeader()
    }

    [void]WriteHeader() {
        $this.sb.AppendLine("0`nSECTION`n2`nHEADER`n9`n`$ACADVER`n1`nAC1009`n9`n`$INSUNITS`n70`n4`n9`n`$MEASUREMENT`n70`n1`n0`nENDSEC")
        
        # TABLES
        $this.sb.AppendLine("0`nSECTION`n2`nTABLES")
        
        # LTYPE
        $this.sb.AppendLine("0`nTABLE`n2`nLTYPE`n70`n3")
        $this.sb.AppendLine("0`nLTYPE`n2`nCONTINUOUS`n70`n0`n3`nSolid line`n72`n65`n73`n0`n40`n0.0")
        $this.sb.AppendLine("0`nLTYPE`n2`nCENTER`n70`n0`n3`nCenter line ____ _ ____`n72`n65`n73`n4`n40`n31.75`n49`n19.05`n49`n-3.175`n49`n6.35`n49`n-3.175")
        $this.sb.AppendLine("0`nLTYPE`n2`nDASHED`n70`n0`n3`nDashed line __ __ __`n72`n65`n73`n2`n40`n12.7`n49`n6.35`n49`n-6.35")
        $this.sb.AppendLine("0`nENDTAB")

        # LAYER
        $this.sb.AppendLine("0`nTABLE`n2`nLAYER`n70`n7")
        $this.sb.AppendLine("0`nLAYER`n2`n0`n70`n0`n62`n7`n6`nCONTINUOUS")
        $this.sb.AppendLine("0`nLAYER`n2`nCUT_OUTLINE`n70`n0`n62`n1`n6`nCONTINUOUS")  # Red
        $this.sb.AppendLine("0`nLAYER`n2`nHOLES_DRILL`n70`n0`n62`n3`n6`nCONTINUOUS")  # Green
        $this.sb.AppendLine("0`nLAYER`n2`nENGRAVE_TEXT`n70`n0`n62`n4`n6`nCONTINUOUS") # Cyan
        $this.sb.AppendLine("0`nLAYER`n2`nDIMENSIONS`n70`n0`n62`n2`n6`nCONTINUOUS")   # Yellow
        $this.sb.AppendLine("0`nLAYER`n2`nCENTERLINES`n70`n0`n62`n8`n6`nCENTER")      # Dark Gray
        $this.sb.AppendLine("0`nLAYER`n2`nTITLE_BLOCK`n70`n0`n62`n7`n6`nCONTINUOUS")   # White
        $this.sb.AppendLine("0`nENDTAB")
        $this.sb.AppendLine("0`nENDSEC")

        # BLOCKS
        $this.sb.AppendLine("0`nSECTION`n2`nBLOCKS`n0`nENDSEC")

        # ENTITIES
        $this.sb.AppendLine("0`nSECTION`n2`nENTITIES")
    }

    [void]SetLayer([string]$layer) {
        $this.currentLayer = $layer
    }

    [void]AddLine([double]$x1, [double]$y1, [double]$x2, [double]$y2) {
        $ci = [System.Globalization.CultureInfo]::InvariantCulture
        $this.sb.AppendLine("0`nLINE`n8`n$($this.currentLayer)`n10`n$([string]::Format($ci, '{0:F3}', $x1))`n20`n$([string]::Format($ci, '{0:F3}', $y1))`n30`n0.0`n11`n$([string]::Format($ci, '{0:F3}', $x2))`n21`n$([string]::Format($ci, '{0:F3}', $y2))`n31`n0.0")
    }

    [void]AddCircle([double]$cx, [double]$cy, [double]$radius) {
        $ci = [System.Globalization.CultureInfo]::InvariantCulture
        $this.sb.AppendLine("0`nCIRCLE`n8`n$($this.currentLayer)`n10`n$([string]::Format($ci, '{0:F3}', $cx))`n20`n$([string]::Format($ci, '{0:F3}', $cy))`n30`n0.0`n40`n$([string]::Format($ci, '{0:F3}', $radius))")
    }

    [void]AddArc([double]$cx, [double]$cy, [double]$radius, [double]$startAngle, [double]$endAngle) {
        $ci = [System.Globalization.CultureInfo]::InvariantCulture
        $this.sb.AppendLine("0`nARC`n8`n$($this.currentLayer)`n10`n$([string]::Format($ci, '{0:F3}', $cx))`n20`n$([string]::Format($ci, '{0:F3}', $cy))`n30`n0.0`n40`n$([string]::Format($ci, '{0:F3}', $radius))`n50`n$([string]::Format($ci, '{0:F3}', $startAngle))`n51`n$([string]::Format($ci, '{0:F3}', $endAngle))")
    }

    [void]AddText([double]$x, [double]$y, [double]$height, [string]$text) {
        $this.AddText($x, $y, $height, $text, 0.0)
    }

    [void]AddText([double]$x, [double]$y, [double]$height, [string]$text, [double]$rot) {
        $ci = [System.Globalization.CultureInfo]::InvariantCulture
        $clean = $text.Replace("`n", " ").Replace("`r", "")
        $this.sb.AppendLine("0`nTEXT`n8`n$($this.currentLayer)`n10`n$([string]::Format($ci, '{0:F3}', $x))`n20`n$([string]::Format($ci, '{0:F3}', $y))`n30`n0.0`n40`n$([string]::Format($ci, '{0:F3}', $height))`n1`n$clean`n50`n$([string]::Format($ci, '{0:F3}', $rot))")
    }

    [void]AddRoundedRect([double]$x, [double]$y, [double]$w, [double]$h, [double]$r) {
        if ($r -le 0.001) {
            $this.AddLine($x, $y, $x + $w, $y)
            $this.AddLine($x + $w, $y, $x + $w, $y + $h)
            $this.AddLine($x + $w, $y + $h, $x, $y + $h)
            $this.AddLine($x, $y + $h, $x, $y)
            return
        }
        # 4 straight edges
        $this.AddLine($x + $r, $y, $x + $w - $r, $y)
        $this.AddLine($x + $w, $y + $r, $x + $w, $y + $h - $r)
        $this.AddLine($x + $w - $r, $y + $h, $x + $r, $y + $h)
        $this.AddLine($x, $y + $h - $r, $x, $y + $r)
        # 4 corner arcs
        $this.AddArc($x + $w - $r, $y + $r, $r, 270.0, 360.0) # BR
        $this.AddArc($x + $w - $r, $y + $h - $r, $r, 0.0, 90.0)   # TR
        $this.AddArc($x + $r, $y + $h - $r, $r, 90.0, 180.0)   # TL
        $this.AddArc($x + $r, $y + $r, $r, 180.0, 270.0)       # BL
    }

    [void]AddCrosshair([double]$cx, [double]$cy, [double]$size) {
        $orig = $this.currentLayer
        $this.SetLayer("CENTERLINES")
        $h = $size / 2.0
        $this.AddLine($cx - $h, $cy, $cx + $h, $cy)
        $this.AddLine($cx, $cy - $h, $cx, $cy + $h)
        $this.SetLayer($orig)
    }

    [void]AddLinearDimH([double]$x1, [double]$x2, [double]$y, [double]$offset, [string]$label) {
        $orig = $this.currentLayer
        $this.SetLayer("DIMENSIONS")
        $dimY = $y + $offset
        $ext = if ($offset -gt 0) { 3.0 } else { -3.0 }
        $this.AddLine($x1, $y, $x1, $dimY + $ext)
        $this.AddLine($x2, $y, $x2, $dimY + $ext)
        $this.AddLine($x1, $dimY, $x2, $dimY)
        $t = 2.0
        $this.AddLine($x1, $dimY - $t, $x1 + $t, $dimY)
        $this.AddLine($x1, $dimY + $t, $x1 + $t, $dimY)
        $this.AddLine($x2, $dimY - $t, $x2 - $t, $dimY)
        $this.AddLine($x2, $dimY + $t, $x2 - $t, $dimY)
        $midX = ($x1 + $x2) / 2.0
        $this.AddText($midX - 7.0, $dimY + 1.2, 3.0, $label)
        $this.SetLayer($orig)
    }

    [void]AddLinearDimV([double]$y1, [double]$y2, [double]$x, [double]$offset, [string]$label) {
        $orig = $this.currentLayer
        $this.SetLayer("DIMENSIONS")
        $dimX = $x + $offset
        $ext = if ($offset -gt 0) { 3.0 } else { -3.0 }
        $this.AddLine($x, $y1, $dimX + $ext, $y1)
        $this.AddLine($x, $y2, $dimX + $ext, $y2)
        $this.AddLine($dimX, $y1, $dimX, $y2)
        $t = 2.0
        $this.AddLine($dimX - $t, $y1, $dimX, $y1 + $t)
        $this.AddLine($dimX + $t, $y1, $dimX, $y1 + $t)
        $this.AddLine($dimX - $t, $y2, $dimX, $y2 - $t)
        $this.AddLine($dimX + $t, $y2, $dimX, $y2 - $t)
        $midY = ($y1 + $y2) / 2.0
        $this.AddText($dimX + 1.5, $midY - 7.0, 3.0, $label, 90.0)
        $this.SetLayer($orig)
    }

    [void]AddRadialSlots([double]$cx, [double]$cy, [double]$rIn, [double]$rOut, [int]$count, [double]$slotWidth) {
        $orig = $this.currentLayer
        $this.SetLayer("HOLES_DRILL")
        $step = 360.0 / $count
        $halfW = $slotWidth / 2.0
        for ($i = 0; $i -lt $count; $i++) {
            $angleDeg = $i * $step
            $rad = $angleDeg * [Math]::PI / 180.0
            $cos = [Math]::Cos($rad)
            $sin = [Math]::Sin($rad)
            $perpCos = - $sin
            $perpSin = $cos
            
            # 4 corners of slot
            $p1x = $cx + $cos * $rIn - $perpCos * $halfW
            $p1y = $cy + $sin * $rIn - $perpSin * $halfW
            $p2x = $cx + $cos * $rOut - $perpCos * $halfW
            $p2y = $cy + $sin * $rOut - $perpSin * $halfW
            $p3x = $cx + $cos * $rOut + $perpCos * $halfW
            $p3y = $cy + $sin * $rOut + $perpSin * $halfW
            $p4x = $cx + $cos * $rIn + $perpCos * $halfW
            $p4y = $cy + $sin * $rIn + $perpSin * $halfW

            $this.AddLine($p1x, $p1y, $p2x, $p2y)
            $this.AddLine($p2x, $p2y, $p3x, $p3y)
            $this.AddLine($p3x, $p3y, $p4x, $p4y)
            $this.AddLine($p4x, $p4y, $p1x, $p1y)
        }
        $this.SetLayer($orig)
    }

    [void]AddTitleBlock([double]$x, [double]$y, [double]$w, [double]$h, [string]$partName, [string]$mat) {
        $this.AddTitleBlock($x, $y, $w, $h, $partName, $mat, "1:1")
    }

    [void]AddTitleBlock([double]$x, [double]$y, [double]$w, [double]$h, [string]$partName, [string]$mat, [string]$scale) {
        $orig = $this.currentLayer
        $this.SetLayer("TITLE_BLOCK")
        # Outer box
        $this.AddLine($x, $y, $x + $w, $y)
        $this.AddLine($x + $w, $y, $x + $w, $y + $h)
        $this.AddLine($x + $w, $y + $h, $x, $y + $h)
        $this.AddLine($x, $y + $h, $x, $y)
        # Dividers
        $this.AddLine($x, $y + $h * 0.5, $x + $w, $y + $h * 0.5)
        $this.AddLine($x + $w * 0.65, $y, $x + $w * 0.65, $y + $h * 0.5)
        # Text
        $this.AddText($x + 3.0, $y + $h * 0.65, 3.8, "PROJECT: COPPER CHIMNEY V2 - 5.1 AMP")
        $this.AddText($x + 3.0, $y + $h * 0.20, 3.2, "PART: $partName")
        $this.AddText($x + $w * 0.67, $y + $h * 0.28, 2.5, "MAT: $mat")
        $this.AddText($x + $w * 0.67, $y + $h * 0.10, 2.5, "SCALE: $scale | UNITS: mm")
        $this.SetLayer($orig)
    }

    [void]SaveToFile([string]$path) {
        $this.sb.AppendLine("0`nENDSEC`n0`nEOF")
        [System.IO.File]::WriteAllText($path, $this.sb.ToString(), [System.Text.Encoding]::ASCII)
    }
}

# ==============================================================================
# 1. TOP CHIMNEY PANEL (160 x 160 mm, 4mm Amber Polycarbonate)
# ==============================================================================
function Build-TopPanel([string]$filePath) {
    $d = [DxfModel]::new()
    
    # Cut Outline (160x160 with R8 corner fillets)
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect(0.0, 0.0, 160.0, 160.0, 8.0)

    # Drill Holes
    $d.SetLayer("HOLES_DRILL")
    # Central Chimney (OD 35mm -> Radius 17.5)
    $d.AddCircle(80.0, 80.0, 17.5)

    # 4 Corner Copper Convection Tubes (OD 15mm -> Radius 7.5 at +/-62mm)
    $corners = @(
        @(18.0, 18.0),
        @(142.0, 18.0),
        @(142.0, 142.0),
        @(18.0, 142.0)
    )
    foreach ($c in $corners) {
        $d.AddCircle($c[0], $c[1], 7.5)
        $d.AddCrosshair($c[0], $c[1], 18.0)
    }

    # 4 Perimeter Corner Fastening Holes (M3 -> Dia 3.5mm at (8,8), (152,8), etc.)
    $fasteners = @(
        @(8.0, 8.0),
        @(152.0, 8.0),
        @(152.0, 152.0),
        @(8.0, 152.0)
    )
    foreach ($f in $fasteners) {
        $d.AddCircle($f[0], $f[1], 1.75)
    }

    # Centerlines
    $d.AddCrosshair(80.0, 80.0, 42.0)

    # Engraved Details
    $d.SetLayer("ENGRAVE_TEXT")
    # Decorative Collar Ring (ID 35, OD 44)
    $d.AddCircle(80.0, 80.0, 22.0)
    $d.AddCircle(80.0, 80.0, 16.0) # Inner pipe wall
    $d.AddText(44.0, 148.0, 3.2, "COPPER CHIMNEY V2 • TOP COVER")
    $d.AddText(48.0, 8.0, 2.5, "NATURAL CONVECTIVE THERMOSIPHON EXHAUST")

    # Dimensions
    $d.AddLinearDimH(0.0, 160.0, 160.0, 12.0, "160.00 mm")
    $d.AddLinearDimV(0.0, 160.0, 160.0, 12.0, "160.00 mm")
    $d.AddLinearDimH(18.0, 142.0, 0.0, -10.0, "124.00 mm PITCH")
    $d.AddLinearDimV(18.0, 142.0, 0.0, -10.0, "124.00 mm PITCH")

    # Title Block
    $d.AddTitleBlock(0.0, -42.0, 160.0, 26.0, "TOP CHIMNEY COVER", "4mm AMBER POLYCARBONATE")

    $d.SaveToFile($filePath)
    Write-Output "Generated: $filePath"
}

# ==============================================================================
# 2. BOTTOM BASE PLATE (160 x 160 mm, 5mm Polycarbonate / AL6061)
# ==============================================================================
function Build-BottomPanel([string]$filePath) {
    $d = [DxfModel]::new()
    
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect(0.0, 0.0, 160.0, 160.0, 8.0)

    $d.SetLayer("HOLES_DRILL")
    # Central Convective Intake Aperture (Dia 35mm -> R17.5)
    $d.AddCircle(80.0, 80.0, 17.5)

    # 8 Radial Convection Intake Slots (R_in 23mm, R_out 34mm, Width 3.5mm)
    $d.AddRadialSlots(80.0, 80.0, 23.0, 34.0, 8, 3.5)

    # 4 Corner Air Flues (Dia 15mm)
    $corners = @(@(18.0, 18.0), @(142.0, 18.0), @(142.0, 142.0), @(18.0, 142.0))
    foreach ($c in $corners) {
        $d.AddCircle($c[0], $c[1], 7.5)
        $d.AddCrosshair($c[0], $c[1], 18.0)
    }

    # 4 Rubber Feet Mounting Holes (M4 -> Dia 4.5mm at (22, 22), (138, 22), etc.)
    $feet = @(@(22.0, 22.0), @(138.0, 22.0), @(138.0, 138.0), @(22.0, 138.0))
    foreach ($ft in $feet) {
        $d.AddCircle($ft[0], $ft[1], 2.25)
        $d.AddCrosshair($ft[0], $ft[1], 9.0)
    }

    # 4 Chassis Fastening Holes (Dia 3.5mm)
    $fasteners = @(@(8.0, 8.0), @(152.0, 8.0), @(152.0, 152.0), @(8.0, 152.0))
    foreach ($f in $fasteners) {
        $d.AddCircle($f[0], $f[1], 1.75)
    }

    $d.AddCrosshair(80.0, 80.0, 44.0)

    $d.SetLayer("ENGRAVE_TEXT")
    $d.AddText(46.0, 148.0, 3.2, "CHASSIS BASE PLATE • INTAKE")
    $d.AddText(42.0, 8.0, 2.5, "ELEVATED 15mm AIR INTAKE PLENUM")

    $d.AddLinearDimH(0.0, 160.0, 160.0, 12.0, "160.00 mm")
    $d.AddLinearDimV(0.0, 160.0, 160.0, 12.0, "160.00 mm")
    $d.AddLinearDimH(22.0, 138.0, 0.0, -10.0, "96.00 mm FEET PITCH")

    $d.AddTitleBlock(0.0, -42.0, 160.0, 26.0, "CHASSIS BOTTOM INTAKE PLATE", "5mm POLYCARBONATE / AL6061")

    $d.SaveToFile($filePath)
    Write-Output "Generated: $filePath"
}

# ==============================================================================
# 3. FRONT BEZEL PANEL (160 x 160 mm, 4mm Amber Frosted Polycarbonate)
# ==============================================================================
function Build-FrontPanel([string]$filePath) {
    $d = [DxfModel]::new()
    
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect(0.0, 0.0, 160.0, 160.0, 8.0)

    # Display Window Cutout
    # Primary Cutout: Waveshare 4.3"/5" LCD Screen Opening (115 x 72 mm, R3 fillets, center (80, 98))
    $d.SetLayer("HOLES_DRILL")
    $d.AddRoundedRect(22.5, 62.0, 115.0, 72.0, 3.0)

    # Volume Knob / Rotary Encoder Shaft (Center (80, 36))
    # Shaft hole Dia 7.5mm (M7 bush)
    $d.AddCircle(80.0, 36.0, 3.75)
    # Anti-rotation locator tab hole Dia 3.0mm (offset 9.5mm below)
    $d.AddCircle(80.0, 26.5, 1.5)

    # 4 Corner Fasteners (Dia 3.5mm)
    $fasteners = @(@(8.0, 8.0), @(152.0, 8.0), @(152.0, 152.0), @(8.0, 152.0))
    foreach ($f in $fasteners) {
        $d.AddCircle($f[0], $f[1], 1.75)
    }

    $d.AddCrosshair(80.0, 36.0, 14.0)
    $d.AddCrosshair(80.0, 98.0, 20.0)

    # Engraved Details
    $d.SetLayer("ENGRAVE_TEXT")
    # Compact OLED Bezel reference (64 x 32mm with R4, centered at (80, 98))
    $d.AddRoundedRect(48.0, 82.0, 64.0, 32.0, 4.0)
    $d.AddText(65.0, 96.0, 3.0, "[ 120W AMP ]")

    # Volume Dial Scale (Dia 36mm knob envelope + ticks)
    $d.AddCircle(80.0, 36.0, 18.0)
    $ticks = @(-135, -108, -81, -54, -27, 0, 27, 54, 81, 108, 135)
    foreach ($deg in $ticks) {
        $rad = ($deg - 90) * [Math]::PI / 180.0
        $t1x = 80.0 + [Math]::Cos($rad) * 19.5
        $t1y = 36.0 + [Math]::Sin($rad) * 19.5
        $t2x = 80.0 + [Math]::Cos($rad) * 22.0
        $t2y = 36.0 + [Math]::Sin($rad) * 22.0
        $d.AddLine($t1x, $t1y, $t2x, $t2y)
    }
    $d.AddText(56.0, 14.0, 2.5, "MIN")
    $d.AddText(98.0, 14.0, 2.5, "MAX")
    $d.AddText(72.0, 56.0, 2.8, "VOLUME")

    $d.AddText(42.0, 148.0, 3.2, "COPPER CHIMNEY V2 • HMI BEZEL")
    $d.AddText(38.0, 8.0, 2.2, "5.1 HIGH-CURRENT AUDIOPHILE AMPLIFIER")

    # Dimensions
    $d.AddLinearDimH(0.0, 160.0, 160.0, 12.0, "160.00 mm")
    $d.AddLinearDimV(0.0, 160.0, 160.0, 12.0, "160.00 mm")
    $d.AddLinearDimH(22.5, 137.5, 62.0, -10.0, "115.00 mm SCREEN")
    $d.AddLinearDimV(62.0, 134.0, 137.5, 8.0, "72.00 mm")

    $d.AddTitleBlock(0.0, -42.0, 160.0, 26.0, "FRONT DISPLAY & VOLUME BEZEL", "4mm AMBER FROSTED POLYCARBONATE")

    $d.SaveToFile($filePath)
    Write-Output "Generated: $filePath"
}

# ==============================================================================
# 4. REAR I/O PANEL (160 x 160 mm, 4-5mm Amber/Smoked Polycarbonate)
# ==============================================================================
function Build-RearPanel([string]$filePath) {
    $d = [DxfModel]::new()
    
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect(0.0, 0.0, 160.0, 160.0, 8.0)

    $d.SetLayer("HOLES_DRILL")
    
    # 1. GX16 4-Pin Aviation Power Inlet (Center (125, 68), Dia 16.0mm -> R8.0)
    $d.AddCircle(125.0, 68.0, 8.0)
    $d.AddCrosshair(125.0, 68.0, 22.0)

    # 2. 12x Speaker Binding Posts (JS-910B 4mm Banana / Post Jack, Dia 8.0mm -> R4.0)
    # Row 1 (Top / Positive RED): Y = 108.0 mm
    # Row 2 (Bottom / Negative BLACK): Y = 82.0 mm
    # Columns (pitch 16mm): 25, 41, 57, 73, 89, 105
    $xCols = @(25.0, 41.0, 57.0, 73.0, 89.0, 105.0)
    foreach ($colX in $xCols) {
        # Top (+)
        $d.AddCircle($colX, 108.0, 4.0)
        $d.AddCrosshair($colX, 108.0, 11.0)
        # Bottom (-)
        $d.AddCircle($colX, 82.0, 4.0)
        $d.AddCrosshair($colX, 82.0, 11.0)
    }

    # 3. 3.5mm Stereo AUX Input Jack (Center (40, 32), Dia 6.0mm -> R3.0)
    $d.AddCircle(40.0, 32.0, 3.0)
    $d.AddCrosshair(40.0, 32.0, 10.0)

    # 4. USB-C Service Port (Center (110, 32), Slot 10.0 x 4.2mm with rounded ends R2.1)
    $d.AddRoundedRect(105.0, 29.9, 10.0, 4.2, 2.1)
    # 2x M2.5 mounting flange holes
    $d.AddCircle(97.5, 32.0, 1.25)
    $d.AddCircle(122.5, 32.0, 1.25)

    # 5. Convective Exhaust Slits (Bottom)
    $slotsX = @(35.0, 60.0, 85.0, 110.0)
    foreach ($sx in $slotsX) {
        $d.AddRoundedRect($sx - 9.0, 13.0, 18.0, 3.5, 1.75)
    }

    # 4 Corner Fasteners (Dia 3.5mm)
    $fasteners = @(@(8.0, 8.0), @(152.0, 8.0), @(152.0, 152.0), @(8.0, 152.0))
    foreach ($f in $fasteners) {
        $d.AddCircle($f[0], $f[1], 1.75)
    }

    # Engraved Port Labels
    $d.SetLayer("ENGRAVE_TEXT")
    # GX16 Flange reference
    $d.AddCircle(125.0, 68.0, 10.5)
    $d.AddText(114.0, 52.0, 2.4, "DC IN 24V")
    $d.AddText(114.0, 48.0, 2.0, "14.6A GX16")

    # Speaker Terminals Header
    $d.AddText(20.0, 126.0, 3.0, "5.1 HIGH-CURRENT SPEAKER TERMINALS (4 - 8 OHM)")
    $labels = @("FL", "FR", "C", "SL", "SR", "SUB")
    for ($i = 0; $i -lt 6; $i++) {
        $d.AddText($xCols[$i] - 2.5, 116.0, 2.5, $labels[$i])
        $d.AddText($xCols[$i] - 1.5, 96.0, 2.5, "+")
        $d.AddText($xCols[$i] - 1.5, 71.0, 2.5, "-")
    }

    $d.AddText(30.0, 22.0, 2.2, "AUX IN (3.5mm)")
    $d.AddText(100.0, 22.0, 2.2, "USB-C CONFIG")

    $d.AddText(40.0, 148.0, 3.2, "COPPER CHIMNEY V2 • REAR I/O")
    $d.AddText(34.0, 6.0, 2.0, "POLYCARBONATE DIELECTRIC INSULATED PANEL")

    # Dimensions
    $d.AddLinearDimH(0.0, 160.0, 160.0, 12.0, "160.00 mm")
    $d.AddLinearDimV(0.0, 160.0, 160.0, 12.0, "160.00 mm")
    $d.AddLinearDimH(25.0, 105.0, 108.0, 8.0, "80.00 mm (16mm PITCH)")
    $d.AddLinearDimV(82.0, 108.0, 25.0, -12.0, "26.00 mm")

    $d.AddTitleBlock(0.0, -42.0, 160.0, 26.0, "REAR I/O & POWER INFEED PANEL", "4-5mm POLYCARBONATE")

    $d.SaveToFile($filePath)
    Write-Output "Generated: $filePath"
}

# ==============================================================================
# 5. SOLID WOOD PLINTH BASE (180 x 180 mm, 18mm Solid Walnut)
# ==============================================================================
function Build-PlinthWoodBase([string]$filePath) {
    $d = [DxfModel]::new()
    
    # Cut Outline: 180 x 180mm with R14 fillets
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect(0.0, 0.0, 180.0, 180.0, 14.0)

    $d.SetLayer("HOLES_DRILL")
    # Central Convection Flue Through-Bore (Dia 38.0mm -> R19.0 to clear 35mm chimney)
    $d.AddCircle(90.0, 90.0, 19.0)
    $d.AddCrosshair(90.0, 90.0, 48.0)

    # 4 Chassis Standoff Anchor Holes (M4 -> Dia 4.5mm)
    # Centered on 180mm plinth: offset by 10mm from 160mm chassis footprint
    # Feet at (22, 22) in chassis -> (32, 32), (148, 32), (148, 148), (32, 148)
    $anchors = @(
        @(32.0, 32.0),
        @(148.0, 32.0),
        @(148.0, 148.0),
        @(32.0, 148.0)
    )
    foreach ($a in $anchors) {
        $d.AddCircle($a[0], $a[1], 2.25)
        $d.AddCrosshair($a[0], $a[1], 10.0)
    }

    # Engraved Machining References
    $d.SetLayer("ENGRAVE_TEXT")
    # Underside Convection Bell-Mouth Chamfer (Dia 54.0mm)
    $d.AddCircle(90.0, 90.0, 27.0)
    
    # 4 Underside Rubber Feet Pockets (Dia 26.0mm x 4mm depth)
    $feetPockets = @(
        @(24.0, 24.0),
        @(156.0, 24.0),
        @(156.0, 156.0),
        @(24.0, 156.0)
    )
    foreach ($fp in $feetPockets) {
        $d.AddCircle($fp[0], $fp[1], 13.0)
        $d.AddCrosshair($fp[0], $fp[1], 16.0)
    }

    # 160x160mm Chassis Seating Step / Chamfer Reference
    $d.AddRoundedRect(10.0, 10.0, 160.0, 160.0, 8.0)

    $d.AddText(46.0, 168.0, 3.5, "COPPER CHIMNEY V2 • WOODEN PLINTH")
    $d.AddText(38.0, 12.0, 2.5, "SOLID WALNUT / TEAK BASE • 18mm THICKNESS")
    $d.AddText(62.0, 98.0, 2.5, "AIR FLUE O38mm")

    # Dimensions
    $d.AddLinearDimH(0.0, 180.0, 180.0, 12.0, "180.00 mm")
    $d.AddLinearDimV(0.0, 180.0, 180.0, 12.0, "180.00 mm")
    $d.AddLinearDimH(10.0, 170.0, 10.0, -10.0, "160.00 mm CHASSIS RECESS")

    $d.AddTitleBlock(0.0, -42.0, 180.0, 26.0, "ACOUSTIC ISOLATION PLINTH", "SOLID WALNUT / HARDWOOD (18mm)")

    $d.SaveToFile($filePath)
    Write-Output "Generated: $filePath"
}

# ==============================================================================
# 6. SIDE HEATSINK PLATE & FIN PROFILE (160 x 160 mm, AL6061 Extrusion)
# ==============================================================================
function Build-SideHeatsink([string]$filePath) {
    $d = [DxfModel]::new()
    
    # Plate Cut Outline: 160 x 160mm
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect(0.0, 0.0, 160.0, 160.0, 2.0)

    $d.SetLayer("HOLES_DRILL")
    # 4 Corner Chassis Fasteners (M4 Tapped Holes -> Dia 3.3mm for M4 tapping)
    $fasteners = @(@(8.0, 8.0), @(152.0, 8.0), @(152.0, 152.0), @(8.0, 152.0))
    foreach ($f in $fasteners) {
        $d.AddCircle($f[0], $f[1], 1.65)
        $d.AddCrosshair($f[0], $f[1], 8.0)
    }

    # 3x TPA3116D2 Amplifier Board Mounting Grid (Left Flank acts as active heat spreader)
    # Standoff spacing for XH-M562 / Gold A543 board: 30mm (W) x 36mm (H)
    # 3 boards stacked vertically:
    # Board 1 (Front L/R): Center Y = 36.0, X = 80.0
    # Board 2 (Center/Sub): Center Y = 80.0, X = 80.0
    # Board 3 (Surround L/R): Center Y = 124.0, X = 80.0
    $boardY = @(36.0, 80.0, 124.0)
    for ($b = 0; $b -lt 3; $b++) {
        $by = $boardY[$b]
        # 4 mounting holes per board (M3 tapped -> Dia 2.5mm)
        $d.AddCircle(65.0, $by - 18.0, 1.25)
        $d.AddCircle(95.0, $by - 18.0, 1.25)
        $d.AddCircle(95.0, $by + 18.0, 1.25)
        $d.AddCircle(65.0, $by + 18.0, 1.25)

        # Thermal Paste Application Zone (Arctic MX-4)
        $d.SetLayer("ENGRAVE_TEXT")
        $d.AddRoundedRect(68.0, $by - 12.0, 24.0, 24.0, 2.0)
        $d.AddText(70.0, $by - 2.0, 2.2, "ARCTIC MX-4")
        $d.SetLayer("HOLES_DRILL")
    }

    # Extrusion Fin Cross-Section View (Bottom Detail)
    $d.SetLayer("ENGRAVE_TEXT")
    $d.AddText(38.0, 148.0, 3.2, "AL6061 FINNED HEATSINK FLANK (10 FINS)")
    $d.AddText(42.0, 8.0, 2.2, "5mm BASE WALL • 14mm DEEP FINS • 2.5mm THICK")

    # Fin Profile Representation (Section A-A drawn to the right: X from 180 to 220)
    $d.SetLayer("CUT_OUTLINE")
    # Base wall (160mm long x 5mm thick)
    $d.AddLine(180.0, 0.0, 185.0, 0.0)
    $d.AddLine(180.0, 0.0, 180.0, 160.0)
    $d.AddLine(180.0, 160.0, 185.0, 160.0)

    # 10 Extrusion Fins (pitch 15.5mm, depth 14mm, thickness 2.5mm)
    $finSpacing = 140.0 / 9.0
    for ($i = 0; $i -lt 10; $i++) {
        $fy = 10.0 + $i * $finSpacing
        $d.AddLine(185.0, $fy, 199.0, $fy)
        $d.AddLine(199.0, $fy, 199.0, $fy + 2.5)
        $d.AddLine(199.0, $fy + 2.5, 185.0, $fy + 2.5)
        if ($i -lt 9) {
            $nextY = 10.0 + ($i + 1) * $finSpacing
            $d.AddLine(185.0, $fy + 2.5, 185.0, $nextY)
        }
    }
    $d.AddLine(185.0, 0.0, 185.0, 10.0)
    $d.AddLine(185.0, 10.0 + 9 * $finSpacing + 2.5, 185.0, 160.0)

    $d.SetLayer("ENGRAVE_TEXT")
    $d.AddText(182.0, 164.0, 3.0, "SECTION A-A (FIN EXTRUSION)")

    # Dimensions
    $d.AddLinearDimH(0.0, 160.0, 160.0, 12.0, "160.00 mm")
    $d.AddLinearDimV(0.0, 160.0, 160.0, 12.0, "160.00 mm")
    $d.AddLinearDimH(180.0, 199.0, 0.0, -10.0, "19.00 mm TOTAL")

    $d.AddTitleBlock(0.0, -42.0, 160.0, 26.0, "AL6061 HEATSINK FLANK (LEFT/RIGHT)", "AL6061-T6 ALUMINUM EXTRUSION")

    $d.SaveToFile($filePath)
    Write-Output "Generated: $filePath"
}

# ==============================================================================
# 7. COMPLETE MASTER FABRICATION SHEET (600 x 400 mm Laser/CNC Bed)
# ==============================================================================
function Build-MasterFabricationSheet([string]$filePath) {
    $d = [DxfModel]::new()
    
    # Outer Sheet Boundary (600 x 400 mm with 10mm border)
    $d.SetLayer("TITLE_BLOCK")
    $d.AddLine(0.0, 0.0, 600.0, 0.0)
    $d.AddLine(600.0, 0.0, 600.0, 400.0)
    $d.AddLine(600.0, 400.0, 0.0, 400.0)
    $d.AddLine(0.0, 400.0, 0.0, 0.0)

    # Inner Border Frame (580 x 380 mm)
    $d.AddLine(10.0, 10.0, 590.0, 10.0)
    $d.AddLine(590.0, 10.0, 590.0, 390.0)
    $d.AddLine(590.0, 390.0, 10.0, 390.0)
    $d.AddLine(10.0, 390.0, 10.0, 10.0)

    # Master Title Block (Bottom Right: 240 x 50 mm)
    $tbX = 350.0
    $tbY = 10.0
    $d.AddLine($tbX, $tbY, $tbX + 240.0, $tbY)
    $d.AddLine($tbX + 240.0, $tbY, $tbX + 240.0, $tbY + 50.0)
    $d.AddLine($tbX + 240.0, $tbY + 50.0, $tbX, $tbY + 50.0)
    $d.AddLine($tbX, $tbY + 50.0, $tbX, $tbY)
    
    $d.AddLine($tbX, $tbY + 25.0, $tbX + 240.0, $tbY + 25.0)
    $d.AddLine($tbX + 150.0, $tbY, $tbX + 150.0, $tbY + 25.0)

    $d.AddText($tbX + 5.0, $tbY + 36.0, 5.0, "COPPER CHIMNEY V2 — 5.1 CHASSIS")
    $d.AddText($tbX + 5.0, $tbY + 28.0, 3.2, "COMPLETE LASER CUT & CNC MASTER FABRICATION SHEET")
    $d.AddText($tbX + 5.0, $tbY + 14.0, 2.8, "TOLERANCES: LINEAR +/-0.15mm | HOLE DIA +/-0.10mm")
    $d.AddText($tbX + 5.0, $tbY + 4.0, 2.6, "FINISH: FROSTED AMBER & SMOKED POLYCARBONATE / AL6061")
    $d.AddText($tbX + 155.0, $tbY + 14.0, 3.0, "SHEET 1 OF 1")
    $d.AddText($tbX + 155.0, $tbY + 4.0, 2.8, "SCALE: 1:1 (TRUE METRIC)")

    # --------------------------------------------------------------------------
    # Panel A: FRONT BEZEL PANEL at (25, 215)
    # --------------------------------------------------------------------------
    $ax = 25.0; $ay = 215.0
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect($ax, $ay, 160.0, 160.0, 8.0)
    $d.SetLayer("HOLES_DRILL")
    $d.AddRoundedRect($ax + 22.5, $ay + 62.0, 115.0, 72.0, 3.0)
    $d.AddCircle($ax + 80.0, $ay + 36.0, 3.75)
    $d.AddCircle($ax + 80.0, $ay + 26.5, 1.5)
    foreach ($f in @(@(8.0, 8.0), @(152.0, 8.0), @(152.0, 152.0), @(8.0, 152.0))) {
        $d.AddCircle($ax + $f[0], $ay + $f[1], 1.75)
    }
    $d.SetLayer("ENGRAVE_TEXT")
    $d.AddRoundedRect($ax + 48.0, $ay + 82.0, 64.0, 32.0, 4.0)
    $d.AddCircle($ax + 80.0, $ay + 36.0, 18.0)
    $d.AddText($ax + 42.0, $ay + 164.0, 3.2, "[ITEM 1] FRONT BEZEL (4mm AMBER)")

    # --------------------------------------------------------------------------
    # Panel B: REAR I/O PANEL at (205, 215)
    # --------------------------------------------------------------------------
    $bx = 205.0; $by = 215.0
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect($bx, $by, 160.0, 160.0, 8.0)
    $d.SetLayer("HOLES_DRILL")
    $d.AddCircle($bx + 125.0, $by + 68.0, 8.0) # GX16
    $xCols = @(25.0, 41.0, 57.0, 73.0, 89.0, 105.0)
    foreach ($cx in $xCols) {
        $d.AddCircle($bx + $cx, $by + 108.0, 4.0)
        $d.AddCircle($bx + $cx, $by + 82.0, 4.0)
    }
    $d.AddCircle($bx + 40.0, $by + 32.0, 3.0) # AUX
    $d.AddRoundedRect($bx + 105.0, $by + 29.9, 10.0, 4.2, 2.1) # USB-C
    $d.AddCircle($bx + 97.5, $by + 32.0, 1.25)
    $d.AddCircle($bx + 122.5, $by + 32.0, 1.25)
    foreach ($f in @(@(8.0, 8.0), @(152.0, 8.0), @(152.0, 152.0), @(8.0, 152.0))) {
        $d.AddCircle($bx + $f[0], $by + $f[1], 1.75)
    }
    $d.SetLayer("ENGRAVE_TEXT")
    $d.AddCircle($bx + 125.0, $by + 68.0, 10.5)
    $d.AddText($bx + 40.0, $by + 164.0, 3.2, "[ITEM 2] REAR I/O (4-5mm POLYCARBONATE)")

    # --------------------------------------------------------------------------
    # Panel C: TOP CHIMNEY PANEL at (25, 25)
    # --------------------------------------------------------------------------
    $cx = 25.0; $cy = 25.0
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect($cx, $cy, 160.0, 160.0, 8.0)
    $d.SetLayer("HOLES_DRILL")
    $d.AddCircle($cx + 80.0, $cy + 80.0, 17.5) # Central chimney
    foreach ($c in @(@(18.0, 18.0), @(142.0, 18.0), @(142.0, 142.0), @(18.0, 142.0))) {
        $d.AddCircle($cx + $c[0], $cy + $c[1], 7.5)
    }
    foreach ($f in @(@(8.0, 8.0), @(152.0, 8.0), @(152.0, 152.0), @(8.0, 152.0))) {
        $d.AddCircle($cx + $f[0], $cy + $f[1], 1.75)
    }
    $d.SetLayer("ENGRAVE_TEXT")
    $d.AddCircle($cx + 80.0, $cy + 80.0, 22.0)
    $d.AddText($cx + 40.0, $cy + 164.0, 3.2, "[ITEM 3] TOP COVER (4mm AMBER)")

    # --------------------------------------------------------------------------
    # Panel D: BOTTOM CONVECTION PLATE at (205, 25)
    # --------------------------------------------------------------------------
    $dx = 205.0; $dy = 25.0
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect($dx, $dy, 160.0, 160.0, 8.0)
    $d.SetLayer("HOLES_DRILL")
    $d.AddCircle($dx + 80.0, $dy + 80.0, 17.5)
    $d.AddRadialSlots($dx + 80.0, $dy + 80.0, 23.0, 34.0, 8, 3.5)
    foreach ($c in @(@(18.0, 18.0), @(142.0, 18.0), @(142.0, 142.0), @(18.0, 142.0))) {
        $d.AddCircle($dx + $c[0], $dy + $c[1], 7.5)
    }
    foreach ($ft in @(@(22.0, 22.0), @(138.0, 22.0), @(138.0, 138.0), @(22.0, 138.0))) {
        $d.AddCircle($dx + $ft[0], $dy + $ft[1], 2.25)
    }
    foreach ($f in @(@(8.0, 8.0), @(152.0, 8.0), @(152.0, 152.0), @(8.0, 152.0))) {
        $d.AddCircle($dx + $f[0], $dy + $f[1], 1.75)
    }
    $d.SetLayer("ENGRAVE_TEXT")
    $d.AddText($dx + 38.0, $dy + 164.0, 3.2, "[ITEM 4] CHASSIS BASE (5mm POLYCARBONATE)")

    # --------------------------------------------------------------------------
    # Panel E: WOODEN PLINTH BASE at (385, 205)
    # --------------------------------------------------------------------------
    $ex = 385.0; $ey = 205.0
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect($ex, $ey, 180.0, 180.0, 14.0)
    $d.SetLayer("HOLES_DRILL")
    $d.AddCircle($ex + 90.0, $ey + 90.0, 19.0) # Flue bore
    foreach ($a in @(@(32.0, 32.0), @(148.0, 32.0), @(148.0, 148.0), @(32.0, 148.0))) {
        $d.AddCircle($ex + $a[0], $ey + $a[1], 2.25)
    }
    $d.SetLayer("ENGRAVE_TEXT")
    $d.AddCircle($ex + 90.0, $ey + 90.0, 27.0)
    $d.AddRoundedRect($ex + 10.0, $ey + 10.0, 160.0, 160.0, 8.0)
    foreach ($fp in @(@(24.0, 24.0), @(156.0, 24.0), @(156.0, 156.0), @(24.0, 156.0))) {
        $d.AddCircle($ex + $fp[0], $ey + $fp[1], 13.0)
    }
    $d.AddText($ex + 40.0, $ey + 184.0, 3.2, "[ITEM 5] WOOD PLINTH (18mm WALNUT)")

    # --------------------------------------------------------------------------
    # Fabrication Legend
    # --------------------------------------------------------------------------
    $d.SetLayer("TITLE_BLOCK")
    $d.AddText(385.0, 175.0, 3.0, "CAD LAYER MAPPING & COLOR CODES:")
    $d.AddText(385.0, 165.0, 2.5, "• RED (ACI 1)   : CUT_OUTLINE — Laser / CNC perimeter cutting")
    $d.AddText(385.0, 156.0, 2.5, "• GREEN (ACI 3) : HOLES_DRILL — Through-holes, apertures & slots")
    $d.AddText(385.0, 147.0, 2.5, "• CYAN (ACI 4)  : ENGRAVE_TEXT — Surface etching, legends & labels")
    $d.AddText(385.0, 138.0, 2.5, "• YELLOW (ACI 2): DIMENSIONS — Quality inspection measurement lines")
    $d.AddText(385.0, 129.0, 2.5, "• WHITE (ACI 7) : TITLE_BLOCK — ISO/ANSI drawing frames & borders")

    $d.SaveToFile($filePath)
    Write-Output "Generated: $filePath"
}

# ==============================================================================
# 8. MULTI-VIEW ASSEMBLY ORTHOGRAPHIC DRAWING (ISO A1: 840 x 594 mm)
# ==============================================================================
function Build-MultiViewAssembly([string]$filePath) {
    $d = [DxfModel]::new()

    # Outer Sheet Boundary (840 x 594 mm - Standard ISO A1)
    $d.SetLayer("TITLE_BLOCK")
    $d.AddLine(0.0, 0.0, 840.0, 0.0)
    $d.AddLine(840.0, 0.0, 840.0, 594.0)
    $d.AddLine(840.0, 594.0, 0.0, 594.0)
    $d.AddLine(0.0, 594.0, 0.0, 0.0)

    # Inner Border Frame (20mm margin)
    $d.AddLine(20.0, 20.0, 820.0, 20.0)
    $d.AddLine(820.0, 20.0, 820.0, 574.0)
    $d.AddLine(820.0, 574.0, 20.0, 574.0)
    $d.AddLine(20.0, 574.0, 20.0, 20.0)

    # --------------------------------------------------------------------------
    # VIEW 1: FRONT ELEVATION VIEW (Center: X=160, Y=160)
    # --------------------------------------------------------------------------
    $fx = 70.0; $fy = 60.0
    $d.SetLayer("TITLE_BLOCK")
    $d.AddText($fx + 25.0, $fy + 225.0, 4.0, "VIEW A: FRONT ELEVATION")

    # Solid Wood Plinth Base: 180mm W x 18mm H (R14 corners)
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect($fx - 10.0, $fy, 180.0, 18.0, 6.0)

    # Chassis Body: 160mm W x 160mm H (resting at Y = fy + 18)
    $cy = $fy + 18.0
    $d.AddRoundedRect($fx, $cy, 160.0, 160.0, 8.0)

    # Left & Right Heatsink Fins (Extending outward on flanks)
    # Left flank fins (10 fins spaced along height)
    for ($i = 0; $i -lt 10; $i++) {
        $finY = $cy + 10.0 + $i * 15.5
        $d.AddLine($fx, $finY, $fx - 12.0, $finY)
        $d.AddLine($fx - 12.0, $finY, $fx - 12.0, $finY + 2.5)
        $d.AddLine($fx - 12.0, $finY + 2.5, $fx, $finY + 2.5)
    }
    # Right flank fins
    for ($i = 0; $i -lt 10; $i++) {
        $finY = $cy + 10.0 + $i * 15.5
        $d.AddLine($fx + 160.0, $finY, $fx + 172.0, $finY)
        $d.AddLine($fx + 172.0, $finY, $fx + 172.0, $finY + 2.5)
        $d.AddLine($fx + 172.0, $finY + 2.5, $fx + 160.0, $finY + 2.5)
    }

    # Top Central Chimney Protrusion (Protrudes 14mm above chassis)
    $topY = $cy + 160.0
    $chimX = $fx + 80.0
    $d.AddLine($chimX - 17.5, $topY, $chimX - 17.5, $topY + 14.0)
    $d.AddLine($chimX + 17.5, $topY, $chimX + 17.5, $topY + 14.0)
    $d.AddLine($chimX - 17.5, $topY + 14.0, $chimX + 17.5, $topY + 14.0)
    # Collar Lip (OD 44mm, H 4mm)
    $d.AddRoundedRect($chimX - 22.0, $topY + 6.0, 44.0, 5.0, 1.5)

    # 4 Corner Pillars Top Studs
    $d.AddLine($fx + 18.0 - 7.5, $topY, $fx + 18.0 - 7.5, $topY + 3.0)
    $d.AddLine($fx + 18.0 + 7.5, $topY, $fx + 18.0 + 7.5, $topY + 3.0)
    $d.AddLine($fx + 18.0 - 7.5, $topY + 3.0, $fx + 18.0 + 7.5, $topY + 3.0)
    $d.AddLine($fx + 142.0 - 7.5, $topY, $fx + 142.0 - 7.5, $topY + 3.0)
    $d.AddLine($fx + 142.0 + 7.5, $topY, $fx + 142.0 + 7.5, $topY + 3.0)
    $d.AddLine($fx + 142.0 - 7.5, $topY + 3.0, $fx + 142.0 + 7.5, $topY + 3.0)

    # Front Panel Features:
    # 1. LCD / OLED Screen Window (115 x 72mm)
    $d.SetLayer("HOLES_DRILL")
    $d.AddRoundedRect($fx + 22.5, $cy + 62.0, 115.0, 72.0, 3.0)
    # 2. Rotary Volume Knob (Dia 36mm)
    $d.AddCircle($chimX, $cy + 36.0, 18.0)
    $d.AddCircle($chimX, $cy + 36.0, 15.0)

    # Centerlines
    $d.SetLayer("CENTERLINES")
    $d.AddLine($chimX, $fy - 10.0, $chimX, $topY + 25.0) # Vertical main centerline
    $d.AddCrosshair($chimX, $cy + 36.0, 12.0)

    # Engraved Graphics
    $d.SetLayer("ENGRAVE_TEXT")
    $d.AddText($chimX - 22.0, $cy + 104.0, 3.5, "COPPER CHIMNEY V2")
    $d.AddText($chimX - 16.0, $cy + 94.0, 3.0, "[ 120W AMP ]")
    $d.AddText($chimX - 12.0, $cy + 82.0, 2.5, "6-CH VU METERS")
    $d.AddText($chimX - 9.0, $cy + 14.0, 2.6, "VOLUME")
    $d.AddText($fx + 10.0, $fy + 6.0, 2.4, "SOLID WALNUT ACOUSTIC ISOLATION PLINTH (18mm)")

    # Dimensions on Front View
    $d.AddLinearDimH($fx, $fx + 160.0, $fy, -14.0, "160.00 mm CHASSIS")
    $d.AddLinearDimH($fx - 10.0, $fx + 170.0, $fy, -28.0, "180.00 mm PLINTH")
    $d.AddLinearDimV($fy, $fy + 18.0, $fx - 10.0, -12.0, "18.00")
    $d.AddLinearDimV($cy, $topY, $fx - 10.0, -22.0, "160.00 mm")
    $d.AddLinearDimV($fy, $topY + 14.0, $fx + 170.0, 20.0, "192.00 mm TOTAL HEIGHT")

    # --------------------------------------------------------------------------
    # VIEW 2: TOP PLAN VIEW (Center: X=160, Y=430, vertically aligned above Front View)
    # --------------------------------------------------------------------------
    $tx = $fx; $ty = 330.0
    $d.SetLayer("TITLE_BLOCK")
    $d.AddText($tx + 30.0, $ty + 205.0, 4.0, "VIEW B: TOP PLAN VIEW")

    # Plinth Base (dashed/etched reference outline 180x180)
    $d.SetLayer("CENTERLINES")
    $d.AddRoundedRect($tx - 10.0, $ty - 10.0, 180.0, 180.0, 14.0)

    # Top Plate (160x160 R8)
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect($tx, $ty, 160.0, 160.0, 8.0)

    # Central Copper Chimney (Dia 35mm through-flue + Dia 44mm collar)
    $d.SetLayer("HOLES_DRILL")
    $d.AddCircle($tx + 80.0, $ty + 80.0, 17.5) # Flue bore
    $d.SetLayer("CUT_OUTLINE")
    $d.AddCircle($tx + 80.0, $ty + 80.0, 22.0) # Outer collar ring

    # 4 Corner Copper Pillars (Dia 15mm)
    $d.SetLayer("HOLES_DRILL")
    foreach ($c in @(@(18.0, 18.0), @(142.0, 18.0), @(142.0, 142.0), @(18.0, 142.0))) {
        $d.AddCircle($tx + $c[0], $ty + $c[1], 7.5)
        $d.AddCrosshair($tx + $c[0], $ty + $c[1], 18.0)
    }

    # Left & Right Extruded Fins (depth 14mm, thickness 2.5mm)
    $d.SetLayer("CUT_OUTLINE")
    for ($i = 0; $i -lt 10; $i++) {
        $fz = $ty + 10.0 + $i * 15.5
        # Left fins
        $d.AddLine($tx, $fz, $tx - 14.0, $fz)
        $d.AddLine($tx - 14.0, $fz, $tx - 14.0, $fz + 2.5)
        $d.AddLine($tx - 14.0, $fz + 2.5, $tx, $fz + 2.5)
        # Right fins
        $d.AddLine($tx + 160.0, $fz, $tx + 174.0, $fz)
        $d.AddLine($tx + 174.0, $fz, $tx + 174.0, $fz + 2.5)
        $d.AddLine($tx + 174.0, $fz + 2.5, $tx + 160.0, $fz + 2.5)
    }

    # Volume Knob Protrusion at bottom (Front edge)
    $d.AddRoundedRect($tx + 80.0 - 18.0, $ty - 16.0, 36.0, 16.0, 4.0)

    # Rear Binding Posts Protrusion at top (Back edge)
    $xCols = @(25.0, 41.0, 57.0, 73.0, 89.0, 105.0)
    foreach ($rc in $xCols) {
        $d.AddRoundedRect($tx + $rc - 4.0, $ty + 160.0, 8.0, 14.0, 2.0)
    }

    # Centerlines on Top View
    $d.SetLayer("CENTERLINES")
    $d.AddCrosshair($tx + 80.0, $ty + 80.0, 50.0)
    # Vertical projection guideline linking Top to Front
    $d.AddLine($tx + 80.0, $ty - 20.0, $tx + 80.0, $cy + 160.0)

    # Engraved labels
    $d.SetLayer("ENGRAVE_TEXT")
    $d.AddText($tx + 60.0, $ty + 85.0, 3.2, "CHIMNEY O35mm")
    $d.AddText($tx + 62.0, $ty + 75.0, 2.5, "NATURAL EXHAUST")
    $d.AddText($tx + 38.0, $ty - 22.0, 2.6, "[FRONT - VOLUME DIAL]")
    $d.AddText($tx + 38.0, $ty + 180.0, 2.6, "[REAR - SPEAKER TERMINALS]")

    # Dimensions on Top View
    $d.AddLinearDimV($ty, $ty + 160.0, $tx - 14.0, -18.0, "160.00 mm BODY")
    $d.AddLinearDimH($tx - 14.0, $tx + 174.0, $ty + 160.0, 24.0, "188.00 mm OVER FINS")

    # --------------------------------------------------------------------------
    # VIEW 3: LEFT SIDE PROFILE & THERMAL FLOW (Center: X=400, Y=160, horizontal with Front)
    # --------------------------------------------------------------------------
    $sx = 320.0; $sy = $fy
    $d.SetLayer("TITLE_BLOCK")
    $d.AddText($sx + 20.0, $sy + 225.0, 4.0, "VIEW C: LEFT SIDE SECTION & HEATSINK")

    # Plinth Base (180 D x 18 H)
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect($sx - 10.0, $sy, 180.0, 18.0, 6.0)

    # Heatsink Base Plate (160 D x 160 H, 5mm wall)
    $scy = $sy + 18.0
    $d.AddRoundedRect($sx, $scy, 160.0, 160.0, 2.0)

    # 10 Extruded Cooling Fins visible on side
    for ($i = 0; $i -lt 10; $i++) {
        $fz = $sx + 10.0 + $i * 15.5
        $d.AddLine($fz, $scy, $fz, $scy + 160.0)
        $d.AddLine($fz + 2.5, $scy, $fz + 2.5, $scy + 160.0)
    }

    # Volume Knob Protrusion on Front (Right edge of this view)
    $d.AddRoundedRect($sx + 160.0, $scy + 36.0 - 18.0, 16.0, 36.0, 3.0)

    # Rear Binding Posts Protrusion on Back (Left edge of this view)
    $d.AddRoundedRect($sx - 16.0, $scy + 82.0 - 5.0, 16.0, 10.0, 2.0)
    $d.AddRoundedRect($sx - 16.0, $scy + 108.0 - 5.0, 16.0, 10.0, 2.0)

    # Top Central Chimney
    $d.AddLine($sx + 80.0 - 17.5, $scy + 160.0, $sx + 80.0 - 17.5, $scy + 174.0)
    $d.AddLine($sx + 80.0 + 17.5, $scy + 160.0, $sx + 80.0 + 17.5, $scy + 174.0)
    $d.AddLine($sx + 80.0 - 17.5, $scy + 174.0, $sx + 80.0 + 17.5, $scy + 174.0)
    $d.AddRoundedRect($sx + 80.0 - 22.0, $scy + 166.0, 44.0, 5.0, 1.5)

    # Internal Hidden Features: Central Chimney Flue & Airflow Vectors
    $d.SetLayer("CENTERLINES")
    # Internal chimney pipe running down to bottom
    $d.AddLine($sx + 80.0 - 17.5, $scy, $sx + 80.0 - 17.5, $scy + 160.0)
    $d.AddLine($sx + 80.0 + 17.5, $scy, $sx + 80.0 + 17.5, $scy + 160.0)
    $d.AddCrosshair($sx + 80.0, $scy + 80.0, 20.0)

    # Airflow Draft Arrows
    $d.SetLayer("ENGRAVE_TEXT")
    $d.AddText($sx + 74.0, $scy + 30.0, 3.0, "▲ ▲")
    $d.AddText($sx + 74.0, $scy + 80.0, 3.0, "▲ ▲")
    $d.AddText($sx + 74.0, $scy + 130.0, 3.0, "▲ ▲")
    $d.AddText($sx + 52.0, $scy + 90.0, 2.5, "NATURAL DRAFT")

    $d.AddText($sx + 15.0, $scy + 148.0, 2.8, "10x AL6061 COOLING FINS")
    $d.AddText($sx + 15.0, $scy + 140.0, 2.2, "22.0W PASSIVE HEAT REJECTION")

    # Dimensions on Side View
    $d.AddLinearDimH($sx, $sx + 160.0, $scy, -14.0, "160.00 mm DEPTH")
    $d.AddLinearDimH($sx + 160.0, $sx + 176.0, $scy + 36.0, 12.0, "16.00")

    # --------------------------------------------------------------------------
    # VIEW 4: REAR I/O ELEVATION VIEW (Center: X=400, Y=430)
    # --------------------------------------------------------------------------
    $rx = $sx; $ry = $ty
    $d.SetLayer("TITLE_BLOCK")
    $d.AddText($rx + 30.0, $ry + 205.0, 4.0, "VIEW D: REAR I/O ELEVATION")

    # Plinth Base
    $d.SetLayer("CUT_OUTLINE")
    $d.AddRoundedRect($rx - 10.0, $ry, 180.0, 18.0, 6.0)

    # Chassis Body
    $rcy = $ry + 18.0
    $d.AddRoundedRect($rx, $rcy, 160.0, 160.0, 8.0)

    # Top Chimney Protrusion
    $d.AddLine($rx + 80.0 - 17.5, $rcy + 160.0, $rx + 80.0 - 17.5, $rcy + 174.0)
    $d.AddLine($rx + 80.0 + 17.5, $rcy + 160.0, $rx + 80.0 + 17.5, $rcy + 174.0)
    $d.AddLine($rx + 80.0 - 17.5, $rcy + 174.0, $rx + 80.0 + 17.5, $rcy + 174.0)
    $d.AddRoundedRect($rx + 80.0 - 22.0, $rcy + 166.0, 44.0, 5.0, 1.5)

    # Rear I/O Cutouts & Connectors:
    $d.SetLayer("HOLES_DRILL")
    # GX16 Aviation Socket (Center (125, 68))
    $d.AddCircle($rx + 125.0, $rcy + 68.0, 8.0)
    # 12 Binding Posts (Rows Y=82, Y=108, cols 25..105)
    foreach ($colX in @(25.0, 41.0, 57.0, 73.0, 89.0, 105.0)) {
        $d.AddCircle($rx + $colX, $rcy + 108.0, 4.0)
        $d.AddCircle($rx + $colX, $rcy + 82.0, 4.0)
    }
    # AUX Jack
    $d.AddCircle($rx + 40.0, $rcy + 32.0, 3.0)
    # USB-C Slot
    $d.AddRoundedRect($rx + 105.0, $rcy + 29.9, 10.0, 4.2, 2.1)
    # Convection Slits (Bottom)
    foreach ($slX in @(35.0, 60.0, 85.0, 110.0)) {
        $d.AddRoundedRect($rx + $slX - 9.0, $rcy + 13.0, 18.0, 3.5, 1.75)
    }

    # Engraved Port Markings
    $d.SetLayer("ENGRAVE_TEXT")
    $d.AddCircle($rx + 125.0, $rcy + 68.0, 10.5)
    $d.AddText($rx + 114.0, $rcy + 52.0, 2.3, "24V 14.6A")
    $d.AddText($rx + 117.0, $rcy + 47.0, 2.0, "GX16-4")
    $d.AddText($rx + 22.0, $rcy + 124.0, 2.6, "5.1 HIGH-CURRENT BINDING POSTS")
    $lbls = @("FL", "FR", "C", "SL", "SR", "SUB")
    $cols = @(25.0, 41.0, 57.0, 73.0, 89.0, 105.0)
    for ($k = 0; $k -lt 6; $k++) {
        $d.AddText($rx + $cols[$k] - 2.5, $rcy + 115.0, 2.3, $lbls[$k])
        $d.AddText($rx + $cols[$k] - 1.5, $rcy + 95.0, 2.3, "+")
        $d.AddText($rx + $cols[$k] - 1.5, $rcy + 71.0, 2.3, "-")
    }
    $d.AddText($rx + 32.0, $rcy + 22.0, 2.2, "AUX IN")
    $d.AddText($rx + 100.0, $rcy + 22.0, 2.2, "USB-C")

    # Dimensions on Rear View
    $d.AddLinearDimH($rx + 25.0, $rx + 105.0, $rcy + 108.0, 26.0, "80.00 mm PITCH")

    # --------------------------------------------------------------------------
    # VIEW 5: 3D ISOMETRIC AXONOMETRIC WIREFRAME (X=660, Y=330)
    # --------------------------------------------------------------------------
    $ix = 650.0; $iy = 330.0
    $d.SetLayer("TITLE_BLOCK")
    $d.AddText($ix - 40.0, $iy + 205.0, 4.0, "VIEW E: 3D ISOMETRIC VIEW")

    $d.SetLayer("CUT_OUTLINE")
    # Isometric axes vectors (30 deg): cos(30)=0.866, sin(30)=0.5
    # Iso origin at (ix, iy)
    # Base Box (180x180x18mm) scaled down to 0.70x for fit
    $s = 0.70
    $cos30 = 0.866 * $s
    $sin30 = 0.500 * $s

    # Plinth Base Isometric corners
    # (x, y, z) -> isoX = ix + (x - z) * cos30, isoY = iy + (x + z) * sin30 + y * s
    function Get-Iso([double]$x, [double]$y, [double]$z) {
        $px = $ix + ($x - $z) * $cos30
        $py = $iy + ($x + $z) * $sin30 + $y * $s
        return @($px, $py)
    }

    # Plinth 8 vertices (0..180 in X, 0..18 in Y, 0..180 in Z)
    $p000 = Get-Iso 0 0 0
    $p100 = Get-Iso 180 0 0
    $p101 = Get-Iso 180 0 180
    $p001 = Get-Iso 0 0 180
    $p010 = Get-Iso 0 18 0
    $p110 = Get-Iso 180 18 0
    $p111 = Get-Iso 180 18 180
    $p011 = Get-Iso 0 18 180

    # Plinth Base lines
    $d.AddLine($p000[0], $p000[1], $p100[0], $p100[1])
    $d.AddLine($p100[0], $p100[1], $p101[0], $p101[1])
    $d.AddLine($p101[0], $p101[1], $p001[0], $p001[1])
    $d.AddLine($p001[0], $p001[1], $p000[0], $p000[1])

    $d.AddLine($p010[0], $p010[1], $p110[0], $p110[1])
    $d.AddLine($p110[0], $p110[1], $p111[0], $p111[1])
    $d.AddLine($p111[0], $p111[1], $p011[0], $p011[1])
    $d.AddLine($p011[0], $p011[1], $p010[0], $p010[1])

    $d.AddLine($p000[0], $p000[1], $p010[0], $p010[1])
    $d.AddLine($p100[0], $p100[1], $p110[0], $p110[1])
    $d.AddLine($p101[0], $p101[1], $p111[0], $p111[1])
    $d.AddLine($p001[0], $p001[1], $p011[0], $p011[1])

    # Chassis Body Isometric (10..170 in X, 18..178 in Y, 10..170 in Z)
    $c000 = Get-Iso 10 18 10
    $c100 = Get-Iso 170 18 10
    $c101 = Get-Iso 170 18 170
    $c001 = Get-Iso 10 18 170
    $c010 = Get-Iso 10 178 10
    $c110 = Get-Iso 170 178 10
    $c111 = Get-Iso 170 178 170
    $c011 = Get-Iso 10 178 170

    $d.AddLine($c010[0], $c010[1], $c110[0], $c110[1])
    $d.AddLine($c110[0], $c110[1], $c111[0], $c111[1])
    $d.AddLine($c111[0], $c111[1], $c011[0], $c011[1])
    $d.AddLine($c011[0], $c011[1], $c010[0], $c010[1])

    $d.AddLine($c000[0], $c000[1], $c010[0], $c010[1])
    $d.AddLine($c100[0], $c100[1], $c110[0], $c110[1])
    $d.AddLine($c101[0], $c101[1], $c111[0], $c111[1])
    $d.AddLine($c001[0], $c001[1], $c011[0], $c011[1])

    # Front LCD display screen on face (Z=10 plane)
    $d.SetLayer("HOLES_DRILL")
    $sc1 = Get-Iso 35 80 10
    $sc2 = Get-Iso 145 80 10
    $sc3 = Get-Iso 145 150 10
    $sc4 = Get-Iso 35 150 10
    $d.AddLine($sc1[0], $sc1[1], $sc2[0], $sc2[1])
    $d.AddLine($sc2[0], $sc2[1], $sc3[0], $sc3[1])
    $d.AddLine($sc3[0], $sc3[1], $sc4[0], $sc4[1])
    $d.AddLine($sc4[0], $sc4[1], $sc1[0], $sc1[1])

    # Volume Knob on Front face (Z=10)
    $knobCenter = Get-Iso 90 54 10
    $d.AddCircle($knobCenter[0], $knobCenter[1], 12.0 * $s)

    # Top Central Chimney Cylinder (Center (90, 178, 90))
    $d.SetLayer("CUT_OUTLINE")
    $chBot = Get-Iso 90 178 90
    $chTop = Get-Iso 90 192 90
    $d.AddCircle($chBot[0], $chBot[1], 12.0 * $s)
    $d.AddCircle($chTop[0], $chTop[1], 12.0 * $s)
    $d.AddLine($chBot[0] - 12.0 * $s, $chBot[1], $chTop[0] - 12.0 * $s, $chTop[1])
    $d.AddLine($chBot[0] + 12.0 * $s, $chBot[1], $chTop[0] + 12.0 * $s, $chTop[1])

    # Side cooling fins on Right side (X=170 face)
    for ($k = 0; $k -lt 6; $k++) {
        $fz1 = Get-Iso 170 (30 + $k * 24) 25
        $fz2 = Get-Iso 170 (30 + $k * 24) 155
        $d.AddLine($fz1[0], $fz1[1], $fz2[0], $fz2[1])
    }

    # --------------------------------------------------------------------------
    # MASTER ISO/ANSI TITLE BLOCK (Bottom Right: X=540..820, Y=20..110)
    # --------------------------------------------------------------------------
    $tbX = 540.0; $tbY = 20.0
    $d.SetLayer("TITLE_BLOCK")
    $d.AddLine($tbX, $tbY, 820.0, $tbY)
    $d.AddLine(820.0, $tbY, 820.0, $tbY + 90.0)
    $d.AddLine(820.0, $tbY + 90.0, $tbX, $tbY + 90.0)
    $d.AddLine($tbX, $tbY + 90.0, $tbX, $tbY)

    $d.AddLine($tbX, $tbY + 45.0, 820.0, $tbY + 45.0)
    $d.AddLine($tbX + 175.0, $tbY, $tbX + 175.0, $tbY + 45.0)

    # Standard 3rd Angle Projection Symbol
    $pSymX = $tbX + 230.0; $pSymY = $tbY + 68.0
    # Concentric circles
    $d.AddCircle($pSymX + 22.0, $pSymY, 5.0)
    $d.AddCircle($pSymX + 22.0, $pSymY, 10.0)
    $d.AddCrosshair($pSymX + 22.0, $pSymY, 24.0)
    # Truncated cone
    $d.AddLine($pSymX - 10.0, $pSymY - 10.0, $pSymX + 6.0, $pSymY - 5.0)
    $d.AddLine($pSymX + 6.0, $pSymY - 5.0, $pSymX + 6.0, $pSymY + 5.0)
    $d.AddLine($pSymX + 6.0, $pSymY + 5.0, $pSymX - 10.0, $pSymY + 10.0)
    $d.AddLine($pSymX - 10.0, $pSymY + 10.0, $pSymX - 10.0, $pSymY - 10.0)
    $d.AddLine($pSymX - 14.0, $pSymY, $pSymX + 10.0, $pSymY)

    $d.AddText($tbX + 8.0, $tbY + 75.0, 5.0, "COPPER CHIMNEY V2")
    $d.AddText($tbX + 8.0, $tbY + 65.0, 3.6, "5.1 AUDIOPHILE CHASSIS")
    $d.AddText($tbX + 8.0, $tbY + 53.0, 3.0, "MULTI-VIEW ORTHOGRAPHIC ASSEMBLY BLUEPRINT")

    $d.AddText($tbX + 8.0, $tbY + 34.0, 2.8, "DRAWING NO: CC-V2-ASM-01")
    $d.AddText($tbX + 8.0, $tbY + 22.0, 2.8, "TOLERANCES: +/-0.15mm | ANGLE +/-0.2 DEG")
    $d.AddText($tbX + 8.0, $tbY + 8.0, 2.4, "MATL: AL6061-T6 / AMBER POLYCARB / WALNUT")

    $d.AddText($tbX + 182.0, $tbY + 34.0, 2.7, "SCALE: 1:1 METRIC")
    $d.AddText($tbX + 182.0, $tbY + 22.0, 2.5, "PROJECTION: 3RD ANGLE")
    $d.AddText($tbX + 182.0, $tbY + 10.0, 2.4, "UNITS: MILLIMETERS")

    $d.SaveToFile($filePath)
    Write-Output "Generated: $filePath"
}

# Run All Builders
Build-TopPanel (Join-Path $OutputDir "PANEL_TOP_CHIMNEY.dxf")
Build-BottomPanel (Join-Path $OutputDir "PANEL_BOTTOM_BASE.dxf")
Build-FrontPanel (Join-Path $OutputDir "PANEL_FRONT.dxf")
Build-RearPanel (Join-Path $OutputDir "PANEL_REAR_IO.dxf")
Build-PlinthWoodBase (Join-Path $OutputDir "PLINTH_WOOD_BASE.dxf")
Build-SideHeatsink (Join-Path $OutputDir "PANEL_SIDE_HEATSINK.dxf")
Build-MasterFabricationSheet (Join-Path $OutputDir "CHASSIS_MASTER_FABRICATION_SHEET.dxf")
Build-MultiViewAssembly (Join-Path $OutputDir "CHASSIS_MULTI_VIEW_ASSEMBLY.dxf")

Write-Output "ALL 8 DXF FILES (INCLUDING MULTI-VIEW ASSEMBLY) GENERATED SUCCESSFULLY IN $OutputDir"

