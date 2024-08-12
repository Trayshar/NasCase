// Parametric Mini-ITX Case
// https://github.com/eclecticc/ParametricCase
//
// BSD 2-Clause License
// Copyright (c) 2024, Trayshar
//
// Custom-build NAS case for my specific requirements - Change stuff on your own risk!

include <defaults.scad>;
include <fan.scad>;
include <heatsink.scad>;
include <pcie.scad>;
include <motherboard.scad>;
include <hdd.scad>;
use <honeycomb.scad>;
use <screw.scad>;

// Screws I have laying around
screw_UNC_6_32 = [8.3/2, 3.2, 3.51/2, 6.4];
screw_M3_silver = [3, 2, 1.5, 4];
screw_M3_black = [7/2, 1.6, 1.5, 5];
screw_M3_long = [3, 2, 1.5, 10];
screw_Fan = [5.5/2, 0.25, 3/2, 8, 5.5/2, 1.5];
screw_Plasfast = [5.6/2, 2.1, 3/2*0.86, 10, 3/2+0.1, 2];

// The vibration dampeners I have left from some other project
module hdd_dampeners(height=8, diameter=8) {
    color("Black") cylinder(height, diameter/2, diameter/2);
}

module nas(case_parts=true, show_components=false, render_screws=false, show_debug=false) {
    render_parts = is_string(case_parts) ? case_parts : "abcdefghijklmnop";

    // Config. Change these if you want.
    hdd_dampener_height = 8;
    hdd_dampener_diameter = 8;
    hdd_dampener_thread_depth = 2.9;
    fan_definition = [80, 25, 9];

    hdd_dampener_screw = screw_M3_black;

    // Additional space in the direction perpendicular to the PCIe slot
    cf_space_right = 16;
    // Additional space in the direction where the front fans are
    cf_space_front = 0; // TODO: Split into
    // Distance between end of the mainboard and the fans
    cf_clearance_fans_mb = 3;
    // Distance between end of the mainboard and the side HDD
    cf_clearance_hdd_a_mb = 3;
    // Distance between the case and the side HDD
    cf_clearance_hdd_a_case = 3;
    // Offset along the back-front-axis of the side HDD
    cf_offset_hdd_a = 12;
    // Horizontal position of the top HDD
    cf_offset_hdd_b = (miniitx[1]-hdd_w)/2;
    // Offset of the back plate relative to the mainboard IO position
    cf_offset_back = 1;
    // Additional thickness of the back plate part
    cf_thickness_back = 0;
    // Thickness of HDD A bracket. 1.8mm base thichness + height of dampener screw head
    cf_thickness_hdd_a_bracket = 1.8 + hdd_dampener_screw[1];
    // HDD A Bottom side holes that are actually there. See hdd.scad for where those are.
    cf_holes_hdd_a = [0, 1, 3, 4];
    // X,Y offset of the HDD A Dampener holes used. Positive means outwards, negative means inwards.
    cf_holes_hdd_a_offsets = [-10, -2];

    // Derived automatically. DO NOT CHANGE!
    case_origin = [
        motherboard_back_edge + cf_offset_back  - wall, // the back side, so it's just the space to the cutout. Ignoring additional thickness so it goes inwards
        -cf_space_right         - wall, // Just our custom offset to the right
        -miniitx_bottom_keepout - wall  // Respect mainboard keepout area
    ];
    case_size = [
        // Sum over distances, from back to front:
        // back-to-mainboard, mainboard, fan clearance, fan width, front clearence 
        abs(motherboard_back_edge+cf_offset_back)+miniitx[0]+cf_clearance_fans_mb+fan_definition[1]+cf_space_front + 2*wall,
        // Space for LAN-card, mainboard, clearance for HDD, HDD, Dampeners for HDD
        cf_space_right+miniitx[1]+cf_clearance_hdd_a_mb+hdd_h+hdd_dampener_height+cf_thickness_hdd_a_bracket + 2*wall, 
        // Just the clearance+width of the vertical-mounted HDD on the side
        2*cf_clearance_hdd_a_case + hdd_w + 2*wall
    ];
    echo(str("Case Size: ", case_size));


