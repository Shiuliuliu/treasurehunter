/**
 * Treasure Hunter - Gemstone Crafting Studio (Công cụ Ghép Đá Nâng Cao)
 * Tương thích 100% với định dạng Base64 nhị phân của toantth.github.io/ghep-da
 */

// ==========================================
// 1. Dữ Liệu Đá & Cổ Vật (27 Loại Đá Chuẩn Game)
// ==========================================
const STONES = [
  { id: 64, name: "health", viName: "Sinh Lực (HP)", category: "stat", upgradeCost: { value: 10, currencyId: 1, rate: 1.5 } },
  { id: 65, name: "speed", viName: "Tốc Độ Chạy", category: "stat", upgradeCost: { value: 10, currencyId: 1, rate: 1.5 } },
  { id: 66, name: "damage", viName: "Sát Thương Vật Lý", category: "stat", upgradeCost: { value: 10, currencyId: 1, rate: 1.5 } },
  { id: 67, name: "craftChance", viName: "Tỉ Lệ Chế Tạo", category: "special", upgradeCost: { value: 2, currencyId: 2, rate: 1.5 } },
  { id: 68, name: "criticalRate", viName: "Tỉ Lệ Chí Mạng", category: "stat", upgradeCost: { value: 10, currencyId: 1, rate: 1.5 } },
  { id: 69, name: "defense", viName: "Giáp / Phòng Thủ", category: "stat", upgradeCost: { value: 10, currencyId: 1, rate: 1.5 } },
  { id: 70, name: "inventorySlot", viName: "Ô Túi Trang Bị", category: "special", upgradeCost: { value: 2, currencyId: 2, rate: 1.5 } },
  { id: 71, name: "ingredientSlot", viName: "Ô Túi Nguyên Liệu", category: "special", upgradeCost: { value: 2, currencyId: 2, rate: 1.5 } },
  { id: 225, name: "criticalDamage", viName: "ST Chí Mạng", category: "stat", upgradeCost: { value: 20, currencyId: 1, rate: 1.5 } },
  { id: 226, name: "dodge", viName: "Thân Pháp / Né", category: "stat", upgradeCost: { value: 20, currencyId: 1, rate: 1.5 } },
  { id: 227, name: "accuracy", viName: "Độ Chính Xác", category: "stat", upgradeCost: { value: 20, currencyId: 1, rate: 1.5 } },
  { id: 228, name: "lifesteal", viName: "Hút Máu", category: "special", upgradeCost: { value: 2, currencyId: 2, rate: 1.5 } },
  { id: 229, name: "counterAttack", viName: "Phản Đòn", category: "special", upgradeCost: { value: 2, currencyId: 2, rate: 1.5 } },
  { id: 359, name: "goldDropRate", viName: "Tỉ Lệ Rớt Vàng", category: "stat", upgradeCost: { value: 20, currencyId: 1, rate: 1.5 } },
  { id: 360, name: "diamondDropRate", viName: "Rớt Kim Cương", category: "special", upgradeCost: { value: 3, currencyId: 2, rate: 1.5 } },
  { id: 361, name: "ingredientDropRate", viName: "Rớt Nguyên Liệu", category: "special", upgradeCost: { value: 3, currencyId: 2, rate: 1.5 } },
  { id: 362, name: "aoe", viName: "Sát Thương Lan (AoE)", category: "special", upgradeCost: { value: 3, currencyId: 2, rate: 1.5 } },
  { id: 814, name: "poison", viName: "Sát Thương Độc", category: "special", upgradeCost: { value: 3, currencyId: 2, rate: 1.5 } },
  { id: 899, name: "freeze", viName: "Khống Chế Băng", category: "special", upgradeCost: { value: 3, currencyId: 2, rate: 1.5 } },
  { id: 999, name: "fire", viName: "Thiêu Đốt Lửa", category: "special", upgradeCost: { value: 3, currencyId: 2, rate: 1.5 } },
  { id: 1066, name: "heal", viName: "Hồi Phục Máu", category: "special", upgradeCost: { value: 3, currencyId: 2, rate: 1.5 } },
  { id: 1732, name: "wind", viName: "Cuồng Phong", category: "special", upgradeCost: { value: 3, currencyId: 2, rate: 1.5 } },
  { id: 1012, name: "item_0", viName: "Cổ Vật I", category: "artifact", upgradeCost: { value: 5, currencyId: 1, rate: 1.2 } },
  { id: 1013, name: "item_1", viName: "Cổ Vật II", category: "artifact", upgradeCost: { value: 5, currencyId: 1, rate: 1.2 } },
  { id: 1014, name: "item_2", viName: "Cổ Vật III", category: "artifact", upgradeCost: { value: 5, currencyId: 1, rate: 1.2 } },
  { id: 1015, name: "item_3", viName: "Cổ Vật IV", category: "artifact", upgradeCost: { value: 5, currencyId: 1, rate: 1.2 } },
  { id: 1016, name: "item_4", viName: "Cổ Vật V", category: "artifact", upgradeCost: { value: 5, currencyId: 1, rate: 1.2 } }
];

const STONE_MAP = new Map(STONES.map(s => [s.id, s]));

