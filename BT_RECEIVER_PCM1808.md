# BT Receiver + PCM1808 — Datasheet & 6-Channel Crossover Integration

> **Related Spec:** [PCM1808 24bit SNR Audio Stereo ADC](file:///d:/Documents/DIY%20Amp/PCM1808%2024bit%20SNR%20Audio%20Stereo%20ADC%20Single-Ended%20Analog-Input%20Decoder.md) | [ESP32-S3-Pico (SKU: 1552780)](file:///d:/Documents/DIY%20Amp/esp32.md)

![VHM-314 Blackboard Bluetooth 5.0 Decoder](file:///d:/Documents/DIY%20Amp/image/PROJECT/vhm314_bluetooth_5_decoder.jpg)

* **VHM-314 Jacks & Pads:** `3.5mm` Stereo Line-Out Jack + `L / G / R` solder pads | Micro-USB `5V` Power In + `BAT (-/+)` `3.7V–5V` pads.

---

## 10-Point Reference Summary
1. **Purpose:** Add Bluetooth music input to a DIY amp. Use `PCM1808` only to digitize *true* analog sources, not to re-digitize Bluetooth audio when avoidable.
2. **BT Options:** **`MH-M18`** = Bluetooth 4.2, `5V`, `L/R` analog pads, `MUTE` pin. **`XY-WRBT`** = Bluetooth 5.0, `3.7V–24V` DC, `3.5mm` stereo output, `≥ 90 dB` SNR — better for amp use.
3. **PCM1808:** 24-bit stereo ADC, single-ended analog in, up to `96 kHz`, outputs digital audio via `I2S / Left-Justified`.
4. **Standard 2-Channel Path:** `Phone → BT Module → Amp Input` directly. Keep `PCM1808` on a separate AUX path.
5. **Why Avoid Analog Re-Digitization:** BT module already outputs analog. `PCM1808` converts analog back to digital, forcing another DAC conversion (extra noise/latency).
6. **If Chaining Analog BT into `PCM1808` (for Active 6-Ch Crossovers):** `XY-WRBT L → PCM1808 VINL`, `R → VINR`, `GND → GND`. Power BT module from clean `5V`, `PCM1808` from `3.3V/5V`. Do not share noisy `24V` amp supply.
7. **ESP32-S3 Note:** `ESP32-S3` (`SKU: 1552780` & `Model 28141`) has **Bluetooth 5 LE only**, no Classic Bluetooth (`BR/EDR`), so it cannot do `A2DP` music itself. An external BT module handles music reception.
8. **Grounding:** Common-ground both modules. Ground-loop hum is the most common issue—add a ground-loop isolator or isolated `5V–5V` DC-DC (`B0505S`) on BT power/output if hum appears.
9. **Level Matching:** BT output is line-level (`~1 Vrms`). Keep `PCM1808` input below clipping (`~80%` BT volume if distortion occurs).
10. **Project Verdict (6-Channel Active Crossover Amp):**
    * Unlike a 2-channel stereo amp, our **3× `XH-M562` amps** require the `ESP32-S3-Pico` active crossover (`<100 Hz` Sub, `>100 Hz` Front, `>10 kHz` Piezo) + per-speaker wattage caps.
    * **Best All-Digital Option:** Use an **I2S Bluetooth Classic receiver** (or classic `ESP32-WROOM-32` `A2DP` bridge) feeding digital `I2S` straight into `ESP32-S3-Pico` `GPIO 4` (`DIN`) — **zero ADC re-digitization!**
    * **Simplest Option (`₹150`):** Use **`XY-WRBT`** (`80%` volume) into `PCM1808` `VINL/VINR` (shares ADC with `3.5mm` AUX via a toggle/header) on clean isolated `5V`.
