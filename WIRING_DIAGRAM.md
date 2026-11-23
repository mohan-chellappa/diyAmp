# DIY 5.1 Analog Amplifier — Pictorial System Wiring Guide

**Project:** Copper Chimney V2 (Based on `PROJECT.md` & `BOM.tsv`)  
**Architecture:** 6-Channel Fanless Home Theater Amplifier (3× Stereo XH-M562 TPA3116D2 + 3× PCM5102A DACs + ESP32-S3 Brain + PCM1808 ADC)  
**Power Topology:** Mean Well LRS-350-24 (24V 14.6A) &rarr; XT60 &rarr; 2× WAGO 221-415 (5-Port Rails) &rarr; Amps &amp; XL4015 Buck  
**Date:** October 2026  
**Interactive Version:** [Interactive Pictorial Diagram (WIRING_DIAGRAM.html)](file:///d:/Documents/DIY%20Amp/WIRING_DIAGRAM.html) &bull; [Electronic Circuit Schematic (CIRCUIT_DIAGRAM.html)](file:///d:/Documents/DIY%20Amp/CIRCUIT_DIAGRAM.html) &bull; [Print-Ready Bench Blueprint (PRINTABLE_WIRING_DIAGRAM.html)](file:///d:/Documents/DIY%20Amp/PRINTABLE_WIRING_DIAGRAM.html)

---

## 1. System Architecture & Flow

```
                                 [ Mains 230V AC Inlet ]
                                            │
                                            ▼ (3A Slow-Blow 5x20mm Fuse on Live)
                       [ Mean Well LRS-350-24 SMPS (24V 14.6A 350W) ]
                         ├── Safety Earth (PE / ⏚) ───► Bonded to AL6061 Chassis
                         ├── +24V DC Output (Terminals 7, 8, 9)
                         └── 0V GND Output (Terminals 4, 5, 6)
                                            │
                                            ▼ (16 AWG Pair via GX16 4-Pin Disconnect [Pins 1+2 = +24V, Pins 3+4 = GND])
                     [ Inline 10A DC Slow-Blow Fuse on +24V Rail ]
                                            │
                 ┌──────────────────────────┴──────────────────────────┐
                 ▼                                                     ▼
     [ WAGO 221-415: +24V Bus Rail ]                       [ WAGO 221-415: GND Bus Rail ]
       ├── P1: +24V Input (16 AWG)                           ├── P1: GND Input (16 AWG)
       ├── P2: Amp #1 VCC (Front L/R, 20 AWG)                ├── P2: Amp #1 GND (20 AWG)
       ├── P3: Amp #2 VCC (Rear L/R, 20 AWG)                 ├── P3: Amp #2 GND (20 AWG)
       ├── P4: Amp #3 VCC (Center/Sub, 20 AWG)               ├── P4: Amp #3 GND (20 AWG)
       └── P5: XL4015 Buck IN+ (20 AWG)                      └── P5: XL4015 Buck IN- (20 AWG)
                 │                                                     │
                 └───────────[ 4700µF 35V/50V Bulk Filter Cap ]────────┘
                                            │
                                            ▼
                           [ XL4015 Buck (24V ──► 5.00V Logic) ]
                                            │
                 ┌──────────────────────────┴──────────────────────────┐
                 ▼ (5.0V Logic Bus)                                    ▼ (Logic Ground)
        [ ESP32-S3-Pico MASTER + ESP32-WROOM-32 SLAVE ]                           [ Logic Ground Bus ]
                 │
                 ├── Shared I2S Clock Bus: BCK (Bit Clock) + LRCK (Word Select / WS)
                 ├── DOUT 1 ──► DAC #1 (Front Left & Right)
                 ├── DOUT 2 ──► DAC #3 (Center & Subwoofer)
                 ├── Slave ESP32-WROOM-32 D27 ──► DAC #2 (Rear Left & Rear Right / Surround)
                 └── DIN    ◄── PCM1808 ADC (3.5mm Stereo AUX Jack Line Input)
                                            │
                 ┌──────────────────────────┼──────────────────────────┐
                 ▼                          ▼                          ▼
        [ PCM5102A DAC #1 ]        [ PCM5102A DAC #2 ]        [ PCM5102A DAC #3 ]
          (Front L / R)              (Surround L / R)           (Center / Sub)
                 │ (Shielded 2-Core)        │ (Shielded 2-Core)        │ (Shielded 2-Core)
                 ▼                          ▼                          ▼
        [ Amp #1: XH-M562 ]        [ Amp #2: XH-M562 ]        [ Amp #3: XH-M562 ]
                 │                          │                          │
        ┌────────┴────────┐        ┌────────┴────────┐        ┌────────┴────────┐
        ▼                 ▼        ▼                 ▼        ▼                 ▼
     Front L           Front R   Rear L            Rear R   Center            Subwoofer
    Binding Posts    Binding Posts Binding Posts   Binding Posts Binding Posts   Binding Posts
```

---

## 2. Review of the Wiring Diagram & Engineering Analysis

### 2.1 Power Delivery & Headroom
* **Mean Well LRS-350-24:** Delivers **24.0V DC @ 14.6A (350.4W)**. The three TPA3116D2 amplifier boards produce up to $2 \times 50\text{W} = 100\text{W}$ each at 24V into 4$\Omega$, totaling 300W theoretical peak.
* **Fanless Convection & Power Limiter:** Under movie and music listening, the average power draw is typically only 6%–10% of maximum (~18W–30W). The ESP32 firmware limiter caps maximum voltage output at 83.6% (70% power ceiling = 210W peak). At this level, power supply load remains under 70%, ensuring the Mean Well internal fan **never spins**, providing zero fan noise.
* **4700µF 35V/50V Bulk Electrolytic Capacitor:** Bridged directly across the WAGO 221-415 input ports. This capacitor acts as a local energy reservoir, smoothing switching ripple and instantly supplying current during high-transient bass hits without voltage drop.

### 2.2 Solderless Modular Distribution (WAGO 221-415)
* Instead of messy soldered star splices, two **WAGO 221-415 5-conductor lever connectors** serve as the central power distribution buses.
* Each connector is rated for **32A / 450V**, with transparent poly-carbonate bodies and orange levers for tool-free, gas-tight, vibration-proof connections.
* Test slots on the rear allow probing with a multimeter without disconnecting any wires.

### 2.3 Grounding & Noise Hygiene
1. **Safety Earth (PE / ⏚):** Green/Yellow wire directly from mains inlet to Mean Well chassis terminal AND bolted to the AL6061 enclosure with an M4 toothed star washer for chassis safety ground.
2. **DC Power Ground:** Black wire (16 AWG) from Mean Well -V to WAGO GND rail, distributed to each amplifier's power GND pad (Pad 9).
3. **Audio Signal Ground:** Separate audio ground from DAC AGND to Amp Pad 2 through the braided shield of the 2-core audio cable. The shield is grounded at the DAC end to eliminate ground loops and hum.
4. **Bridge-Tied Load (BTL) Speaker Grounding Rule:** The TPA3116D2 uses BTL outputs. **Neither `SPL-` nor `SPR-` is connected to ground!** Each speaker negative must return exclusively to its dedicated terminal pad on the amplifier board.

---

## 3. Pictorial Power Distribution Subsystem

### 3.1 Mean Well LRS-350-24 SMPS & AC Mains

| Component Photo | Technical Specification |
| :---: | :--- |
| ![Mean Well LRS-350-24](file:///d:/Documents/DIY%20Amp/Meanwell%20LRS-350-24%20SMPS.png)<br>![Terminal View](file:///d:/Documents/DIY%20Amp/image/PROJECT/1791220683079.webp) | **Model:** Mean Well LRS-350-24<br>**Input:** 100–240V AC ~ 50/60Hz<br>**Output:** 24V DC, 14.6A, 350.4W Max<br>**Efficiency:** 89%<br>**Dimensions:** 215 × 115 × 30 mm<br>**Cooling:** Auto ON/OFF fan (silent at &lt; 70% load) |

#### Terminal Block Connections (Terminals 1 to 9 from Left to Right):
1. **Terminal 1 (`L` - Live):** Connect to AC Mains Live via **3A Slow-Blow 5×20mm fuse** in the IEC socket.
2. **Terminal 2 (`N` - Neutral):** Connect to AC Mains Neutral.
3. **Terminal 3 (`⏚` - Earth / PE):** Connect to Mains Safety Earth (Green/Yellow, 18 AWG) and bond to AL6061 metal chassis.
4. **Terminals 4, 5, 6 (`-V` / COM / GND):** 0V DC Negative Output. Run 16 AWG Black wire to XT60 GND pin.
5. **Terminals 7, 8, 9 (`+V` / 24V):** +24V DC Positive Output. Run 16 AWG Red wire to XT60 +24V pin.

#### Quick Disconnect (GX16 4-Pin Metal Aviation Plug [Parallel Pins]):
* **Chassis Socket:** Female 4-pin flange mounted to amplifier polycarbonate back panel (16mm cutout).
* **Umbilical Cable Plug:** Male 4-pin metal plug on external Mean Well harness with screw-locking collar.
* **Pinout & High-Current Distribution (15A continuous rating):**
  - **Pin 1 & Pin 2:** Paralleled together for **+24V DC Infeed** (16 AWG Red, shared current ~7.3A peak per pin).
  - **Pin 3 & Pin 4:** Paralleled together for **0V GND Return** (16 AWG Black, shared current ~7.3A peak per pin).
* **Inrush Mitigation (Cold-Plug Procedure):**
  - Connect and screw-lock the GX16 4-pin connector *before* energizing AC mains power.
  - Mean Well LRS-350 internal soft-start circuit ramps output smoothly, preventing contact arcing across the 9,400µF capacitor bank.

---

### 3.2 24V DC WAGO Distribution Rails & Capacitive Filter

| WAGO 221-415 (5-Port) | 4700µF 50V Bulk Capacitor |
| :---: | :---: |
| ![WAGO 221-415](file:///d:/Documents/DIY%20Amp/WAGO%20221-415%205-Conductor%20Lever%20Splicing%20Connector.png) | ![4700uF Capacitor](file:///d:/Documents/DIY%20Amp/4700uF%2050V%20Electrolytic%20Capacitor.png) |

#### +24V Distribution Rail (WAGO 221-415 #1 — Positive Bus):
* **Port 1 (Input):** +24V DC from XT60 female socket (via 10A inline slow-blow fuse) — **16 AWG Red**
* **Port 2 (Output):** `VCC` to **Amp Board #1** (Front L/R) — **20 AWG Red**
* **Port 3 (Output):** `VCC` to **Amp Board #2** (Rear L/R) — **20 AWG Red**
* **Port 4 (Output):** `VCC` to **Amp Board #3** (Center/Sub) — **20 AWG Red**
* **Port 5 (Output):** `IN+` to **XL4015 Buck Converter** — **20 AWG Red**
* *(Positive lead of 4700µF capacitor inserted into Port 1 alongside the main feed).*

#### 0V / GND Distribution Rail (WAGO 221-415 #2 — Ground Bus):
* **Port 1 (Input):** -V / 0V GND from XT60 female socket — **16 AWG Black**
* **Port 2 (Output):** `GND` to **Amp Board #1** — **20 AWG Black**
* **Port 3 (Output):** `GND` to **Amp Board #2** — **20 AWG Black**
* **Port 4 (Output):** `GND` to **Amp Board #3** — **20 AWG Black**
* **Port 5 (Output):** `IN-` to **XL4015 Buck Converter** — **20 AWG Black**
* *(Negative lead of 4700µF capacitor inserted into Port 1 alongside the main ground).*

---

### 3.3 5V Logic Power Supply (XL4015 5A DC-DC Buck Converter)

* **Input:** 24V DC from WAGO Rails (Port 5 on both rails).
* **Calibration Procedure:**
  1. Power on 24V supply *before* connecting ESP32 or DACs.
  2. Measure `OUT+` and `OUT-` with a digital multimeter.
  3. Turn the brass multiturn trimmer screw counter-clockwise until the output reads **5.00V ± 0.05V DC**.
* **Output:**
  * `OUT+` (5.0V) connects to ESP32 `5V`/`VIN` pin and all three PCM5102A `VCC` pins.
  * `OUT-` (GND) connects to ESP32 `GND` pin and DAC/ADC logic ground pins.

---

## 4. Pictorial Digital Audio & Brain Subsystem

### 4.1 Dual-ESP32-S3 Brain & Wireless/Touch Display Subsystem

| Controller 1: Waveshare 4.3B Touch (`Model 28141`) | Controller 2: Waveshare ESP32-S3-Pico (`SKU: 1552780`) |
| :---: | :---: |
| ![Waveshare ESP32-S3 Touch](file:///d:/Documents/DIY%20Amp/image/PROJECT/1791222659512.png) | ![ESP32-S3-Pico](file:///d:/Documents/DIY%20Amp/image/PROJECT/waveshare_esp32_s3_pico_1552780.jpg) |

* **Controller 1 — Touch HMI / Wireless Sofa Remote (`Model 28141`):** 4.3" `800×480` IPS Capacitive Touch Display (16MB Flash + 8MB PSRAM + onboard `CS8501` 3.7V LiPo battery charger & switch). Can operate **100% untethered as a Battery-Operated Wireless Sofa Remote via ESP-NOW / Wi-Fi (`<2ms` latency)** OR docked via 2-wire `I2C` (`GPIO 8 SDA / GPIO 9 SCL`).
* **Controller 2 — Internal 6-Ch Audio DSP Engine (`Waveshare ESP32-S3-Pico, SKU: 1552780`, Pre-Soldered Yellow Headers):** 32-bit LX7 Dual-Core @ 240MHz (`16MB Flash + 2MB PSRAM + 512KB SRAM + 384KB ROM`, `CH343+CH334` Type-C) mounted inside the amplifier tray. Drives the 3× PCM5102A DACs and 1× PCM1808 ADC with zero LCD DMA interference.
* **Service Port:** USB-C 24-Pin breakout on the rear panel connected to `SKU: 1552780` for firmware upgrades and DSP diagnostics.

---

### 4.2 3× PCM5102A I2S DAC Modules (HW-280)

| PCM5102A HW-280 Stereo DAC Board | Detailed Pinout View |
| :---: | :---: |
| ![PCM5102A DAC](file:///d:/Documents/DIY%20Amp/image/PROJECT/1791016549053.png) | ![PCM5102A Alt](file:///d:/Documents/DIY%20Amp/image/pasted_20261003-052037.png) |

#### Pin Interconnections (`Waveshare ESP32-S3 SKU: 1552780` &rarr; `3× PCM5102A DACs`):

| Signal | ESP32-S3-Pico MASTER (`SKU: 1552780`) Pin | DAC #1 (Amp #1: FL/FR) | DAC #2 (Amp #2: Surround, via Slave) | DAC #3 (Amp #3: Center/Sub) | Wiring Type |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Bit Clock (BCK)** | **`GPIO 15`** | `BCK` | `BCK` | `BCK` | Shared clock bus (28 AWG Cyan) |
| **Word Select (LRCK / WS)** | **`GPIO 16`** | `LCK` | `LCK` | `LCK` | Shared clock bus (28 AWG Blue) |
| **Serial Data 1 (Amp #1)** | **`GPIO 7`** (`DOUT 1`) | `DIN` | — | — | Dedicated line (28 AWG Purple) |
| **Serial Data 2 (Amp #3)** | **`GPIO 6`** (`DOUT 2`) | — | — | `DIN` | Dedicated line (28 AWG Purple) |
| **Serial Data 3 (Amp #2, from Slave)** | **Slave `D27`** | — | `DIN` | — | Dedicated line (28 AWG Purple) |
| **Logic Power (5.0V)** | Buck `OUT+` (`5V`) | `VIN` | `VIN` | `VIN` | Shared 5V bus (24 AWG Orange) |
| **Logic Ground (0V)** | Buck `OUT-` (`GND`) | `GND` | `GND` | `GND` | Shared ground bus (24 AWG Black) |

> ### [!IMPORTANT]
> #### PCM5102A (HW-280) Solder Jumper Configuration (Up to Minute Detail):
> To make the PCM5102A operate seamlessly without an external master clock (MCLK), configure the jumpers on the back of each board:
> 1. **`SCK` Pin:** Connect directly to **`GND`**. Grounding the SCK pin activates the internal Phase-Locked Loop (PLL), which automatically synthesizes the internal system clock from the BCK line.
> 2. **Jumper 1 (`FLT` - Digital Filter):** Solder bridge to **`GND`** (Selects normal latency FIR filter).
> 3. **Jumper 2 (`DMP` - De-emphasis):** Solder bridge to **`GND`** (De-emphasis filter OFF).
> 4. **Jumper 3 (`FMT` - Audio Format):** Solder bridge to **`GND`** (Standard I2S format).
> 5. **Jumper 4 (`XMT` - Soft Mute):** High (Internal pull-up enabled, unmuted).

---

### 4.3 PCM1808 24-Bit Stereo ADC (AUX Input)

| PCM1808 ADC Board | AMS1117 3.3V Module |
| :---: | :---: |
| ![PCM1808 ADC](file:///d:/Documents/DIY%20Amp/image/PROJECT/1791122464907.png) | ![AMS1117 Module](file:///d:/Documents/DIY%20Amp/image/PROJECT/1791221023178.png) |

* **Input:** CentIoT PJ392A-1 3.5mm Stereo Jack:
  * Tip &rarr; `LIN` (Left Audio Input)
  * Ring &rarr; `RIN` (Right Audio Input)
  * Sleeve &rarr; `GND` (Audio Ground)
* **Output:** Converts analog AUX signals to 24-bit 96kHz digital I2S stream connected to ESP32-S3 I2S Data In (`DIN`), sharing `BCK` and `LRC` clocks.

---

## 5. Pictorial Amplifier Subsystem (3× XH-M562 TPA3116D2 Boards)

| XH-M562 TPA3116D2 PCB (Primary View) | XH-M562 Solder-Pad PCB (Header / Trace View) |
| :---: | :---: |
| ![XH-M562 PCB](file:///d:/Documents/DIY%20Amp/image/PROJECT/1791126129975.png) | ![XH-M562 Solder Pads](file:///d:/Documents/DIY%20Amp/image/PROJECT/1791126239021.png) |

### 10-Pad Terminal Pinout (Top to Bottom):

```
 ┌──────────────────────────────────────────────┐
 │ [Pad 1]  INL   ◄── Audio Input Left          │
 │ [Pad 2]  GND   ◄── Audio Ground (Shield)     │
 │ [Pad 3]  INR   ◄── Audio Input Right         │
 │ [Pad 4]  SPL-  ──► Left Speaker Negative (-) │
 │ [Pad 5]  SPL+  ──► Left Speaker Positive (+) │
 │ [Pad 6]  SPR-  ──► Right Speaker Negative(-) │
 │ [Pad 7]  SPR+  ──► Right Speaker Positive(+) │
 │ [Pad 8]  VCC   ◄── +24V DC Power Supply      │
 │ [Pad 9]  GND   ◄── 0V DC Power Ground        │
 │ [Pad 10] CS    ◄── Chip Select (Floating/ON) │
 └──────────────────────────────────────────────┘
```

---

### Detailed Interconnection Matrix per Amplifier Board

#### Amp Board #1: Front Left & Front Right Channels
* **Audio Input:**
  * `INL` (Pad 1) &larr; DAC #1 Analog Out `L` (Core 1 of shielded cable)
  * `GND` (Pad 2) &larr; DAC #1 Audio Ground `G` (Cable shield braid)
  * `INR` (Pad 3) &larr; DAC #1 Analog Out `R` (Core 2 of shielded cable)
* **Speaker Outputs:**
  * `SPL+` (Pad 5) &rarr; Front Left Speaker Binding Post (+ Red)
  * `SPL-` (Pad 4) &rarr; Front Left Speaker Binding Post (- Black)
  * `SPR+` (Pad 7) &rarr; Front Right Speaker Binding Post (+ Red)
  * `SPR-` (Pad 6) &rarr; Front Right Speaker Binding Post (- Black)
* **Power Supply:**
  * `VCC` (Pad 8) &larr; WAGO +24V Rail Port 2 (20 AWG Red)
  * `GND` (Pad 9) &larr; WAGO GND Rail Port 2 (20 AWG Black)
  * `CS` (Pad 10) &larr; Leave Disconnected / Floating

#### Amp Board #2: Rear Left & Rear Right (Surround) Channels
* **Audio Input:**
  * `INL` (Pad 1) &larr; DAC #2 Analog Out `L` (Core 1 of shielded cable)
  * `GND` (Pad 2) &larr; DAC #2 Audio Ground `G` (Cable shield braid)
  * `INR` (Pad 3) &larr; DAC #2 Analog Out `R` (Core 2 of shielded cable)
* **Speaker Outputs:**
  * `SPL+` (Pad 5) &rarr; Rear Left Speaker Binding Post (+ Red)
  * `SPL-` (Pad 4) &rarr; Rear Left Speaker Binding Post (- Black)
  * `SPR+` (Pad 7) &rarr; Rear Right Speaker Binding Post (+ Red)
  * `SPR-` (Pad 6) &rarr; Rear Right Speaker Binding Post (- Black)
* **Power Supply:**
  * `VCC` (Pad 8) &larr; WAGO +24V Rail Port 3 (20 AWG Red)
  * `GND` (Pad 9) &larr; WAGO GND Rail Port 3 (20 AWG Black)
  * `CS` (Pad 10) &larr; Leave Disconnected / Floating

#### Amp Board #3: Center & Subwoofer Channels
* **Audio Input:**
  * `INL` (Pad 1) &larr; DAC #3 Analog Out `L` (Center Channel)
  * `GND` (Pad 2) &larr; DAC #3 Audio Ground `G` (Cable shield braid)
  * `INR` (Pad 3) &larr; DAC #3 Analog Out `R` (Subwoofer Channel)
* **Speaker Outputs:**
  * `SPL+` (Pad 5) &rarr; Center Speaker Binding Post (+ Red)
  * `SPL-` (Pad 4) &rarr; Center Speaker Binding Post (- Black)
  * `SPR+` (Pad 7) &rarr; Subwoofer Speaker Binding Post (+ Red)
  * `SPR-` (Pad 6) &rarr; Subwoofer Speaker Binding Post (- Black)
* **Power Supply:**
  * `VCC` (Pad 8) &larr; WAGO +24V Rail Port 4 (20 AWG Red)
  * `GND` (Pad 9) &larr; WAGO GND Rail Port 4 (20 AWG Black)
  * `CS` (Pad 10) &larr; Leave Disconnected / Floating

---

## 6. Rear Panel I/O & Speaker Binding Posts

| Chassis Hero Concept | Rear Panel Layout Architecture |
| :---: | :---: |
| ![Copper Chimney Hero](file:///d:/Documents/DIY%20Amp/image/copper_chimney_v2_hero.jpg) | ![Rear View](file:///d:/Documents/DIY%20Amp/image/copper_chimney_v2_back_view.jpg) |

### 12× JS-910B 4mm Gold-Plated Binding Posts:
* 6 Red / Blue Binding Posts = Positive speaker connections (`SPL+`, `SPR+`)
* 6 Black Binding Posts = Negative speaker connections (`SPL-`, `SPR-`)
* **Mounting Advantage (Polycarbonate Rear Panel):** Because the rear I/O plate is made of non-conductive Polycarbonate (Lexan), the binding post threads are 100% electrically insulated by default! There is zero risk of BTL amplifier short-circuits to chassis ground.

```
 ┌─────────────────────────────────────────────────────────────┐
 │                    REAR I/O PANEL LAYOUT                    │
 │                                                             │
 │   [FL+]  [FR+]    [RL+]  [RR+]    [CEN+] [SUB+]             │
 │   (RED)  (RED)    (RED)  (RED)    (RED)  (RED)              │
 │                                                  [GX16-4 4P]│
 │   [FL-]  [FR-]    [RL-]  [RR-]    [CEN-] [SUB-]    24V POWER│
 │   (BLK)  (BLK)    (BLK)  (BLK)    (BLK)  (BLK)    (PARALLEL)│
 │                                                             │
 │   [ 3.5mm STEREO AUX ]               [ USB-C SERVICE PORT ] │
 └─────────────────────────────────────────────────────────────┘
```

---

## 7. Master Wire, Gauge & Connection Matrix

| Connection Path | From | To | Wire Type / Gauge | Wire Color | Termination Method |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Mains AC Input** | IEC Socket | Mean Well LRS-350 | 3-Core 0.75mm² (18 AWG) | Brown/Blue/Grn | Screw Terminals (Term 1, 2, 3) |
| **Mains Safety Earth** | IEC Ground | AL6061 Chassis | 18 AWG Stranded | Green/Yellow | M4 Ring Crimp + Star Washer |
| **Main DC +24V Feed** | Mean Well (+V) | WAGO 221-415 #1 (P1) | 16 AWG Stranded | Red | Screw &rarr; 10A Fuse &rarr; WAGO Lever |
| **Main DC GND Feed** | Mean Well (-V) | WAGO 221-415 #2 (P1) | 16 AWG Stranded | Black | Screw &rarr; WAGO Lever |
| **Bulk Capacitor** | WAGO +24V (P1) | WAGO GND (P1) | Radial Capacitor Leads | Black / Silver Band | Inserted directly into WAGO P1 |
| **Amp #1 Power** | WAGO Rails (P2) | Amp #1 (Pad 8, 9) | 20–22 AWG Stranded | Red (+) / Black (-) | WAGO Lever &rarr; Soldered to PCB |
| **Amp #2 Power** | WAGO Rails (P3) | Amp #2 (Pad 8, 9) | 20–22 AWG Stranded | Red (+) / Black (-) | WAGO Lever &rarr; Soldered to PCB |
| **Amp #3 Power** | WAGO Rails (P4) | Amp #3 (Pad 8, 9) | 20–22 AWG Stranded | Red (+) / Black (-) | WAGO Lever &rarr; Soldered to PCB |
| **Buck Converter In** | WAGO Rails (P5) | XL4015 IN+ / IN- | 20 AWG Stranded | Red (+) / Black (-) | WAGO Lever &rarr; Screw Terminals |
| **5V Logic Rail** | XL4015 OUT | ESP32 5V &amp; 3× DACs | 24 AWG Hookup | Orange (+) / Black (-) | Screw &rarr; DuPont / Solder |
| **I2S Clocks (BCK, WS)**| ESP32-S3 | 3× DACs + ADC | 28 AWG Ribbon / DuPont | Cyan (BCK) / Blue (WS)| DuPont Female Header |
| **I2S Data Lines** | ESP32-S3-Pico + Slave ESP32-WROOM-32 | 3× DACs (DIN) | 28 AWG Ribbon / DuPont | Purple | Direct DuPont Lines |
| **Analog Audio (6ch)** | 3× DACs | 3× Amps (Pad 1, 2, 3)| 2-Core Shielded Cable | Red (R) / Wht (L) / Braid | Soldered to DAC &amp; Amp Pads |
| **Speaker Lines (12)** | 3× Amps (P4-7) | 12× Binding Posts | 20–22 AWG Stranded | Red (+) / Black (-) | Soldered to Amp &rarr; Ring Crimp |

---

## 8. Non-Expert Assembly & Quality Assurance Checklist

1. **Pre-Tinning Wire Strands:** Strip 2–3 mm of wire insulation. Tightly twist the copper strands between your fingertips and coat the bare wire with a bead of solder before inserting it into any PCB through-hole.
2. **The 3-Second Soldering Rule:** Place the soldering iron tip across both the wire and the copper ring pad on the board. Feed 1 mm of solder wire. Count *1, 2, 3* and remove the iron immediately to avoid lifting PCB pads.
3. **Calibrate XL4015 Buck Before Connecting Electronics:** Never connect the ESP32 or DACs to the XL4015 until you have verified the output with a multimeter. Adjust the multiturn trimmer until the meter displays exactly **5.00V DC**.
4. **Inspect for Solder Bridges:** Hold the soldered XH-M562 board up to a strong light source. Visually inspect between pads 4 &amp; 5, pads 6 &amp; 7, and pads 8 &amp; 9 to ensure no stray solder hairs or bridges exist.
5. **Strain Relief Glue Bead:** After soldering the 9 wires to each amplifier board, apply a dab of hot-melt glue or non-corrosive neutral RTV silicone across the wire bundle at the board edge to prevent copper fatigue during assembly.
6. **Pre-Power Continuity Check:**
   * Test resistance between the +24V WAGO rail and GND WAGO rail (Must be &gt; $10\text{k}\Omega$).
   * Test resistance between every speaker negative binding post and the aluminum chassis (Must read open circuit / infinite resistance).


---

## Slave ESP32-WROOM-32 (30-pin) — Surround DAC #2

![ESP32-WROOM-32 30-pin Slave](file:///d:/Documents/DIY%20Amp/image/PROJECT/esp32_wroom32_30pin_slave.jpg)

| Slave pin | Function | Connects To |
| :--- | :--- | :--- |
| `D26` | `BCK` in (I2S slave) | Pico `GPIO 15` |
| `D25` | `LRCK` in (I2S slave) | Pico `GPIO 16` |
| `D35` | `DIN` in (input-only pin) | PCM1808 `OUT` (parallel with Pico `GPIO 4`) |
| `D27` | `DOUT` | PCM5102A DAC #2 `DIN` (Amp #2: Surround L/R) |
| `VIN` / `GND` | 5 V / ground | Clean 5 V rail / common ground (do not connect USB and `VIN` together) |

Pico MCLK for the PCM1808 is on `GPIO 2` (not `GPIO 0`). UI control from the 4.3B reaches both MCUs over ESP-NOW. Full notes: [esp32.md](file:///d:/Documents/DIY%20Amp/esp32.md) section 3.
