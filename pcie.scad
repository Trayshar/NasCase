// Parametric Mini-ITX Case
// https://github.com/eclecticc/ParametricCase
//
// BSD 2-Clause License
// Copyright (c) 2024, Trayshar
//
// PCIe slot, bracket and card with support for low profile

include <defaults.scad>;


// Taken from the specs, figure 6-1: 'Connector Width', 'Dim A', 'Dim B'
_connector_width_data = [
        [1, 7.65, 25],
        [4, 21.65, 39],
        [8, 38.65, 56],
        [16, 71.65, 89]
    ];

// Centered on the middle between the two contacts
module pcie_slot_x(connector_width) {
    data = _connector_width_data[search(connector_width, _connector_width_data, 1, 0)[0]];
    // 14.50 (length of Datum A)
    translate([-14.5, -7.5/2, 0]) difference() {
        cube([data[2], 7.5, 11.25]);
        translate([1.9,       (7.5-pcb_thickness)/2, 3.4]) cube([11.65,   pcb_thickness, 12]);
        translate([14.5+0.95, (7.5-pcb_thickness)/2, 3.4]) cube([data[1], pcb_thickness, 12]);
    }
}

// Taken from the specs, figure 6-3: 'Connector Width', 'Dim B'
_connector_width_data_3 = [
        [1, 8.15],
        [4, 22.15],
        [8, 39.15],
        [16, 72.15]
    ];

// Centered on the middle between the two contacts
module pcie_card(pcb_length, pcb_height, pcie_length=1, num_brackets=1, low_profile=false) {
    contact_len = _connector_width_data_3[search(pcie_length, _connector_width_data_3, 1, 0)[0]][1];

    // PCIe Contact
    color("gold") {
        // Front contact
        translate([-12.15, -pcb_thickness/2, 0]) cube([12.15      -0.95, pcb_thickness, 4]);
        // Main contact
        translate([  0.95, -pcb_thickness/2, 0]) cube([contact_len-0.95, pcb_thickness, 4]);
    }

    // PCB. Magic numbers see Figure 9-3.
    color("green") {
        translate([-57.15, -pcb_thickness/2, 4]) cube([pcb_length, pcb_thickness, pcb_height]);
        // TODO: Add cutouts
    }
    
    // PCI bracket. Magic numbers see Figure 9-3 and Figure 9-6.
    bracket_x = low_profile ? 65.4  : 64.13;
    bracket_y = low_profile ? 14.71 + pcb_thickness/2 : -2.84 + pcb_thickness/2;
    bracket_z = low_profile ? 68.09 : 104.86;
    translate([-bracket_x, -bracket_y, bracket_z]) color("DarkGray", 1.0) {
        for (i = [0:num_brackets-1]) {
            // Magic number: See https://www.overclock.net/threads/guide-to-drawing-pci-e-and-atx-mitx-rear-io-bracket-for-a-custom-case.1589018/
            translate([0, -20.32*i, 0]) pcie_bracket(low_profile);
        }
    }
}

// Mounted at the screw on the top
// Magic values: See figure 9-5 and 9-9
module pcie_bracket(low_profile = false) {
    w_top = low_profile ? 11.84 : 11.43;
    l_top = low_profile ? 18.59 : 21.59-2.54;
    delta_hole_to_outside = low_profile ? -3.58-0.87 : -18.42+2.54;
    hole_cutin_offset = low_profile ? -10 : 0;
    diameter_hole = 4.42;
    difference() {
        $fn = 40;
        translate([-w_top/2, delta_hole_to_outside, -0.8/2]) cube([w_top, l_top, 0.8]);
        cylinder(h = 1, r = diameter_hole/2, center=true);
        translate([-diameter_hole/2, hole_cutin_offset, -0.5]) cube([diameter_hole, 10, 1]);
    }

    w_br = 18.42;
    h_br = low_profile ? 79.2 : 120.2;
    delta_side_w = 4.11;
    delta_side_h = 79.2 - 71.46;
    h_edge = 4.6; // Guessed cuz not specified?
    h_rotated_by_5 = 5;
    offset_hole_plate_y = low_profile ? -0.87 : -w_br;
    offset_hole_plate_x = low_profile ? -6.35 : -5.08;
    rotate([0, -90, 0]) translate([-h_br, offset_hole_plate_y, offset_hole_plate_x]) {
        linear_extrude(height = 0.8) polygon([
            [delta_side_h, delta_side_w],
            [h_rotated_by_5, delta_side_w],
            [h_rotated_by_5, w_br-delta_side_w],
            [delta_side_h, w_br-delta_side_w],
            [delta_side_h + h_edge, w_br],
            [h_br, w_br],
            [h_br, 0],
            [delta_side_h + h_edge, 0]
        ]);
        rotate([0, 5, 0]) translate([0, delta_side_w, 0.4325]) cube([h_rotated_by_5,w_br-2*delta_side_w, 0.8]);
    }
}

// pci_card(pcb_length=72.5, pcb_height=50);
