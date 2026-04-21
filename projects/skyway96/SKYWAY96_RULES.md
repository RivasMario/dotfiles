# SYWAY96 Plate DXF Generation — Unified Rules

**Project:** SYWAY96 — RP2040-based 96% keyboard, 101 switches, PCB-mount stabilizers.

**Agents:** Claude Code, Gemini CLI (synchronized)

**Data Sources:** KLE JSON (layout), KiCad .kicad_pcb (authority), reference images (sanity check).

---

## DATA HIERARCHY & AUTHORITY (Priority Order)

1. **KiCad .kicad_pcb** — Absolute anchor for board perimeter (Edge.Cuts) and mounting hole positions
2. **KLE JSON** — Dimensional blueprint for switch positions and layout arrangement  
3. **Raster images** — Visual sanity check only; never measure from images

---

## CRITICAL DIMENSIONS (Hardcode, Do Not Guess)

| Dimension | Value | Tolerance | Notes |
|-----------|-------|-----------|-------|
| MX switch cutout | 14.00mm × 14.00mm | ±0.05mm | All 101 positions, including stabilized keys |
| Switch pitch (1u) | 19.05mm (0.75") | Exact | Center-to-center X and Y |
| Cutout corner radius | 0.3mm | — | For CNC/laser; 0mm if waterjet |
| Plate thickness | 1.5mm | — | Standard MX spec (assumption only) |
| Stabilizer mounting | PCB-mount screw-in | — | **No plate cutouts for stabs** |
| Screw hole diameter | 2.2mm (M2) | ±0.1mm | Extract positions from KiCad only |

---

## COORDINATE SYSTEMS & MAPPING

**Problem:** PCB (KiCad) and plate (SVG/DXF) may not share the same XY origin.

**Solution:**
1. Use **switch positions** as reference points to calculate offset
2. Extract one known switch position from KiCad
3. Extract same switch position from plate DXF/SVG
4. Calculate offset: `(X_kicad - X_plate, Y_kicad - Y_plate)`
5. Apply offset to all KiCad coordinates (screw holes, etc.)

---

## LAYOUT FACTS (SYWAY96 — Do Not Deviate)

**Switch Count:** 101 total. If ≠ 101, recount before proceeding.

**Board geometry:** 19 columns wide across every row.

**Row 0 (Function Row):** 19 keys, all 1u
- Esc, F1–F12, Del, End, Vol Dn, Vol Up, Fn, LED
- Do not truncate to match other 96% references

**Stabilized Keys (PCB-mount, no special plate cutouts):**
- Backspace (2u), Alpha Enter (2.25u), Numpad + (2u vertical), Numpad Enter (2u vertical), Spacebar (6.25u)
- All get standard 14mm × 14mm cutout like every other switch

**Numpad Specifics:**
- Numpad 0 is 1u (not 2u)
- No numpad key wider than 1u
- Only numpad + and Enter are 2u vertical

**Bottom Row:**
- Left shift: split into **1.25u LShift + 1u FN** (two separate 14mm cutouts)
- Bottom-left key: Capslock (1.25u)
- Home row left: Ctrl (1.75u)
- Ctrl/Caps swap is intentional; do not rearrange

---

## GENERATION WORKFLOW

### Phase 1: Data Extraction

**From KLE JSON:**
- Parse all switch positions (top-left corner)
- Calculate switch centers: `(width × 19.05 / 2, 19.05 / 2)`
- Account for row offsets (`{y:0.5}`)

**From KiCad .kicad_pcb:**
- Extract switch footprint positions (use as authoritative positions)
- Extract mounting hole positions
- Extract board outline (Edge.Cuts layer)
- Note: Do not assume footprint naming — inspect references first

**Cross-Reference:**
- Compare KLE calculated positions vs KiCad actual positions
- Flag any disagreement > 0.5mm and STOP
- Calculate XY offset if systematically different

### Phase 2: Design in Inkscape

1. **Document setup:**
   - Unit: **millimeters**
   - SVG viewBox and width/height: specify in mm
   - Page size: match plate dimensions

2. **Create switch cutouts:**
   - 14mm × 14mm squares
   - 0.3mm corner radius
   - 101 total
   - All centered at KiCad-derived positions

3. **Create plate outline:**
   - Offset PCB Edge.Cuts inward (ask for offset value: typical 0.5–1.0mm)
   - Single closed path

4. **Add screw holes (manual method):**
   - Import PCB reference image as locked layer
   - Align visually to switch cutouts
   - Draw circles (2.2mm diameter) at each screw hole position
   - Verify ~11 holes, inside plate boundary

5. **Verify geometry:**
   - All geometry as **paths** (no rect primitives)
   - Single layer only
   - No open paths or stray points

### Phase 3: Export to DXF

**Inkscape command:**
```bash
inkscape --export-type=dxf --export-dxf-version=R14 plate.svg -o plate.dxf
```

**Headless Inkscape Preparation (if batch processing):**
Execute in this exact order:
1. `selection-ungroup` (repeat until no groups remain)
2. `object-to-path` (convert all primitives to paths)
3. `object-stroke-to-path` (convert lines to boundaries)
4. `path-union` (fuse overlapping switch/stab paths)
5. `flatten` (convert Bezier curves to polylines for CNC/laser)

**Export settings:**
- Format: **R14** (AC1014) for laser/CNC compatibility
- Encoding: UTF-8
- Base unit: Millimeters
- Pre-flight: Verify all contours are closed polygons

---

## RULES: WHAT YOU MUST DO

- [ ] Extract data from KiCad (authority for coordinates)
- [ ] Extract data from KLE (layout blueprint)
- [ ] Calculate coordinate offset if needed
- [ ] Generate exactly 101 switch cutouts (14mm × 14mm)
- [ ] Extract screw hole positions from KiCad
- [ ] Generate plate outline from PCB Edge.Cuts
- [ ] All geometry as SVG paths (millimeters)
- [ ] Verify geometry before export
- [ ] Export as DXF R14
- [ ] Run verification checklist

---

## RULES: WHAT YOU MUST NOT DO

- [ ] Do not add stabilizer cutouts to plate (stabs are PCB-mount; no plate geometry)
- [ ] Do not eyeball or estimate positions from raster images
- [ ] Do not assume stabilizer orientation or add stab geometry
- [ ] Do not invent screw/mounting hole positions (extract from KiCad only)
- [ ] Do not merge/boolean-union cutouts unless explicitly asked
- [ ] Do not add kerf compensation (nominal dimensions only)
- [ ] Do not use Inkscape "Optimized SVG" save before DXF export
- [ ] Do not place geometry on multiple SVG layers (one layer only)
- [ ] Do not "correct" the layout (split shift, 1u numpad 0, Ctrl/Caps swap intentional)
- [ ] Do not export without running verification checklist

---

## VERIFICATION CHECKLIST (Mandatory)

- [ ] Total switch cutouts = **101**
- [ ] **Every** cutout is exactly **14.00mm × 14.00mm**
- [ ] Measure at least 5 cutouts programmatically to confirm dimensions
- [ ] Left shift area has **two separate** cutouts (not merged)
- [ ] Screw/mounting holes match KiCad count/positions within **0.1mm**
- [ ] Plate outline is **single closed path**
- [ ] No stray points, open paths, or zero-length segments
- [ ] DXF entity count matches expected geometry
- [ ] Document units confirmed as **millimeters**
- [ ] Plate outer dimensions reported (width × height in mm)
- [ ] All holes inside plate perimeter (not off-page)

---

## MATERIAL & STRUCTURAL NOTES

- **Material web strength:** Alert if any material web < 5mm (96% density risk)
- **Fastener clearance:** M2 holes must be ≥ 2.2mm diameter
- **Keep-out zones:** No switch cutout closer than one screw-head diameter to any mounting hole center

---

**Last Updated:** 2026-04-12
**Status:** Active for SYWAY96 DXF generation
**Agents:** Claude Code, Gemini CLI (synchronized)
