// ═══════════════════════════════════════════════════════
//  POS Terminal — Button Retainer Disc
//
//  Slides onto the post tip of each button cap from inside
//  the case. Glue it in place with superglue.
//
//  Why it works:
//    disc (10.5mm) > button hole (7.0mm)
//    → cap can no longer be pulled outward through the face
//    → also adds 2.5mm extra reach toward the tactile switch
//
//  Print: 3×  (all three are on the plate below)
//  Orientation: flat face DOWN, socket opening facing UP
//  No supports needed.
//  Colour: same as caps, or black — it's hidden inside anyway
// ═══════════════════════════════════════════════════════

$fn = 64;

module retainer_disc() {
    difference() {
        cylinder(d=10.5, h=2.5);
        translate([0, 0, 1.0])
            cylinder(d=7.1, h=1.6);
    }
}

retainer_disc();
translate([14, 0, 0]) retainer_disc();
translate([28, 0, 0]) retainer_disc();