    // Derived positions of all components. DO NOT CHANGE
    lan_card_location = [pci_e_offset[0],  pci_e_offset[1],    pci_e_offset[2]+miniitx[2]];
    hdd_a_location = [miniitx[0]-hdd_l+cf_offset_hdd_a, hdd_h+miniitx[1]+cf_clearance_hdd_a_mb, hdd_w-(miniitx_bottom_keepout-cf_clearance_hdd_a_case)];
    hdd_b_location = [miniitx[0]-hdd_l, hdd_w+cf_offset_hdd_b,                  hdd_w-(miniitx_bottom_keepout-cf_clearance_hdd_a_case)-hdd_h];
    fan_front_a_location = [miniitx[0]+cf_clearance_fans_mb, 40,            case_size[2]/2+case_origin[2]];
    fan_front_b_location = [miniitx[0]+cf_clearance_fans_mb, miniitx[1]-40, case_size[2]/2+case_origin[2]];
    length_ab = 210;
    length_c = 10;
    wall_b = wall+cf_thickness_back;
    hdd_a_dampener_locations = [
        for (i = cf_holes_hdd_a) [ 
            hdd_3_5_inch_bottom_thread_pos[i].x + sign(hdd_3_5_inch_bottom_thread_pos[i].x-50) * cf_holes_hdd_a_offsets[0], 
            hdd_3_5_inch_bottom_thread_pos[i].y + sign(hdd_3_5_inch_bottom_thread_pos[i].y-50) * cf_holes_hdd_a_offsets[1], 
            hdd_3_5_inch_bottom_thread_pos[i].z
        ]
    ];
    size_i = [0.75*cf_space_right, 0.75*cf_space_right];
    wall_i = wall*0.75;