const RARITIES = [
  { id: 0, name: "Thường", en: "Common", class: "rarity-common", color: "#cbd5e1" },
  { id: 1, name: "Hiếm", en: "Rare", class: "rarity-rare", color: "#38bdf8" },
  { id: 2, name: "Sử Thi", en: "Epic", class: "rarity-epic", color: "#c084fc" },
  { id: 3, name: "Huyền Thoại", en: "Legendary", class: "rarity-legendary", color: "#fbbf24" }
];

// ==========================================
// 2. Bộ Tính Toán Chi Phí Chuẩn Game
// ==========================================
const costCache = new Map();

function getCost(val, rate, rareType, level) {
  let sub = costCache.get(val);
  if (!sub) {
    sub = new Map();
    costCache.set(val, sub);
  }
  let arr = sub.get(rate);
  if (!arr) {
    arr = new Array(10);
    arr[0] = val;
    for (let o = 1; o < 10; o++) arr[o] = arr[o - 1] * rate;
    sub.set(rate, arr);
  }
  let total = 0;
  let sellCost = Math.floor(val / 2);
  for (let o = 0; o < level; o++) {
    let f = arr[o] * (rareType + 1);
    total += f;
    sellCost += f / 2;
  }
  return { total: Math.floor(total), sellCost: Math.ceil(sellCost) };
}

function calcCostStone(stone) {
  let stoneData = STONE_MAP.get(stone.id);
  if (!stoneData) return { gold: 0, diamond: 0 };
  let uc = stoneData.upgradeCost;
  let cost = getCost(uc.value, uc.rate, stone.rareType, stone.level);
  let res = { gold: 0, diamond: 0 };
  if (uc.currencyId === 2) {
    res.diamond = cost.total;
  } else {
    res.gold = cost.total;
  }
  res.gold += cost.sellCost;
  return res;
}

function calcCostGroup(stone, groups) {
  let grp = groups.find(g => g.id === stone.id);
  if (!grp || grp.ids.length === 0) return { gold: 0, diamond: 0 };
  let res = { gold: 0, diamond: 0 };
  for (let sid of grp.ids) {
    let sc = calcCostStone({ ...stone, id: sid });
    if (res.gold < sc.gold) res.gold = sc.gold;
    if (res.diamond < sc.diamond) res.diamond = sc.diamond;
  }
  return res;
}

function calcCostSlot(stone, groups) {
  if (stone.id === -1) return { gold: 0, diamond: 0 };
  return stone.isGroup ? calcCostGroup(stone, groups) : calcCostStone(stone);
}

function calcCostFormula(stones, groups) {
  let res = { gold: 0, diamond: 0 };
  for (let s of stones) {
    if (s.id !== -1) {
      let c = calcCostSlot(s, groups);
      res.gold += c.gold;
      res.diamond += c.diamond;
    }
  }
  return res;
}

// ==========================================
// 3. Bộ Mã Hóa & Giải Mã Nhị Phân Base64
// ==========================================
class BinaryWriter {
  constructor() {
    this.buffer = new Uint8Array(256);
    this.view = new DataView(this.buffer.buffer);
    this.offset = 0;
  }
  ensure(bytes) {
    if (this.offset + bytes > this.buffer.length) {
      let nextLen = Math.max(this.buffer.length * 2, this.offset + bytes + 256);
      let newBuf = new Uint8Array(nextLen);
      newBuf.set(this.buffer);
      this.buffer = newBuf;
      this.view = new DataView(this.buffer.buffer);
    }
  }
  writeUint8(val) {
    this.ensure(1);
    this.view.setUint8(this.offset, val);
    this.offset += 1;
  }
  writeUint16(val) {
    this.ensure(2);
    this.view.setUint16(this.offset, val, false); // Big-Endian
    this.offset += 2;
  }
  getUint8Array() {
    return this.buffer.subarray(0, this.offset);
  }
}

class BinaryReader {
  constructor(arrayBuffer) {
    this.view = new DataView(arrayBuffer);
    this.offset = 0;
    this.size = arrayBuffer.byteLength;
  }
  readUint8() {
    if (this.offset >= this.size) return 0;
    let val = this.view.getUint8(this.offset);
    this.offset += 1;
    return val;
  }
  readUint16() {
    if (this.offset + 1 >= this.size) return 0;
    let val = this.view.getUint16(this.offset, false); // Big-Endian
    this.offset += 2;
    return val;
  }
}

function encodeRecipeData(name, formulas, groups) {
  let writer = new BinaryWriter();
  let nameBytes = new TextEncoder().encode(name || "Công thức");
  let nameLen = Math.min(nameBytes.length, 100);
  writer.writeUint16(nameLen);
  for (let i = 0; i < nameLen; i++) {
    writer.writeUint8(nameBytes[i]);
  }

  // Filter valid formulas (containing at least 1 stone)
  let validFormulas = formulas.filter(f => f.stones.some(s => s.id !== -1));
  if (validFormulas.length === 0 && formulas.length > 0) validFormulas = [formulas[0]];

  // Identify used groups
  let usedGroupIds = new Set();
  validFormulas.forEach(f => {
    f.stones.forEach(s => {
      if (s.id !== -1 && s.isGroup) usedGroupIds.add(s.id);
    });
  });

  // Write groups
  let activeGroups = groups.filter(g => usedGroupIds.has(g.id) && g.ids.length > 0);
  writer.writeUint8(activeGroups.length);
  for (let g of activeGroups) {
    writer.writeUint8(g.id);
    writer.writeUint8(g.ids.length);
    for (let sid of g.ids) {
      writer.writeUint16(sid);
    }
  }

  // Write formulas
  writer.writeUint8(validFormulas.length);
  for (let f of validFormulas) {
    let cost = calcCostFormula(f.stones, groups);
    let validStones = f.stones.filter(s => s.id !== -1);
    writer.writeUint16(cost.gold);
    writer.writeUint16(cost.diamond);
    writer.writeUint8(validStones.length);
    for (let s of validStones) {
      let isGrp = s.isGroup ? 1 : 0;
      let packed = (isGrp << 7) | ((s.level & 31) << 2) | (s.rareType & 3);
      writer.writeUint8(packed);
      writer.writeUint16(s.id);
    }
  }

  let bytes = writer.getUint8Array();
  let binary = '';
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary);
}

