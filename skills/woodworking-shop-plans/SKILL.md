---
name: "woodworking-shop-plans"
description: "Turn a woodworking/jig/tool build into a printable shop-plan PDF in the Fine Woodworking + Guardian Woodworking style: a full multi-page set, or a one-sheet plan for simple jigs."
---

# Woodworking Shop Plans

Shop plans are for people CUTTING parts from rough stock, not assembling existing parts. So the job is: every part fully dimensioned, every hole located from a named edge with a drill size, and holes that must align are drilled to align (not measured separately). Model the look on Fine Woodworking articles (one exploded drawing + dimensioned orthographic views + detail circles) and Guardian Woodworking free plans (cut list with a drawing of each part, one step per page, new part highlighted, one or two sentences).

## Pick the format first

- **One-sheet plan ("oner")**: use when the build is simple, meaning about 8 parts or fewer, little or no threaded hardware, and steps that fit in a sentence or two each. Use it also whenever the user asks for one page, a oner, or something simple. See "One-sheet layout" below.
- **Full set**: use for builds with mechanisms, many holes, hardware runs, or more than about 8 steps. See "Page order" below.
- If the user calls the full set too much, switch to the one-sheet layout. Don't trim pages one at a time.

## Workflow

1. **Settle the design first.** Confirm every dimension, joint and fastener with the user before drawing. Keep the user's hardware purchases fixed; if a design change affects them, say so. When working from a video or photo, check frames before asserting how the original works, and ask about any mechanism you can't see clearly instead of inventing one.
2. **Build ONE 3D model** (a small Python dict of boxes, prisms and cylinders in inches: x along length, y depth with 0 = front/user side, z up). Beveled or roofed parts are prisms: a cross-section polygon extruded along x. Every drawing is generated from it, so numbers can't disagree between views.
3. **Render with a script**, not hand-placed SVG:
   - Axonometric view (front-right, ~0.94/-0.30 for x, 0.52/0.34 for y) with flat 3-tone shading per face (top lightest, front mid, side darkest), thin dark outlines.
   - Painter's ordering by pairwise separating-axis tests, then a depth tie-break.
   - Only draw the visible stubs of rods/bolts that pass through wood.
   - Auto-fit each view to its region.
   - Orthographic front/end/top views from the same model.
   - Build pages as SVG in HTML, print to PDF with Playwright/Chromium (letter portrait, 8.5x11, reads on a phone).
4. **Render to PNG and LOOK at every page** before sending. Fix overlaps, cut-off labels, labels on the wrong side of leaders, dims colliding with parts. Check the page count: a one-sheet plan must print as exactly 1 page; shrink drawing heights until it does. Iterate until clean.

## One-sheet layout

One letter page, everything on it, no step-per-page:
1. Header: project name, short subtitle.
2. Top band: assembled 3D view with overall dims and letter tags (left, large). On the right, a small exploded inset for the one joint or mechanism that needs explaining, plus a 1-2 sentence "how it works" tip box.
3. Middle band: dimensioned end/section view and dimensioned top view, side by side.
4. Lower band: cut list (letter, part, T x W x L, stock) and a sizes/settings table if the jig has settings (left); hardware list and numbered "Use" steps (right).
5. Bottom: "Build" as one numbered list in two columns, one or two sentences per step.
6. Footer: project name, 'dimensions in inches', thread spec or 'no threaded hardware', 'Page 1 of 1'.
Skip the separate cover, bits page, tools page and per-part shop drawings; put any hole location the builder needs into a build step or a dimension on the views.

## Page order (full set)

1. Cover: assembled 3D view with overall dims, 'at a glance' specs, wood to buy, tools checklist.
2. Exploded view: parts pulled apart along their assembly axis, circled LETTER tags for wood parts, black-square NUMBER tags for hardware, and a parts table (part, name, qty, T x W x L). Do not float long text labels around the drawing; use tags + table.
3. Front / end / top views, dimensioned (overall, key heights like center height, gaps).
4. Cut list with a small 3D drawing of every part + board layouts showing which piece comes from which stock (8-ft 2x4, 4x4, 1x4...) with saw-kerf allowance and dashed rip lines.
5. Hardware: drawing of each item, quantity, size, example store model # labeled 'any brand works', plus a cut chart if rod is cut from one stick.
6. Drill bits & tools: icon per bit, size, type, what it drills, a tip; then other tools with icons.
7+. Shop drawings: flat 2D drawing per machined part, every hole located from the bottom/left edge, diameter with the symbol (Ø), depth or 'thru', hidden lines dashed, which step drills it.
Steps: 'STEP n' header, 1-3 sentences, one big drawing with the NEW parts in yellow, zoom circles or section views only where it's tight; extra notes go at the top so they never collide with the drawing.
Last: every-session checklist + safety box.

## Drafting conventions

- Imperial fractions (3/4, 1-1/2), never decimals or mm. Round to the nearest 1/32 or 1/16, never limit_denominator to odd fractions. Sizes as thickness x width x length.
- Footer on every page: project name, 'dimensions in inches', thread spec, page number.
- Dimension lines with arrowheads, extension lines, text on a white knockout. Vertical dims keep text horizontal. Stagger stacked dims far enough apart that their text can't overlap.
- Letters for wood parts, numbers for hardware, used identically on every page or view.
- Muted wood palette, one accent color (orange) for arrows/cord/highlights, yellow for 'new in this step' or the part being called out.

## Best-practice build rules (general, not user-specific)

- **Simplest thing that works.** Prefer geometry, stops, wedges and drop-in spacers over bolts, slots and threaded hardware. Offer the simpler option when a mechanism adds parts without adding function.
- **Standard tools only.** Design so every hole fits a jobber-length bit (a 1/16-1/2 set covers twist sizes; spade bits for 3/4 and up; Forstner listed as an option). Never require extra-long bits; split deep holes from both faces.
- **Start holes with an awl or center punch** dimple; no pilot holes needed in wood for rod-clearance holes.
- **Clearance holes are one size up** from the rod or bolt (3/8 rod gets a 7/16 hole), or it jams.
- **Coordinate holes:**
  - Drill mating parts together (clamp two rails face to face, one pass).
  - Drill glued-up assemblies through the existing holes so the bit is guided.
  - Mark centers with the mechanism itself (e.g. crank the tailstock point into the headstock to dimple it).
  - Add a check step (points meet tip to tip).
- Prefer self-countersinking construction screws over requiring a countersink bit; 1/8 pilot only near board ends.
- Keep one thread spec throughout where possible and say it everywhere; warn about fine-thread lookalikes.
- Prefer threaded rod cut to length over long bolts where the head can't fit; show a cut chart and the 'spin a nut on before cutting' tip.
- Wood stock: 4 ft of 1x4 rather than 3 ft when kerfs push it over.
- Give the drawing tools/process to make plans readable before drawing: users are visual; every new idea gets a picture. When the user doesn't recognize a term, show a drawing of it instead of describing it again.

## Delivering

Send the PDF as a file. In the reply, list what changed in a few bullets and flag anything that affects parts the user already bought. Don't recap the drawing process.