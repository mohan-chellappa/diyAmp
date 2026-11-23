/**
 * db.js — Embedded IndexedDB Storage Engine for DIY 5.1 Amp Project
 * 
 * Strict Architecture Rules:
 * - Zero HTML strings
 * - Data returned strictly as 2D Arrays
 * - Native browser embedded database (IndexedDB)
 * - Persists stock status, pricing, component specs, and file paths
 */

var AppDB = (function() {
  var DB_NAME = "DIYAmp_EmbeddedDB";
  var DB_VERSION = 1;
  var STORE_NAME = "components";

  // Initial Seed Data (2D Array matching BOM.tsv SSOT)
  var INITIAL_SEED_2D = [
    // [ID, Category, Item, Spec, Qty, Unit, Rate, Vendor, StockStatus, Remarks, ImagePath, DocPath]
    [1, "Power", "Mean Well LRS-350-24", "24V 14.6A 350.4W SMPS Single Output", 1, "pcs", 2499.00, "Hubtronics.in", "inhand", "External wall-mounted. 100% capacity.", "Meanwell LRS-350-24 SMPS.png", "Meanwell LRS-350-24 SMPS Power Supply.md"],
    [2, "Power", "Wago 221-415", "5-way lever nut — 24V + GND distribution rails", 4, "pcs", 99.00, "robu.in", "inhand", "4 pcs in hand for 24V and GND bus rails.", "WAGO 221-415 5-Conductor Lever Splicing Connector.png", "wago 221 specs.md"],
    [3, "Power", "Wago 221-412", "2-way lever nut — individual amp power feeds", 6, "pcs", 49.00, "robu.in", "inhand", "6 pcs in hand for direct amp feeds.", "image/PROJECT/wago_221_412.png", "wago 221 412 2way spec.md"],
    [4, "Power", "Bulk Capacitor", "4700 uF 50V Low ESR Electrolytic", 2, "pcs", 70.00, "robu.in", "inhand", "On 24V bus for ripple absorption. 108% headroom.", "4700uF 50V Electrolytic Capacitor.png", "4700uF capacitor Spec Sheet.md"],
    [5, "Power", "XL4015 5A Buck Module", "24V -> 5.0V @ 3A Step-Down DC-DC Converter", 1, "pcs", 90.00, "robu.in", "inhand", "Powers ESP32, DACs, and ADC cleanly.", "image/PROJECT/xl4015_buck.jpg", "XL4015 Spec.md"],
    [6, "Power", "AMS1117 Module", "3.3V Linear Power Supply Step-Down Module", 1, "pcs", 19.00, "robu.in", "inhand", "Auxiliary 3.3V rail for PCM1808 VDD.", "image/PROJECT/1791221023178.png", "AMS 117 3.3 V power supply module.md"],
    [7, "Power", "Power Rocker Switch", "SPST/DPST 250V 10A/15A ON-OFF Switch", 1, "pcs", 45.00, "robu.in", "missing", "Master AC/DC disconnect switch.", "image/components/rocker_switch.png", "WIRING_DIAGRAM.md"],
    [8, "Power", "Logic Decoupling Caps", "2x 100µF 25V + 4x 0.1µF Ceramic Caps", 6, "pcs", 25.00, "Local Electronics", "missing", "Buck switching hash suppression on 5V/3.3V.", "image/components/decoupling_caps.png", "CARRIER_MOTHERBOARD_DIAGRAM.html"],
    [9, "Analog In", "CentIoT PJ392A-1 3.5mm Jack", "3-Pin Gold Plated Panel Mount TRS", 5, "pcs", 32.00, "amazon.in", "inhand", "Stereo AUX line-in to PCM1808 ADC.", "image/components/pj392a.png", "WIRING_DIAGRAM.md"],
    [10, "Analog In", "B0505S-1WR3 Isolated 5V", "1W Isolated 5V-to-5V DC-DC Converter", 1, "pcs", 99.00, "robu.in", "ordered", "Isolates Bluetooth 5V power from audio ground loop.", "image/PROJECT/b0505s.jpg", "BT_RECEIVER_PCM1808.md"],
    [11, "Analog In", "VHM-314 Bluetooth 5.0", "Blackboard BT 5.0 Audio Receiver Board", 1, "pcs", 164.00, "robu.in", "ordered", "Receives wireless SBC/AAC audio stream.", "image/PROJECT/vhm314_bluetooth_5_decoder.jpg", "BT_RECEIVER_PCM1808.md"],
    [12, "Analog In", "DPDT Audio Selector Switch", "Mini 6-Pin ON-ON Toggle/Slide Switch", 1, "pcs", 25.00, "robu.in", "missing", "Hardware toggle: 3.5mm AUX vs Bluetooth into ADC.", "image/components/dpdt_switch.png", "CARRIER_MOTHERBOARD_DIAGRAM.html"],
    [13, "Analog In", "PCM1808 Stereo ADC", "24-bit 96kHz Single-Ended Line-In ADC", 1, "pcs", 209.00, "hubtronics.in", "inhand", "Digitizes switched AUX/BT analog to I2S.", "image/PROJECT/1791122464907.png", "PCM1808 24bit SNR Audio Stereo ADC Single-Ended Analog-Input Decoder.md"],
    [14, "DAC + Brain", "Waveshare ESP32-S3 4.3B Touch", "800x480 Capacitive Touch IPS (Model 28141)", 1, "pcs", 5349.00, "robu.in", "inhand", "Dedicated Touch HMI sofa remote (ESP-NOW).", "image/PROJECT/1791222659512.png", "Waveshare ESP32-S3 with Touch spec.md"],
    [15, "DAC + Brain", "Waveshare ESP32-S3-Pico", "Master Audio MCU with Yellow Header (1552780)", 1, "pcs", 1209.00, "robu.in", "ordered", "Master clock generator & Active 5.1 Matrix DSP.", "image/PROJECT/waveshare_esp32_s3_pico_1552780.jpg", "esp32.md"],
    [16, "DAC + Brain", "ESP32-WROOM-32 30-Pin Dev", "NodeMCU Slave MCU (2x15 Header)", 1, "pcs", 434.00, "robu.in", "ordered", "I2S Slave for Surround Haas delay & Cymbal synth.", "image/PROJECT/esp32_wroom32_30pin_slave.jpg", "esp32.md"],
    [17, "DAC + Brain", "PCM5102A DAC Board (3 pcs)", "Stereo I2S Audio Decoder Module (HW-280)", 3, "pcs", 449.00, "hubtronics.in", "inhand", "3 DACs = 6 Discrete line-out channels.", "image/PROJECT/1791016549053.png", "PCM5102 12S Spec.md"],
    [18, "Digital Wiring", "Clock Damping Resistors", "10-Pack 33Ω–47Ω 1/4W Metal Film", 10, "pcs", 1.00, "Local Electronics", "missing", "Star-branch source termination on BCK, LRCK, MCLK.", "image/components/resistors.png", "CARRIER_MOTHERBOARD_DIAGRAM.html"],
    [19, "Digital Wiring", "10x10 cm Perfboard (Zero-PCB)", "Universal FR4 Prototype Board 2.54mm", 1, "pcs", 69.00, "robu.in", "ordered", "Carrier motherboard for MCUs, DACs, and ADC.", "image/components/perfboard.jpg", "CARRIER_MOTHERBOARD_DIAGRAM.html"],
    [20, "Signal Wiring", "Shielded 2-Core Audio Cable", "3 meters low-noise braided audio wire", 3, "m", 40.00, "Local Audio", "missing", "Runs DAC line-outs to Amp inputs without 50Hz hum.", "image/components/shielded_wire.jpg", "WIRING_DIAGRAM.md"],
    [21, "Amplifiers", "XH-M562 TPA3116D2 (3 pcs)", "2x50W @ 24V Class-D Stereo Solder Boards", 3, "pcs", 129.00, "robu.in", "inhand", "3 boards = 6 discrete BTL power channels.", "image/PROJECT/1791126129975.png", "XH-M562 TPA3116D2.md"],
    [22, "Amplifiers", "HY510 Thermal Paste (30g)", "Non-conductive silicone compound (SKU: 07555)", 1, "pcs", 158.00, "hubtronics.in", "ordered", "Couples 3x TPA3116D2 chips to L-bridge heatsinks.", "image/PROJECT/hy510_thermal_paste.jpg", "arctic mx-4 4g thermal paste.md"],
    [23, "Passive Crossover", "JIMSON 10µF 250V Film Cap", "CBB20 MEA Axial Film Audio Cap (x2)", 2, "pcs", 60.00, "In Lab", "inhand", "High-pass vocal filter for Output #5 Center Voice.", "image/components/jimson_film_cap.jpg", "PROJECT.md"],
    [24, "Passive Crossover", "JIMSON 4.7µF 250V Film Cap", "CBB20 MEA Axial Film Audio Cap (x2)", 2, "pcs", 30.00, "In Lab", "inhand", "High-pass protection for Surround Silver Domes.", "image/components/jimson_film_cap.jpg", "PROJECT.md"],
    [25, "Passive Crossover", "JIMSON 2.2µF 250V Film Cap", "CBB20 MEA Axial Film Audio Cap (x2)", 2, "pcs", 30.00, "In Lab", "inhand", "High-pass shimmer filter for Piezo Super-Tweeters.", "image/components/jimson_film_cap.jpg", "PROJECT.md"],
    [26, "Mechanical", "Speaker Terminals (JS-910B)", "4mm Gold Binding Posts (12 In Hand + 4 Ordered)", 16, "pcs", 29.00, "robu.in", "inhand", "Rear panel non-conductive BTL speaker posts.", "image/components/js910b.jpg", "PROJECT.md"],
    [27, "Mechanical", "M3x10mm Standoffs (30 pcs)", "Nylon Hex Spacer w/ Brass Thread", 30, "pcs", 8.20, "robu.in", "ordered", "Elevates all boards 10mm off chassis floor.", "image/components/standoffs.jpg", "AMP_MECHANICAL_BOM.tsv"]
  ];

  function openDatabase() {
    return new Promise(function(resolve, reject) {
      if (!window.indexedDB) {
        reject(new Error("IndexedDB not supported in this environment"));
        return;
      }
      var request = window.indexedDB.open(DB_NAME, DB_VERSION);

      request.onupgradeneeded = function(event) {
        var db = event.target.result;
        if (!db.objectStoreNames.contains(STORE_NAME)) {
          var store = db.createObjectStore(STORE_NAME, { keyPath: "id" });
          store.createIndex("category", "category", { unique: false });
          store.createIndex("stock_status", "stock_status", { unique: false });
          store.createIndex("vendor", "vendor", { unique: false });

          // Seed with initial records
          INITIAL_SEED_2D.forEach(function(row) {
            store.add({
              id: row[0],
              category: row[1],
              item: row[2],
              spec: row[3],
              qty: row[4],
              unit: row[5],
              rate: row[6],
              vendor: row[7],
              stock_status: row[8],
              remarks: row[9],
              image_path: row[10],
              doc_path: row[11]
            });
          });
        }
      };

      request.onsuccess = function(event) {
        resolve(event.target.result);
      };

      request.onerror = function(event) {
        reject(event.target.error);
      };
    });
  }

  // Returns all components strictly as a 2D Array
  function getAllAs2DArray() {
    return openDatabase().then(function(db) {
      return new Promise(function(resolve, reject) {
        var transaction = db.transaction([STORE_NAME], "readonly");
        var store = transaction.objectStore(STORE_NAME);
        var request = store.getAll();

        request.onsuccess = function() {
          var list = request.result;
          var array2D = list.map(function(item) {
            return [
              item.id,
              item.category,
              item.item,
              item.spec,
              item.qty,
              item.unit,
              item.rate,
              item.vendor,
              item.stock_status,
              item.remarks,
              item.image_path,
              item.doc_path
            ];
          });
          resolve(array2D);
        };

        request.onerror = function(event) {
          reject(event.target.error);
        };
      });
    });
  }

  // Update a single component's status (inhand, ordered, missing)
  function updateComponentStatus(id, newStatus) {
    return openDatabase().then(function(db) {
      return new Promise(function(resolve, reject) {
        var transaction = db.transaction([STORE_NAME], "readwrite");
        var store = transaction.objectStore(STORE_NAME);
        var getReq = store.get(id);

        getReq.onsuccess = function() {
          var record = getReq.result;
          if (!record) {
            reject(new Error("Record " + id + " not found"));
            return;
          }
          record.stock_status = newStatus;
          var putReq = store.put(record);
          putReq.onsuccess = function() {
            resolve(true);
          };
          putReq.onerror = function(event) {
            reject(event.target.error);
          };
        };

        getReq.onerror = function(event) {
          reject(event.target.error);
        };
      });
    });
  }

  return {
    getAllAs2DArray: getAllAs2DArray,
    updateComponentStatus: updateComponentStatus,
    getInitialSeed2D: function() { return INITIAL_SEED_2D; }
  };
})();