function decodeRecipeData(base64Str) {
  let clean = base64Str.trim().replace(/\s+/g, '');
  while (clean.length % 4 !== 0) clean += '=';
  let binary = atob(clean);
  let bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  let reader = new BinaryReader(bytes.buffer);
  let nameLen = reader.readUint16();
  let nameBytes = new Uint8Array(nameLen);
  for (let i = 0; i < nameLen; i++) {
    nameBytes[i] = reader.readUint8();
  }
  let name = new TextDecoder('utf-8').decode(nameBytes);

  let numGroups = reader.readUint8();
  let groups = [];
  for (let i = 0; i < numGroups; i++) {
    let gid = reader.readUint8();
    let count = reader.readUint8();
    let ids = [];
    for (let c = 0; c < count; c++) {
      ids.push(reader.readUint16());
    }
    groups.push({ id: gid, ids: ids });
  }

  let numFormulas = reader.readUint8();
  let formulas = [];
  for (let i = 0; i < numFormulas; i++) {
    let goldNeed = reader.readUint16();
    let diamondNeed = reader.readUint16();
    let stoneLen = reader.readUint8();
    let stones = new Array(8).fill(null).map(() => ({ id: -1, isGroup: false, rareType: 0, level: 0 }));
    for (let j = 0; j < stoneLen; j++) {
      let packed = reader.readUint8();
      let sid = reader.readUint16();
      let rareType = packed & 3;
      let level = (packed >> 2) & 31;
      let isGroup = ((packed >> 7) & 1) !== 0;
      if (j < 8) {
        stones[j] = { id: sid, isGroup: isGroup, rareType: rareType, level: level };
      }
    }
    formulas.push({ goldNeed, diamondNeed, stones });
  }

  if (formulas.length === 0) {
    formulas.push({
      goldNeed: 0,
      diamondNeed: 0,
      stones: new Array(8).fill(null).map(() => ({ id: -1, isGroup: false, rareType: 0, level: 0 }))
    });
  }

  return { name, groups, formulas };
}

// ==========================================
// 4. Trạng Thái Ứng Dụng (App State)
// ==========================================
const AppState = {
  recipes: [
    { name: "Công thức 0", formula: "" }
  ],
  currentRecipeIndex: 0,
  currentFormulaIndex: 0,
  selectedSlotIndex: 0,
  activeRarity: 2, // Mặc định: Sử thi (Tím)
  activeLevel: 0,  // Cấp 1 (index 0)
  activeTab: "all",
  searchQuery: "",
  selectedGroupId: -1,
  
  // Dữ liệu đang biên tập của recipe hiện tại
  formulas: [
    {
      stones: new Array(8).fill(null).map(() => ({ id: -1, isGroup: false, rareType: 0, level: 0 }))
    }
  ],
  groups: [] // [{ id: 0, ids: [64, 65] }]
};

// ==========================================
// 5. Khởi Tạo & Quản Lý Dữ Liệu
// ==========================================
function initApp() {
  loadSavedData();
  setupEventListeners();
  renderAll();
}

function loadSavedData() {
  try {
    let saved = localStorage.getItem("mergeList");
    if (saved) {
      let list = JSON.parse(saved);
      if (Array.isArray(list) && list.length > 0) {
        AppState.recipes = list;
        AppState.currentRecipeIndex = 0;
        if (list[0].formula) {
          loadRecipeFromBase64(list[0].formula, false);
          return;
        }
      }
    }
  } catch (e) {
    console.warn("Could not load localStorage data:", e);
  }

  // Khởi tạo công thức mặc định (8 viên Tím cấp 1)
  AppState.formulas = [
    {
      stones: [
        { id: 69, isGroup: false, rareType: 2, level: 0 },
        { id: 68, isGroup: false, rareType: 2, level: 0 },
        { id: 229, isGroup: false, rareType: 2, level: 0 },
        { id: 362, isGroup: false, rareType: 2, level: 0 },
        { id: 226, isGroup: false, rareType: 2, level: 0 },
        { id: 227, isGroup: false, rareType: 2, level: 0 },
        { id: 229, isGroup: false, rareType: 2, level: 0 },
        { id: 1066, isGroup: false, rareType: 2, level: 0 }
      ]
    }
  ];
  saveCurrentRecipeToState();
}

