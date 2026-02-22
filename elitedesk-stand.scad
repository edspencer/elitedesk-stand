// =============================================
// HP EliteDesk Mini Triple Vertical Stand
// =============================================
//
// An arch-inspired stand holding 3 HP EliteDesk
// Mini PCs vertically for improved airflow.
// Inspired by BookArc-style laptop stands.
//
// Compatible with:
//   HP EliteDesk 800 G3/G4/G5/G6 Mini
//   HP ProDesk 600 G3/G4/G5/G6 Mini
//   HP ProDesk 400 G3/G4/G5/G6 Mini
//   (All share ~177 x 175 x 34mm dimensions)
//
// Orientation: PCs stand vertically in slots.
//   Front = power button side
//   Back  = ports side
//
// Print settings:
//   Orientation: flat base down (no supports needed)
//   Material:    PETG recommended (heat near PCs)
//   Infill:      20-30%, 3+ perimeters
//   Layer height: 0.2mm
// =============================================

$fn = 80;

// -----------------------------------------------
// PC DIMENSIONS (HP EliteDesk Mini)
// -----------------------------------------------
// Measured when PC is lying flat (horizontal):
//   Width  = 177mm (front/back face)
//   Depth  = 175mm (left/right face)
//   Height = 34mm  (thickness)
//
// When standing VERTICAL in the slot:
//   Slot width needed = 34mm + clearance
//   PC height above stand = 175mm - slot_depth
//   PC face (177mm) spans front-to-back

pc_thickness = 34;       // mm - case thickness (horizontal height)

// -----------------------------------------------
// SLOT CONFIGURATION
// -----------------------------------------------
clearance    = 2.5;      // mm per side (5mm total play)
slot_w       = pc_thickness + 2 * clearance;  // ~39mm
slot_depth   = 72;       // mm - how deep from top of stand
slot_r       = 4;        // mm - radius at slot bottom
num_slots    = 3;

// -----------------------------------------------
// WALL DIMENSIONS
// -----------------------------------------------
inner_wall   = 7;        // mm - wall between adjacent slots
outer_wall   = 8;        // mm - outer wall on each side

// Derived total width across all slots
total_w = 2 * outer_wall + num_slots * slot_w + (num_slots - 1) * inner_wall;

// -----------------------------------------------
// OVERALL STAND SHAPE
// -----------------------------------------------
stand_d      = 100;      // mm - front-to-back depth
stand_h      = 85;       // mm - total height
base_flare   = 10;       // mm - extra base width per side (stability)
base_h       = 5;        // mm - base plate thickness
base_r       = 4;        // mm - base corner rounding

// Arch taper: top is narrower front-to-back than base
top_inset    = 14;       // mm - per side depth reduction at top
top_r        = 12;       // mm - top edge rounding radius

// -----------------------------------------------
// RUBBER FEET
// -----------------------------------------------
pad_d        = 10;       // mm - pad recess diameter
pad_h        = 1.5;      // mm - pad recess depth

// ===============================================
// MODULES
// ===============================================

// Rounded rectangular slab (used as hull primitives)
//   w = x-width, d = y-depth, h = z-height, r = corner radius
module rounded_slab(w, d, h, r) {
    rr = min(r, min(w/2, min(d/2, h)));
    hull() {
        for (x = [rr, w - rr])
            for (y = [rr, d - rr])
                translate([x, y, 0])
                    cylinder(r = rr, h = h);
    }
}

// -----------------------------------------------
// MAIN BODY - arch/dome taper shape
// -----------------------------------------------
// Hull of a wide flat base slab and a narrower
// rounded top slab creates the arch profile.
// Viewed from the side, the body tapers inward
// toward the top with smooth rounded edges.
module body() {
    hull() {
        // Base: wide, flat, stable
        translate([-base_flare, 0, 0])
            rounded_slab(
                total_w + 2 * base_flare,
                stand_d,
                base_h,
                base_r
            );

        // Top: narrower depth, generously rounded
        translate([0, top_inset, stand_h - top_r * 2])
            rounded_slab(
                total_w,
                stand_d - 2 * top_inset,
                top_r * 2,
                top_r
            );
    }
}

// -----------------------------------------------
// SLOT CUTOUTS
// -----------------------------------------------
// Each slot is a vertical channel cut from the top,
// open front and back for airflow/cable access.
// Bottom of each slot has a rounded U-shape for
// the PC to rest on.
module slots() {
    for (i = [0 : num_slots - 1]) {
        x = outer_wall + i * (slot_w + inner_wall);

        // Upper rectangular portion of slot
        translate([x, -1, stand_h - slot_depth + slot_r])
            cube([slot_w, stand_d + 2, slot_depth - slot_r + 1]);

        // Rounded bottom of slot (hull of two cylinders)
        hull() {
            translate([x + slot_r, -1, stand_h - slot_depth + slot_r])
                rotate([-90, 0, 0])
                    cylinder(r = slot_r, h = stand_d + 2);
            translate([x + slot_w - slot_r, -1, stand_h - slot_depth + slot_r])
                rotate([-90, 0, 0])
                    cylinder(r = slot_r, h = stand_d + 2);
        }
    }
}

// -----------------------------------------------
// RUBBER FOOT RECESSES
// -----------------------------------------------
// Four recesses on the bottom for adhesive rubber
// pads (anti-slip, protects desk surface).
module feet() {
    inset_x = 18;
    inset_y = 18;
    for (x = [-base_flare + inset_x, total_w + base_flare - inset_x])
        for (y = [inset_y, stand_d - inset_y])
            translate([x, y, -0.01])
                cylinder(d = pad_d, h = pad_h + 0.01);
}

// ===============================================
// FINAL ASSEMBLY
// ===============================================
difference() {
    body();
    slots();
    feet();
}

// ===============================================
// DIMENSION REPORT
// ===============================================
echo(str(""));
echo(str("=== EliteDesk Triple Stand ==="));
echo(str("Width:      ", total_w, " mm  (",
    round(total_w / 25.4 * 10) / 10, " in)"));
echo(str("  w/ flare: ", total_w + 2 * base_flare, " mm  (",
    round((total_w + 2 * base_flare) / 25.4 * 10) / 10, " in)"));
echo(str("Depth:      ", stand_d, " mm  (",
    round(stand_d / 25.4 * 10) / 10, " in)"));
echo(str("Height:     ", stand_h, " mm  (",
    round(stand_h / 25.4 * 10) / 10, " in)"));
echo(str("Slot width: ", slot_w, " mm  (PC + ",
    2 * clearance, "mm play)"));
echo(str("Slot depth: ", slot_depth, " mm"));
echo(str("PC extends: ~103 mm above stand"));
echo(str(""));
