# Master Assembly Manual & Standard Operating Procedure (SOP)

**Project:** DIY 5.1 Analog Amplifier (Copper Chimney V2)  
**Standard Compliance:** AIAG-VDA 1st Edition / IATF 16949 / IPC-A-610 Class 2  
**Document Revision:** 2.2 (SSOT Locked)  
**Associated Artifacts:**
- Tabular Assembly Workflow: [ASSEMBLY_STEPS.tsv](file:///d:/Documents/DIY%20Amp/ASSEMBLY_STEPS.tsv)
- Interactive Workbench App: [ASSEMBLY_MANUAL.html](file:///d:/Documents/DIY%20Amp/ASSEMBLY_MANUAL.html)
- Quality Management Dashboard: [QUALITY_MANAGEMENT_FMEA_CP.html](file:///d:/Documents/DIY%20Amp/QUALITY_MANAGEMENT_FMEA_CP.html) & [Report](file:///d:/Documents/DIY%20Amp/QUALITY_MANAGEMENT_FMEA_CP.md)
- Process FMEA Dataset: [PFMEA.tsv](file:///d:/Documents/DIY%20Amp/PFMEA.tsv)
- Quality Control Plan: [CONTROL_PLAN.tsv](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv)
- System Wiring Blueprint: [WIRING_DIAGRAM.html](file:///d:/Documents/DIY%20Amp/WIRING_DIAGRAM.html) & [PRINTABLE_WIRING_DIAGRAM.html](file:///d:/Documents/DIY%20Amp/PRINTABLE_WIRING_DIAGRAM.html)
- Electronic Circuit Schematic: [CIRCUIT_DIAGRAM.html](file:///d:/Documents/DIY%20Amp/CIRCUIT_DIAGRAM.html)
- Project Master Specification: [PROJECT.md](file:///d:/Documents/DIY%20Amp/PROJECT.md) & [PROJECT.html](file:///d:/Documents/DIY%20Amp/PROJECT.html)

---

## 1. Safety Directives & Poka-Yoke Assembly Commandments

Before commencing assembly, review the five non-negotiable engineering safety directives derived from [DFMEA.tsv](file:///d:/Documents/DIY%20Amp/DFMEA.tsv) and [PFMEA.tsv](file:///d:/Documents/DIY%20Amp/PFMEA.tsv):

> [!CAUTION]
> ### 1. The Absolute BTL Speaker Output Rule (DFM-01 / OP-90)
> The [XH-M562 TPA3116D2](file:///d:/Documents/DIY%20Amp/XH-M562%20TPA3116D2.md) runs in Bridge-Tied Load (BTL) configuration. **Neither speaker positive (+) nor speaker negative (-) may ever touch chassis ground or each other.** Any short circuit between a speaker terminal and the aluminum heatsink will immediately destroy the lower internal MOSFET of the H-bridge. All 12 binding posts MUST be mounted through the non-conductive Polycarbonate rear plate with verified infinite resistance ($\infty\ \Omega$) to chassis.

> [!WARNING]
> ### 2. The Two-Stage 5.00V Logic Rail Rule (DFM-06 / OP-70)
> Never connect the 5V logic harness to the [Waveshare ESP32-S3](file:///d:/Documents/DIY%20Amp/Waveshare%20ESP32-S3%20with%20Touch%20spec.md) or [PCM5102A DACs](file:///d:/Documents/DIY%20Amp/PCM5102%2012S%20Spec.md) until the [XL4015 Buck Converter](file:///d:/Documents/DIY%20Amp/XL4015%20Spec.md) is pre-calibrated on the bench under 24V input and locked to exactly $5.00\text{V} \pm 0.05\text{V}$ with Loctite 290. Applying raw 24V or untrimmed buck output ($>5.5\text{V}$) will permanently fry all logic chips.

> [!IMPORTANT]
> ### 3. The 3-Second Soldering Dwell Rule (OP-30 / CP-30)
> When hand-soldering wires to the 10-pad perimeter on the XH-M562 boards, keep soldering iron temperature at $350^\circ\text{C}$ and **do not exceed 3.0 seconds dwell time per pad**. Excessive heat will delaminate the FR4 copper pads or cause internal capacitor thermal stress.

> [!TIP]
> ### 4. Thermal Compound Micro-Dispensing Rule (OP-20 / CP-20)
> Dispense strictly **$0.05\text{g} \pm 0.01\text{g}$** of [Arctic MX-4](file:///d:/Documents/DIY%20Amp/arctic%20mx-4%204g%20thermal%20paste.md) per TPA3116 die in an "X-pattern". Over-application creates thick thermal insulation ($>50\,\mu\text{m}$); under-application causes hot spots. Tighten M3 standoff screws to $0.35\text{ N}\cdot\text{m}$.

> [!NOTE]
> ### 5. Single-Point Star Audio Grounding Rule (DFM-07 / OP-50)
> To prevent $50/100\text{ Hz}$ mains hum ground loops, all audio grounds must converge at a single star point at the DAC AGND rail. The 3.5mm AUX input jack shield MUST be isolated from the metal chassis ($>1.0\text{ M}\Omega$).

---

## 2. Shop Floor Tooling & Equipment Checklist

Ensure all required tools are on the bench and calibrated before starting assembly:

| Tool Category | Equipment & Model | Specification / Setting | Calibration Check |
| :--- | :--- | :--- | :--- |
| **Soldering Station** | Hakko FX-888D / TS100 | $350^\circ\text{C}$, 2.4D chisel tip | Temp verified via tip thermometer |
| **Solder Wire** | Kester 63/37 Rosin Core | 0.8 mm diameter, eutectic flux | Clean non-corrosive flux |
| **Torque Driver** | Wiha / Torq-Master Micro Driver | Range: $0.1$ to $1.2\text{ N}\cdot\text{m}$ | Calibration certified $\pm 5\%$ |
| **Wire Stripper** | Calibrated Automatic Stripper | Built-in 11.0 mm mechanical depth stop | Verified against 11mm steel rule |
| **Crimping Tool** | Engineer PA-09 / IWISS IWS-2820 | Ratchet cycle-lock, AWG 20–28 dies | Zero jaw wobble, smooth ratchet |
| **Digital Multimeter** | Fluke 87V True-RMS DMM | 4.5-digit, low-ohm resolution ($0.01\,\Omega$) | Calibrated test leads (< 0.05Ω shorted) |
| **Insulation Tester** | Megger / Fluke 1507 | 500V DC test mode | Verified open circuit detection |
| **Thermal Imager** | FLIR E4 / E8 or Seek Compact | 80x60 / 320x240 thermal resolution | $\pm 2^\circ\text{C}$ emissivity calibrated |
| **Audio Analyzer** | QuantAsylum QA403 / APx500 | 24-bit 192kHz USB audio analyzer | Loopback calibrated SNR > 115 dB |
| **Dummy Load Bank** | 6-Channel $4\,\Omega$ Non-Inductive | 100W per channel, heatsink mounted | Resistance verified $4.0\,\Omega \pm 1\%$ |

---

## 3. Fastener Torque & Mechanical Assembly Reference

To prevent stripped threads in polycarbonate panels or cracked PCB corners, follow the torque matrix below:

| Joint Description | Fastener Type | Target Torque | Tolerance | Thread Treatment |
| :--- | :--- | :---: | :---: | :--- |
| **M3 Standoffs to AL6061 Fins** | M3×8mm SS Button Head | $0.60\text{ N}\cdot\text{m}$ | $\pm 0.05\text{ N}\cdot\text{m}$ | Loctite 243 (Blue medium) |
| **TPA3116 PCB Clamp Standoffs** | M3 Nylon Standoffs | $0.35\text{ N}\cdot\text{m}$ | $\pm 0.03\text{ N}\cdot\text{m}$ | None (Nylon self-locking) |
| **Central Copper Chimney Flange** | M4×10mm SS Socket Cap | $1.20\text{ N}\cdot\text{m}$ | $\pm 0.10\text{ N}\cdot\text{m}$ | Loctite 243 |
| **Corner Pillar M4 Studs** | M4 Brass / SS Studs | $1.00\text{ N}\cdot\text{m}$ | $\pm 0.10\text{ N}\cdot\text{m}$ | Loctite 243 |
| **JS-910B Binding Post Nuts** | M8 Brass Nut on Nylon Washer | $0.80\text{ N}\cdot\text{m}$ | $\pm 0.05\text{ N}\cdot\text{m}$ | Double lock nut + nylon washer |
| **GX16 4-Pin Aviation Chassis Nut** | M16 Hex Locknut | $1.00\text{ N}\cdot\text{m}$ | $\pm 0.10\text{ N}\cdot\text{m}$ | External star lock washer |
| **Polycarbonate Top/Front Screws** | M3×10mm Black SS Countersunk | $0.50\text{ N}\cdot\text{m}$ | $\pm 0.05\text{ N}\cdot\text{m}$ | None (Finger snug + 1/8 turn) |

---

## 4. Conductor Wire Gauge & Color Code Standard

Strictly adhere to the wire color and gauge chart for rapid visual tracing and inspection:

| Signal Function | Wire Gauge | Color Standard | Strip Length | Termination Type |
| :--- | :---: | :---: | :---: | :--- |
| **+24V DC Main Infeed** | 16 AWG | **Solid Red** | 11.0 mm | GX16-4 Pins 1+2 parallel $\rightarrow$ 10A Fuse $\rightarrow$ WAGO 221-415 |
| **GND DC Main Return** | 16 AWG | **Solid Black** | 11.0 mm | GX16-4 Pins 3+4 parallel $\rightarrow$ WAGO 221-415 |
| **+24V Branch Feeds (Amps)** | 20 AWG | **Solid Red** | 11.0 mm | WAGO 221-415 $\rightarrow$ XH-M562 Pad 8 |
| **GND Branch Returns (Amps)**| 20 AWG | **Solid Black** | 11.0 mm | WAGO 221-415 $\rightarrow$ XH-M562 Pad 9 |
| **+5.00V DC Logic Bus** | 20 AWG | **Solid Orange / Red** | 7.0 mm | XL4015 OUT+ $\rightarrow$ JST-XH 2-pin |
| **Logic Return (GND)** | 20 AWG | **Solid Black** | 7.0 mm | XL4015 OUT- $\rightarrow$ JST-XH 2-pin |
| **Speaker BTL Outputs (+)** | 16 AWG | **Solid White** | 10.0 mm | XH-M562 Pad 4/6 $\rightarrow$ Red Binding Post |
| **Speaker BTL Outputs (-)** | 16 AWG | **Solid Blue** | 10.0 mm | XH-M562 Pad 5/7 $\rightarrow$ Black Binding Post |
| **I2S Clocks (BCK, LRCK, DIN)**| 24 AWG | **Ribbon / Twisted** | 4.0 mm | JST-XH 5-Pin Crimp $\rightarrow$ PCM5102A |
| **Analog Line Signals** | 24 AWG Shielded| **Red (R) / White (L)**| 15mm jacket, 4mm wire | 2-Core Braided Shield $\rightarrow$ JST-XH 3-Pin |

---

## 5. Complete Step-by-Step Assembly Procedure

The assembly process is divided into 10 structured phases comprising 20 explicit shop floor steps.

```
========================================================================================================
ASSEMBLY PROCESS FLOW (PFMEA & CONTROL PLAN ALIGNED)
  Phase 1: Mechanical Prep & Framework (Steps 01 - 03)
  Phase 2: Board-Level Bench Prep & Calibration (Steps 04 - 07)
  Phase 3: Thermal Interface & Heatsink Clamping (Steps 08 - 09)
  Phase 4: Wire Harness & Cable Fabrication (Steps 10 - 11)
  Phase 5: Power Subsystem & Reservoir Assembly (Steps 12 - 13)
  Phase 6: Rear Panel I/O Dressing (Steps 14 - 15)
  Phase 7: Enclosure Integration & Interconnection (Steps 16 - 17)
  Phase 8: Safety Verification - Pre-Power Gate OP-90 (Step 18)
  Phase 9: Commissioning, Acoustic Sweep & Burn-In (Step 19)
  Phase 10: Final Closure & Quality Sign-Off (Step 20)
========================================================================================================
```

---

### Phase 1: Mechanical Prep & Framework

#### Step 01: Chassis Panel Inspection & Deburring
- **PFMEA Ref:** [OP-10](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L2) | **Control Plan:** [CP-10](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L2)
- **Parts:** 4× 4mm Polycarbonate panels (Front, Back, Top, Bottom) + 2× AL6061 finned side plates.
- **Action:** 
  1. Inspect all laser-cut and CNC-machined edges under bright bench lighting.
  2. Deburr any sharp flashing using an acrylic scraping blade.
  3. Verify mounting hole centers with a digital caliper ($\pm 0.15\text{ mm}$ tolerance).
  4. Test fit the 35mm central chimney cutout on the top and bottom plates against the Go/No-Go plug gauge ($\pm 0.20\text{ mm}$).

#### Step 02: Base Plate & Isolation Foot Installation
- **PFMEA Ref:** [OP-10](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L2) | **Control Plan:** [CP-10](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L2)
- **Parts:** Bottom Polycarbonate plate, 4× 20mm rubber vibration-isolation feet, 4× M3×8mm stainless screws, 4× M3 washers.
- **Action:**
  1. Position rubber feet in corner counterbores on the exterior of the base plate.
  2. Insert M3 screws with flat washers from the inside.
  3. Torque each screw to **$0.60\text{ N}\cdot\text{m}$** using the calibrated hex driver.
  4. Place base plate on a granite surface plate; verify zero wobble or rocking.

#### Step 03: Copper Chimney & Corner Pillar Erection
- **PFMEA Ref:** [OP-10](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L2) | **Control Plan:** [CP-10](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L2)
- **Parts:** 35mm OD central copper chimney tube (160mm length), 4× 15mm corner copper tubes, M4 threaded rods/standoffs.
- **Action:**
  1. Seat the 35mm central copper chimney into the base plate collar recess.
  2. Install the 4 corner 15mm copper support pillars using M4 stainless studs.
  3. Torque bottom M4 mounting studs to **$1.20\text{ N}\cdot\text{m}$** with a dab of Loctite 243.
  4. Check perpendicularity with a 90° machinist square ($90.0^\circ \pm 0.5^\circ$).

---

### Phase 2: Board-Level Bench Prep & Calibration

#### Step 04: ESP32-S3 Firmware Flashing & Configuration
- **PFMEA Ref:** [OP-80](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L9) | **Control Plan:** [CP-80](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L9)
- **Parts:** [Waveshare ESP32-S3 Touch LCD](file:///d:/Documents/DIY%20Amp/Waveshare%20ESP32-S3%20with%20Touch%20spec.md), USB-C data cable.
- **Action:**
  1. Connect ESP32-S3 to development PC via USB-C port.
  2. Execute automated flash script:
     ```bash
     esptool.py --chip esp32s3 write_flash 0x0 ccv2_firmware_v2.2.bin
     ```
  3. Verify SHA256 build checksum in console output.
  4. Open serial monitor ($115,200\text{ baud}$); confirm boot message:
     `[AUDIO] Volume Ceiling locked at 83.6% (210W Peak unclipped) - OK`.

#### Step 05: XL4015 Buck Converter Calibration & Potentiometer Lock
- **PFMEA Ref:** [OP-70](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L8) | **Control Plan:** [CP-70](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L8)
- **Parts:** [XL4015 DC-DC Buck Converter](file:///d:/Documents/DIY%20Amp/XL4015%20Spec.md), bench DC power supply set to 24.0V DC.
- **Action:**
  1. Connect bench supply +24V and GND to XL4015 input terminals.
  2. Clip Fluke 87V true-RMS DMM probes across XL4015 output terminals.
  3. Adjust the 25-turn cermet trimmer until output reads **exactly $5.000\text{V DC} \pm 0.050\text{V}$** (acceptance window: $4.950\text{V}$ to $5.050\text{V}$).
  4. Apply 1 drop of green wicking Loctite 290 threadlocker to the potentiometer screw thread.
  5. Affix calibration sticker with date and voltage reading.

#### Step 06: XH-M562 Amplifier Solder Pad Tinning & Header Prep
- **PFMEA Ref:** [OP-30](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L4) | **Control Plan:** [CP-30](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L4)
- **Parts:** 3× [XH-M562 TPA3116D2 Mini Boards](file:///d:/Documents/DIY%20Amp/XH-M562%20TPA3116D2.md) (solder-pad version, no potentiometers), gold-plated pin headers.
- **Action:**
  1. Clean 10 solder pads on all 3 boards with 99% IPA and lint-free swab.
  2. Set soldering iron to $350^\circ\text{C}$ with 2.4D chisel tip; apply rosin flux.
  3. Pre-tin each pad with 63/37 solder. Enforce the **3-second dwell rule**.
  4. Inspect fillets under 10x loupe. Form a shiny, concave meniscus with zero solder bridging.
  5. Check continuity between adjacent pads (Pads 4/5, Pads 8/9); verify resistance is $>100\text{ k}\Omega$.

#### Step 07: PCM5102A DAC & PCM1808 ADC Hardware Configuration
- **PFMEA Ref:** [OP-30](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L4) | **Control Plan:** [CP-30](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L4)
- **Parts:** 3× [PCM5102A DAC Boards](file:///d:/Documents/DIY%20Amp/PCM5102%2012S%20Spec.md), 1× [PCM1808 ADC Board](file:///d:/Documents/DIY%20Amp/PCM1808%2024bit%20SNR%20Audio%20Stereo%20ADC%20Single-Ended%20Analog-Input%20Decoder.md).
- **Action:**
  1. On each of the 3 PCM5102A boards, solder the **SCK solder bridge directly to GND**. This configures the PCM5102A internal PLL to generate its own system clock from BCK.
  2. Verify solder bridge with DMM resistance mode ($< 0.1\,\Omega$).
  3. On PCM1808 ADC board, configure mode jumpers for $24\text{-bit}$ I2S slave operation ($FMT0=\text{GND}$, $FMT1=\text{GND}$).

---

### Phase 3: Thermal Interface & Amplifier IC Heatsink Clamping

#### Step 08: Thermal Compound Micro-Dispensing
- **PFMEA Ref:** [OP-20](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L3) | **Control Plan:** [CP-20](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L3)
- **Parts:** 3× XH-M562 boards, [Arctic MX-4 thermal paste](file:///d:/Documents/DIY%20Amp/arctic%20mx-4%204g%20thermal%20paste.md), micro-dispensing syringe.
- **Action:**
  1. Clean exposed heatsink mating surface of TPA3116D2 ICs with 99% IPA.
  2. Dispense strictly **$0.05\text{g} \pm 0.01\text{g}$** of Arctic MX-4 in an "X-pattern" across each exposed silicon slug.
  3. Ensure zero entrapped air bubbles, dust fibers, or dry spots.

#### Step 09: Amplifier Heatsink Clamping to AL6061 Finned Plates
- **PFMEA Ref:** [OP-20](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L3) | **Control Plan:** [CP-20](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L3)
- **Parts:** 2× AL6061 finned heatsink side plates, 6× M3 nylon standoffs, 6× M3×12mm screws.
- **Action:**
  1. Carefully position Amp #1 (Front L/R) and Amp #2 (Rear L/R) against Left Fin Plate.
  2. Position Amp #3 (Center/Sub) against Right Fin Plate.
  3. Thread M3 screws through nylon standoffs into the pre-tapped holes in the aluminum plate.
  4. Tighten diagonally in 2 passes, reaching final torque of **$0.35\text{ N}\cdot\text{m} \pm 0.03\text{ N}\cdot\text{m}$**.
  5. Inspect the perimeter of each TPA3116 die for uniform paste squeeze-out. Wipe away any excess with an alcohol swab.

---

### Phase 4: Wire Harness & Cable Fabrication

#### Step 10: Signal Cable JST-XH Crimping & Heat-Shrinking
- **PFMEA Ref:** [OP-50](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L6) | **Control Plan:** [CP-50](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L6)
- **Parts:** 2-core shielded audio cable, 24 AWG ribbon wire, JST-XH terminals and housings.
- **Action:**
  1. Strip outer jacket of shielded cable back 15mm; peel back copper braid.
  2. Twist shield drain wire and slide a 10mm length of 2:1 dual-wall adhesive heat-shrink over the transition.
  3. Strip conductors back 2.5mm; insert into JST-XH crimp terminal.
  4. Crimp with Engineer PA-09 ratchet tool using 1.6mm die for conductor, 1.9mm die for insulation.
  5. Perform manual pull test ($> 15\text{ N}$ pull force). Insert crimped pins into JST-XH plastic housing until audible click.

#### Step 11: Power Conductor Stripping & Preparation
- **PFMEA Ref:** [OP-40](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L5) | **Control Plan:** [CP-40](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L5)
- **Parts:** 16 AWG high-strand silicone wire (Red/Black), 20 AWG silicone wire (Red/Black).
- **Action:**
  1. Insert wire into calibrated automatic stripper with 11.0mm mechanical stop locked.
  2. Strip conductor. Inspect stripped copper length with a digital caliper: must measure **$11.0\text{ mm}\ (+1.0/-0.5\text{ mm})$**.
  3. Verify that zero wire strands are nicked, severed, or splayed.
  4. Twist strands lightly to form a compact, cylindrical conductor bundle.

---

### Phase 5: Power Subsystem & Reservoir Capacitor Assembly

#### Step 12: WAGO 221-415 Bus Block Splicing & Capacitor Bridging
- **PFMEA Ref:** [OP-40](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L5) | **Control Plan:** [CP-40](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L5)
- **Parts:** 2× [WAGO 221-415 Lever Connectors](file:///d:/Documents/DIY%20Amp/wago%20221%20specs.md), 1× [4700µF 50V Low-ESR Capacitor](file:///d:/Documents/DIY%20Amp/4700uF%20capacitor%20Spec%20Sheet.md).
- **Action:**
  1. Identify Block 1 as **+24V Rail (Orange Levers)** and Block 2 as **GND Rail (Orange Levers)**.
  2. Connect the [4700µF 50V capacitor](file:///d:/Documents/DIY%20Amp/4700uF%20capacitor%20Spec%20Sheet.md) directly across Port 5 of both blocks:
     - Positive capacitor lead (longer leg) $\rightarrow$ Block 1, Port 5.
     - Negative capacitor lead (stripe side) $\rightarrow$ Block 2, Port 5.
  3. Slide silicone insulated boots over capacitor leads to prevent short circuits.
  4. Insert the 16 AWG main DC power feed from the rear aviation connector into Port 1 of each block.
  5. Insert the 20 AWG branch power leads for Amps 1, 2, 3 into Ports 2, 3, 4.
  6. Snap all orange levers completely flat. Perform a $30\text{ N}$ pull test on every wire.

#### Step 13: XL4015 5.00V Logic Feed Integration
- **PFMEA Ref:** [OP-70](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L8) | **Control Plan:** [CP-70](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L8)
- **Parts:** Pre-calibrated XL4015 Buck Module, 20 AWG infeed wire, JST-XH 2-pin connector.
- **Action:**
  1. Connect XL4015 `IN+` and `IN-` to the 24V WAGO distribution blocks via 20 AWG wires.
  2. Connect XL4015 `OUT+` and `OUT-` to a keyed JST-XH 2-pin female harness.
  3. Power the 24V bus from bench supply; probe the JST-XH pin with Fluke 87V.
  4. Confirm output reads $5.00\text{V} \pm 0.05\text{V}$ and polarity matches red (+5V) / black (GND).

---

### Phase 6: Rear Panel I/O Dressing

#### Step 14: Binding Post Installation in Polycarbonate
- **PFMEA Ref:** [OP-60](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L7) | **Control Plan:** [CP-60](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L7)
- **Parts:** 4mm Polycarbonate rear panel, 12× JS-910B gold binding posts (6 red, 6 black), stepped nylon shoulder washers.
- **Action:**
  1. Push stepped nylon shoulder washers into the 12 keyed D-holes on the polycarbonate rear panel.
  2. Insert JS-910B binding post shafts through the panel (Red = Positive upper row, Black = Negative lower row).
  3. Install flat nylon washer, spring washer, and M8 brass nut on the inside.
  4. Use calibrated torque socket preset to **$0.80\text{ N}\cdot\text{m} \pm 0.05\text{ N}\cdot\text{m}$**.
  5. Check rotational torque with wrench: posts must not slip under $1.2\text{ N}\cdot\text{m}$.
  6. Verify zero stress crazing or cracking on the polycarbonate panel around holes.

#### Step 15: Power Umbilical & Audio Input Jack Mounting
- **PFMEA Ref:** [OP-60](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L7) | **Control Plan:** [CP-60](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L7)
- **Parts:** GX16 4-pin aviation chassis jack (In Hand), PJ392A-1 3.5mm stereo AUX jack (In Hand: 5 pcs), 10A inline DC fuse holder.
- **Action:**
  1. Mount GX16 4-pin aviation jack into lower rear cutout (16mm hole); tighten rear locknut to **$1.00\text{ N}\cdot\text{m}$** with star lock washer.
  2. Solder short 16 AWG Red jumper bridging Pin 1 and Pin 2 together for parallel +24V infeed (15A rating); connect to inline 10A fuse holder; insulate with dual-wall adhesive heat-shrink.
  3. Solder short 16 AWG Black jumper bridging Pin 3 and Pin 4 together for parallel GND return (15A rating); insulate with dual-wall heat-shrink.
  4. Mount PJ392A 3.5mm jack into upper rear cutout; ensure nylon isolation shoulder isolates jack barrel from chassis.
  5. **Cold-Mating Inrush Protocol:** Always mate and screw-lock the GX16 4-pin umbilical connector *before* applying AC mains power to the Mean Well SMPS. Never hot-plug while SMPS is energized.

---

### Phase 7: Enclosure Integration & Interconnection

#### Step 16: Amplifier Board Wiring & Strain-Relief Dressing
- **PFMEA Ref:** [OP-30](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L4) | **Control Plan:** [CP-30](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L4)
- **Parts:** Wired heatsink plates, 16 AWG speaker twisted pairs, 20 AWG power leads.
- **Action:**
  1. Fasten left and right AL6061 fin plates to the base plate using M3×10mm stainless screws ($0.60\text{ N}\cdot\text{m}$).
  2. Solder 20 AWG Red (+24V) to Pad 8 and Black (GND) to Pad 9 on each XH-M562 board.
  3. Solder 16 AWG White (+) to Pads 4 & 6; solder 16 AWG Blue (-) to Pads 5 & 7.
  4. Route twisted speaker pairs neatly to rear panel binding posts and solder to terminal tabs.
  5. Apply a dab of non-corrosive neutral RTV silicone across wire bundles at board edges for vibration strain relief.

#### Step 17: Front Panel & Brain Module Integration
- **PFMEA Ref:** [OP-50](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L6) | **Control Plan:** [CP-50](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L6)
- **Parts:** Front Polycarbonate panel, Waveshare ESP32-S3 Touch LCD, 3× PCM5102A DAC boards, PCM1808 ADC board, M2.5 nylon standoffs.
- **Action:**
  1. Mount ESP32-S3 display assembly to front panel using M2.5 nylon hardware ($0.40\text{ N}\cdot\text{m}$).
  2. Stack 3× PCM5102A DAC boards directly behind ESP32 using 12mm nylon standoffs.
  3. Connect I2S star-clock harness (BCK on GPIO 12, LRCK on GPIO 13, DIN 1/2/3 on GPIO 14/15/16). Keep ribbon lengths under $60\text{ mm}$.
  4. Connect 3-pin shielded audio harnesses from DAC outputs to Amplifier inputs (Pad 1 = RIN, Pad 2 = GND, Pad 3 = LIN).
  5. Connect 5.00V logic power harness from XL4015 buck module to brain distribution header.

---

### Phase 8: Mandatory Safety Inspection — Pre-Power 6-Point Gate

#### Step 18: Pre-Power Electrical Checkout (OP-90 Sign-Off)
- **PFMEA Ref:** [OP-90](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L10) | **Control Plan:** [CP-90](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L10)
- **Equipment:** Fluke 87V Multimeter, Megger 500V DC Insulation Tester, Physical Lock-Out Tag.
- **Mandatory Procedure:**
  1. Affix physical red **LOCK-OUT TAG** over the mains IEC inlet. Power must not be applied until all 6 tests pass.
  2. Execute the 6 verification measurements:

```
+-----------------------------------------------------------------------------------------+
|                  OPERATION OP-90: PRE-POWER ELECTRICAL VERIFICATION GATE               |
+-----------------------------------------------------------------------------------------+
| Check 1 [YS]: Protective Earth (PE) Chassis Bond        | Spec: < 0.10 Ohm  | Status: [ ] |
| Check 2 [CC]: 24V DC Bulk Bus Cold Resistance           | Spec: > 10.0 kOhm | Status: [ ] |
| Check 3 [CC]: 5.00V DC Logic Bus Cold Resistance        | Spec: > 2.0 kOhm  | Status: [ ] |
| Check 4 [CC]: 12x Binding Posts to Aluminum Chassis     | Spec: OPEN (INF)  | Status: [ ] |
| Check 5 [SC]: Adjacent Binding Post Pair Cross-Isol.    | Spec: > 100 kOhm  | Status: [ ] |
| Check 6 [SC]: 3.5mm AUX Shield to Chassis Isolation     | Spec: > 1.0 MOhm  | Status: [ ] |
+-----------------------------------------------------------------------------------------+
```

> [!CAUTION]
> If Check 4 shows ANY continuity between any speaker post and the chassis, **STOP IMMEDIATELY**. Locate and rectify the insulation fault. DO NOT connect power.

---

### Phase 9: System Energizing, Acoustic Calibration & Burn-In

#### Step 19: Full-Load Acoustic Sweep & 30-Minute Thermal Soak
- **PFMEA Ref:** [OP-100](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L11) | **Control Plan:** [CP-100](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L11)
- **Equipment:** [Mean Well LRS-350-24](file:///d:/Documents/DIY%20Amp/Meanwell%20LRS-350-24%20SMPS%20Power%20Supply.md), QuantAsylum QA403 Analyzer, FLIR E4 Thermal Camera, 6× $4\,\Omega$ 100W Dummy Load Bank.
- **Action:**
  1. Remove lock-out tag. Connect 24V DC umbilical from Mean Well power supply.
  2. Connect all 6 speaker output channels to the $4\,\Omega$ load bank.
  3. Power on mains. Verify ESP32 boot screen illuminates and idle current is $< 120\text{ mA}$.
  4. Inject $1\text{ kHz}$ sine test wave at 70% volume unclipped ceiling ($210\text{W}$ peak total).
  5. Measure THD+N across all 6 channels: must measure **$< 0.05\%$**.
  6. Run continuous 30-minute burn-in cycle.
  7. Monitor thermal equilibrium with FLIR camera: heatsink fins must stabilize below **$52^\circ\text{C}$** ($< 25^\circ\text{C}$ rise above ambient).

---

### Phase 10: Final Closure & Quality Sign-Off

#### Step 20: Top Plate Sealing & Quality Assurance Hologram
- **PFMEA Ref:** [OP-10](file:///d:/Documents/DIY%20Amp/PFMEA.tsv#L2) | **Control Plan:** [CP-10](file:///d:/Documents/DIY%20Amp/CONTROL_PLAN.tsv#L10)
- **Parts:** Top Polycarbonate plate, high-temperature silicone rubber chimney grommet, 4× M3×10mm black stainless screws, serialized QA hologram sticker.
- **Action:**
  1. Slide high-temperature silicone thermal isolation ring over the top of the 35mm central copper chimney.
  2. Lower the top Polycarbonate plate onto the chassis, ensuring the silicone grommet seats cleanly in the 35mm cutout.
  3. Fasten top plate with 4× M3 screws into corner pillars; torque to **$0.50\text{ N}\cdot\text{m}$**.
  4. Clean exterior surfaces with antistatic microfiber cloth.
  5. Affix tamper-evident serialized QA hologram over bottom chassis seam.
  6. Record unit serial number (`CCV2-2026-PUN-001`) in master QA database.

---

## 6. Assembly Quality Traveler & Sign-Off Sheet

Print this traveler sheet and attach it to the assembly clipboard during production:

| Step | Operation Description | Characteristic Checked | Spec / Value | Sign-off Tech | Date |
| :---: | :--- | :--- | :---: | :---: | :---: |
| **01** | Panel Cutout Inspection | Hole centers / apertures | $\pm 0.15\text{ mm}$ | ____________ | __/__ |
| **02** | Base Plate & Feet Assembly | Surface plate stability | Zero wobble | ____________ | __/__ |
| **03** | Copper Chimney Erection | Perpendicularity | $90.0^\circ \pm 0.5^\circ$ | ____________ | __/__ |
| **04** | ESP32-S3 Firmware Flash | SHA256 build checksum | Hash Verified | ____________ | __/__ |
| **05** | XL4015 Buck Calibration | Output voltage | $5.00\text{V} \pm 0.05\text{V}$ | ____________ | __/__ |
| **06** | XH-M562 Pad Tinning | Fillet shape / dwell | Concave / $<3\text{s}$ | ____________ | __/__ |
| **07** | DAC / ADC Hardware Jumper | SCK to GND resistance | $< 0.1\,\Omega$ | ____________ | __/__ |
| **08** | Thermal Compound Dispense | Arctic MX-4 mass | $0.05\text{g} \pm 0.01\text{g}$ | ____________ | __/__ |
| **09** | Heatsink Clamp Torquing | M3 nylon standoff torque | $0.35\text{ N}\cdot\text{m}$ | ____________ | __/__ |
| **10** | JST-XH Signal Crimping | Crimp retention pull | $> 15\text{ N}$ | ____________ | __/__ |
| **11** | Power Conductor Stripping | Conductor strip length | $11.0\text{ mm}$ | ____________ | __/__ |
| **12** | WAGO Bus & 4700µF Assembly| Terminal pull retention | $> 30\text{ N}$ | ____________ | __/__ |
| **13** | 5V Logic Bus Integration | 5V rail polarity check | $5.00\text{V DC}$ | ____________ | __/__ |
| **14** | Binding Post Dressing | Anti-rotation slip | $> 1.2\text{ N}\cdot\text{m}$ | ____________ | __/__ |
| **15** | Umbilical & Jack Mounting | Hardware tightness | $1.00\text{ N}\cdot\text{m}$ | ____________ | __/__ |
| **16** | Amp Wiring & Strain Relief | Silicone bead applied | Verified | ____________ | __/__ |
| **17** | Front Panel Brain Mount | I2S ribbon length | $< 60\text{ mm}$ | ____________ | __/__ |
| **18** | **Pre-Power 6-Point Gate** | **All 6 cold DC checks** | **100% Passed** | ____________ | __/__ |
| **19** | Acoustic 30-Min Burn-In | THD+N & Max Temp | $<0.05\% / <52^\circ\text{C}$ | ____________ | __/__ |
| **20** | Top Plate Sealing & QA Tag | Tamper seal affixed | Serialized | ____________ | __/__ |

---

*Manual verified for prototype assembly and serial production release under AIAG-VDA and IATF 16949 standards.*