function saveStateToStorage() {
  try {
    localStorage.setItem("mergeList", JSON.stringify(AppState.recipes));
  } catch (e) {
    console.warn("Storage save failed:", e);
  }
}

function saveCurrentRecipeToState() {
  let cur = AppState.recipes[AppState.currentRecipeIndex];
  if (!cur) return;
  let b64 = encodeRecipeData(cur.name, AppState.formulas, AppState.groups);
  cur.formula = b64;
  saveStateToStorage();
}

function loadRecipeFromBase64(b64, updateName = true) {
  try {
    let decoded = decodeRecipeData(b64);
    if (updateName && decoded.name) {
      AppState.recipes[AppState.currentRecipeIndex].name = decoded.name;
    }
    AppState.groups = decoded.groups || [];
    AppState.formulas = decoded.formulas || [];
    AppState.currentFormulaIndex = 0;
    AppState.selectedSlotIndex = 0;
    saveCurrentRecipeToState();
    renderAll();
    return true;
  } catch (e) {
    showToast("❌ Mã công thức không hợp lệ!", "danger");
    return false;
  }
}

// ==========================================
// 6. Giao Diện & Kết Nối Sự Kiện
// ==========================================
function renderAll() {
  renderRecipeSelector();
  renderCostSummary();
  renderFormulaTabs();
  renderMatrixSockets();
  renderModifierPanel();
  renderGroupsList();
  renderVaultCatalog();
  renderCodeOutput();
}

function renderRecipeSelector() {
  const sel = document.getElementById("recipeSelect");
  const nameInput = document.getElementById("recipeNameInput");
  if (!sel || !nameInput) return;

  sel.innerHTML = "";
  AppState.recipes.forEach((r, idx) => {
    let opt = document.createElement("option");
    opt.value = idx;
    opt.textContent = `${idx + 1}. ${r.name || "Chưa đặt tên"}`;
    if (idx === AppState.currentRecipeIndex) opt.selected = true;
    sel.appendChild(opt);
  });

  let cur = AppState.recipes[AppState.currentRecipeIndex];
  nameInput.value = cur ? cur.name : "";
}

function renderCostSummary() {
  let curFormula = AppState.formulas[AppState.currentFormulaIndex];
  if (!curFormula) return;
  let cost = calcCostFormula(curFormula.stones, AppState.groups);
  let totalStones = curFormula.stones.filter(s => s.id !== -1).length;

  document.getElementById("costGold").textContent = cost.gold.toLocaleString();
  document.getElementById("costDiamond").textContent = cost.diamond.toLocaleString();
  document.getElementById("costStoneCount").textContent = `${totalStones}/8`;
}

function renderFormulaTabs() {
  const bar = document.getElementById("formulaTabsBar");
  if (!bar) return;
  bar.innerHTML = "";

  AppState.formulas.forEach((f, idx) => {
    let tab = document.createElement("div");
    tab.className = `formula-tab ${idx === AppState.currentFormulaIndex ? 'active' : ''}`;
    
    let count = f.stones.filter(s => s.id !== -1).length;
    tab.innerHTML = `
      <span>⚡ Bộ ${idx + 1} (${count}đ)</span>
      ${AppState.formulas.length > 1 ? `<span class="formula-tab-del" title="Xóa bộ này">✕</span>` : ''}
    `;

    tab.onclick = (e) => {
      if (e.target.classList.contains("formula-tab-del")) {
        e.stopPropagation();
        deleteFormula(idx);
        return;
      }
      AppState.currentFormulaIndex = idx;
      AppState.selectedSlotIndex = 0;
      renderAll();
    };

    bar.appendChild(tab);
  });

  let addBtn = document.createElement("button");
  addBtn.className = "btn btn-outline btn-sm";
  addBtn.innerHTML = "+ Thêm Bộ Ghép";
  addBtn.onclick = addNewFormula;
  bar.appendChild(addBtn);
}

function renderMatrixSockets() {
  const grid = document.getElementById("matrixGrid");
  if (!grid) return;
  grid.innerHTML = "";

  let curFormula = AppState.formulas[AppState.currentFormulaIndex];
  if (!curFormula) return;

  curFormula.stones.forEach((stone, idx) => {
    let slot = document.createElement("div");
    let isSelected = idx === AppState.selectedSlotIndex;
    let isFilled = stone.id !== -1;
    let rarityClass = isFilled ? RARITIES[stone.rareType].class : '';

    slot.className = `stone-slot ${isSelected ? 'selected' : ''} ${isFilled ? 'filled' : ''} ${rarityClass}`;
    
    // Drag & Drop destination
    slot.ondragover = (e) => { e.preventDefault(); slot.classList.add("drag-over"); };
    slot.ondragleave = () => { slot.classList.remove("drag-over"); };
    slot.ondrop = (e) => {
      e.preventDefault();
      slot.classList.remove("drag-over");
      let data = e.dataTransfer.getData("text/plain");
      if (data) {
        let payload = JSON.parse(data);
        assignStoneToSlot(idx, payload.id, payload.isGroup);
      }
    };

    if (isFilled) {
      let iconSrc = stone.isGroup ? "images/err.png" : `images/${STONE_MAP.get(stone.id)?.name || 'err'}.png`;
      let nameLabel = stone.isGroup ? `Nhóm G${stone.id}` : (STONE_MAP.get(stone.id)?.viName || `Đá ${stone.id}`);

      slot.innerHTML = `
        <span class="slot-index">#${idx + 1}</span>
        ${stone.isGroup ? `<span class="slot-group-badge">G${stone.id}</span>` : ''}
        <span class="slot-clear-btn" title="Gỡ đá">✕</span>
        <img class="slot-img" src="${iconSrc}" alt="" onerror="this.src='images/err.png'"/>
        <span class="slot-level-badge">Lv.${stone.level + 1}</span>
        <span class="slot-name-label">${nameLabel}</span>
      `;

      slot.querySelector(".slot-clear-btn").onclick = (e) => {
        e.stopPropagation();
        clearSlot(idx);
      };
    } else {
      slot.innerHTML = `
        <span class="slot-index">#${idx + 1}</span>
        <span style="font-size: 1.5rem; opacity: 0.25;">+</span>
        <span style="font-size: 0.65rem; color: var(--text-dim);">Trống</span>
      `;
    }

    slot.onclick = () => {
      AppState.selectedSlotIndex = idx;
      if (isFilled) {
        AppState.activeRarity = stone.rareType;
        AppState.activeLevel = stone.level;
      }
      renderMatrixSockets();
      renderModifierPanel();
    };

    slot.ondblclick = () => {
      clearSlot(idx);
    };

    grid.appendChild(slot);
  });
}

