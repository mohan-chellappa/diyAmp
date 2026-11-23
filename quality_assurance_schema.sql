-- ==============================================================================
-- DIY 5.1 Analog Amplifier (Copper Chimney V2)
-- Quality Assurance & Engineering Risk Management Database Schema
-- Standard: AIAG-VDA FMEA 1st Edition / IATF 16949 Control Plan
-- Target Engine: MySQL 8.0+ / 8.2+
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS `diy_amp_quality`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `diy_amp_quality`;

-- ------------------------------------------------------------------------------
-- 1. Table: dfmea_records (Design Failure Mode and Effects Analysis)
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS `dfmea_records`;
CREATE TABLE `dfmea_records` (
  `id` VARCHAR(16) NOT NULL,
  `subsystem` VARCHAR(64) NOT NULL,
  `item_function` VARCHAR(128) NOT NULL,
  `potential_failure_mode` VARCHAR(255) NOT NULL,
  `potential_failure_effects` VARCHAR(255) NOT NULL,
  `severity` TINYINT UNSIGNED NOT NULL CHECK (`severity` BETWEEN 1 AND 10),
  `potential_causes` VARCHAR(255) NOT NULL,
  `occurrence` TINYINT UNSIGNED NOT NULL CHECK (`occurrence` BETWEEN 1 AND 10),
  `current_prevention_controls` VARCHAR(255) NOT NULL,
  `current_detection_controls` VARCHAR(255) NOT NULL,
  `detection` TINYINT UNSIGNED NOT NULL CHECK (`detection` BETWEEN 1 AND 10),
  `initial_rpn` SMALLINT UNSIGNED GENERATED ALWAYS AS (`severity` * `occurrence` * `detection`) STORED,
  `recommended_action` TEXT NOT NULL,
  `action_taken_status` VARCHAR(255) NOT NULL,
  `rev_sev` TINYINT UNSIGNED NOT NULL CHECK (`rev_sev` BETWEEN 1 AND 10),
  `rev_occ` TINYINT UNSIGNED NOT NULL CHECK (`rev_occ` BETWEEN 1 AND 10),
  `rev_det` TINYINT UNSIGNED NOT NULL CHECK (`rev_det` BETWEEN 1 AND 10),
  `final_rpn` SMALLINT UNSIGNED GENERATED ALWAYS AS (`rev_sev` * `rev_occ` * `rev_det`) STORED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_dfmea_subsystem` (`subsystem`),
  INDEX `idx_dfmea_final_rpn` (`final_rpn`),
  INDEX `idx_dfmea_severity` (`severity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 2. Table: pfmea_records (Process Failure Mode and Effects Analysis)
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS `pfmea_records`;
CREATE TABLE `pfmea_records` (
  `op_no` VARCHAR(16) NOT NULL,
  `process_step` VARCHAR(128) NOT NULL,
  `process_function` VARCHAR(255) NOT NULL,
  `potential_failure_mode` VARCHAR(255) NOT NULL,
  `potential_failure_effects` VARCHAR(255) NOT NULL,
  `severity` TINYINT UNSIGNED NOT NULL CHECK (`severity` BETWEEN 1 AND 10),
  `potential_causes` VARCHAR(255) NOT NULL,
  `occurrence` TINYINT UNSIGNED NOT NULL CHECK (`occurrence` BETWEEN 1 AND 10),
  `current_prevention_controls` VARCHAR(255) NOT NULL,
  `current_detection_controls` VARCHAR(255) NOT NULL,
  `detection` TINYINT UNSIGNED NOT NULL CHECK (`detection` BETWEEN 1 AND 10),
  `initial_rpn` SMALLINT UNSIGNED GENERATED ALWAYS AS (`severity` * `occurrence` * `detection`) STORED,
  `recommended_action` TEXT NOT NULL,
  `action_taken_status` VARCHAR(255) NOT NULL,
  `rev_sev` TINYINT UNSIGNED NOT NULL CHECK (`rev_sev` BETWEEN 1 AND 10),
  `rev_occ` TINYINT UNSIGNED NOT NULL CHECK (`rev_occ` BETWEEN 1 AND 10),
  `rev_det` TINYINT UNSIGNED NOT NULL CHECK (`rev_det` BETWEEN 1 AND 10),
  `final_rpn` SMALLINT UNSIGNED GENERATED ALWAYS AS (`rev_sev` * `rev_occ` * `rev_det`) STORED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`op_no`),
  INDEX `idx_pfmea_final_rpn` (`final_rpn`),
  INDEX `idx_pfmea_severity` (`severity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 3. Table: control_plan_records (Quality Control & Inspection Plan)
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS `control_plan_records`;
CREATE TABLE `control_plan_records` (
  `plan_id` VARCHAR(16) NOT NULL,
  `op_no` VARCHAR(16) NOT NULL,
  `process_name` VARCHAR(128) NOT NULL,
  `machine_device_jig` VARCHAR(255) NOT NULL,
  `characteristic_type` ENUM('Product', 'Process') NOT NULL,
  `characteristic_description` VARCHAR(255) NOT NULL,
  `special_char_class` ENUM('CC (Critical)', 'SC (Significant)', 'YS (Safety)', 'Standard') NOT NULL,
  `specification_tolerance` VARCHAR(255) NOT NULL,
  `measurement_technique` VARCHAR(255) NOT NULL,
  `sample_size_frequency` VARCHAR(128) NOT NULL,
  `control_method` VARCHAR(255) NOT NULL,
  `reaction_plan` TEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`plan_id`),
  CONSTRAINT `fk_cp_op_no` FOREIGN KEY (`op_no`) REFERENCES `pfmea_records` (`op_no`) ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX `idx_cp_special_class` (`special_char_class`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- SAMPLE DATA INSERTION: DFMEA RECORDS
-- ==============================================================================
INSERT INTO `dfmea_records` (
  `id`, `subsystem`, `item_function`, `potential_failure_mode`, `potential_failure_effects`,
  `severity`, `potential_causes`, `occurrence`, `current_prevention_controls`, `current_detection_controls`,
  `detection`, `recommended_action`, `action_taken_status`, `rev_sev`, `rev_occ`, `rev_det`
) VALUES
('DFM-01', 'Acoustic Output', 'BTL Speaker Negative Return Isolation',
 'Speaker negative lead shorts to chassis ground',
 'BTL H-bridge lower MOSFET overcurrent, catastrophic TPA3116 die destruction',
 10, 'Metal-to-chassis contact through conducting rear plate or loose terminal washers',
 7, 'Isolate binding posts from aluminum frame', 'Bench DMM continuity check before power',
 6, 'Mount all 12 binding posts into 4mm non-conductive Polycarbonate rear panel; eliminate all conductive chassis path',
 'Implemented: 100% non-conductive rear panel', 10, 1, 2),

('DFM-02', 'Thermal Management', 'Amplifier Heat Dissipation',
 'TPA3116 die temperature exceeds 150°C junction limit',
 'Amplifier thermal shutdown, audio dropout, long-term silicon aging',
 8, 'Insufficient passive heatsinking surface, trapped heat inside sealed chamber',
 8, 'Internal aluminum heat plates', 'Thermal imaging during bench prototyping',
 5, 'Direct flat clamping of TPA3116 chips to AL6061 finned side plates with Arctic MX-4 paste + 35mm central convective copper chimney',
 'Implemented: 30.2W passive dissipation capacity vs 18W max heat', 8, 2, 2),

('DFM-03', 'Power Supply', '24V DC Rail Stability',
 'Voltage drop/sag (> 3.5V) during high-transient bass hits',
 'Audible clipping, distortion, low-frequency rail pumping, brownout',
 7, 'High internal resistance on long umbilical or inadequate reservoir capacitance',
 7, 'Standard Mean Well SMPS internal output caps', 'Oscilloscope peak transient capture',
 5, 'Bridge 4700uF 50V Low-ESR bulk electrolytic reservoir capacitor directly across WAGO 221-415 bus bars',
 'Implemented: 4700uF cap buffers transient current surges', 7, 2, 2),

('DFM-04', 'Audio Processing', 'ESP32-S3 Digital Audio Supervisory',
 'Digital full-scale (0 dBFS) clipping into DAC inputs',
 'Audible harmonic distortion (> 10% THD), harsh treble clipping',
 7, 'Overdriven software gain scaling or volume multiplier mismatch in firmware',
 8, 'Default ESP-IDF audio volume algorithm', 'Listening tests at full volume',
 4, 'Firmware hard limit set at 83.6% voltage amplitude ceiling (70% power ceiling = 210W peak unclipped)',
 'Implemented: Permanent firmware limiter keeps TPA3116 in <0.05% THD window', 7, 1, 2),

('DFM-05', 'I2S Bus', 'Clock Synchronization across 3x PCM5102A',
 'Bit Clock (BCK) or Word Select (LRCK) skew and jitter',
 'Channel phase misalignment, digital clicks, DAC decoding failure',
 6, 'Long daisy-chained clock traces with excessive parasitic capacitance (> 50pF)',
 6, 'Standard ribbon cable interconnects', 'Logic analyzer multi-channel clock timing verification',
 5, 'Star clock distribution bus with trace runs < 60mm; stack DACs directly behind ESP32 front panel',
 'Implemented: Short parallel clock lines, jitter < 50ps', 6, 2, 2),

('DFM-06', 'Logic Regulation', 'XL4015 DC-DC Buck Step-Down',
 'Buck output drifts above 5.5V logic absolute maximum',
 'Permanent overvoltage burnout of ESP32-S3, DACs, and ADC',
 9, 'Potentiometer wiper vibration drift or failure under heat',
 6, 'Single multi-turn trimming potentiometer', 'Bench multimeter verification before logic plug-in',
 5, 'Pre-calibrate buck trimmer with thread-locking compound; add zener clamp overvoltage crowbar on 5V logic bus',
 'Implemented: Multi-turn cermet trimmer glued at 5.00V DC', 9, 2, 2),

('DFM-07', 'Analog Audio', '3.5mm Stereo AUX Line Input',
 'Ground loop 50Hz/100Hz mains hum induced into analog signal',
 'Audible hum through all 6 speakers, degraded SNR (< 75 dB)',
 6, 'Multiple ground return paths between input jack, DAC ground, and power ground',
 7, 'Common ground return wire', 'Bench acoustic noise floor analysis (A-weighted)',
 4, 'Isolated audio ground path; shielded 2-core cable grounded strictly at DAC AGND end only',
 'Implemented: Single-point star audio grounding; SNR > 102 dB', 6, 2, 2),

('DFM-08', 'Acoustics & PSU', 'Mean Well LRS-350-24 Fan Operation',
 'Internal SMPS fan switches ON during quiet listening sessions',
 'Acoustic background fan noise (38 dBA) destroys listening ambiance',
 5, 'Thermal load on internal SMPS heatsink exceeds 50°C fan threshold',
 8, 'Internal SMPS fan thermostat', 'Sound level meter at 1m distance',
 3, 'External wall mounting of SMPS outside cube + ESP32 70% power ceiling keeps PSU load <= 60% (fan remains off)',
 'Implemented: SMPS permanently silent during home theater playback', 5, 2, 2),

('DFM-09', 'Wireless RF', '2.4 GHz Wi-Fi & Bluetooth 5.0 LE',
 'Faraday cage attenuation drops RF signal (> 25 dB loss)',
 'Bluetooth audio dropouts, loss of web dashboard connectivity, erratic playback',
 7, 'All-metal aluminum chassis enclosure completely shielding internal antenna',
 9, 'Internal PCB antenna on ESP32-S3', 'RF RSSI signal strength mapping',
 4, 'Adopt 4-Face Polycarbonate enclosure (Front, Back, Top, Bottom) with dielectric constant er ≈ 2.9 (RF transparent)',
 'Implemented: 360° unattenuated wireless transmission', 7, 1, 2),

('DFM-10', 'Enclosure Mechanics', 'Polycarbonate Chimney Exhaust Interface',
 'Thermal softening or optical haze on top plate around copper pipe',
 'Top panel distortion, loosened chimney seal, aesthetic degradation',
 6, 'Continuous conductive heat transfer from central copper pipe (> 65°C) to plastic',
 6, 'Direct contact between copper pipe and laser cutout', 'Thermal chamber stress testing at 60°C ambient',
 4, 'Insert high-temperature silicone rubber isolation grommet between copper chimney and polycarbonate top plate',
 'Implemented: Silicone thermal barrier isolates copper tube from plastic', 6, 2, 2),

('DFM-11', 'Electrical Safety', '230V AC Mains Insulation',
 'Mains Live conductor loose wire touches external chassis',
 'Electric shock hazard, user injury, ground fault trip',
 10, 'Vibration loosening screw terminal or insulation abrasion on sharp metal edge',
 5, 'Standard terminal cover on SMPS', 'Dielectric withstand (Hipot) test 1500V AC',
 4, '3A fused IEC socket with heat-shrink insulated boot + M4 star-washer chassis ground bonding (< 0.1 ohm)',
 'Implemented: Full double insulation on AC side and certified PE bond', 10, 1, 2),

('DFM-12', 'DAC Initialization', 'PCM5102A Start-Up Synchronization',
 'DAC powers up before external system clock stabilizes',
 'Pop noise on power-on, soft-mute stuck in muted state',
 7, 'Asynchronous power-up between XL4015 buck and ESP32 I2S clock generator',
 7, 'Internal PCM5102A power-on reset circuit', 'Oscilloscope timing trace on VCC vs BCK rise time',
 4, 'Hardwire PCM5102A SCK pin directly to GND to enable internal PLL; ESP32 initializes audio bus before unmuting',
 'Implemented: Automatic PLL generation and zero pop noise on boot', 7, 2, 2);

-- ==============================================================================
-- SAMPLE DATA INSERTION: PFMEA RECORDS
-- ==============================================================================
INSERT INTO `pfmea_records` (
  `op_no`, `process_step`, `process_function`, `potential_failure_mode`, `potential_failure_effects`,
  `severity`, `potential_causes`, `occurrence`, `current_prevention_controls`, `current_detection_controls`,
  `detection`, `recommended_action`, `action_taken_status`, `rev_sev`, `rev_occ`, `rev_det`
) VALUES
('OP-10', 'Chassis Machining & Cutouts', 'CNC laser cut Polycarbonate panels & mill AL6061 fin plates',
 'Micro-cracks, burrs, or dimensional mismatch (> 0.5mm) on cutouts',
 'Air leaks around chimney, binding post loose fit, cracked plastic panel',
 6, 'Feed rate too fast, incorrect laser power setting, dull CNC milling bit',
 6, 'Machine tool calibration and test cut on scrap piece', 'Vernier caliper 100% dimensional check and edge optical inspection',
 4, 'Use specialized single-flute plastic endmill; anneal laser-cut edges; verify cutouts against go/no-go acrylic gauge',
 'Implemented: Laser cutting parameters calibrated; edge tolerance < 0.15mm', 6, 2, 2),

('OP-20', 'Thermal Interface Dispensing', 'Apply Arctic MX-4 thermal compound on TPA3116 chips',
 'Uneven paste spread, air voids, or paste dry-out (> 50 micron layer)',
 'Elevated thermal resistance (> 3.5°C/W), localized hot spot, thermal throttling',
 8, 'Improper dot dispensing pattern, inadequate clamping pressure on PCB',
 7, 'Operator visual estimation of thermal paste blob size', 'Post-clamping squeeze-out visual inspection and thermal camera soak test',
 5, 'Standardize on "X-pattern" micro-dispensing (0.05g per chip); torque-controlled M3 nylon clamping standoffs (0.35 N·m)',
 'Implemented: Calibrated thermal syringe dispensing and uniform screw torque', 8, 2, 2),

('OP-30', 'PCB Solder Pad Assembly', 'Hand solder 10-pad terminals on XH-M562 boards & dev headers',
 'Solder bridge between adjacent pads (Pads 4/5 or 8/9) or cold joint',
 'Short circuit on 24V rail, speaker BTL short to GND, high contact resistance',
 9, 'Excess solder feed, iron tip too wide, dwelling > 5s on pad, oxidation',
 8, 'Standard rosin-core solder and manual soldering iron', '10x magnifying loupe visual inspection & DMM continuity probe',
 5, 'Use 0.8mm 63/37 leaded solder, temperature-controlled iron at 350°C, strict 3-second dwell rule, backlight inspection jig',
 'Implemented: Backlight bridge check jig + DMM adjacent-pad resistance test', 9, 2, 2),

('OP-40', 'Power Bus Wire Splicing', 'Strip and insert 16/20 AWG wires into WAGO 221-415 blocks',
 'Wire strip length out of spec (< 10mm or > 12mm), loose wire strand',
 'Exposed live conductor shorting, high resistance joint, wire slip-out',
 8, 'Manual stripping without calibrated wire stripper or length guide',
 7, 'Visual check against WAGO housing molded gauge mark', 'Post-insertion pull test (pull-force > 30N) and rear test port probing',
 4, 'Use automatic calibrated wire stripper with built-in 11mm mechanical stop; verify lever snaps 100% flat',
 'Implemented: Calibrated wire stripper with fixed 11mm stop; 100% pull test', 8, 1, 2),

('OP-50', 'Signal Harness Crimping', 'Crimp JST-XH terminals and prepare 2-core shielded audio cable',
 'Loose crimp pin, open circuit, nicked drain wire, broken shield braid',
 'Audio channel dropout, ground loop hum, intermittent crackling',
 7, 'Improper crimp die size, excessive operator hand pressure, wire tension',
 7, 'Manual ratchet crimping tool (SN-01BM)', 'Tug test on crimp pin and DMM pin-to-pin loop resistance check',
 4, 'Use calibrated ratcheting crimper with exact AWG die; slide 2:1 dual-wall heat-shrink over shield ground drain transition',
 'Implemented: Calibrated ratcheting die + heat-shrink strain relief', 7, 2, 2),

('OP-60', 'Rear Panel I/O Dressing', 'Press-fit and bolt 12x JS-910B binding posts in Polycarbonate',
 'Loose binding post rotation, stripped M8 plastic threads, cracked panel',
 'Terminal spins when tightening speaker cable, inter-terminal short',
 8, 'Over-torquing metal nuts on plastic panel without torque limiter',
 6, 'Operator manual wrench tightening', 'Torque wrench inspection and manual rotational torque verification',
 4, 'Use double nylon lock washers; apply torque-limiting nut runner preset to 0.8 N·m; press-fit flat keyed D-hole profile',
 'Implemented: D-shaped anti-rotation cutouts and calibrated 0.8 N·m torque', 8, 1, 2),

('OP-70', 'Buck Converter Calibration', 'Trim XL4015 buck converter multi-turn pot to 5.00V output',
 'Output voltage set incorrectly (> 5.5V or < 4.75V) before connecting loads',
 'Overvoltage destruction of ESP32 and DACs, or brownout boot failure',
 9, 'Operator forgets to trim under 24V input or reads incorrect multimeter scale',
 6, 'Operator manual multimeter adjustment', 'Two-stage power-up protocol: verify 5.00V on bench BEFORE connecting loads',
 4, 'Mandatory two-stage assembly work instruction: lock trimmer with green Loctite 290 threadlocker after measuring 5.00V ± 0.05V',
 'Implemented: Sign-off checklist required before connecting 5V harness to ESP32', 9, 1, 2),

('OP-80', 'Firmware Flashing & Config', 'Flash ESP32-S3 firmware with volume limiter and I2S registers',
 'Incorrect firmware branch flashed or volume ceiling limiter disabled',
 'TPA3116 driven into 10% THD clipping; PSU overload (> 250W); fan starts',
 7, 'Operator flashing wrong build target or corrupted non-volatile settings',
 5, 'Automated esptool.py flash script', 'Serial monitor diagnostic verification of boot log settings',
 3, 'Single master automated flash script with checksum verification; hardcoded 83.6% voltage ceiling compiled into binary firmware',
 'Implemented: Firmware binary verified with SHA256 checksum during bench flash', 7, 1, 2),

('OP-90', 'Pre-Power Bench Checkout', 'Perform electrical continuity and ground isolation test protocol',
 'Power applied while short circuit or BTL-to-chassis fault exists',
 'Smoked components, blown SMPS fuse, permanent damage to prototype',
 10, 'Rushing assembly sequence, skipping pre-power test checklist',
 6, 'Paper checklist filled by operator', 'Mandatory 6-step resistance sign-off before mains power cable attached',
 3, 'Implement physical lock-out tag on mains IEC inlet until all 6 resistance checkpoints (> 10k bus, < 0.1 ground) are verified and signed',
 'Implemented: Quality gate checklist attached to chassis before first power', 10, 1, 2),

('OP-100', 'Acoustic & Burn-In Test', 'Run 6-channel full load sweep at 70% power into 4 ohm dummy loads',
 'High harmonic distortion, channel imbalance, excessive thermal rise',
 7, 'Defective batch capacitor, cold solder joint failing under thermal stress',
 5, 'Acoustic sweep generator and 6x 100W 4 ohm load bank', 'Audio analyzer THD measurement and FLIR thermal camera recording',
 3, 'Automated 30-minute burn-in sequence: log thermal equilibrium (< 52°C) and THD+N (< 0.05%) on all 6 channels simultaneously',
 'Implemented: 30-min burn-in test station with automated pass/fail report', 7, 1, 2);

-- ==============================================================================
-- SAMPLE DATA INSERTION: CONTROL PLAN RECORDS
-- ==============================================================================
INSERT INTO `control_plan_records` (
  `plan_id`, `op_no`, `process_name`, `machine_device_jig`, `characteristic_type`,
  `characteristic_description`, `special_char_class`, `specification_tolerance`,
  `measurement_technique`, `sample_size_frequency`, `control_method`, `reaction_plan`
) VALUES
('CP-10', 'OP-10', 'Chassis Machining & Cutouts', 'CO2 Laser Cutter / CNC Mill with single-flute acrylic cutter',
 'Product', 'Polycarbonate panel perimeter, cutouts & AL6061 fin hole spacing',
 'SC (Significant)', '±0.15 mm on mounting holes, ±0.20 mm on chimney aperture',
 'Digital Vernier Caliper & Go/No-Go Acrylic Gauge Jig', '100% of panels (1st piece + every panel)',
 'CNC program lock, calibrated fixture stop blocks',
 'Quarantine panel; reject piece if tolerance exceeded; readjust laser offset and re-cut'),

('CP-20', 'OP-20', 'Thermal Interface Dispensing', 'Micro-syringe precision dispenser & Torq-Master 0.35 N·m driver',
 'Process', 'Arctic MX-4 thermal compound volume & standoff clamp torque',
 'SC (Significant)', '0.05 g ± 0.01 g per chip; 0.35 N·m ± 0.03 N·m screw torque',
 'High-precision micro-scale & calibrated torque driver', '100% of amplifier board mounts (3 boards/unit)',
 'Visual verification of full-die squeeze-out; torque click sign-off',
 'Wipe clean with 99% Isopropanol (IPA), re-dispense paste and re-torque to spec'),

('CP-30', 'OP-30', 'PCB Solder Pad Assembly', 'TS100 / Hakko FX-888D soldering station (350°C, 2.4D chisel)',
 'Product', 'XH-M562 10-pad solder fillets, pad wetness, zero solder bridging',
 'CC (Critical)', '100% shiny concave meniscus, zero bridge, pad dwell < 3.0 s',
 '10x Optical Inspection Loupe & DMM Adjacent Pad Probe', '100% solder pads (10 pads × 3 boards = 30 pads)',
 'Backlight jig bridge inspection; DMM continuity test between adjacent pads',
 'Desolder bridge with fluxed copper wick, clean with IPA, re-inspect under 10x magnification'),

('CP-40', 'OP-40', 'Power Bus Wire Splicing', 'Automatic wire stripper with 11mm mechanical stop',
 'Process', '16 AWG / 20 AWG strip length and WAGO lever full closure',
 'CC (Critical)', 'Strip length 11.0 mm (+1.0/-0.5 mm); pull force > 30 N',
 'Visual strip gauge template & calibrated mechanical pull tester', '100% of conductor terminations (10 wires/unit)',
 'WAGO molded strip guide check; 100% manual tug test',
 'Re-strip wire if copper exposed outside housing; re-terminate if pull test yields movement'),

('CP-50', 'OP-50', 'Signal Harness Crimping', 'IWISS / Engineer PA-09 ratchet crimp tool with dual-wall heatshrink',
 'Process', 'JST-XH terminal crimp height, retention force & shield grounding',
 'SC (Significant)', 'Retention force > 15 N; 100% heatshrink insulation over drain wire',
 'Calibrated tensile pull gauge & DMM loop resistance (< 0.05 Ω)', '100% of signal harnesses (3 I2S + 1 AUX)',
 'Ratchet cycle-lock tool prevents partial crimps; heat-gun thermal indicator',
 'Cut off defective crimp pin, re-strip conductor, crimp fresh JST terminal, re-heatshrink'),

('CP-60', 'OP-60', 'Rear Panel I/O Dressing', 'Keyed D-hole punch jig & 0.8 N·m preset torque socket',
 'Product', 'JS-910B binding post alignment, anti-rotation & Polycarbonate stress',
 'CC (Critical)', 'Rotational slip torque > 1.2 N·m; panel tightening torque 0.8 N·m ± 0.05 N·m',
 'Calibrated digital torque wrench & angle vernier', '100% of binding posts (12 terminals/unit)',
 'Double nylon washer lock; D-shaped anti-rotation cutout profile',
 'Disassemble post; replace sheared nylon washer or cracked polycarbonate panel; re-torque'),

('CP-70', 'OP-70', 'Buck Converter Calibration', 'Regulated bench DC power supply (24.0V) & 4.5-digit true-RMS DMM',
 'Product', 'XL4015 DC-DC Buck converter output voltage under no load and 1A load',
 'CC (Critical)', '5.00 V DC ± 0.05 V (range: 4.95 V to 5.05 V DC max)',
 'Fluke 87V 4.5-digit DMM connected to buck output test pads', '100% of buck modules prior to brain wiring',
 'Two-stage power checkout; Loctite 290 threadlocker on potentiometer',
 'Quarantine buck module; do not connect to ESP32/DAC rail; readjust trimmer or discard defective module'),

('CP-80', 'OP-80', 'Firmware Flashing & Config', 'Automated esptool.py flash fixture with checksum validator',
 'Process', 'ESP32-S3 firmware build SHA256, 83.6% voltage ceiling & I2S clocks',
 'SC (Significant)', 'SHA256 match; volume ceiling hardcoded <= 83.6% (210W peak unclipped)',
 'Serial monitor automated boot script & SHA256 log audit', '100% of ESP32-S3 boards during assembly',
 'Automated flash runner with automatic pass/fail bit in NVS',
 'Reflash firmware binary; if hash mismatch persists, erase flash completely and re-upload golden image'),

('CP-90', 'OP-90', 'Pre-Power Bench Checkout', 'Fluke 87V Multimeter (Resistance & Insulation modes)',
 'Product', 'Cold DC resistance on 24V rail, 5V rail & BTL-to-chassis isolation',
 'YS (Safety)', '24V bus > 10 kΩ; 5V bus > 2 kΩ; BTL speaker (-) to chassis = OPEN (∞ Ω)',
 'DMM 2-wire resistance & 500V DC insulation tester on speaker posts', '100% of completed amplifier assemblies before AC plug-in',
 'Physical lock-out tag on IEC mains socket; mandatory 6-point checklist card',
 'Do NOT energize unit; locate short with thermal cam on 1V current-limited bench supply; rectify wiring error'),

('CP-100', 'OP-100', 'Acoustic & Burn-In Test', '6-channel 4Ω 100W non-inductive load bank, FLIR E4, Audio Analyzer',
 'Product', 'THD+N (< 0.05% @ 1kHz 10W), SNR (> 102 dB), max heatsink temp (< 52°C)',
 'SC (Significant)', 'THD+N < 0.05%; heatsink rise < 25°C above ambient; idle current < 120 mA',
 'Audio Precision / QuantAsylum QA403 analyzer & FLIR thermal camera', '100% of production amplifiers for 30 minutes continuous',
 'Automated test script records JSON/TSV log; thermal camera continuous alarm',
 'Halt test immediately if temp > 55°C or THD > 0.1%; trace to defective chip or cold solder joint; rework board');

-- ==============================================================================
-- ANALYTICAL VIEWS
-- ==============================================================================

-- View 1: DFMEA High Risk Modes (Initial RPN >= 200 OR Severity >= 9)
CREATE OR REPLACE VIEW `view_dfmea_high_risk` AS
SELECT
  `id`,
  `subsystem`,
  `potential_failure_mode`,
  `severity`,
  `occurrence`,
  `detection`,
  `initial_rpn`,
  `recommended_action`,
  `rev_sev`,
  `rev_occ`,
  `rev_det`,
  `final_rpn`,
  ROUND(((`initial_rpn` - `final_rpn`) / `initial_rpn`) * 100, 1) AS `risk_reduction_pct`
FROM `dfmea_records`
WHERE `initial_rpn` >= 200 OR `severity` >= 9
ORDER BY `initial_rpn` DESC;

-- View 2: PFMEA Risk Reduction Summary
CREATE OR REPLACE VIEW `view_pfmea_rpn_reduction` AS
SELECT
  `op_no`,
  `process_step`,
  `potential_failure_mode`,
  `severity`,
  `initial_rpn`,
  `recommended_action`,
  `final_rpn`,
  ROUND(((`initial_rpn` - `final_rpn`) / `initial_rpn`) * 100, 1) AS `risk_reduction_pct`
FROM `pfmea_records`
ORDER BY `initial_rpn` DESC;

-- View 3: Integrated Quality Control Map (Linking PFMEA to Control Plan)
CREATE OR REPLACE VIEW `view_integrated_quality_control_map` AS
SELECT
  p.`op_no`,
  p.`process_step`,
  p.`potential_failure_mode`,
  p.`severity` AS `failure_severity`,
  p.`final_rpn`,
  c.`plan_id`,
  c.`special_char_class`,
  c.`characteristic_description`,
  c.`specification_tolerance`,
  c.`measurement_technique`,
  c.`control_method`,
  c.`reaction_plan`
FROM `pfmea_records` p
JOIN `control_plan_records` c ON p.`op_no` = c.`op_no`
ORDER BY p.`final_rpn` DESC;
