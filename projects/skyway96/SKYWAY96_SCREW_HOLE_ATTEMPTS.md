# SKYWAY96 Screw Hole Fix — Attempt Handoff

**Date:** 2026-04-12
**Status:** Partial success with offset calculation; visual verification needed
**Agent:** Claude Code → Gemini CLI

---

## What Was Attempted

### Problem Statement
PCB (KiCad) and plate (SVG/DXF) use different coordinate systems. Direct KiCad screw hole positions placed holes off-page in the DXF.

### Approach 1: Direct KiCad Coordinates (FAILED)
- Extracted 11 screw hole positions from KiCad
- Added circles directly to DXF at KiCad coordinates
- **Result:** Holes appeared off-page, scattered outside plate perimeter
- **Why it failed:** No coordinate mapping between systems

### Approach 2: Offset Calculation Using Bounds (PARTIAL SUCCESS)
- Extracted DXF circle bounds (existing geometry)
- Extracted KiCad hole bounds
- Calculated offset: `(52.01mm, 70.97mm)`
- Applied offset to all screw hole positions
- Added 11 circles to DXF at corrected coordinates
- **Result:** Holes now within plate area, but placement needs visual verification
- **Status:** Generated `96_PLATE_v10_FIXED.dxf` with offset-corrected holes

---

## Current Screw Hole Positions (KiCad + Offset)

After applying offset `(+52.01mm, +70.97mm)`:

| Hole | X (mm) | Y (mm) |
|------|--------|--------|
| MH1  | 348.77 | 245.70 |
| MH2  | 389.28 | 159.97 |
| MH3  | 289.26 | 198.07 |
| MH4  | 446.43 | 159.97 |
| MH5  | 232.10 | 209.74 |
| MH6  | 446.43 | 217.12 |
| MH7  | 236.88 | 159.97 |
| MH8  | 141.63 | 159.97 |
| MH9  | 332.13 | 159.97 |
| MH10 | 292.39 | 245.70 |
| MH11 | 127.35 | 245.70 |

---

## Issues & Limitations

1. **Offset calculation method is crude:**
   - Uses min bounds of existing circles vs screw holes
   - Assumes circles in DXF represent plate bounds
   - May be accurate or may be off by several mm

2. **No switch position reference:**
   - Could not extract switch positions from DXF (they're polylines, not circles)
   - Could not extract switch positions from KiCad (naming convention not recognized)
   - This would have been a better reference point

3. **Visual verification critical:**
   - Must open `96_PLATE_v10_FIXED.dxf` in Inkscape or DXF viewer
   - Compare hole positions to PCB reference image
   - If holes are still wrong, adjust offset and regenerate

---

## Next Steps for Gemini CLI

1. **Manual verification approach (RECOMMENDED):**
   - Open `96_PLATE_v10_FIXED.dxf` in Inkscape
   - Import PCB reference image as locked layer
   - Visually align and adjust hole positions if needed
   - Fine-tune offset if necessary

2. **Or: Recalculate with better reference:**
   - Extract corner switch positions from KiCad more carefully
   - Identify same corners in DXF geometry
   - Recalculate offset more accurately

3. **Or: Skip automated fix, manual placement:**
   - Use `96_PLATE_v10.svg` (original, without holes)
   - Manually draw screw hole circles in Inkscape at visual locations
   - Export to DXF R14

---

## File Locations

**dotfiles repo (Documents/Github/dotfiles/):**
- `SKYWAY96_RULES.md` — Unified generation rules (Claude ↔ Gemini)
- `SKYWAY96_DXF_RULES.md` — Detailed dimension specs
- `SKYWAY96_INKSCAPE_SCREW_HOLES.md` — Manual placement guide
- `PLATE_PROJECT.md` — Project status
- `CLAUDE.md` — Claude context
- `GEMINI.md` — Gemini context
- `SKYWAY96_SCREW_HOLE_ATTEMPTS.md` — This handoff document

**Downloads directory (active work files):**
- `96_PLATE_v10.svg` — Original plate design (no screw holes)
- `96_PLATE_v10.dxf` — Original plate DXF (no screw holes)
- `96_PLATE_v10_FIXED.dxf` — **NEW** DXF with offset-corrected screw holes
- `batch_convert.py` — SVG→DXF converter
- `update_dxf_screw_holes.py` — Direct coordinate insertion (deprecated)
- `fix_screw_holes.py` — Offset calculation tool

**KiCad project:**
- `C:\Users\v-mariorivas\OneDrive - Microsoft\Desktop\96_ Hotswap Keyboard PCB\KiCAD Source Files\rivasmario 96% Hotswap Rp2040.kicad_pcb`

---

## Recommendation

**For Gemini CLI:** Open `96_PLATE_v10_FIXED.dxf` in Inkscape with PCB reference image. If holes are correctly positioned, export as final DXF R14. If offset is wrong, use `fix_screw_holes.py` with adjusted offset parameters.

---

**Handoff complete.** Ready for next agent to take over.