    // Define case screw locations
    screw_offset_b = 8;
    screw_offset_d_x = 10;
    screw_offset_d_z = 16;
    screw_depth = wall/2;
    // Chassis screws. 
    screws = [ // x, y, z, orientation, type, components_involved.  XYZ are always relative to the case origin!
        // Bottom (part a): Mainboard Screws
        [miniitx_mounting_holes[0] + [0,0,pcb_thickness] - case_origin, [0, 180, 0], screw_M3_black, "a"],
        [miniitx_mounting_holes[1] + [0,0,pcb_thickness] - case_origin, [0, 180, 0], screw_M3_black, "a"],
        [miniitx_mounting_holes[2] + [0,0,pcb_thickness] - case_origin, [0, 180, 0], screw_M3_black, "a"],
        [miniitx_mounting_holes[3] + [0,0,pcb_thickness] - case_origin, [0, 180, 0], screw_M3_black, "a"],
        // Back (part b): Screws
        [[wall_b-screw_depth, screw_offset_b,            screw_offset_b],               [0, 90, 0], screw_M3_long, "ab"],
        [[wall_b-screw_depth, screw_offset_b,            -screw_offset_b+case_size[2]], [0, 90, 0], screw_M3_long, "bd"],
        [[wall_b-screw_depth, -screw_offset_b+length_ab, screw_offset_b],               [0, 90, 0], screw_M3_long, "ab"],
        [[wall_b-screw_depth, -screw_offset_b+length_ab, -screw_offset_b+case_size[2]], [0, 90, 0], screw_M3_long, "bd"],
        // Back (part b): Screw above IO Shield
        [[wall_b-screw_depth, length_ab/2,               -screw_offset_b+case_size[2]], [0, 90, 0], screw_M3_long, "bd"],
        // Left (part c): Screws
        [[-screw_offset_d_x+case_size[0], length_ab+screw_M3_long[3]/2, screw_offset_d_z],               [90, 0, 0], screw_M3_long, "ac"],
        [[screw_offset_d_x,               length_ab+screw_M3_long[3]/2, screw_offset_d_z],               [90, 0, 0], screw_M3_long, "ac"],
        [[-screw_offset_d_x+case_size[0], length_ab+screw_M3_long[3]/2, -screw_offset_d_z+case_size[2]], [90, 0, 0], screw_M3_long, "cd"],
        [[screw_offset_d_x,               length_ab+screw_M3_long[3]/2, -screw_offset_d_z+case_size[2]], [90, 0, 0], screw_M3_long, "cd"],
        // Front (part i): Connections to right (part g)
        [[case_size[0]-wall-size_i[0]+screw_M3_long[3]/2, wall+size_i[1]/2, case_size[2]/2], [0, 270, 0], screw_M3_long, "ig"],
        // Front (part i): Connections to left (part c)
        [[case_size[0]-wall-size_i[0]+screw_M3_long[3]/2, length_ab-length_c/2, case_size[2]/2], [0, 270, 0], screw_M3_long, "ic"],
        // Front (part i): Fan screws
        [fan_front_a_location - case_origin + [fan_definition[1]+wall_i, hole_spacing(80)/2,   hole_spacing(80)/2], [0, 270, 0], screw_Fan, "i"],
        [fan_front_a_location - case_origin + [fan_definition[1]+wall_i, -hole_spacing(80)/2,  hole_spacing(80)/2], [0, 270, 0], screw_Fan, "i"],
        [fan_front_a_location - case_origin + [fan_definition[1]+wall_i, hole_spacing(80)/2,  -hole_spacing(80)/2], [0, 270, 0], screw_Fan, "i"],
        [fan_front_a_location - case_origin + [fan_definition[1]+wall_i, -hole_spacing(80)/2, -hole_spacing(80)/2], [0, 270, 0], screw_Fan, "i"],
        [fan_front_b_location - case_origin + [fan_definition[1]+wall_i, hole_spacing(80)/2,   hole_spacing(80)/2], [0, 270, 0], screw_Fan, "i"],
        [fan_front_b_location - case_origin + [fan_definition[1]+wall_i, -hole_spacing(80)/2,  hole_spacing(80)/2], [0, 270, 0], screw_Fan, "i"],
        [fan_front_b_location - case_origin + [fan_definition[1]+wall_i, hole_spacing(80)/2,  -hole_spacing(80)/2], [0, 270, 0], screw_Fan, "i"],
        [fan_front_b_location - case_origin + [fan_definition[1]+wall_i, -hole_spacing(80)/2, -hole_spacing(80)/2], [0, 270, 0], screw_Fan, "i"],
    ];

    module impl_screw_cutouts(part) {
        for (screw_ = screws) {
            if (search(part, screw_[3])) translate(screw_[0]+case_origin) rotate(screw_[1]) screw_cutout(screw_[2]);
        }
    }

    if(render_screws) {
        for (screw_ = screws) {
            translate(screw_[0]+case_origin) rotate(screw_[1]) screw(screw_[2]);
        }
    }

    // Debug stuff
    if (show_debug) {
        for(x = [0, case_size[0]]) for(y = [0, case_size[1]]) for(z = [0, case_size[2]]) {
            // Debug: Mark case vertices
            translate(case_origin) translate([x,y,z]) #sphere(2);
        }
        // Debug: Show motherboard cutouts
        motherboard_miniitx_keepouts();
    }

