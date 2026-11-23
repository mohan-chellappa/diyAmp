-- ==============================================================================
-- DIY 5.1 Analog Amplifier (Copper Chimney V2)
-- Shop Floor Assembly Traveler & Production Tracking Database Schema
-- Standard: AIAG-VDA / IATF 16949 / IPC-A-610 Class 2
-- Target Engine: MySQL 8.0+ / 8.2+
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS `diy_amp_assembly`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `diy_amp_assembly`;

-- ------------------------------------------------------------------------------
-- 1. Table: production_units (Master Build Unit Ledger)
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS `assembly_execution_log`;
DROP TABLE IF EXISTS `quality_gate_signoffs`;
DROP TABLE IF EXISTS `assembly_step_definitions`;
DROP TABLE IF EXISTS `production_units`;

CREATE TABLE `production_units` (
  `unit_serial` VARCHAR(32) NOT NULL,
  `model_name` VARCHAR(64) NOT NULL DEFAULT 'Copper Chimney V2',
  `hardware_rev` VARCHAR(16) NOT NULL DEFAULT 'V2.2',
  `start_date` DATE NOT NULL,
  `completion_date` DATE DEFAULT NULL,
  `lead_technician` VARCHAR(64) NOT NULL,
  `current_status` ENUM('In Assembly', 'Awaiting OP-90 Gate', 'In Burn-In', 'Passed QA', 'Quarantined', 'Rework Required') NOT NULL DEFAULT 'In Assembly',
  `burn_in_hours` DECIMAL(4, 2) DEFAULT 0.00,
  `notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`unit_serial`),
  INDEX `idx_unit_status` (`current_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 2. Table: assembly_step_definitions (Master 20-Step Catalog)
-- ------------------------------------------------------------------------------
CREATE TABLE `assembly_step_definitions` (
  `step_no` TINYINT UNSIGNED NOT NULL,
  `phase` VARCHAR(64) NOT NULL,
  `operation_name` VARCHAR(128) NOT NULL,
  `task_description` TEXT NOT NULL,
  `tools_required` VARCHAR(255) NOT NULL,
  `parts_materials_used` VARCHAR(255) NOT NULL,
  `torque_spec` VARCHAR(64) DEFAULT NULL,
  `wire_gauge` VARCHAR(64) DEFAULT NULL,
  `inspection_checkpoint` VARCHAR(255) NOT NULL,
  `pfmea_ref` VARCHAR(16) NOT NULL,
  `cp_ref` VARCHAR(16) NOT NULL,
  PRIMARY KEY (`step_no`),
  INDEX `idx_step_phase` (`phase`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 3. Table: assembly_execution_log (Station Execution & Sign-Offs)
-- ------------------------------------------------------------------------------
CREATE TABLE `assembly_execution_log` (
  `log_id` BIGINT UNSIGNED AUTO_INCREMENT NOT NULL,
  `unit_serial` VARCHAR(32) NOT NULL,
  `step_no` TINYINT UNSIGNED NOT NULL,
  `technician_name` VARCHAR(64) NOT NULL,
  `measured_value` VARCHAR(128) DEFAULT NULL,
  `status` ENUM('Pending', 'In Progress', 'Completed', 'Rejected') NOT NULL DEFAULT 'Pending',
  `signed_off_at` TIMESTAMP NULL DEFAULT NULL,
  `notes` VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`log_id`),
  UNIQUE KEY `uk_unit_step` (`unit_serial`, `step_no`),
  CONSTRAINT `fk_log_unit_serial` FOREIGN KEY (`unit_serial`) REFERENCES `production_units` (`unit_serial`) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT `fk_log_step_no` FOREIGN KEY (`step_no`) REFERENCES `assembly_step_definitions` (`step_no`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 4. Table: quality_gate_signoffs (Mandatory OP-90 Pre-Power 6-Point Gate)
-- ------------------------------------------------------------------------------
CREATE TABLE `quality_gate_signoffs` (
  `gate_id` INT UNSIGNED AUTO_INCREMENT NOT NULL,
  `unit_serial` VARCHAR(32) NOT NULL,
  `check_no` TINYINT UNSIGNED NOT NULL CHECK (`check_no` BETWEEN 1 AND 6),
  `characteristic` VARCHAR(128) NOT NULL,
  `specification` VARCHAR(128) NOT NULL,
  `measured_value` VARCHAR(64) NOT NULL,
  `result` ENUM('PASS', 'FAIL') NOT NULL,
  `technician_name` VARCHAR(64) NOT NULL,
  `verified_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`gate_id`),
  UNIQUE KEY `uk_unit_check` (`unit_serial`, `check_no`),
  CONSTRAINT `fk_gate_unit_serial` FOREIGN KEY (`unit_serial`) REFERENCES `production_units` (`unit_serial`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- MASTER STEP CATALOG DATA INSERTION (20 STEPS)
-- ==============================================================================
INSERT INTO `assembly_step_definitions` (
  `step_no`, `phase`, `operation_name`, `task_description`, `tools_required`,
  `parts_materials_used`, `torque_spec`, `wire_gauge`, `inspection_checkpoint`,
  `pfmea_ref`, `cp_ref`
) VALUES
(1, 'Phase 1: Mechanical Prep', 'Chassis Panel Cutout Inspection',
 'Deburr edges and verify 4x Polycarbonate panels and 2x AL6061 finned side plates against drawings',
 'Vernier Caliper, Go/No-Go Gauge', '4mm Polycarbonate (Top, Bottom, Front, Back), AL6061 plates',
 NULL, NULL, 'Hole centers ±0.15mm, Chimney aperture ±0.20mm, edge finish', 'OP-10', 'CP-10'),

(2, 'Phase 1: Mechanical Prep', 'Base Plate & Foot Assembly',
 'Fit 4x 20mm rubber vibration-isolation feet to base plate with M3 stainless hardware',
 'M3 Hex Driver, Tweezers', '4x Rubber Feet, 4x M3x8mm SS Screws, M3 Washers',
 '0.60 N·m', NULL, 'Rubber feet seated flat, no rocking on granite surface plate', 'OP-10', 'CP-10'),

(3, 'Phase 1: Mechanical Prep', 'Copper Chimney & Pillar Erection',
 'Mount 35mm central copper chimney and 4x 15mm corner copper support tubes into base plate recess',
 'M4 Hex Driver, Level Gauge', '35mm OD Copper Pipe, 4x 15mm OD Copper Pipes, M4 Standoffs',
 '1.20 N·m', NULL, 'Pillars vertical (90° ± 0.5°), chimney base seating seated flush', 'OP-10', 'CP-10'),

(4, 'Phase 2: Board Prep', 'ESP32-S3 Firmware Flashing',
 'Flash ESP32-S3 firmware binary with volume limiter and I2S registers; verify SHA256 hash',
 'PC, USB-C Data Cable, esptool.py', 'Waveshare ESP32-S3 Touch LCD Dev Board',
 NULL, NULL, 'Boot log shows 83.6% voltage ceiling active, SHA256 verified', 'OP-80', 'CP-80'),

(5, 'Phase 2: Board Prep', 'XL4015 Buck Converter Calibration',
 'Power XL4015 on bench with 24.0V DC; trim potentiometer to exactly 5.00V; apply threadlocker',
 'Bench DC PSU (24V), Fluke 87V DMM, Trimmer Tool', 'XL4015 DC-DC Buck Converter, Loctite 290',
 NULL, NULL, 'Output voltage = 5.00V ± 0.05V (4.95V to 5.05V max); pot locked', 'OP-70', 'CP-70'),

(6, 'Phase 2: Board Prep', 'XH-M562 Solder Pad Tinning',
 'Pre-tin 10 solder pads on each of 3x XH-M562 boards; solder gold-plated header pins',
 'Hakko FX-888D (350°C), 0.8mm 63/37 Solder, Flux', '3x XH-M562 TPA3116D2 Mini Boards, 2.54mm Header Pins',
 NULL, NULL, 'Bright concave solder fillets, dwell < 3.0s, zero solder bridges', 'OP-30', 'CP-30'),

(7, 'Phase 2: Board Prep', 'PCM5102A & PCM1808 Jumper Prep',
 'Solder SCK jumper to GND on 3x PCM5102A DACs; bridge format pins for I2S 24-bit slave',
 'Soldering Iron (350°C), Fine Tweezers, Solder Wick', '3x PCM5102A DAC Boards, 1x PCM1808 ADC Board',
 NULL, NULL, 'SCK-to-GND solder bridge verified with DMM (< 0.1 ohm)', 'OP-30', 'CP-30'),

(8, 'Phase 3: Thermal Assembly', 'Thermal Paste Dispensing',
 'Clean TPA3116 chip tops with 99% IPA; dispense Arctic MX-4 in micro X-pattern',
 'Lint-free wipes, 99% IPA, Micro-syringe dispenser', 'Arctic MX-4 Thermal Paste (0.05g per chip)',
 NULL, NULL, 'Paste mass 0.05g ± 0.01g; no air bubbles or dry spots', 'OP-20', 'CP-20'),

(9, 'Phase 3: Thermal Assembly', 'Amplifier Heatsink Clamping',
 'Clamp 3x XH-M562 boards to AL6061 finned side plates using nylon standoffs and M3 screws',
 'Calibrated Torque Driver, 2.5mm Hex Bit', '6x M3 Nylon Standoffs, 6x M3x12mm Screws, Arctic MX-4',
 '0.35 N·m', NULL, 'Uniform paste squeeze-out around silicon perimeter, torque 0.35 N·m', 'OP-20', 'CP-20'),

(10, 'Phase 4: Harness Fabrication', 'Signal Cable JST-XH Crimping',
 'Strip 2-core shielded cable, crimp JST-XH terminals, slide 2:1 dual-wall heat-shrink on drain',
 'Engineer PA-09 Crimper, Wire Stripper, Heat Gun', '2-Core Shielded Cable, JST-XH Pins & Housings, Heat-shrink',
 NULL, '24 AWG Shielded', 'Pull test > 15N, heat-shrink covers shield transition completely', 'OP-50', 'CP-50'),

(11, 'Phase 4: Harness Fabrication', 'Power Wire Stripping & Prep',
 'Strip 16 AWG red/black main feeds and 20 AWG branch lines to exactly 11.0mm',
 'Calibrated Automatic Wire Stripper (11mm stop)', '16 AWG & 20 AWG High-Strand Silicone Wire',
 NULL, '16 / 20 AWG', 'Exposed copper = 11.0mm (+1.0/-0.5mm), zero nicked strands', 'OP-40', 'CP-40'),

(12, 'Phase 5: Power Subsystem', 'WAGO 221-415 Bus Assembly',
 'Insert stripped wires into WAGO 221-415 blocks; solder 4700µF capacitor directly across rails',
 'Wire Stripper, Soldering Iron, Heat-shrink', '2x WAGO 221-415 Blocks, 4700µF 50V Low-ESR Capacitor',
 NULL, '16 / 20 AWG', 'Levers snapped 100% flat; 30N tug test passed on every port', 'OP-40', 'CP-40'),

(13, 'Phase 5: Power Subsystem', 'XL4015 5V Logic Bus Integration',
 'Connect XL4015 input to WAGO 221-415 bus; route 5.00V / GND harness to brain distribution',
 'Wire Stripper, Soldering Iron', '20 AWG Red/Black Wires, JST-XH 2-pin connector',
 NULL, '20 AWG', 'Polarity double-checked with DMM; 5.00V verified at JST connector', 'OP-70', 'CP-70'),

(14, 'Phase 6: Rear Panel I/O', 'Binding Post Installation',
 'Press-fit and bolt 12x JS-910B binding posts into 4mm Polycarbonate rear panel',
 '0.8 N·m Preset Torque Socket, Vernier Depth Gauge', '12x JS-910B Gold Binding Posts, Nylon Step Washers',
 '0.80 N·m', NULL, 'Rotational slip torque > 1.2 N·m; zero panel crazing or cracks', 'OP-60', 'CP-60'),

(15, 'Phase 6: Rear Panel I/O', 'Power & AUX Connector Mounting',
 'Mount GX16 4-pin aviation chassis socket (Pins 1+2 = +24V, Pins 3+4 = GND) and PJ392A 3.5mm stereo AUX jack on rear panel',
 'Spanner Wrench, Threadlocker', 'GX16 4-Pin Socket, PJ392A 3.5mm Jack, 10A Fuse Holder',
 '1.00 N·m', '16 AWG', 'Connectors tight, Pins 1+2 & 3+4 parallel bridged, inline 10A fuse holder locked', 'OP-60', 'CP-60'),

(16, 'Phase 7: Interconnection', 'Amplifier Wiring Harness Dressing',
 'Connect 20 AWG power lines to Pad 8/9, signal lines to Pad 1/2/3, and twisted speaker wires',
 'Soldering Iron (350°C), Hot Melt Glue, Cable Ties', 'Silicone Wire, Zip Ties, Neutral RTV Silicone',
 NULL, '16 / 20 AWG', 'Strain-relief silicone bead placed at board edge; clean routing', 'OP-30', 'CP-30'),

(17, 'Phase 7: Interconnection', 'Front Panel & Brain Mounting',
 'Mount ESP32-S3 and 3x PCM5102A DAC stack to front Polycarbonate panel; plug I2S harnesses',
 'M2.5 Hex Driver, JST Cable Assemblies', 'Waveshare ESP32-S3, 3x PCM5102A, M2.5 Standoffs',
 '0.40 N·m', '24 AWG', 'Short I2S ribbon runs (< 60mm); display seated flush in bezel', 'OP-50', 'CP-50'),

(18, 'Phase 8: Safety & Verification', 'Pre-Power 6-Point Gate (OP-90)',
 'Attach lock-out tag to IEC inlet; perform mandatory 6-point cold DC resistance checkout',
 'Fluke 87V DMM, Insulation Tester (500V DC)', 'Sign-Off Inspection Card, Physical Lock-Out Tag',
 NULL, NULL, 'PE bond < 0.1Ω; 24V bus > 10kΩ; BTL (-) to chassis = OPEN (∞ Ω)', 'OP-90', 'CP-90'),

(19, 'Phase 9: Commissioning', 'Acoustic Sweep & 30-Min Burn-In',
 'Remove lock-out tag; connect 24V supply; run 6-channel full load sweep into 4Ω dummy load bank',
 'QuantAsylum QA403 Analyzer, FLIR E4, 6x 4Ω 100W Loads', 'Mean Well LRS-350-24 SMPS, Test Harness',
 NULL, NULL, 'THD+N < 0.05%; heatsink rise < 25°C above ambient; silent idle', 'OP-100', 'CP-100'),

(20, 'Phase 10: Final Closure', 'Top Plate Sealing & Quality Seal',
 'Fit high-temp silicone isolation ring over chimney flue; fasten top Polycarbonate plate; apply QA tag',
 'M3 Hex Driver, Tamper-Evident QA Hologram', 'M3x12mm SS Screws, High-Temp Silicone Grommet',
 '0.50 N·m', NULL, 'Silicone gasket fully seated; top plate screws torqued; QA tag affixed', 'OP-10', 'CP-10');

-- ==============================================================================
-- SAMPLE DATA INSERTION: PROTOTYPE UNIT CCV2-2026-PUN-001
-- ==============================================================================
INSERT INTO `production_units` (
  `unit_serial`, `model_name`, `hardware_rev`, `start_date`, `completion_date`,
  `lead_technician`, `current_status`, `burn_in_hours`, `notes`
) VALUES (
  'CCV2-2026-PUN-001', 'Copper Chimney V2', 'V2.2', '2026-10-12', '2026-10-12',
  'Lead Tech - Pimpri Works', 'Passed QA', 0.50, 'Golden master unit. Passed all 6 pre-power checks and 30-min burn-in.'
);

-- Pre-populate all 20 steps as COMPLETED for golden master unit
INSERT INTO `assembly_execution_log` (
  `unit_serial`, `step_no`, `technician_name`, `measured_value`, `status`, `signed_off_at`, `notes`
) VALUES
('CCV2-2026-PUN-001', 1, 'Lead Tech', 'Within ±0.10mm', 'Completed', NOW(), 'Laser cut edges deburred'),
('CCV2-2026-PUN-001', 2, 'Lead Tech', '0.60 N·m', 'Completed', NOW(), 'Zero rocking on surface plate'),
('CCV2-2026-PUN-001', 3, 'Lead Tech', '90.1° vertical', 'Completed', NOW(), 'Loctite 243 applied on M4 studs'),
('CCV2-2026-PUN-001', 4, 'Lead Tech', 'SHA256 Match OK', 'Completed', NOW(), 'Limiter set to 83.6% unclipped'),
('CCV2-2026-PUN-001', 5, 'Lead Tech', '5.002 V DC', 'Completed', NOW(), 'Loctite 290 applied on pot'),
('CCV2-2026-PUN-001', 6, 'Lead Tech', 'Fillets Concave', 'Completed', NOW(), 'Dwell < 2.5s per pad'),
('CCV2-2026-PUN-001', 7, 'Lead Tech', '0.04 Ohm', 'Completed', NOW(), 'SCK grounded on all 3 DACs'),
('CCV2-2026-PUN-001', 8, 'Lead Tech', '0.052 g per die', 'Completed', NOW(), 'Arctic MX-4 X-pattern applied'),
('CCV2-2026-PUN-001', 9, 'Lead Tech', '0.35 N·m', 'Completed', NOW(), 'Uniform squeeze-out verified'),
('CCV2-2026-PUN-001', 10, 'Lead Tech', 'Pull > 22 N', 'Completed', NOW(), 'Heat-shrink covers drain transition'),
('CCV2-2026-PUN-001', 11, 'Lead Tech', '11.0 mm exact', 'Completed', NOW(), 'Zero severed strands'),
('CCV2-2026-PUN-001', 12, 'Lead Tech', 'Pull > 35 N', 'Completed', NOW(), '4700uF cap polarity confirmed'),
('CCV2-2026-PUN-001', 13, 'Lead Tech', '5.001 V DC', 'Completed', NOW(), 'Polarity double checked'),
('CCV2-2026-PUN-001', 14, 'Lead Tech', '0.80 N·m', 'Completed', NOW(), 'Rotational slip > 1.4 N·m'),
('CCV2-2026-PUN-001', 15, 'Lead Tech', '1.00 N·m', 'Completed', NOW(), '10A inline fuse confirmed'),
('CCV2-2026-PUN-001', 16, 'Lead Tech', 'RTV Applied', 'Completed', NOW(), 'Silicone strain relief cured'),
('CCV2-2026-PUN-001', 17, 'Lead Tech', 'Length 45mm', 'Completed', NOW(), 'Display seated flush'),
('CCV2-2026-PUN-001', 18, 'Lead Tech', '100% Passed', 'Completed', NOW(), '6-point checklist verified'),
('CCV2-2026-PUN-001', 19, 'Lead Tech', 'THD=0.038%, T=48.2C', 'Completed', NOW(), '30-minute full power soak passed'),
('CCV2-2026-PUN-001', 20, 'Lead Tech', 'Hologram #001', 'Completed', NOW(), 'Silicone grommet seated; sealed');

-- Populate OP-90 Gate Sign-offs
INSERT INTO `quality_gate_signoffs` (
  `unit_serial`, `check_no`, `characteristic`, `specification`, `measured_value`, `result`, `technician_name`
) VALUES
('CCV2-2026-PUN-001', 1, 'Protective Earth (PE) Ground Bond', '< 0.10 Ohm', '0.04 Ohm', 'PASS', 'Lead Tech'),
('CCV2-2026-PUN-001', 2, '24V DC Bulk Power Rail Resistance', '> 10.0 kOhm', '14.2 kOhm', 'PASS', 'Lead Tech'),
('CCV2-2026-PUN-001', 3, '5.00V DC Logic Bus Resistance', '> 2.0 kOhm', '3.8 kOhm', 'PASS', 'Lead Tech'),
('CCV2-2026-PUN-001', 4, 'BTL Speaker (-) to Chassis Isolation', 'OPEN (INF)', 'OPEN (OL)', 'PASS', 'Lead Tech'),
('CCV2-2026-PUN-001', 5, 'Adjacent Channel Cross Isolation', '> 100 kOhm', '> 20 MOhm', 'PASS', 'Lead Tech'),
('CCV2-2026-PUN-001', 6, '3.5mm AUX AGND Shield Isolation', '> 1.0 MOhm', '> 50 MOhm', 'PASS', 'Lead Tech');

-- ==============================================================================
-- ANALYTICAL VIEWS
-- ==============================================================================

-- View 1: Unit Assembly Progress & Completion Rate
CREATE OR REPLACE VIEW `view_unit_assembly_progress` AS
SELECT
  u.`unit_serial`,
  u.`model_name`,
  u.`hardware_rev`,
  u.`current_status`,
  COUNT(l.`step_no`) AS `total_steps_logged`,
  SUM(CASE WHEN l.`status` = 'Completed' THEN 1 ELSE 0 END) AS `steps_completed`,
  ROUND((SUM(CASE WHEN l.`status` = 'Completed' THEN 1 ELSE 0 END) / 20) * 100, 1) AS `completion_pct`,
  u.`lead_technician`
FROM `production_units` u
LEFT JOIN `assembly_execution_log` l ON u.`unit_serial` = l.`unit_serial`
GROUP BY u.`unit_serial`, u.`model_name`, u.`hardware_rev`, u.`current_status`, u.`lead_technician`;

-- View 2: Complete Unit Assembly Traveler Sheet
CREATE OR REPLACE VIEW `view_unit_assembly_traveler` AS
SELECT
  l.`unit_serial`,
  s.`step_no`,
  s.`phase`,
  s.`operation_name`,
  s.`inspection_checkpoint`,
  s.`torque_spec`,
  l.`measured_value`,
  l.`status`,
  l.`technician_name`,
  l.`signed_off_at`
FROM `assembly_step_definitions` s
LEFT JOIN `assembly_execution_log` l ON s.`step_no` = l.`step_no`
ORDER BY l.`unit_serial`, s.`step_no`;