function renderModifierPanel() {
  const container = document.getElementById("slotModifierBox");
  if (!container) return;

  let curFormula = AppState.formulas[AppState.currentFormulaIndex];
  let curSlot = curFormula?.stones[AppState.selectedSlotIndex];
  let isFilled = curSlot && curSlot.id !== -1;

  let title = isFilled 
    ? (curSlot.isGroup ? `Nhóm đá G${curSlot.id}` : STONE_MAP.get(curSlot.id)?.viName || `Đá ${curSlot.id}`)
    : `Ô số #${AppState.selectedSlotIndex + 1} (Đang trống)`;

  document.getElementById("currentSlotTitle").textContent = title;
  document.getElementById("currentSlotLevelDisplay").textContent = `Lv.${AppState.activeLevel + 1}`;

  // Rarity pills
  const pills = document.querySelectorAll(".rarity-pill");
  pills.forEach((p, idx) => {
    p.className = `rarity-pill ${RARITIES[idx].class} ${AppState.activeRarity === idx ? 'active' : ''}`;
  });
}

function renderGroupsList() {
  const list = document.getElementById("groupsList");
  if (!list) return;
  list.innerHTML = "";

  if (AppState.groups.length === 0) {
    list.innerHTML = `
      <div style="font-size: 0.8rem; color: var(--text-dim); text-align: center; padding: 16px 0;">
        Chưa tạo nhóm đá nào. Nhấn "+ Tạo Nhóm" để thêm nhóm đá linh hoạt.
      </div>
    `;
    return;
  }

  AppState.groups.forEach(g => {
    let card = document.createElement("div");
    let isActive = AppState.selectedGroupId === g.id;
    card.className = `group-card ${isActive ? 'active' : ''}`;

    let chipsHtml = g.ids.map((sid, i) => {
      let st = STONE_MAP.get(sid);
      let img = st ? `images/${st.name}.png` : 'images/err.png';
      return `
        <div class="group-stone-chip" title="${st?.viName || sid}">
          <img src="${img}" alt="" onerror="this.src='images/err.png'"/>
          <span class="remove-chip" data-idx="${i}">✕</span>
        </div>
      `;
    }).join("");

    card.innerHTML = `
      <div class="group-card-header">
        <div style="display: flex; align-items: center; gap: 6px;">
          <span class="group-badge">G${g.id}</span>
          <span style="font-size: 0.75rem; color: var(--text-muted);">(${g.ids.length} loại đá)</span>
        </div>
        <div style="display: flex; gap: 4px;">
          <button class="btn btn-outline btn-sm btn-use-group" style="padding: 2px 6px;">Gán ô</button>
          <button class="btn btn-danger btn-sm btn-del-group" style="padding: 2px 6px;">Xóa</button>
        </div>
      </div>
      <div class="group-chips">${chipsHtml || '<span style="font-size: 0.7rem; color: var(--text-dim); font-style: italic;">Chưa có đá nào</span>'}</div>
    `;

    card.onclick = () => {
      AppState.selectedGroupId = g.id;
      renderGroupsList();
    };

    // Remove single stone from group
    card.querySelectorAll(".remove-chip").forEach(btn => {
      btn.onclick = (e) => {
        e.stopPropagation();
        let idx = parseInt(btn.getAttribute("data-idx"));
        g.ids.splice(idx, 1);
        saveCurrentRecipeToState();
        renderAll();
      };
    });

    // Use group in selected slot
    card.querySelector(".btn-use-group").onclick = (e) => {
      e.stopPropagation();
      assignStoneToSlot(AppState.selectedSlotIndex, g.id, true);
    };

    // Delete entire group
    card.querySelector(".btn-del-group").onclick = (e) => {
      e.stopPropagation();
      deleteGroup(g.id);
    };

    list.appendChild(card);
  });
}