    if (show_components) {
        // TODO: I don't have an AM4 system, set correct values
        motherboard_miniitx(false, am4_holes, am4_socket, 4);

        // Heatsink
        translate([64+60/2, 60+71/2, 5+miniitx[2]]) heatsink([60, 71, 20], 3, 15);

        // LAN card
        translate(lan_card_location) pcie_card(pcb_length = 72.5, pcb_height = 50, low_profile=true);

        // HDD at the side
        translate(hdd_a_location) rotate([0,90,-90]) {
            hdd_3_5_inch();
            for (i = cf_holes_hdd_a) {
                translate(hdd_3_5_inch_bottom_thread_pos[i] - [0,0,cf_thickness_hdd_a_bracket/2]) screw(screw_UNC_6_32);
            }
            for (pos = hdd_a_dampener_locations) {
                // Dampeners
                translate(pos - [0,0,cf_thickness_hdd_a_bracket+hdd_dampener_height]) hdd_dampeners(hdd_dampener_height, hdd_dampener_diameter);
                // Screw with the chassis
                translate(pos - [0,0,cf_thickness_hdd_a_bracket+hdd_dampener_height+(hdd_dampener_screw[3]-hdd_dampener_thread_depth)]) screw(hdd_dampener_screw);
                // Screw with the mounting bracket
                translate(pos - [0,0,hdd_dampener_screw[1]]) rotate([180, 0, 0]) screw(hdd_dampener_screw);
            }
        }
        
        // HDD at the top
        translate(hdd_b_location) rotate([0,0,-90]) {
            hdd_3_5_inch();
            for (pos = hdd_3_5_inch_vertical_thread_pos) {
                translate(pos) rotate([0, 90 * (pos[0] > 0 ? -1 : 1), 0]) translate([0, 0, -wall]) screw(screw_UNC_6_32);
            }
        }
        
        // Front Fans
        translate(fan_front_a_location) rotate([0,90,0]) fan(fan_definition[0], fan_definition[1], fan_definition[2]);
        translate(fan_front_b_location) rotate([0,90,0]) fan(fan_definition[0], fan_definition[1], fan_definition[2]);
    }

    // ################## Part A: Bottom #####################################
    if (search("a", render_parts)) color("yellow") difference() {
        union() {
            // Base plate
            translate([case_origin[0]+wall_b, case_origin[1], case_origin[2]]) cube([case_size[0]-wall_b, length_ab, wall]);
            // Connection structure for B,G
            d_pcie_cutout = 6.365;
            translate([case_origin[0]+wall_b, case_origin[1]+wall, case_origin[2]]) {
                _a = cf_space_right-wall-d_pcie_cutout;
                _b = cf_space_right-wall;
                rotate([90, 0, 0]) translate([0, 0, -_a]) linear_extrude(_a) polygon([[0,0], [0, 36],    [36, 0]]);
                rotate([90, 0, 0]) translate([0, 0, -_b]) linear_extrude(_b) polygon([[0,0], [0, 18.37], [36, 0]]);
            }
            // Connection structure for B,C
            translate([case_origin[0]+wall_b, case_origin[1]+length_ab, case_origin[2]]) {
                rotate([90, 0, 0]) linear_extrude(cf_space_right) polygon([[0,0], [0, 36], [25, 0]]);
            }
            // Mainboard standoffs
            translate([0, 0, -miniitx_bottom_keepout-wall]) for (hole = miniitx_mounting_holes) {
                translate(hole) cylinder(r = 0.2*25.4, h = miniitx_bottom_keepout+wall, $fn = 50);
            }
        }

        // Chassis screw cutouts
        impl_screw_cutouts("a");
    }

    // ################## Part B: Backside ###################################
    if (search("b", render_parts)) color("blue") difference() {
        union() {
            // The main plate
            translate([case_origin[0], case_origin[1], case_origin[2]]) cube([wall_b, length_ab, case_size[2]]);
            // Part that the GPU screws into
            translate(lan_card_location) pcie_bracket_support(true);
        }
        motherboard_back_panel_cutout();
        translate(lan_card_location) pcie_bracket_cutout(low_profile=true);

        // Hexagonal cutout
        l=34;
        ofs_w=4;
        translate([case_origin[0]-0.1, miniitx_hole_c[1]+7.52-ofs_w/2, 52]) {
            // #cube([wall_b+0.2, motherboard_back_panel_size[0]+ofs_w, l]);
            translate([0,0,l]) rotate([0, 90, 0]) linear_extrude(wall_b+0.2) {
                honeycomb_cutout(l,motherboard_back_panel_size[0]+ofs_w, 5, 1, true);
            }
        }

        // Chassis screw cutouts
        impl_screw_cutouts("b");
    } 

