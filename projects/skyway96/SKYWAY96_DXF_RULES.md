# SYWAY96 — Plate DXF Generation Rules

**Project:** SYWAY96 — RP2040-based 96% keyboard, 101 switches, PCB-mount stabilizers.

**Data Sources:** KLE JSON (layout), KiCad .kicad_pcb (authority), reference images (sanity check only).

---

## CRITICAL DIMENSIONS (hardcode, do not guess)

| Dimension | Value | Tolerance | Notes |
|-----------|-------|-----------|-------|
| MX switch cutout | 14.00mm × 14.00mm | ±0.05mm | All 101 positions, including stabilized keys |
| Switch pitch (1u) | 19.05mm (0.75") | Exact | Center-to-center in X and Y |
| Cutout corner radius | 0.3mm | — | For CNC/laser; 0mm if waterjet |
| Plate thickness | 1.5mm | — | Standard MX spec (assumption only) |
| Stabilizer mounting | PCB-mount screw-in | — | **No plate cutouts for stabs** |
| Screw hole diameter | 2.2mm | — | M2; extract positions from KiCad only |

---

## DATA HIERARCHY (Priority Order)

1. **KiCad .kicad_pcb** — Absolute authority for board perimeter (Edge.Cuts) and mounting hole positions
2. **KLE JSON** — Dimensional blueprint for switch positions and layout arrangement
3. **Raster images** — Visual sanity check only; never measure from images

---

## LAYOUT FACTS (Skyway96 — Do Not Deviate)

**Switch Count:** 101 total. If count ≠ 101, stop and recount before proceeding.

**Board dimensions:** 19 columns wide across every row.

**Row 0 (Function Row):** 19 keys, all 1u
- Esc, F1–F12, Del, End, Vol Dn, Vol Up, Fn, LED
- Do not truncate to match other 96% references

**Stabilized Keys (PCB-mount, no special plate cutouts):**
- Backspace (2u)
- Alpha Enter (2.25u)
- Numpad + (2u vertical)
- Numpad Enter (2u vertical)
- Spacebar (6.25u)
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

### 1. Parse KLE JSON
- Convert KLE units: 1u = 19.05mm
- KLE x/y = top-left corner of key
- Calculate switch center: offset by `(width × 19.05 / 2, 19.05 / 2)`
- Account for row 0 `{y:0.5}` offset

### 2. Parse KiCad .kicad_pcb
- Extract switch footprint positions and rotations
- Inspect footprint reference prefixes first (do not assume naming)
- Extract mounting hole positions
- Extract board outline from Edge.Cuts layer
- **Cross-reference KLE vs KiCad positions:** flag any disagreement > 0.5mm
- KiCad is authoritative for physical coordinates

### 3. Generate Plate Outline
- Offset PCB Edge.Cuts inward (ask for offset value before generating, typical: 0.5–1.0mm)

### 4. Build SVG in Inkscape
- Document unit: **millimeters**
- SVG viewBox and width/height: specify in mm
- All geometry: **paths only** (no rect primitives)

### 5. Export to DXF
```bash
inkscape --export-type=dxf --export-dxf-version=R14 plate.svg -o plate.dxf
```
- Format: **R14** (AC1014) for laser/CNC compatibility
- Encoding: UTF-8
- Base unit: Millimeters

---

## HEADLESS INKSCAPE CLI SEQUENCE (if batch processing)

Execute in this exact order to prevent corruption:

1. `selection-ungroup` (repeat until no groups remain)
2. `object-to-path` (convert all primitives to paths)
3. `object-stroke-to-path` (convert lines to boundaries)
4. `path-union` (fuse overlapping switch/stab paths)
5. `flatten` (convert Bezier curves to polylines for CNC/laser)

---

## RULES: WHAT YOU MUST DO

- [ ] Parse KLE JSON for layout arrangement
- [ ] Parse KiCad for authoritative physical positions
- [ ] Generate exactly 101 switch cutouts (14mm × 14mm)
- [ ] Extract mounting hole positions from KiCad
- [ ] Generate plate outline from PCB Edge.Cuts
- [ ] All geometry as SVG paths (millimeters)
- [ ] Export as DXF R14
- [ ] Run verification checklist before declaring done

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
- [ ] Do not generate without running verification checklist

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

---

## TOLERANCE & MATERIAL NOTES

- **Material web strength:** Alert user if any material web < 5mm (96% density risk)
- **Fastener clearance:** M2 holes must be ≥ 2.2mm diameter
- **Keep-out zones:** No switch cutout closer than one screw-head diameter to any mounting hole center

---

**Last Updated:** 2026-04-12 (Claude Code recovery)
**Status:** Active for SYWAY96 DXF generation
**Agent:** Claude Code only
