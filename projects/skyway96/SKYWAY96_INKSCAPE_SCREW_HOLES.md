# SYWAY96 — Manual Screw Hole Placement in Inkscape

## Before DXF Export — Add Screw Holes Manually

Since PCB and plate use different coordinate systems, place screw holes by visual reference in Inkscape.

---

## STEP 1: Open the Plate SVG

1. Open `96_PLATE_v10.svg` in Inkscape
2. Confirm:
   - Document unit: **millimeters** (File → Document Properties)
   - Viewbox shows full plate
   - All switch cutouts visible and centered

---

## STEP 2: Reference the PCB Image

1. File → Import → Select PCB reference image (e.g., screenshot of KiCad board)
2. Place image as a **locked reference layer** (Lock icon in Layers panel)
3. Align PCB image to match plate geometry visually:
   - Match switch positions between image and plate cutouts
   - Use corner switches or edge references for alignment
4. Once aligned, you can see where screw holes should go

---

## STEP 3: Draw Screw Holes

**Tool:** Circle tool (press `C` or use toolbar)

**For each screw hole:**
1. Click on PCB image at screw hole location
2. Drag to create circle
3. Hold **Ctrl** while dragging to make perfect circle
4. After creation:
   - Right-click circle → Fill and Stroke
   - Set **Fill:** None
   - Set **Stroke:** 0.5mm black line (for visibility in DXF)

**Diameter:** 2.2mm (radius 1.1mm)
- If using radius input: type `1.1`
- If using diameter: type `2.2`

**Count:** Should have ~11 screw holes total

---

## STEP 4: Verify Placement

- [ ] All 11 screw holes visible
- [ ] Holes not overlapping switch cutouts
- [ ] Holes roughly in corners/edges of plate
- [ ] Holes inside plate perimeter (not off-page)

---

## STEP 5: Export to DXF

1. File → Save As → `96_PLATE_v10_FINAL.svg` (save working copy first)
2. File → Export As
3. Format: **DXF R14** (AutoCAD 2000)
4. Filename: `96_PLATE_v10_FINAL.dxf`
5. Click Export
6. In DXF export dialog:
   - Uncheck "Optimize output for Corel"
   - Units: **Millimeters**
   - Click OK

---

## RESULT

DXF now contains:
- 101 switch cutouts (14mm × 14mm)
- ~11 screw holes (2.2mm diameter)
- Plate outline

Ready for manufacturing.

---

## TROUBLESHOOTING

**Holes too small/large?**
- Zoom in, select circle, adjust radius via Object → Fill and Stroke → Dimensions tab

**Holes overlapping switches?**
- Select hole, use arrow keys to nudge position (1mm increments)

**Can't see PCB reference?**
- Check Layers panel — reference image layer might be hidden
- Adjust opacity: select layer, change opacity slider

**DXF export missing holes?**
- Confirm circles have **stroke** (not just fill)
- Verify circles are on the same layer as plate geometry
