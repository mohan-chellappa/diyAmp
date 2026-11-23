# DIY 5.1 / 8-Output Amplifier — Mechanical Design Drawing & Standard Off-The-Shelf Fastener BOM

> **Interactive Blueprint & Filterable BOM:** [Open Interactive CAD Blueprint & Fastener Schedule (AMP_DESIGN_DRAWING.html)](file:///d:/Documents/DIY%20Amp/AMP_DESIGN_DRAWING.html)  
> **Machine-Readable TSV Dataset:** [AMP_MECHANICAL_BOM.tsv](file:///d:/Documents/DIY%20Amp/AMP_MECHANICAL_BOM.tsv)  
> **Proper Amp + Copper Through-Pipe Detail:** [proper_xh_m562_copper_through_pipe.jpg](file:///d:/Documents/DIY%20Amp/image/proper_xh_m562_copper_through_pipe.jpg)  
> **Corrected 3-Pipe Full Enclosure Cutaway:** [triple_copper_pipe_amp_layout.jpg](file:///d:/Documents/DIY%20Amp/image/triple_copper_pipe_amp_layout.jpg)

---

## 1. Dimensional Specification (`160 × 160 × 95 mm` Body + `15 mm` Feet)

```
                      TOP ORTHOGRAPHIC VIEW (160.0 × 160.0 mm)
          LEFT = 24V AMP ZONE             │           RIGHT = 5V CLEAN DAC ZONE
       ┌──────────────────────────────────┼───────────────────────────────────┐
       │  (●) M-06 (14,14)    [ 2× WAGO + 4700µF + XL4015 + ADC ]    M-06 (●) │
       │   ║                              │                               ║   │
       │  M-01  ╔══╦════════════╗         │          ┌──────────────┐   Right │
       │  Left  ║8m║ AMP #1     ║ ◄───────┼──────────┤ DAC #1 (I2S) │   Clean │
       │  5mm   ║Al║ (Pins In!) ║         │          └──────────────┘   Wall  │
       │  Alu   ║Br╠════════════╣    ╔═════════╗     ┌──────────────┐         │
       │  Wall  ║id║ AMP #2     ║ ◄──╣ Ø35.0mm ╠─────┤ DAC #2 (I2S) │         │
       │ (+Outer║ge║ (Pins In!) ║    ║  FLUSH  ║     └──────────────┘         │
       │  PC Fin║Ba╠════════════╣    ╚╣CHIMNEY╠╝     ┌──────────────┐         │
       │  if req║r ║ AMP #3     ║ ◄───╚═══╪═══╝──────┤ DAC #3 (I2S) │         │
       │   !)   ╚══╩════════════╝         │          └──────▲───────┘         │
       │                                  │    [ESP32-Pico]─┘                 │
       │  (●) M-06 (14,146)               │              [M-10 Vol] (●) M-06  │
       └───────────────╔══════════════════╧═════════════════╗─────────────────┘
                       ╚══ M-07: Click-In 4.3" Touch Dock ══╝
```

### Key Dimensions & Drilling Coordinates
1. **Overall Footprint:** `160.0 mm (W) × 160.0 mm (D) × 95.0 mm (Body H)` (`110.0 mm` total height including `15.0 mm` rubber feet `M-23`).
2. **Internal Chamber Height:** `87.0 mm` clear height between the `4.0 mm` Top Plate and `5.0 mm` Bottom Plate (`4 + 87 + 5 = 96 mm` nominal).
3. **Central Flush Copper Chimney (`M-03` + `M-04`):**
   * Center at `X = 80.0 mm, Y = 80.0 mm`.
   * Hole diameter in Top & Bottom plates: `Ø35.5 mm`.
   * Copper pipe length: `94.0 mm` (sits flush inside top and bottom plates, sealed by `2× Ø35×3 mm` O-rings `M-25` and topped by a standard `1.5"` bevelled copper/brass flare collar `M-04`).
4. **4× Corner Copper Pillars (`M-05` + `M-06` + `M-12/13/14`):**
   * Centers at `(14.0, 14.0)`, `(146.0, 14.0)`, `(14.0, 146.0)`, `(146.0, 146.0)` (`132.0 mm` square bolt pattern).
   * `Ø15.0 mm × 87.0 mm` copper sleeves clamped by `M4 × 115 mm` SS304 studs (`M-12`), `M4 × 20 mm` coupling nuts (`M-14`), `M4 × 12 mm` CSK top screws (`M-13`) seated in flat-sanded `15 mm` copper end-caps (`M-06`), and `M4` Nyloc nuts (`M-24`) inside the `Ø25 × 15 mm` bottom rubber feet (`M-23`).
5. **Front Click-In 4.3" Touch Screen Dock (`M-07` + `M-08`):**
   * Uses 3 strips of standard `18 mm` U-channel trim (`Left = 78 mm`, `Right = 78 mm`, `Bottom = 116 mm`) with a right-angle **Magnetic USB-C charging adapter (`M-08`)** centered in the bottom rail.
6. **Front-Right Sideways `15 mm` `V`-Line Volume Wheel (`M-10` + `M-11`):**
   * Standard `Ø30 × 15 mm` knurled brass/copper audio knob (`M-10`) mounted horizontally on an internal `20 mm` L-bracket (`M-16`) so `4 mm` of its knurled rim protrudes through an `8 × 16 mm` vertical slot at the front-right edge.
   * Wrapped with a `70 mm × 15 mm` right-triangle strip of **Gold/Copper Reflective Tape** (`0 mm` tip at Mute → `15 mm` full height at 100% Volume).
7. **Rear Non-Conductive `5 mm` Polycarbonate I/O Panel (`150 × 87 mm`):**
   * **16× `Ø8.0 mm` holes** in 2 rows of 8 (`16.5 mm` horizontal pitch, `22.0 mm` vertical row spacing) for Outputs `#1` through `#8` (`JS-910B` binding posts).
   * **1× `Ø16.0 mm` hole** (bottom-right) for the `GX16 4-Pin` 24V aviation power socket.
   * **1× `Ø6.0 mm` hole** (bottom-left) for the `PJ392A-1` 3.5mm stereo AUX jack.
   * **1× `9.5 × 3.8 mm` oval slot + `2× Ø2.6 mm` holes** (bottom-center) for the `USB-C` service port (`M2.5 × 8 mm` screws `M-21`).

---

## 2. Complete Standard Off-The-Shelf Mechanical & Fastener BOM (`M-01` to `M-26`)

| ID | Sub-Assembly | Part Name | Standard Off-The-Shelf Spec | Dimensions / Thread | Material / Finish | Qty | Rate (₹) | Total (₹) | Local Pune Source | Exact Mounting Location |
| :---: | :--- | :--- | :--- | :--- | :--- | :---: | :---: | :---: | :--- | :--- |
| **M-01** | Left Fin Wall + L-Bridges | `AL6061` Finned Wall + `3×` L-Angle Bridges | `150×87×25 mm` External Finned Wall (`480 cm²`, catches room fan/AC!) + `3× 25×25×4mm` L-Bridges | `150×87×25 mm` + `3×` L-Bridges | AL6061 Black + Copper/Alu | 1 set | 500 | **500** | Pioneer Market | External fins catch room fan/AC breeze (`30W+`); `3×` L-Bridges press onto TOP of the `3×` horizontal `TPA3116D2` chips |
| **M-02** | 5-Face Plates | Laser-Cut Polycarbonate / Matte Acrylic Set | `4mm` Top + `5mm` Bot + `4mm` Right Wall + `4mm` Front + `5mm` Rear | `160×160 mm` (2), `150×87 mm` (3) | Polycarbonate / Matte Acrylic | 1 set | 580 | **580** | Pimpri Plastics | 5 closed plates (Left wall is `M-01` External Finned Heatsink) |
| **M-03** | Central Chimney | Standard `1-3/8"` (`Ø35mm`) AC Copper Pipe | Standard HVAC Rigid Copper Tube cut flush (residual internal heat) | `OD 35.0 × 1.2 × 94 mm` | C1100 Pure Copper | 1 pc | 280 | **280** | Bhosari AC Spares | Center `(80,80)` sealed through-pipe for residual internal warmth |
| **M-04** | Chimney Collar | Standard `1.5"` Copper/Brass Flare Collar | Plumbing Waste Coupling Ring / Heavy Curtain Eyelet | `ID 35 × OD 48 mm` bevelled | Brushed Copper / Brass | 1 pc | 45 | **45** | Nana Peth Hardware | Flush top rim around `Ø35.5 mm` center hole |
| **M-05** | Corner Pillars | Standard `1/2"` AC Copper Pipe Sleeves | Standard `15 mm` OD Rigid Copper Tube | `OD 15.0 × ID 13.0 × 87 mm` | C1100 Pure Copper | 4 pcs | 50 | **200** | Bhosari AC Spares | 4 corners `(14/146, 14/146)` between Top & Bottom |
| **M-06** | Corner Discs | Standard `15 mm` Copper Plumbing End-Caps | Flat-sanded top face with `Ø4.2 mm` center hole | `OD 16.5 × 8 mm` | C1100 Pure Copper | 4 pcs | 20 | **80** | Bhosari AC Spares | Flush corner inlays on Top Plate |
| **M-07** | Touch Dock Rails | Standard `18 mm` U-Channel Edge Profile | Left (`78mm`), Right (`78mm`), Bottom (`116mm`) | `18 mm` U-width × `8 mm` leg | Black / Copper Aluminum | 1 set | 80 | **80** | Pimpri Glass Hardware | Front click-in cradle for Waveshare 4.3B (`115×78×17mm`) |
| **M-08** | Dock Charger | Right-Angle Magnetic USB-C Adapter | 90° L-head magnetic breakaway tip + `20cm` 5V lead | `5V 3A` Magnetic Pogo | Gold / Neodymium | 1 pc | 260 | **260** | Amazon / Robu | Bottom U-channel of front dock (auto-charges on click-in) |
| **M-09** | Remote Battery | `3.7V 2000mAh` Li-Po Flat Pouch Cell | Standard `603450` Li-Po with `MX1.25 2P` plug | `50 × 34 × 6 mm` | Li-Po (`7.4 Wh`) | 1 pc | 240 | **240** | Robu.in | Inside Waveshare 4.3B case (`CS8501` charger header) |
| **M-10** | Sideways Wheel | Standard Knurled Knob + Reflective `V`-Tape | `Ø30 × 15 mm` Metal Knob + Gold Reflective `V` Stencil | `Ø30 × 15 mm`, `6mm` hole | Brass/Copper + Gold Vinyl | 1 set | 95 | **95** | Robu + Sticker Shop | Front-Right sideways `15mm` slot (`0–15mm` fill indicator) |
| **M-11** | Volume Pot/Enc | `10kΩ` Linear Pot (`B10K`) or `EC11` | Panel-mount `6mm` shaft with `M7×0.75` nut | `Ø6 × 15 mm` shaft | Metal Bushing | 1 pc | 40 | **40** | Robu / In Lab | Mounted on internal L-bracket at Front-Right corner |
| **M-12** | Corner Tie Rods | `M4 × 115 mm` Full-Thread SS304 Studs | DIN 975 `M4 × 0.7 mm` threaded rod | `M4 × 115 mm` | SS304 Stainless | 4 pcs | 15 | **60** | Pimpri Fasteners | Through all 4 corner pillars (Top Plate to Rubber Feet) |
| **M-13** | Top CSK Screws | `M4 × 12 mm` Countersunk Screws | ISO 10642 / DIN 7991 Flat CSK Head | `M4 × 12 mm` | Black Oxide / Brass | 4 pcs | 4 | **16** | Local Hardware | Top of the 4 corner pillars |
| **M-14** | Coupling Nuts | `M4 × 20 mm` Hex Long Coupling Nuts | Female-to-female hex rod coupler | `M4 × 20 mm` (`7mm` AF) | Nickel Brass / Steel | 4 pcs | 8 | **32** | Local Hardware | Inside top of 4 corner copper pillars |
| **M-15** | Side Wall Bolts | `M4 × 12 mm` Button-Head Allen Screws | ISO 7380 (`2.5 mm` hex key) | `M4 × 12 mm` | Black Oxide Steel | 16 pcs | 3 | **48** | Local Hardware | 8 per side joining panels to Side Heatsinks |
| **M-16** | Corner Brackets | Standard `20 × 20 × 15 mm` 90° L-Brackets | 2-hole right-angle gusset (`Ø4.2 mm` holes) | `20 × 20 × 15 × 2 mm` | Aluminum / Zinc Steel | 10 pcs | 6 | **60** | Local Hardware | 8 for side walls + 2 for sideways volume pot |
| **M-17** | Amp Screws | `M3 × 10 mm` Pan-Head Machine Screws | DIN 7985 (`0.5 mm` pitch) | `M3 × 10 mm` | SS304 Stainless | 14 pcs | 2 | **28** | Local Hardware | Clamps 3× TPA3116D2 (12) + 1× XL4015 Buck (2) to heatsinks |
| **M-18** | Amp Washers | `M3` Spring Lock + `M3` Flat Washers | DIN 127 + DIN 125 (`14 + 14 pcs`) | `ID 3.2 × OD 7 mm` | SS304 Stainless | 28 pcs | 1 | **28** | Local Hardware | Under `M3 × 10 mm` amp clamping screws (`0.6 N·m`) |
| **M-19** | PCB Standoffs | `M3 × 8 mm` Male-Female Brass Standoffs | Elevates all horizontal boards (`3× Amps`, `3× DACs`, `ADC`, `ESP32`, `Buck`) | `M3 × 8+6 mm` | Solid Brass | 30 pcs | 4 | **120** | Robu / Local | All boards sit horizontally on bottom plate (`8mm` clearance for bottom solder/wire stubs) |
| **M-20** | PCB Screws/Nuts | `M3 × 6 mm` Screws + `M3` Hex Nuts | DIN 7985 + DIN 934 (`30 + 30 pcs`) | `M3 × 6 mm` | SS304 / Brass | 60 pcs | 1.5 | **90** | Local Hardware | Secures all horizontal boards to `M3 × 8 mm` brass standoffs |
| **M-21** | USB-C Screws | `M2.5 × 8 mm` Pan Screws + `M2.5` Nuts | Secures rear USB-C service port flange | `M2.5 × 8 mm` | SS304 Stainless | 4 pcs | 2 | **8** | Local Hardware | Rear panel USB-C cutout (`2 screws + 2 nuts`) |
| **M-22** | Earth Lug Set | `M4 × 10 mm` Bolt + DIN 6798 Star Washer | External-tooth star washer + `M4` ring lug | `M4 × 10 mm` | SS304 + Tinned Copper | 1 set | 10 | **10** | Local Hardware | Safety Earth bond to Left AL6061 Heatsink (`< 0.1 Ω`) |
| **M-23** | Rubber Feet | Standard `Ø25 × 15 mm` Instrument Feet | Molded rubber foot with embedded steel washer | `Ø25 × 15 mm` (`Ø4.2` hole) | EPDM Rubber | 4 pcs | 15 | **60** | Pioneer Market | Bottom corners (creates `15 mm` cold-air intake plenum) |
| **M-24** | Bottom Locknuts | `M4` Nyloc Nuts + `M4` Fender Washers | DIN 985 Nyloc (`4`) + DIN 9021 Washer (`4`) | `M4` (`12 mm` OD washer) | SS304 Stainless | 8 pcs | 3 | **24** | Local Hardware | Recessed inside the 4 bottom rubber feet |
| **M-25** | Chimney Seals | Standard `Ø35 mm` ID Rubber O-Rings | `3 mm` cross-section elastomer seal | `ID 35 × OD 41 × 3 mm` | Nitrile / Silicone | 2 pcs | 10 | **20** | Bhosari Seal Shop | Top & bottom chimney pass-through dust seal |
| **M-26** | Wood 2-Tier Stand | `18 mm` Plywood Open-Sided 2-Shelf Stand | `2× 235×175×18 mm` boards + `2×` back pillars | `235 × 175 × 95 mm` | `18 mm` Veneer Plywood | 1 set | 350 | **350** | Local Carpenter | Bottom: Mean Well SMPS (sides open); Top: Amp Module |
| | **TOTAL** | **26 Standard Off-The-Shelf Line Items** | **Max Cooling Headroom: External Fins + Central Copper Chimney** | | | **202 pcs** | | **₹2,998** | | |