function renderVaultCatalog() {
  const grid = document.getElementById("vaultGrid");
  if (!grid) return;
  grid.innerHTML = "";

  let filtered = STONES.filter(s => {
    // Category filter
    if (AppState.activeTab !== "all" && s.category !== AppState.activeTab) return false;
    // Search query
    if (AppState.searchQuery) {
      let q = AppState.searchQuery.toLowerCase();
      let matchVi = s.viName.toLowerCase().includes(q);
      let matchEn = s.name.toLowerCase().includes(q);
      let matchId = s.id.toString().includes(q);
      if (!matchVi && !matchEn && !matchId) return false;
    }
    return true;
  });

  // Render Stone cards
  filtered.forEach(s => {
    let card = document.createElement("div");
    card.className = "vault-card";
    card.draggable = true;

    card.innerHTML = `
      <img src="images/${s.name}.png" alt="" onerror="this.src='images/err.png'"/>
      <span class="stone-title">${s.viName}</span>
      <span class="stone-en">ID: ${s.id}</span>
    `;

    card.ondragstart = (e) => {
      e.dataTransfer.setData("text/plain", JSON.stringify({ id: s.id, isGroup: false }));
    };

    card.onclick = () => {
      // If user has an active group selected, add stone to that group!
      if (AppState.selectedGroupId !== -1 && AppState.activeTab === "group") {
        addStoneToGroup(AppState.selectedGroupId, s.id);
        return;
      }
      assignStoneToSlot(AppState.selectedSlotIndex, s.id, false);
    };

    card.ondblclick = () => {
      // Fast append to first empty slot
      let curFormula = AppState.formulas[AppState.currentFormulaIndex];
      let emptyIdx = curFormula.stones.findIndex(st => st.id === -1);
      if (emptyIdx !== -1) {
        assignStoneToSlot(emptyIdx, s.id, false);
      } else {
        assignStoneToSlot(AppState.selectedSlotIndex, s.id, false);
      }
    };

    grid.appendChild(card);
  });

  // If on Group tab, also show Group items in vault!
  if (AppState.activeTab === "group" || AppState.activeTab === "all") {
    AppState.groups.forEach(g => {
      let card = document.createElement("div");
      card.className = "vault-card group-card-item";
      card.draggable = true;

      card.innerHTML = `
        <div style="width:40px; height:40px; display:flex; align-items:center; justify-content:center; background:rgba(168,85,247,0.2); border-radius:8px; font-weight:800; color:var(--accent-purple); font-size:1.1rem; margin-bottom:4px;">
          G${g.id}
        </div>
        <span class="stone-title">Nhóm G${g.id}</span>
        <span class="stone-en">${g.ids.length} loại đá</span>
      `;

      card.ondragstart = (e) => {
        e.dataTransfer.setData("text/plain", JSON.stringify({ id: g.id, isGroup: true }));
      };

      card.onclick = () => {
        assignStoneToSlot(AppState.selectedSlotIndex, g.id, true);
      };

      grid.appendChild(card);
    });
  }
}

function renderCodeOutput() {
  const out = document.getElementById("codeOutput");
  if (!out) return;
  let cur = AppState.recipes[AppState.currentRecipeIndex];
  if (!cur) return;
  let b64 = encodeRecipeData(cur.name, AppState.formulas, AppState.groups);
  out.value = b64;
  cur.formula = b64;
}

// ==========================================
// 7. Thao Tác Chỉnh Sửa Slot & Công Thức
// ==========================================
function assignStoneToSlot(slotIdx, stoneId, isGroup) {
  let curFormula = AppState.formulas[AppState.currentFormulaIndex];
  if (!curFormula || slotIdx < 0 || slotIdx >= 8) return;

  curFormula.stones[slotIdx] = {
    id: stoneId,
    isGroup: isGroup,
    rareType: AppState.activeRarity,
    level: AppState.activeLevel
  };

  // Move selected to next slot automatically for ultra-fast workflow
  if (slotIdx < 7) {
    AppState.selectedSlotIndex = slotIdx + 1;
  }

  saveCurrentRecipeToState();
  renderAll();
}

function clearSlot(slotIdx) {
  let curFormula = AppState.formulas[AppState.currentFormulaIndex];
  if (!curFormula || slotIdx < 0 || slotIdx >= 8) return;
  curFormula.stones[slotIdx] = { id: -1, isGroup: false, rareType: 0, level: 0 };
  saveCurrentRecipeToState();
  renderAll();
}

function setRarity(rIndex) {
  AppState.activeRarity = rIndex;
  let curFormula = AppState.formulas[AppState.currentFormulaIndex];
  let curSlot = curFormula?.stones[AppState.selectedSlotIndex];
  if (curSlot && curSlot.id !== -1) {
    curSlot.rareType = rIndex;
    saveCurrentRecipeToState();
  }
  renderAll();
}

function adjustLevel(delta) {
  let newLvl = AppState.activeLevel + delta;
  if (newLvl < 0) newLvl = 0;
  if (newLvl > 9) newLvl = 9;
  AppState.activeLevel = newLvl;

  let curFormula = AppState.formulas[AppState.currentFormulaIndex];
  let curSlot = curFormula?.stones[AppState.selectedSlotIndex];
  if (curSlot && curSlot.id !== -1) {
    curSlot.level = newLvl;
    saveCurrentRecipeToState();
  }
  renderAll();
}

