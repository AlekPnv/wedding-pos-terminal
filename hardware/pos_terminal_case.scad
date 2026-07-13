// ═══════════════════════════════════════════════════════
//  POS Terminal Enclosure  v3  (with engravings)
//
//  Internal space verified against:
//    Pi Zero WH      65 × 30 × 13mm (PCB + header)
//    RC522 module    60 × 39 × 10mm
//    OLED module     27 × 28 ×  5mm
//    Buzzer module   33 × 13 ×  9mm
//    Jumper wires    20cm folded — ~15mm clearance provided
//
//  THREE PARTS — export each separately as STL:
//    1. main_shell
//    2. back_lid
//    3. button_cap  (×3, change LABEL each time)
//
//  Print: Black PLA, 0.2mm layers, 3 walls, 20% infill
//  Orientation: face-down on print bed
// ═══════════════════════════════════════════════════════

$fn = 64;

// ── Walls & corners ───────────────────────────────────
T  = 2.2;    // wall thickness (mm)
R  = 6;      // outer corner radius

// ── Outer shell ───────────────────────────────────────
SW = 85;     // width
SH = 120;    // height
SD = 35;     // depth (front → back)

// ── OLED window (upper third, front face) ─────────────
OW = 26;
OH = 14;
OX = (SW - OW) / 2;    // centred = 29.5
OY = SH - 32;           // bottom of window at 88mm from base

// ── Button holes (lower third, front face) ────────────
BD  = 7.5;              // diameter
BY  = 20;               // centre Y from base
BXS = 22;               // spacing between centres

// ── USB slot (bottom face) ────────────────────────────
UW = 13;
UH = 10;

// ── RFID zone geometry (front face, mid section) ──────
RFX  = SW / 2;           // centre X
RFY  = 54;               // centre Y — shifted down to sit mid-face
RFW  = SW - 2*T - 10;    // zone width
RFH  = SH * 0.26;        // zone height ≈ 31mm

// ── Engraving depth ───────────────────────────────────
ENG  = 0.5;              // how deep engravings cut (mm)

// ═══════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════

module rrect(w, h, d, r) {
    hull() {
        for (x = [r, w - r])
            for (y = [r, h - r])
                translate([x, y, 0])
                    cylinder(r=r, h=d);
    }
}

module nfc_arc(r_in, r_out, h) {
    linear_extrude(h)
        difference() {
            intersection() {
                circle(r_out);
                translate([0, -r_out])
                    square([r_out, r_out * 2]);
            }
            circle(r_in);
        }
}

module nfc_symbol(h = ENG + 0.1) {
    linear_extrude(h) circle(d=2.0);
    nfc_arc(3.2,  4.6,  h);
    nfc_arc(5.8,  7.2,  h);
    nfc_arc(8.4,  9.8,  h);
}

// ═══════════════════════════════════════════════════════
//  PART 1 — MAIN SHELL
// ═══════════════════════════════════════════════════════
module main_shell() {
    difference() {
        rrect(SW, SH, SD, R);
        translate([T, T, T])
            rrect(SW - 2*T, SH - 2*T, SD + 1, R - T + 0.5);
        translate([OX, OY, -0.1])
            cube([OW, OH, T + 0.2]);
        for (i = [-1, 0, 1])
            translate([SW/2 + i*BXS, BY, -0.1])
                cylinder(d=BD, h=T + 0.2);
        translate([(SW - UW)/2, -0.1, SD/2 - UH/2])
            cube([UW, T + 0.2, UH]);
        for (i = [0:3])
            translate([SW - T - 0.1, SH*0.55 + i*5.5, SD/2 - 4])
                cube([T + 0.2, 2.5, 6]);
        translate([RFX, RFY + 2, -0.1])
            mirror([1, 0, 0])
                rotate([0, 0, 90])
                    nfc_symbol();
        translate([RFX, RFY - 10, -0.1])
            linear_extrude(ENG + 0.1)
                mirror([1, 0, 0])
                    text("TAP CARD HERE",
                         size   = 4.2,
                         halign = "center",
                         valign = "center",
                         font   = "Liberation Sans:style=Bold");
        translate([RFX - RFW/2, RFY - RFH/2, -0.1]) {
            difference() {
                cube([RFW, RFH, ENG + 0.1]);
                translate([1.2, 1.2, -0.1])
                    cube([RFW - 2.4, RFH - 2.4, ENG + 0.3]);
            }
        }
    }
}

// ═══════════════════════════════════════════════════════
//  PART 2 — BACK LID
// ═══════════════════════════════════════════════════════
module back_lid() {
    LT = T + 1;
    difference() {
        rrect(SW - 0.4, SH - 0.4, LT, R - 0.2);
        translate([(SW - 20)/2, SH/2 - 5, -0.1])
            cube([20, 10, LT + 0.2]);
    }
}

// ═══════════════════════════════════════════════════════
//  PART 3 — BUTTON CAP
//  Print 3×. Change LABEL each time: "X"  "OK"  "R"
// ═══════════════════════════════════════════════════════
LABEL = "X";

module button_cap() {
    difference() {
        union() {
            cylinder(d=9.5, h=2.8);
            translate([0, 0, -4.2])
                cylinder(d=6.8, h=4.3);
        }
        translate([0, 0, 1.6])
            linear_extrude(1.6)
                text(LABEL,
                     size   = 3.8,
                     halign = "center",
                     valign = "center",
                     font   = "Liberation Sans:style=Bold");
    }
}

main_shell();
// back_lid();
// button_cap();
