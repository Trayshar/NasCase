// Parametric Mini-ITX Case
// https://github.com/eclecticc/ParametricCase
//
// BSD 2-Clause License
// Copyright (c) 2018, Nirav Patel, http://eclecti.cc
//
// Motherboard modules

include <defaults.scad>;
include <pcie.scad>;

// Base PCB dimensions
miniitx = [170, 170, pcb_thickness];

// Motherboard mounting hold diameter and offsets (relative to hole c)
miniitx_hole = 3.96;
miniitx_hole_c = [10.16, 6.35];
miniitx_hole_f = [22.86, 157.48];
miniitx_hole_h = [154.94, 0];
miniitx_hole_j = [154.94, 157.48];

// Keepouts on top and bottom of board
miniitx_bottom_keepout = 0.25 * 25.4;

// AM4 Socket specs
am4_holes = [80, 95, 54, 90]; // Center not measured
am4_socket = [40, 40, 7.35]; // Not measured

// Offset from origin corner of motherboard to the base of the PCI-e card
pci_e_offset = [42.2 + 14.5, 4 + 7.5/2, 114.55-111.15+miniitx[2]];

module motherboard_miniitx(show_keepouts, socket_holes, socket, pcie_width=16) {
    area_a_keepout = [27, 15, 170-27-30, 170-15, 57];
    area_b_keepout = [0, 0, 170, 15, 16];
    area_c_keepout = [170-30, 15, 30, 170-15, 38];
    area_d_keepout = [0, 15, 27, 170-15, 39];
    $fn = 20;
    
    difference() {
        union() {
            // The PCB
            color("Green", 1.0) {
                cube(miniitx);
            }
            translate([socket_holes[0]-socket[0]/2, socket_holes[1]-socket[1]/2, miniitx[2]]) {
                color("OldLace", 1.0) {
                    cube(socket);
                }
            }
        }
        
        // Mounting holes for the motherboard
        translate([miniitx_hole_c[0], miniitx_hole_c[1], -extra/2]) {
            cylinder(r = miniitx_hole/2, h = miniitx[2]+extra);
            for (hole = [miniitx_hole_f, miniitx_hole_h, miniitx_hole_j]) {
                translate([hole[0], hole[1], 0]) cylinder(r = miniitx_hole/2, h = miniitx[2]+extra);
            }
        }
        
        // Mounting holes for the CPU cooler
        translate([socket_holes[0], socket_holes[1], -extra/2]) {
            for (i = [-socket_holes[2]/2, socket_holes[2]/2]) {
                for (j = [-socket_holes[3]/2, socket_holes[3]/2]) {
                    translate([i, j, 0]) cylinder(r = miniitx_hole/2, h = miniitx[2]+extra);
                }
            }
        }
    }
    
    // PCI-e slot
    color("DarkSlateGray", 1.0) {
        translate([pci_e_offset[0], pci_e_offset[1], miniitx[2]]) pcie_slot_x(pcie_width);
    }

    // IO Panel
    color("Gray", 1.0) {
        translate([0, 15, miniitx[2]]) cube([35, 150, 27]);
    }

    // RAM
    color("Black", 1.0) {
        translate([25, 150, miniitx[2]]) cube([143, 6, 45]);
    }
    
    // Keepouts for visualization purposes
    if (show_keepouts == true) {
         color("GreenYellow", 0.25) {
            translate([0, 0, -miniitx_bottom_keepout]) cube([miniitx[0], miniitx[1], miniitx_bottom_keepout]);
            
            for (keepout = [area_a_keepout, area_b_keepout, area_c_keepout, area_d_keepout]) {
                translate([keepout[0], keepout[1], miniitx[2]]) {
                    cube([keepout[2], keepout[3], keepout[4]]);
                }
            }
        }
    }
}

// The last part I got from testing. Altough 12.27 is in the spec, the IO shield is a bit to far away
motherboard_back_edge = miniitx_hole_c[0]-12.27+0.8;

// Magic numbers: See MiniITX.pdf
motherboard_back_panel_overhang = 158.75+7.52+6.35-miniitx[1];
motherboard_back_panel_lip = 2.54;
motherboard_back_panel_size = [158.75, 44.45];

module motherboard_back_panel_cutout() {
    // Cut-out for the back panel i/o
    translate([-extra/2+motherboard_back_edge-wall, miniitx_hole_c[1]+7.52, -2.24]) {
        translate([-10, 0, 0]) cube([extra/2+wall+motherboard_back_edge+40, motherboard_back_panel_size[0], motherboard_back_panel_size[1]]);
        // Thin a 2.54mm area around the i/o down to a typical sheet metal thickness
        translate([0, -motherboard_back_panel_lip, -motherboard_back_panel_lip]) cube([extra/2+wall-1.2, 158.75+motherboard_back_panel_lip*2, 44.45+motherboard_back_panel_lip*2]);
    }
}

// motherboard_miniitx(false, am4_holes, am4_socket);
// translate(pci_e_offset) {
//     pcie_card(pcb_length=72.5, pcb_height=50, low_profile=true, pcie_length=1, num_brackets=1);
// }

// % motherboard_back_panel_cutout();