function addNewFormula() {
  AppState.formulas.push({
    stones: new Array(8).fill(null).map(() => ({ id: -1, isGroup: false, rareType: 0, level: 0 }))
  });
  AppState.currentFormulaIndex = AppState.formulas.length - 1;
  AppState.selectedSlotIndex = 0;
  saveCurrentRecipeToState();
  renderAll();
}

function deleteFormula(idx) {
  if (AppState.formulas.length <= 1) return;
  AppState.formulas.splice(idx, 1);
  if (AppState.currentFormulaIndex >= AppState.formulas.length) {
    AppState.currentFormulaIndex = AppState.formulas.length - 1;
  }
  AppState.selectedSlotIndex = 0;
  saveCurrentRecipeToState();
  renderAll();
}

function clearActiveFormula() {
  let curFormula = AppState.formulas[AppState.currentFormulaIndex];
  if (!curFormula) return;
  curFormula.stones = new Array(8).fill(null).map(() => ({ id: -1, isGroup: false, rareType: 0, level: 0 }));
  saveCurrentRecipeToState();
  renderAll();
  showToast("Đã dọn sạch 8 ô ghép!", "success");
}

function fillAllSlotsWithCurrent() {
  let curFormula = AppState.formulas[AppState.currentFormulaIndex];
  let curSlot = curFormula?.stones[AppState.selectedSlotIndex];
  if (!curSlot || curSlot.id === -1) {
    showToast("Vui lòng chọn hoặc gán 1 viên đá trước!", "danger");
    return;
  }

  for (let i = 0; i < 8; i++) {
    curFormula.stones[i] = { ...curSlot };
  }
  saveCurrentRecipeToState();
  renderAll();
  showToast("Đã phủ đầy 8 ô với loại đá đã chọn!", "success");
}

// ==========================================
// 8. Quản Lý Nhóm Đá (Group Management)
// ==========================================
function addNewGroup() {
  let nextId = 0;
  while (AppState.groups.some(g => g.id === nextId)) {
    nextId++;
  }
  AppState.groups.push({ id: nextId, ids: [] });
  AppState.selectedGroupId = nextId;
  saveCurrentRecipeToState();
  renderAll();
  showToast(`Đã tạo Nhóm G${nextId}! Nhấp chọn đá trong kho để thêm vào nhóm.`, "success");
}

function addStoneToGroup(groupId, stoneId) {
  let g = AppState.groups.find(x => x.id === groupId);
  if (!g) return;
  if (!g.ids.includes(stoneId)) {
    g.ids.push(stoneId);
    saveCurrentRecipeToState();
    renderAll();
    let st = STONE_MAP.get(stoneId);
    showToast(`Đã thêm ${st?.viName || stoneId} vào Nhóm G${groupId}`, "success");
  } else {
    showToast("Viên đá này đã có trong nhóm rồi!", "info");
  }
}

function deleteGroup(groupId) {
  AppState.groups = AppState.groups.filter(g => g.id !== groupId);
  // Also clean up any slots using this group
  AppState.formulas.forEach(f => {
    f.stones.forEach(s => {
      if (s.isGroup && s.id === groupId) {
        s.id = -1;
        s.isGroup = false;
      }
    });
  });
  if (AppState.selectedGroupId === groupId) AppState.selectedGroupId = -1;
  saveCurrentRecipeToState();
  renderAll();
  showToast(`Đã xóa Nhóm G${groupId}`, "info");
}

// ==========================================
// 9. Quản Lý Công Thức (Recipe Profiles)
// ==========================================
function createNewRecipeProfile() {
  let count = AppState.recipes.length;
  let newName = `Công thức ${count}`;
  AppState.recipes.push({
    name: newName,
    formula: ""
  });
  AppState.currentRecipeIndex = AppState.recipes.length - 1;
  AppState.formulas = [
    { stones: new Array(8).fill(null).map(() => ({ id: -1, isGroup: false, rareType: 0, level: 0 })) }
  ];
  AppState.groups = [];
  AppState.currentFormulaIndex = 0;
  AppState.selectedSlotIndex = 0;
  saveCurrentRecipeToState();
  renderAll();
  showToast(`Đã tạo mới: ${newName}`, "success");
}

function deleteCurrentRecipeProfile() {
  if (AppState.recipes.length <= 1) {
    showToast("Không thể xóa công thức duy nhất còn lại!", "danger");
    return;
  }
  let oldName = AppState.recipes[AppState.currentRecipeIndex].name;
  AppState.recipes.splice(AppState.currentRecipeIndex, 1);
  AppState.currentRecipeIndex = Math.max(0, AppState.currentRecipeIndex - 1);
  let cur = AppState.recipes[AppState.currentRecipeIndex];
  if (cur.formula) {
    loadRecipeFromBase64(cur.formula, false);
  } else {
    AppState.formulas = [{ stones: new Array(8).fill(null).map(() => ({ id: -1, isGroup: false, rareType: 0, level: 0 })) }];
    AppState.groups = [];
  }
  saveStateToStorage();
  renderAll();
  showToast(`Đã xóa: ${oldName}`, "info");
}

