/**
 * xtbl.js — High-Performance Vanilla JS Data Table & HMI Component
 * Styled with W3.CSS & Pure DOM APIs (Zero HTML Strings)
 * 
 * Complies with user architecture rules:
 * - 2D Array in, DOM table out
 * - No HTML string concatenation
 * - Responsive layout, sorting & filtering
 * - Direct image thumbnail zoom & technical document viewer
 */

var xTbl = (function() {

  function renderTable(containerId, data2D, options) {
    var container = document.getElementById(containerId);
    if (!container) return;
    while (container.firstChild) container.removeChild(container.firstChild);

    options = options || {};
    var headers = options.headers || ["ID", "Category", "Item", "Specification", "Qty", "Unit", "Rate (₹)", "Vendor", "Status", "Remarks", "Image", "Doc"];
    var onStatusChange = options.onStatusChange || null;
    var onImageChange = options.onImageChange || null;
    var onDocChange = options.onDocChange || null;

    var table = document.createElement("table");
    table.className = "w3-table w3-bordered w3-hoverable w3-small";
    table.style.color = "#cbd5e1";

    // Header
    var thead = document.createElement("thead");
    var hRow = document.createElement("tr");
    headers.forEach(function(hText) {
      var th = document.createElement("th");
      th.textContent = hText;
      th.style.background = "#131d2e";
      th.style.color = "#f1f5f9";
      th.style.padding = "8px 10px";
      hRow.appendChild(th);
    });
    thead.appendChild(hRow);
    table.appendChild(thead);

    // Body
    var tbody = document.createElement("tbody");

    data2D.forEach(function(row) {
      var tr = document.createElement("tr");
      tr.setAttribute("data-id", row[0]);

      // Category
      var tdCat = document.createElement("td");
      tdCat.textContent = row[1];
      tdCat.style.fontWeight = "bold";
      tr.appendChild(tdCat);

      // Item Name
      var tdItem = document.createElement("td");
      tdItem.textContent = row[2];
      tdItem.style.color = "#e2e8f0";
      tdItem.style.fontWeight = "600";
      tr.appendChild(tdItem);

      // Specification
      var tdSpec = document.createElement("td");
      tdSpec.textContent = row[3];
      tdSpec.style.fontSize = "11.5px";
      tdSpec.style.color = "#94a3b8";
      tr.appendChild(tdSpec);

      // Qty + Unit
      var tdQty = document.createElement("td");
      tdQty.textContent = row[4] + " " + row[5];
      tdQty.style.textAlign = "center";
      tdQty.style.color = "#cbd5e1";
      tr.appendChild(tdQty);

      // Rate
      var tdRate = document.createElement("td");
      tdRate.textContent = "₹ " + Number(row[6]).toFixed(2);
      tdRate.style.color = "#94a3b8";
      tr.appendChild(tdRate);

      // Total Cost
      var tdTot = document.createElement("td");
      var totVal = row[4] * row[6];
      tdTot.textContent = "₹ " + totVal.toFixed(2);
      tdTot.style.fontWeight = "600";
      tdTot.style.color = "#e2e8f0";
      tr.appendChild(tdTot);

      // Stock Status (Interactive Matte Pill Selector)
      var tdStatus = document.createElement("td");
      var statusKey = row[8];

      if (onStatusChange) {
        var sel = document.createElement("select");
        sel.className = "w3-select status-select-pill";
        sel.setAttribute("aria-label", "Change status for " + row[2]);
        sel.style.fontSize = "11.5px";
        sel.style.fontWeight = "600";
        sel.style.borderRadius = "4px";
        sel.style.padding = "4px 8px";
        sel.style.cursor = "pointer";
        sel.style.width = "auto";
        sel.style.minWidth = "110px";
        sel.style.display = "inline-block";
        sel.style.outline = "none";
        sel.style.transition = "all 0.2s ease";

        function updatePillStyle(el, key) {
          if (key === "inhand") {
            el.style.background = "#0c2518";
            el.style.color = "#4ade80";
            el.style.border = "1px solid rgba(34, 197, 94, 0.45)";
          } else if (key === "ordered") {
            el.style.background = "#082338";
            el.style.color = "#38bdf8";
            el.style.border = "1px solid rgba(56, 189, 248, 0.45)";
          } else if (key === "missing") {
            el.style.background = "#2b0f13";
            el.style.color = "#f87171";
            el.style.border = "1px solid rgba(239, 68, 68, 0.45)";
          } else {
            el.style.background = "#172033";
            el.style.color = "#94a3b8";
            el.style.border = "1px solid rgba(148, 163, 184, 0.3)";
          }
        }

        updatePillStyle(sel, statusKey);

        var statusOptions = [
          { key: "inhand", label: "✔ In Hand" },
          { key: "ordered", label: "✈ Ordered" },
          { key: "missing", label: "⚠ Pending" },
          { key: "omitted", label: "— Omitted" }
        ];

        statusOptions.forEach(function(opt) {
          var o = document.createElement("option");
          o.value = opt.key;
          o.textContent = opt.label;
          o.style.background = "#0f172a";
          o.style.color = "#e2e8f0";
          if (opt.key === statusKey) o.selected = true;
          sel.appendChild(o);
        });

        sel.onchange = function() {
          var chosen = this.value;
          updatePillStyle(this, chosen);
          onStatusChange(row[0], chosen);
        };

        tdStatus.appendChild(sel);
      } else {
        var badge = document.createElement("span");
        badge.style.display = "inline-block";
        badge.style.padding = "2px 8px";
        badge.style.borderRadius = "4px";
        badge.style.fontSize = "11px";
        badge.style.fontWeight = "600";
        badge.style.letterSpacing = "0.2px";

        if (statusKey === "inhand") {
          badge.style.background = "rgba(34, 197, 94, 0.12)";
          badge.style.color = "#4ade80";
          badge.style.border = "1px solid rgba(34, 197, 94, 0.35)";
          badge.textContent = "✔ In Hand";
        } else if (statusKey === "ordered") {
          badge.style.background = "rgba(56, 189, 248, 0.12)";
          badge.style.color = "#38bdf8";
          badge.style.border = "1px solid rgba(56, 189, 248, 0.35)";
          badge.textContent = "✈ Ordered";
        } else if (statusKey === "missing") {
          badge.style.background = "rgba(239, 68, 68, 0.12)";
          badge.style.color = "#f87171";
          badge.style.border = "1px solid rgba(239, 68, 68, 0.35)";
          badge.textContent = "⚠ Pending";
        } else {
          badge.style.background = "rgba(148, 163, 184, 0.1)";
          badge.style.color = "#94a3b8";
          badge.style.border = "1px solid rgba(148, 163, 184, 0.25)";
          badge.textContent = "Omitted";
        }
        tdStatus.appendChild(badge);
      }
      tr.appendChild(tdStatus);

      // Vendor
      var tdVendor = document.createElement("td");
      tdVendor.textContent = row[7];
      tr.appendChild(tdVendor);

      // Image Thumbnail Preview & Edit
      var tdImg = document.createElement("td");
      tdImg.style.whiteSpace = "nowrap";
      var imgPath = row[10];

      if (imgPath && imgPath.length > 2) {
        var thumbWrap = document.createElement("div");
        thumbWrap.style.display = "inline-flex";
        thumbWrap.style.alignItems = "center";
        thumbWrap.style.gap = "5px";

        var thumb = document.createElement("img");
        thumb.src = imgPath;
        thumb.style.width = "32px";
        thumb.style.height = "32px";
        thumb.style.objectFit = "cover";
        thumb.style.borderRadius = "4px";
        thumb.style.cursor = "pointer";
        thumb.style.border = "1px solid #475569";
        thumb.title = "Click to zoom";
        thumb.onerror = function() {
          this.style.display = "none";
        };
        thumb.onclick = function() {
          openImageModal(imgPath, row[2]);
        };
        thumbWrap.appendChild(thumb);

        if (onImageChange) {
          var editBtn = document.createElement("button");
          editBtn.className = "w3-button w3-tiny";
          editBtn.style.padding = "2px 5px";
          editBtn.style.fontSize = "10px";
          editBtn.style.background = "#1e293b";
          editBtn.style.color = "#94a3b8";
          editBtn.style.border = "1px solid #334155";
          editBtn.style.borderRadius = "3px";
          editBtn.style.cursor = "pointer";
          editBtn.textContent = "✏️";
          editBtn.title = "Change picture for " + row[2];
          editBtn.onclick = function(e) {
            e.stopPropagation();
            onImageChange(row[0], row[2], imgPath);
          };
          thumbWrap.appendChild(editBtn);
        }

        tdImg.appendChild(thumbWrap);
      } else {
        if (onImageChange) {
          var addBtn = document.createElement("button");
          addBtn.className = "w3-button w3-tiny";
          addBtn.style.padding = "3px 8px";
          addBtn.style.fontSize = "11px";
          addBtn.style.background = "#0f1f33";
          addBtn.style.color = "#38bdf8";
          addBtn.style.border = "1px dashed #0284c7";
          addBtn.style.borderRadius = "4px";
          addBtn.style.cursor = "pointer";
          addBtn.textContent = "+ 📷";
          addBtn.title = "Add picture for " + row[2];
          addBtn.onclick = function(e) {
            e.stopPropagation();
            onImageChange(row[0], row[2], "");
          };
          tdImg.appendChild(addBtn);
        } else {
          tdImg.textContent = "—";
        }
      }
      tr.appendChild(tdImg);

      // Doc Link & Edit (Subtle Slate Button + Edit/Add)
      var tdDoc = document.createElement("td");
      tdDoc.style.whiteSpace = "nowrap";
      var docPath = row[11];
      if (docPath && docPath.length > 2) {
        var docWrap = document.createElement("div");
        docWrap.style.display = "inline-flex";
        docWrap.style.alignItems = "center";
        docWrap.style.gap = "5px";

        var link = document.createElement("a");
        link.href = docPath;
        link.target = "_blank";
        link.style.display = "inline-block";
        link.style.padding = "3px 8px";
        link.style.borderRadius = "4px";
        link.style.fontSize = "11px";
        link.style.fontWeight = "600";
        link.style.textDecoration = "none";
        link.style.background = "#1e293b";
        link.style.color = "#94a3b8";
        link.style.border = "1px solid #334155";
        link.onmouseover = function() { this.style.color = "#f8fafc"; this.style.borderColor = "#64748b"; };
        link.onmouseout = function() { this.style.color = "#94a3b8"; this.style.borderColor = "#334155"; };
        link.textContent = "📄 Doc";
        docWrap.appendChild(link);

        if (onDocChange) {
          var editDocBtn = document.createElement("button");
          editDocBtn.className = "w3-button w3-tiny";
          editDocBtn.style.padding = "2px 5px";
          editDocBtn.style.fontSize = "10px";
          editDocBtn.style.background = "#1e293b";
          editDocBtn.style.color = "#94a3b8";
          editDocBtn.style.border = "1px solid #334155";
          editDocBtn.style.borderRadius = "3px";
          editDocBtn.style.cursor = "pointer";
          editDocBtn.textContent = "✏️";
          editDocBtn.title = "Change spec doc for " + row[2];
          editDocBtn.onclick = function(e) {
            e.stopPropagation();
            onDocChange(row[0], row[2], docPath);
          };
          docWrap.appendChild(editDocBtn);
        }

        tdDoc.appendChild(docWrap);
      } else {
        if (onDocChange) {
          var addDocBtn = document.createElement("button");
          addDocBtn.className = "w3-button w3-tiny";
          addDocBtn.style.padding = "3px 8px";
          addDocBtn.style.fontSize = "11px";
          addDocBtn.style.background = "#0f1f33";
          addDocBtn.style.color = "#38bdf8";
          addDocBtn.style.border = "1px dashed #0284c7";
          addDocBtn.style.borderRadius = "4px";
          addDocBtn.style.cursor = "pointer";
          addDocBtn.textContent = "+ 📄";
          addDocBtn.title = "Add spec doc / datasheet for " + row[2];
          addDocBtn.onclick = function(e) {
            e.stopPropagation();
            onDocChange(row[0], row[2], "");
          };
          tdDoc.appendChild(addDocBtn);
        } else {
          tdDoc.textContent = "—";
        }
      }
      tr.appendChild(tdDoc);

      tbody.appendChild(tr);
    });

    table.appendChild(tbody);
    container.appendChild(table);
  }

  // Pure DOM Modal for Image Zoom
  function openImageModal(imgSrc, title) {
    var modalId = "xtbl-img-modal";
    var modal = document.getElementById(modalId);
    if (!modal) {
      modal = document.createElement("div");
      modal.id = modalId;
      modal.className = "w3-modal";
      modal.style.display = "none";
      modal.onclick = function() { modal.style.display = "none"; };

      var content = document.createElement("div");
      content.className = "w3-modal-content w3-animate-zoom w3-card-4";
      content.style.maxWidth = "600px";
      content.style.background = "#0f172a";
      content.style.padding = "16px";
      content.style.borderRadius = "8px";
      content.style.border = "1px solid #38bdf8";

      var mHeader = document.createElement("div");
      mHeader.id = "xtbl-modal-title";
      mHeader.style.fontWeight = "bold";
      mHeader.style.color = "#38bdf8";
      mHeader.style.marginBottom = "10px";
      content.appendChild(mHeader);

      var mImg = document.createElement("img");
      mImg.id = "xtbl-modal-img";
      mImg.style.width = "100%";
      mImg.style.borderRadius = "6px";
      content.appendChild(mImg);

      modal.appendChild(content);
      document.body.appendChild(modal);
    }

    document.getElementById("xtbl-modal-title").textContent = title || "Component View";
    document.getElementById("xtbl-modal-img").src = imgSrc;
    modal.style.display = "block";
  }

  // Calculates Live Statistics from 2D Array
  function calculateStats(data2D) {
    var stats = {
      totalItems: data2D.length,
      inHandCount: 0,
      orderedCount: 0,
      missingCount: 0,
      inHandValue: 0,
      orderedValue: 0,
      missingValue: 0,
      totalValue: 0
    };

    data2D.forEach(function(row) {
      var qty = row[4];
      var rate = row[6];
      var val = qty * rate;
      var status = row[8];

      stats.totalValue += val;
      if (status === "inhand") {
        stats.inHandCount++;
        stats.inHandValue += val;
      } else if (status === "ordered") {
        stats.orderedCount++;
        stats.orderedValue += val;
      } else if (status === "missing") {
        stats.missingCount++;
        stats.missingValue += val;
      }
    });

    return stats;
  }

  // Category color mapping
  var CATEGORY_COLORS = {
    "DAC + Brain": "#38bdf8",
    "Mechanical & Hardware": "#f59e0b",
    "Power": "#10b981",
    "Amplifiers": "#c084fc",
    "Wiring / Protection": "#fb923c",
    "Passive Crossover": "#818cf8",
    "Optional / Audio Control": "#64748b"
  };

  var FALLBACK_COLORS = ["#38bdf8", "#f59e0b", "#10b981", "#c084fc", "#fb923c", "#818cf8", "#ec4899", "#14b8a6"];

  function getCategoryColor(name, index) {
    if (CATEGORY_COLORS[name]) return CATEGORY_COLORS[name];
    return FALLBACK_COLORS[index % FALLBACK_COLORS.length];
  }

  // Calculates Category-Wise Statistics from 2D Array
  function calculateCategoryStats(data2D) {
    var catMap = {};
    var catOrder = [];
    var totalCostAll = 0;
    var totalCountAll = 0;

    data2D.forEach(function(row) {
      var cat = row[1] || "Uncategorized";
      var qty = Number(row[4]) || 1;
      var rate = Number(row[6]) || 0;
      var val = qty * rate;
      var status = row[8]; // "inhand", "ordered", "missing", "omitted"

      if (!catMap[cat]) {
        catMap[cat] = {
          name: cat,
          totalCost: 0,
          itemCount: 0,
          inHandCount: 0,
          orderedCount: 0,
          missingCount: 0,
          omittedCount: 0,
          inHandCost: 0,
          orderedCost: 0,
          missingCost: 0
        };
        catOrder.push(cat);
      }

      var c = catMap[cat];
      c.itemCount++;
      c.totalCost += val;
      totalCostAll += val;
      totalCountAll++;

      if (status === "inhand") {
        c.inHandCount++;
        c.inHandCost += val;
      } else if (status === "ordered") {
        c.orderedCount++;
        c.orderedCost += val;
      } else if (status === "missing") {
        c.missingCount++;
        c.missingCost += val;
      } else {
        c.omittedCount++;
      }
    });

    var list = catOrder.map(function(k) { return catMap[k]; });
    list.sort(function(a, b) { return b.totalCost - a.totalCost; });

    return {
      categories: list,
      totalCost: totalCostAll,
      totalCount: totalCountAll
    };
  }

  // Renders Pure DOM & SVG Category Breakdown Chart Widget
  function renderCategoryChart(containerId, data2D, options) {
    var mount = document.getElementById(containerId);
    if (!mount) return;
    while (mount.firstChild) mount.removeChild(mount.firstChild);

    options = options || {};
    var activeCategory = options.activeCategory || "all";
    var chartMode = options.chartMode || "cost"; // "cost" or "count"
    var onCategoryClick = options.onCategoryClick || null;
    var onModeChange = options.onModeChange || null;

    var stats = calculateCategoryStats(data2D);
    var categories = stats.categories;
    var totalCost = stats.totalCost;
    var totalCount = stats.totalCount;

    // Outer Card Header with Title and Mode Switcher
    var headerRow = document.createElement("div");
    headerRow.style.display = "flex";
    headerRow.style.justifyContent = "space-between";
    headerRow.style.alignItems = "center";
    headerRow.style.flexWrap = "wrap";
    headerRow.style.gap = "10px";
    headerRow.style.marginBottom = "14px";
    headerRow.style.borderBottom = "1px solid #1e293b";
    headerRow.style.paddingBottom = "10px";

    var titleBox = document.createElement("div");
    var titleH = document.createElement("h3");
    titleH.style.margin = "0";
    titleH.style.fontSize = "15px";
    titleH.style.fontWeight = "700";
    titleH.style.color = "#38bdf8";
    titleH.textContent = "📊 Category-Wise Investment & Readiness";
    var titleSub = document.createElement("div");
    titleSub.style.fontSize = "11.5px";
    titleSub.style.color = "#94a3b8";
    titleSub.textContent = "Interactive overview — click any category to filter table below";
    titleBox.appendChild(titleH);
    titleBox.appendChild(titleSub);
    headerRow.appendChild(titleBox);

    // Switcher buttons (Cost vs Count)
    var btnGroup = document.createElement("div");
    btnGroup.style.display = "flex";
    btnGroup.style.alignItems = "center";
    btnGroup.style.gap = "6px";

    var btnCost = document.createElement("button");
    btnCost.className = "filter-btn" + (chartMode === "cost" ? " active" : "");
    btnCost.textContent = "💰 Valuation (₹)";
    btnCost.style.padding = "4px 10px";
    btnCost.style.fontSize = "11px";
    btnCost.onclick = function() {
      if (onModeChange) onModeChange("cost");
    };

    var btnCount = document.createElement("button");
    btnCount.className = "filter-btn" + (chartMode === "count" ? " active" : "");
    btnCount.textContent = "📦 Item Count";
    btnCount.style.padding = "4px 10px";
    btnCount.style.fontSize = "11px";
    btnCount.onclick = function() {
      if (onModeChange) onModeChange("count");
    };

    btnGroup.appendChild(btnCost);
    btnGroup.appendChild(btnCount);

    if (activeCategory !== "all") {
      var btnReset = document.createElement("button");
      btnReset.className = "filter-btn";
      btnReset.style.padding = "4px 10px";
      btnReset.style.fontSize = "11px";
      btnReset.style.background = "#0369a1";
      btnReset.style.color = "#f8fafc";
      btnReset.textContent = "Filter: " + activeCategory + " ✕";
      btnReset.title = "Click to show all categories";
      btnReset.onclick = function() {
        if (onCategoryClick) onCategoryClick("all");
      };
      btnGroup.appendChild(btnReset);
    }

    headerRow.appendChild(btnGroup);
    mount.appendChild(headerRow);

    // Main Chart Layout: 2-Column Responsive Layout
    var chartLayout = document.createElement("div");
    chartLayout.className = "w3-row-padding";
    chartLayout.style.marginLeft = "-8px";
    chartLayout.style.marginRight = "-8px";

    // Column 1: SVG Donut Chart
    var colLeft = document.createElement("div");
    colLeft.className = "w3-col l4 m5 s12";
    colLeft.style.textAlign = "center";
    colLeft.style.marginBottom = "14px";

    var svgNS = "http://www.w3.org/2000/svg";
    var svg = document.createElementNS(svgNS, "svg");
    svg.setAttribute("viewBox", "0 0 240 240");
    svg.style.width = "100%";
    svg.style.maxWidth = "220px";
    svg.style.height = "auto";
    svg.style.display = "inline-block";
    svg.style.filter = "drop-shadow(0 4px 12px rgba(0,0,0,0.5))";

    var radius = 78;
    var cx = 120;
    var cy = 120;
    var circ = 2 * Math.PI * radius; // ~490.09
    var currentOffset = 0;

    // Background track circle
    var bgCircle = document.createElementNS(svgNS, "circle");
    bgCircle.setAttribute("cx", cx);
    bgCircle.setAttribute("cy", cy);
    bgCircle.setAttribute("r", radius);
    bgCircle.setAttribute("fill", "none");
    bgCircle.setAttribute("stroke", "#0f172a");
    bgCircle.setAttribute("stroke-width", "32");
    svg.appendChild(bgCircle);

    // Build slices
    categories.forEach(function(cat, idx) {
      var color = getCategoryColor(cat.name, idx);
      var sliceVal = (chartMode === "cost") ? cat.totalCost : cat.itemCount;
      var totalVal = (chartMode === "cost") ? totalCost : totalCount;
      var ratio = totalVal > 0 ? (sliceVal / totalVal) : 0;
      var strokeLen = ratio * circ;
      var strokeGap = circ - strokeLen;

      if (strokeLen > 0.5) {
        var circle = document.createElementNS(svgNS, "circle");
        circle.setAttribute("cx", cx);
        circle.setAttribute("cy", cy);
        circle.setAttribute("r", radius);
        circle.setAttribute("fill", "none");
        circle.setAttribute("stroke", color);
        circle.setAttribute("stroke-width", activeCategory === cat.name ? "38" : "30");
        circle.setAttribute("stroke-dasharray", strokeLen + " " + strokeGap);
        circle.setAttribute("stroke-dashoffset", -currentOffset);
        circle.setAttribute("transform", "rotate(-90 " + cx + " " + cy + ")");
        circle.style.cursor = "pointer";
        circle.style.transition = "stroke-width 0.2s, opacity 0.2s";
        circle.style.opacity = (activeCategory === "all" || activeCategory === cat.name) ? "1" : "0.35";

        var titleEl = document.createElementNS(svgNS, "title");
        titleEl.textContent = cat.name + ": " + (chartMode === "cost" ? "₹ " + cat.totalCost.toFixed(2) : cat.itemCount + " items") + " (" + (ratio * 100).toFixed(1) + "%)";
        circle.appendChild(titleEl);

        circle.onclick = function() {
          if (onCategoryClick) onCategoryClick(cat.name);
        };

        svg.appendChild(circle);
        currentOffset += strokeLen;
      }
    });

    // Donut Center Text
    var textGroup = document.createElementNS(svgNS, "g");
    textGroup.setAttribute("text-anchor", "middle");

    var valText = document.createElementNS(svgNS, "text");
    valText.setAttribute("x", cx);
    valText.setAttribute("y", cy - 4);
    valText.setAttribute("fill", "#38bdf8");
    valText.setAttribute("font-size", chartMode === "cost" ? "17" : "24");
    valText.setAttribute("font-weight", "bold");
    valText.textContent = chartMode === "cost" ? ("₹ " + Math.round(totalCost).toLocaleString("en-IN")) : (totalCount + " Items");

    var lblText = document.createElementNS(svgNS, "text");
    lblText.setAttribute("x", cx);
    lblText.setAttribute("y", cy + 16);
    lblText.setAttribute("fill", "#94a3b8");
    lblText.setAttribute("font-size", "10.5");
    lblText.setAttribute("font-weight", "600");
    lblText.textContent = chartMode === "cost" ? "Total Valuation" : "Active BOM";

    textGroup.appendChild(valText);
    textGroup.appendChild(lblText);
    svg.appendChild(textGroup);

    colLeft.appendChild(svg);
    chartLayout.appendChild(colLeft);

    // Column 2: Detailed Category Rows with Stacked Readiness Bars
    var colRight = document.createElement("div");
    colRight.className = "w3-col l8 m7 s12";

    var listWrap = document.createElement("div");
    listWrap.style.display = "flex";
    listWrap.style.flexDirection = "column";
    listWrap.style.gap = "8px";

    categories.forEach(function(cat, idx) {
      var color = getCategoryColor(cat.name, idx);
      var isSelected = activeCategory === cat.name;
      var sliceVal = (chartMode === "cost") ? cat.totalCost : cat.itemCount;
      var totalVal = (chartMode === "cost") ? totalCost : totalCount;
      var ratio = totalVal > 0 ? (sliceVal / totalVal) : 0;
      var pct = (ratio * 100).toFixed(1);

      var rowBox = document.createElement("div");
      rowBox.style.background = isSelected ? "#0c1a2e" : "#090e17";
      rowBox.style.border = isSelected ? "1.5px solid #38bdf8" : "1px solid #1e293b";
      rowBox.style.borderRadius = "6px";
      rowBox.style.padding = "8px 12px";
      rowBox.style.cursor = "pointer";
      rowBox.style.transition = "all 0.15s ease-in-out";
      rowBox.onmouseover = function() {
        if (!isSelected) this.style.borderColor = "#334155";
      };
      rowBox.onmouseout = function() {
        if (!isSelected) this.style.borderColor = "#1e293b";
      };
      rowBox.onclick = function() {
        if (onCategoryClick) onCategoryClick(cat.name);
      };

      // Header of row: Name + Cost / Count
      var rHead = document.createElement("div");
      rHead.style.display = "flex";
      rHead.style.justifyContent = "space-between";
      rHead.style.alignItems = "center";
      rHead.style.marginBottom = "4px";

      var rNameBox = document.createElement("div");
      rNameBox.style.display = "flex";
      rNameBox.style.alignItems = "center";
      rNameBox.style.gap = "8px";

      var dot = document.createElement("span");
      dot.style.display = "inline-block";
      dot.style.width = "10px";
      dot.style.height = "10px";
      dot.style.borderRadius = "50%";
      dot.style.backgroundColor = color;
      rNameBox.appendChild(dot);

      var nameText = document.createElement("span");
      nameText.style.fontWeight = "600";
      nameText.style.fontSize = "12.5px";
      nameText.style.color = isSelected ? "#38bdf8" : "#f1f5f9";
      nameText.textContent = cat.name;
      rNameBox.appendChild(nameText);

      var rValBox = document.createElement("div");
      rValBox.style.fontSize = "12px";
      rValBox.style.fontWeight = "bold";
      rValBox.style.color = "#cbd5e1";

      var costSpan = document.createElement("span");
      costSpan.style.color = "#f8fafc";
      costSpan.textContent = "₹ " + cat.totalCost.toLocaleString("en-IN", { minimumFractionDigits: 2, maximumFractionDigits: 2 });

      var pctSpan = document.createElement("span");
      pctSpan.style.fontSize = "11px";
      pctSpan.style.color = "#94a3b8";
      pctSpan.style.marginLeft = "8px";
      pctSpan.textContent = "(" + pct + "%)";

      rValBox.appendChild(costSpan);
      rValBox.appendChild(pctSpan);

      rHead.appendChild(rNameBox);
      rHead.appendChild(rValBox);
      rowBox.appendChild(rHead);

      // Stacked Mini Bar for Category Readiness (In Hand / Ordered / Missing)
      var barWrap = document.createElement("div");
      barWrap.style.height = "6px";
      barWrap.style.background = "#1e293b";
      barWrap.style.borderRadius = "3px";
      barWrap.style.overflow = "hidden";
      barWrap.style.display = "flex";
      barWrap.style.margin = "4px 0";

      var activeCatItems = cat.inHandCount + cat.orderedCount + cat.missingCount;
      if (activeCatItems > 0) {
        var pInHand = (cat.inHandCount / activeCatItems) * 100;
        var pOrdered = (cat.orderedCount / activeCatItems) * 100;
        var pMissing = (cat.missingCount / activeCatItems) * 100;

        if (pInHand > 0) {
          var segInHand = document.createElement("div");
          segInHand.style.width = pInHand + "%";
          segInHand.style.background = "#10b981";
          segInHand.title = cat.inHandCount + " In Hand";
          barWrap.appendChild(segInHand);
        }
        if (pOrdered > 0) {
          var segOrdered = document.createElement("div");
          segOrdered.style.width = pOrdered + "%";
          segOrdered.style.background = "#0284c7";
          segOrdered.title = cat.orderedCount + " In Transit";
          barWrap.appendChild(segOrdered);
        }
        if (pMissing > 0) {
          var segMissing = document.createElement("div");
          segMissing.style.width = pMissing + "%";
          segMissing.style.background = "#ef4444";
          segMissing.title = cat.missingCount + " Pending Procurement";
          barWrap.appendChild(segMissing);
        }
      } else {
        var segOmitted = document.createElement("div");
        segOmitted.style.width = "100%";
        segOmitted.style.background = "#475569";
        barWrap.appendChild(segOmitted);
      }
      rowBox.appendChild(barWrap);

      // Sub-footer pill tags: In-Hand, In-Transit, Pending counts
      var pillRow = document.createElement("div");
      pillRow.style.display = "flex";
      pillRow.style.justifyContent = "space-between";
      pillRow.style.fontSize = "10.5px";
      pillRow.style.color = "#64748b";

      var countLbl = document.createElement("span");
      countLbl.textContent = cat.itemCount + (cat.itemCount === 1 ? " item" : " items");

      var badgesBox = document.createElement("div");
      badgesBox.style.display = "flex";
      badgesBox.style.gap = "6px";

      if (cat.inHandCount > 0) {
        var bInHand = document.createElement("span");
        bInHand.style.color = "#4ade80";
        bInHand.textContent = "✔ " + cat.inHandCount + " in hand";
        badgesBox.appendChild(bInHand);
      }
      if (cat.orderedCount > 0) {
        var bOrdered = document.createElement("span");
        bOrdered.style.color = "#38bdf8";
        bOrdered.textContent = "✈ " + cat.orderedCount + " transit";
        badgesBox.appendChild(bOrdered);
      }
      if (cat.missingCount > 0) {
        var bMissing = document.createElement("span");
        bMissing.style.color = "#f87171";
        bMissing.textContent = "⚠ " + cat.missingCount + " to buy";
        badgesBox.appendChild(bMissing);
      }
      if (cat.omittedCount > 0) {
        var bOmitted = document.createElement("span");
        bOmitted.style.color = "#94a3b8";
        bOmitted.textContent = "⊘ " + cat.omittedCount + " omitted";
        badgesBox.appendChild(bOmitted);
      }

      pillRow.appendChild(countLbl);
      pillRow.appendChild(badgesBox);
      rowBox.appendChild(pillRow);

      listWrap.appendChild(rowBox);
    });

    colRight.appendChild(listWrap);
    chartLayout.appendChild(colRight);
    mount.appendChild(chartLayout);
  }

  return {
    renderTable: renderTable,
    calculateStats: calculateStats,
    calculateCategoryStats: calculateCategoryStats,
    renderCategoryChart: renderCategoryChart,
    openImageModal: openImageModal
  };
})();