    // ################## Part C: Side with HDD at the side ##################
    if (search("c", render_parts)) color("orange") difference() {
        union() {
            translate([case_origin[0], case_origin[1]+length_ab, case_origin[2]]) cube([case_size[0], case_size[1]-length_ab, wall]);
            translate([case_origin[0], case_origin[1]+case_size[1]-wall, case_origin[2]]) cube([case_size[0], wall, case_size[2]]);
            translate([case_origin[0], case_origin[1]+length_ab, case_origin[2]]) cube([wall_b, case_size[1]-length_ab, case_size[2]]);
            translate([case_origin[0], case_origin[1]+length_ab, case_origin[2]+case_size[2]-wall]) cube([case_size[0], case_size[1]-length_ab, wall]);
            translate([case_origin[0]+case_size[0]-wall, case_origin[1]+length_ab-length_c, case_origin[2]+wall]) cube([wall, length_c+case_size[1]-length_ab-wall, case_size[2]-2*wall]);
            // Connection structure for A
            translate([case_origin[0]+wall_b, case_origin[1]+case_size[1]-wall, case_origin[2]]) {
                rotate([90, 0, 0]) linear_extrude(case_size[1]-length_ab-wall) polygon([[0,0], [0, 36], [25, 0]]);
            }
            // Connection structure for D
            translate([case_origin[0]+wall_b, case_origin[1]+case_size[1]-wall, case_origin[2]+case_size[2]-wall-36]) {
                rotate([90, 0, 0]) linear_extrude(case_size[1]-length_ab-wall) polygon([[0,0], [0, 36], [25, 36]]);
            }

            // Connection structure for A,D,F
            translate([hdd_a_location[0]+hdd_l+cf_clearance_hdd_a_case, case_origin[1]+case_size[1]-wall-(case_size[1]-length_ab-wall), case_origin[2]+wall]) {
                cube([(case_origin[0]+case_size[0]-wall)-(hdd_a_location[0]+hdd_l+cf_clearance_hdd_a_case), case_size[1]-length_ab-wall, case_size[2]-2*wall]);
            }
        }
        // Cutouts for HDD Mounting Bracket (Part J)
        translate(hdd_a_location) rotate([0,90,-90]) {
            for (pos = hdd_a_dampener_locations) {
                translate(pos - [0,0,cf_thickness_hdd_a_bracket+hdd_dampener_height+(hdd_dampener_screw[3]-hdd_dampener_thread_depth)]) screw_cutout(hdd_dampener_screw);
            }
        }
        
        // Chassis screw cutouts
        impl_screw_cutouts("c");
    }