// ==========================================
// 10. Tiện Ích Sao Chép & Modal Nhập Mã
// ==========================================
function copyCodeToClipboard() {
  const out = document.getElementById("codeOutput");
  if (!out || !out.value) return;
  navigator.clipboard.writeText(out.value).then(() => {
    showToast("✅ Đã sao chép mã công thức vào Clipboard!", "success");
  }).catch(() => {
    out.select();
    document.execCommand("copy");
    showToast("✅ Đã sao chép mã!", "success");
  });
}

function openImportModal() {
  const modal = document.getElementById("importModal");
  const area = document.getElementById("importTextarea");
  if (!modal || !area) return;
  area.value = "";
  modal.classList.add("open");
  area.focus();
}

function closeImportModal() {
  const modal = document.getElementById("importModal");
  if (modal) modal.classList.remove("open");
}

function processImport() {
  const area = document.getElementById("importTextarea");
  if (!area) return;
  let text = area.value.trim();
  if (!text) {
    showToast("Vui lòng dán mã Base64 trước!", "danger");
    return;
  }
  let ok = loadRecipeFromBase64(text, true);
  if (ok) {
    closeImportModal();
    showToast("🎉 Nạp công thức thành công!", "success");
  }
}

function loadExampleCode() {
  let exampleB64 = "AA5Dw7RuZyB0aOG7qWMgMAABACIAAAgCAEUCAEQCAOUCAWoCAOICAOMCAOUCBCo=";
  loadRecipeFromBase64(exampleB64, true);
  showToast("💎 Đã tải công thức mẫu (8 viên Tím)!", "success");
}

function showToast(message, type = "success") {
  const container = document.getElementById("toastContainer");
  if (!container) return;
  let toast = document.createElement("div");
  toast.className = `toast ${type}`;
  
  let icon = "✨";
  if (type === "danger") icon = "⚠️";
  if (type === "info") icon = "ℹ️";

  toast.innerHTML = `<span>${icon}</span> <span>${message}</span>`;
  container.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = "0";
    toast.style.transform = "translateY(10px)";
    toast.style.transition = "all 0.3s";
    setTimeout(() => toast.remove(), 300);
  }, 2600);
}

// ==========================================
// 11. Đăng Ký Sự Kiện Toàn Cục
// ==========================================
function setupEventListeners() {
  // Recipe selector
  document.getElementById("recipeSelect").onchange = (e) => {
    AppState.currentRecipeIndex = parseInt(e.target.value);
    let cur = AppState.recipes[AppState.currentRecipeIndex];
    if (cur.formula) {
      loadRecipeFromBase64(cur.formula, false);
    } else {
      AppState.formulas = [{ stones: new Array(8).fill(null).map(() => ({ id: -1, isGroup: false, rareType: 0, level: 0 })) }];
      AppState.groups = [];
      AppState.currentFormulaIndex = 0;
      AppState.selectedSlotIndex = 0;
      renderAll();
    }
  };

  // Recipe Rename
  document.getElementById("recipeNameInput").oninput = (e) => {
    let cur = AppState.recipes[AppState.currentRecipeIndex];
    if (cur) {
      cur.name = e.target.value;
      saveCurrentRecipeToState();
      renderRecipeSelector();
      renderCodeOutput();
    }
  };

  document.getElementById("btnNewRecipe").onclick = createNewRecipeProfile;
  document.getElementById("btnDeleteRecipe").onclick = deleteCurrentRecipeProfile;
  document.getElementById("btnNewGroup").onclick = addNewGroup;

  // Rarity pills
  document.querySelectorAll(".rarity-pill").forEach((pill, idx) => {
    pill.onclick = () => setRarity(idx);
  });

  // Level stepper
  document.getElementById("btnLevelDec").onclick = () => adjustLevel(-1);
  document.getElementById("btnLevelInc").onclick = () => adjustLevel(1);

  // Quick slot actions
  document.getElementById("btnClearCurrentSlot").onclick = () => clearSlot(AppState.selectedSlotIndex);
  document.getElementById("btnFillAllSlots").onclick = fillAllSlotsWithCurrent;
  document.getElementById("btnClearFormula").onclick = clearActiveFormula;

  // Vault category filter tabs
  document.querySelectorAll(".vault-tab").forEach(tab => {
    tab.onclick = () => {
      document.querySelectorAll(".vault-tab").forEach(t => t.classList.remove("active"));
      tab.classList.add("active");
      AppState.activeTab = tab.getAttribute("data-category");
      renderVaultCatalog();
    };
  });

  // Vault search
  document.getElementById("vaultSearchInput").oninput = (e) => {
    AppState.searchQuery = e.target.value.trim();
    renderVaultCatalog();
  };

  // Import / Export Buttons
  document.getElementById("btnCopyCode").onclick = copyCodeToClipboard;
  document.getElementById("btnOpenImport").onclick = openImportModal;
  document.getElementById("btnImportSubmit").onclick = processImport;
  document.getElementById("btnImportClose").onclick = closeImportModal;
  document.getElementById("btnLoadPreset").onclick = loadExampleCode;

  // Close modal on click overlay
  document.getElementById("importModal").onclick = (e) => {
    if (e.target.id === "importModal") closeImportModal();
  };

  // Keyboard escape
  window.onkeydown = (e) => {
    if (e.key === "Escape") closeImportModal();
  };
}

// Start app
window.addEventListener("DOMContentLoaded", initApp);
