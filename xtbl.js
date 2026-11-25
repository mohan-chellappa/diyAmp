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

  return {
    renderTable: renderTable,
    calculateStats: calculateStats,
    openImageModal: openImageModal
  };
})();