    // ################## Part D: Top ########################################
    if (search("d", render_parts)) color("purple") difference() {
        union() {
            // Base plate
            translate([case_origin[0]+wall_b, case_origin[1], case_origin[2]+case_size[2]-wall]) cube([case_size[0]-wall_b, length_ab, wall]);
            // Connection structure for B,C
            translate([case_origin[0]+wall_b, case_origin[1]+length_ab, case_origin[2]+case_size[2]-wall-35]) {
                rotate([90, 0, 0]) linear_extrude(case_size[1]-length_ab-wall) polygon([[0,0], [0, 35], [25, 35]]);
            }
            // Connection structure for B,G
            tmp_support_height = 14;
            translate([case_origin[0]+wall_b, case_origin[1]+wall, case_origin[2]+case_size[2]-wall-tmp_support_height]) {
                linear_extrude(tmp_support_height) polygon([[0,0], [0, 35-wall], [25, 0]]);
            }
            // Connection structure for B in the middle
            tmp_width = 40;
            translate([case_origin[0]+wall_b, case_origin[1]+length_ab/2+tmp_width/2, case_origin[2]+case_size[2]-wall-tmp_support_height]) {
                rotate([90, 0, 0]) linear_extrude(tmp_width) polygon([[0,0], [0, tmp_support_height], [25, tmp_support_height]]);
            }
        }

        // Chassis screw cutouts
        impl_screw_cutouts("d");
    }
    // ################## Part F: Front ######################################
    // ################## Part G: Side near PCIe slot ########################
    if (search("g", render_parts)) color("lime") difference() {
        union() {
            // Base plate
            translate([case_origin[0]+wall, case_origin[1], case_origin[2]+wall]) cube([case_size[0]-wall, wall, case_size[2]-2*wall]);
        }

        // Chassis screw cutouts
        impl_screw_cutouts("g");
    }
    // ################## Part H: Internal Top HDD Bracket ###################
    // ################## Part I: Internal Front Fan Mount ###################
    if (search("i", render_parts)) color("#2596be") difference() {
        union() {
            // This is cursed...
            translate([miniitx[0]+cf_clearance_fans_mb+fan_definition[1], miniitx[1]/2, case_origin[2]+case_size[2]/2]) {
                // The inner structure that covers the fans
                rotate([0, 90, 0]) linear_extrude(wall_i) for(y_sign = [-1, 1]) {
                    translate([0, y_sign*((miniitx[1]-2*fan_definition[0])/2+fan_definition[0]/2), 0]) offset($fn=20, r=-wall) union() {
                        for(angle = [45, -45]) {
                            rotate(angle) square([(wall+fan_definition[0])*sqrt(2), 4*wall], center=true);
                        }
                    }
                }
                // the outer border
                for(i = [-1, 1]) {
                    translate([wall_i/2, 0, i*fan_definition[0]/2]) cube([wall_i, miniitx[1]+wall, wall], center=true);
                    translate([wall_i/2, i*miniitx[1]/2, 0])        cube([wall_i, wall, fan_definition[0]+wall], center=true);
                }
                translate([wall_i/2,0,0]) cube([wall_i, (miniitx[1]-2*fan_definition[0])+wall, fan_definition[0]+wall], center=true);
            }
            translate([case_origin[0]+case_size[0]-wall-size_i[0], case_origin[1]+wall, case_origin[2]+wall]) cube([size_i[0], size_i[1], case_size[2]-2*wall]);
        }
        // Chassis screw cutouts
        impl_screw_cutouts("i");
    }
    // ################## Part J: Internal Side HDD Bracket ##################
    if (search("j", render_parts)) color("navy") {
        translate(hdd_a_location) rotate([0,90,-90]) difference() { 
            $fn=50;
            // This encodes the holes to use. Each pair is one connection between holes.
            union() {
                for(pairs = [[0,1], [3,4], [0,4], [1,3], [0,3], [1,4]]) {
                    hull() {
                        translate(hdd_3_5_inch_bottom_thread_pos[pairs[0]]-[0,0,cf_thickness_hdd_a_bracket]) cylinder(h = cf_thickness_hdd_a_bracket, r = 3.5);
                        translate(hdd_3_5_inch_bottom_thread_pos[pairs[1]]-[0,0,cf_thickness_hdd_a_bracket]) cylinder(h = cf_thickness_hdd_a_bracket, r = 3.5);
                    }
                }
                translate(hdd_3_5_inch_bottom_thread_pos[0]-[0,0,cf_thickness_hdd_a_bracket]) 
                    cube([14, hdd_3_5_inch_bottom_thread_pos[1].y-hdd_3_5_inch_bottom_thread_pos[0].y, cf_thickness_hdd_a_bracket]); 
                translate(hdd_3_5_inch_bottom_thread_pos[3]-[14,0,cf_thickness_hdd_a_bracket]) 
                    cube([14, hdd_3_5_inch_bottom_thread_pos[4].y-hdd_3_5_inch_bottom_thread_pos[3].y, cf_thickness_hdd_a_bracket]); 
            }
            // Cutouts for HDD screws, inset such that the screw has good connection to the HDD
            for (i=cf_holes_hdd_a) translate(hdd_3_5_inch_bottom_thread_pos[i] - [0, 0, cf_thickness_hdd_a_bracket/2]) screw_cutout(screw_UNC_6_32);
            // Cutouts for dampener screws, inset such that the head is fully covered
            for (pos = hdd_a_dampener_locations) translate(pos - [0, 0, hdd_dampener_screw[1]]) rotate([180, 0, 0]) screw_cutout(hdd_dampener_screw);

            // Chassis screw cutouts
            impl_screw_cutouts("j");
        }
    }

}

nas("cbdefij", false, true, false);
