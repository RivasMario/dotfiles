# Plate Project - DXF Conversion

## Summary
Mario's plate design project: converting SVG schematics to DXF format for PCB/mechanical use.

## Files
- **Source:** `96_PLATE_v*.svg` (v1-v10, 44KB each)
- **Output:** `96_PLATE_v*.dxf` (normalized, 135-145KB each)
- **Converter:** `batch_convert.py` (robust batch converter with error handling)

## Crash Context
Gemini's last run (before crash) successfully converted v1-v7 via `convert_dxf_clean.py`. Crash occurred before v8-v10 were processed.

## Recovery Status (2026-04-12 19:39)
✓ Batch converted v4-v10 successfully
✗ v2, v3 skipped (malformed XML in SVG source)
✓ All active versions (v4-v10) now have matching DXF outputs

## Files in C:\Users\v-mariorivas\Downloads:
- `batch_convert.py` - Main converter script (flexible, handles any SVG)
- `convert_dxf.py` - Original basic converter (deprecated, hardcoded paths)
- `convert_dxf_clean.py` - Original clean converter (deprecated, hardcoded paths)

## Operational Rules
See `SKYWAY96_RULES.md` for comprehensive generation and verification rules (Claude ↔ Gemini synchronized).
- Data hierarchy: KiCad (authority) > KLE JSON (layout) > images (sanity check)
- Critical dimensions hardcoded (14mm switch cutouts, 19.05mm pitch)
- 101 total switches; no stabilizer plate cutouts (PCB-mount only)
- **Coordinate mapping required:** PCB (KiCad) and plate (SVG) may use different origins
- Manual screw hole placement in Inkscape (visual alignment to PCB reference)
- Mandatory verification checklist before releasing any DXF

## Next Steps
- Review v10.dxf for final design
- v2/v3 SVGs may need manual XML repair if needed
- Coordinate with Mario on design direction
- For new generations: follow SKYWAY96_DXF_RULES.md strictly
