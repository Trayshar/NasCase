// Parametric Mini-ITX Case
// https://github.com/eclecticc/ParametricCase
//
// BSD 2-Clause License
// Copyright (c) 2024, Trayshar
//
// 3.5' HDD according to SFF-8301

// See Table 3-1 in SFF-8301, at https://members.snia.org/document/dl/25862
hdd_a1  =  26.10 + 0;
hdd_a2  = 147.00 + 0;
hdd_a3  = 101.60 + 0;
hdd_a4  =  95.25 + 0;
hdd_a5  =   3.18 + 0;
hdd_a6  =  44.45 + 0;
hdd_a7  =  41.28 + 0;
hdd_a8  =  28.50 + 0;
hdd_a9  = 101.60 + 0;
hdd_a10 =   6.35 + 0;
hdd_a13 =  76.20 + 0;

// SFF-8301 doesn't clearly specify this, but I do not rely on these values being exact
thread_diameter = 4;
thread_depth = 6;

hdd_h = hdd_a1 + 0.25;
hdd_w = hdd_a3 + 0.25;
hdd_l = hdd_a2 + 0.25;

module hdd_3_5_inch() {
    tolerance = 0.25;
    difference() {
        union() {
            connector_x = 70;
            connector_y = 10;
            connector_z = 9;
            color("Silver") translate([0, 0, connector_z]) cube([ hdd_w, hdd_l, hdd_h - connector_z]);
            color("Silver") translate([0, connector_y, 0]) cube([ hdd_w, hdd_l - connector_y, hdd_h]);
            color("DarkSlateGray") cube([ connector_x + tolerance, connector_y + tolerance, connector_z + tolerance]);
        }
        hdd_3_5_inch_vertical_cutout(tolerance);
        hdd_3_5_inch_bottom_cutout(tolerance);
    }
}

module hdd_3_5_inch_vertical_cutout(tolerance = 0.25) {
    $fn = 16;
    for (x = [0-tolerance, hdd_a3+tolerance]) {
        translate([x, hdd_a8, hdd_a10]) {
            rotate([0, 90, 0]) cylinder(thread_depth+tolerance, thread_diameter/2, thread_diameter/2, center=true);
            translate([0, hdd_a9, 0]) rotate([0, 90, 0]) cylinder(thread_depth+tolerance, thread_diameter/2, thread_diameter/2, center=true);
        }
    }
}

module hdd_3_5_inch_bottom_cutout(tolerance = 0.25) {
    $fn = 16;
    for (x = [hdd_a5, hdd_a3-hdd_a5]) {
        translate([x, hdd_a7, tolerance]) {
            cylinder(thread_depth+tolerance, thread_diameter/2, thread_diameter/2, center=true);
            translate([0, hdd_a6, 0]) cylinder(thread_depth+tolerance, thread_diameter/2, thread_diameter/2, center=true);
            translate([0, hdd_a13, 0]) cylinder(thread_depth+tolerance, thread_diameter/2, thread_diameter/2, center=true);
        }
    }
}


// hdd_3_5_inch();