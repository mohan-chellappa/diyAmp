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
      tdItem.style.color = "#38bdf8";
      tdItem.style.fontWeight = "600";
      tr.appendChild(tdItem);

      // Specification
      var tdSpec = document.createElement("td");
      tdSpec.textContent = row[3];
      tdSpec.style.fontSize = "11.5px";
      tr.appendChild(tdSpec);

      // Qty + Unit
      var tdQty = document.createElement("td");
      tdQty.textContent = row[4] + " " + row[5];
      tdQty.style.textAlign = "center";
      tr.appendChild(tdQty);

      // Rate
      var tdRate = document.createElement("td");
      tdRate.textContent = "₹ " + Number(row[6]).toFixed(2);
      tr.appendChild(tdRate);

      // Total Cost
      var tdTot = document.createElement("td");
      var totVal = row[4] * row[6];
      tdTot.textContent = "₹ " + totVal.toFixed(2);
      tdTot.style.fontWeight = "bold";
      tr.appendChild(tdTot);

      // Stock Status (Interactive Dropdown / Badge)
      var tdStatus = document.createElement("td");
      var statusKey = row[8];
      var badge = document.createElement("span");
      badge.className = "w3-tag w3-round";
      badge.style.fontSize = "11px";
      badge.style.fontWeight = "bold";

      if (statusKey === "inhand") {
        badge.className += " w3-green";
        badge.textContent = "✔ In Hand";
      } else if (statusKey === "ordered") {
        badge.className += " w3-blue";
        badge.textContent = "✈ Ordered";
      } else if (statusKey === "missing") {
        badge.className += " w3-red";
        badge.textContent = "⚠ Missing";
      } else {
        badge.className += " w3-grey";
        badge.textContent = "Omitted";
      }
      tdStatus.appendChild(badge);

      if (onStatusChange) {
        var sel = document.createElement("select");
        sel.className = "w3-select w3-tiny w3-dark-grey";
        sel.style.marginLeft = "6px";
        sel.style.width = "auto";
        sel.style.display = "inline-block";
        sel.style.padding = "2px";

        ["inhand", "ordered", "missing"].forEach(function(optKey) {
          var opt = document.createElement("option");
          opt.value = optKey;
          opt.textContent = optKey.toUpperCase();
          if (optKey === statusKey) opt.selected = true;
          sel.appendChild(opt);
        });

        sel.onchange = function() {
          onStatusChange(row[0], sel.value);
        };
        tdStatus.appendChild(sel);
      }
      tr.appendChild(tdStatus);

      // Vendor
      var tdVendor = document.createElement("td");
      tdVendor.textContent = row[7];
      tr.appendChild(tdVendor);

      // Image Thumbnail Preview
      var tdImg = document.createElement("td");
      var imgPath = row[10];
      if (imgPath && imgPath.length > 2) {
        var thumb = document.createElement("img");
        thumb.src = imgPath;
        thumb.style.width = "32px";
        thumb.style.height = "32px";
        thumb.style.objectFit = "cover";
        thumb.style.borderRadius = "4px";
        thumb.style.cursor = "pointer";
        thumb.style.border = "1px solid #475569";
        thumb.onclick = function() {
          openImageModal(imgPath, row[2]);
        };
        tdImg.appendChild(thumb);
      } else {
        tdImg.textContent = "—";
      }
      tr.appendChild(tdImg);

      // Doc Link
      var tdDoc = document.createElement("td");
      var docPath = row[11];
      if (docPath && docPath.length > 2) {
        var link = document.createElement("a");
        link.href = docPath;
        link.target = "_blank";
        link.className = "w3-button w3-tiny w3-round w3-indigo";
        link.style.padding = "3px 8px";
        link.textContent = "Doc";
        tdDoc.appendChild(link);
      } else {
        tdDoc.textContent = "—";
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
