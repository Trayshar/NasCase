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
screw_M3_05l = [7/2,   1.6,  1.5, 5];
screw_M3_08l = [5.5/2, 2,    1.5, 8];
screw_M3_16l = [5.5/2, 2,    1.5, 16];
screw_M3_20l = [5.5/2, 2.5,  1.5, 20];
screw_Fan =    [5.5/2, 0.25, 1.5+0.6, 8, 5.5/2+0.4, 1.5];

// Some M3 inserts I brought on amazon
M3_insert = [5.7, 4.6/2, 1.5, 5.85, 4/2]; // 5.7mm height, 4.6mm diameter, M3 thread, 5.85mm cutout height, 4mm cutout diameter
M3_insert_padding = [0, 0, 0, 0, 0.2]; // Makes the cutout a bit larger. I noticed my printer makes the holes to narrow if I print them parallel to the layers

// The vibration dampeners I have left from some other project
module hdd_dampeners(height=8, diameter=8) {
    $fn=32;
    color("Black") cylinder(h=height, d=diameter);
}

module power_button(length_body=9, diameter_body=6.35, length_button=4.45+3.18, diameter_button=2.69) {
    $fn=32;
    color("Silver") translate([0, 0, -length_body]) cylinder(h=length_body, d=diameter_body);
    color("black") cylinder(h=length_button, d=diameter_button);
}


module nas(case_parts=true, show_components=false, render_screws=false, render_inserts=false, show_debug=false) {
    render_parts = is_string(case_parts) ? case_parts : "abcdefghijklmnop";

    // Config. Change these if you want.
    hdd_dampener_height = 8;
    hdd_dampener_diameter = 8;
    hdd_dampener_thread_depth = 2.9;
    hdd_dampener_screw = screw_M3_05l;
    fan_definition = [80, 25, 9]; // width/length, depth, #num of blades
    fan_filter_size = [3, 90.1, 90]; // depth (x) * width (y) * length (z)

    // Additional space in the direction perpendicular to the PCIe slot
    cf_space_right = 16;
    // length(x), width(y) of front pillar (part f)
    cf_size_front_pillar = [10, 10];
    // width/depth(y/x), height(z) of profiles for parts f/g
    cf_size_profile = [7.235, 10];
    // Size of the IO inlet on the right side (g): [length, depth, height, outer_length, outer_height]
    cf_size_IO_inlet_g = [20, 8, 20, 30, 24];
    // Additional space in the direction where the front fans are
    cf_space_front_h = (cf_size_front_pillar[0]+wall)/2;
    // Distance between the outer edge of the fan and the inner fan duct (of the fan)
    cf_space_fans_f = 2;
    // Distance between end of the mainboard and the fans
    cf_clearance_fans_mb = 3;
    // Distance between end of the mainboard and the side HDD
    cf_clearance_hdd_a_mb = 3;
    // Distance between the case and the side HDD
    cf_clearance_hdd_a_case = 3;
    // Distance between the case and the top HDD
    cf_clearance_hdd_b = 1;
    // Clearance for mounting above the PCIe slot
    cf_clearance_above_pcie_slot = 17;
    // Offset along the back-front-axis of the side HDD
    cf_offset_hdd_a = 12;
    // Horizontal position of the top HDD
    cf_offset_hdd_b = (miniitx[1]-hdd_w)/2;
    // Offset of the back plate relative to the mainboard IO position
    cf_offset_back = 1;
    // Offset of the IO inlet on the right side (g) along the x axis
    cf_offset_IO_inlet_g = 60;
    // General thickness of connection structures
    cf_thickness_connection_structures = 16;
    // Thickness of the inner walls of the IO inlet (part g)
    cf_thickness_inner_walls_IO_inlet_g = wall;
    // Thickness of the inner walls of the Top HDD bracket (part e)
    cf_thickness_inner_walls_e = 3;
    // Additional thickness of the back plate part
    cf_thickness_back = 3.5-wall;
    // Thickness of HDD A bracket. 1.8mm base thichness + height of dampener screw head
    cf_thickness_hdd_a_bracket = 1.8 + hdd_dampener_screw[1];
    // Thickness of the plate holding the two front fans
    cf_thickness_fan_bracket = 1.8;
    // HDD A Bottom side holes that are actually there. See hdd.scad for where those are.
    cf_holes_hdd_a = [0, 1, 3, 4];
    // X,Y offset of the HDD A Dampener holes used. Positive means outwards, negative means inwards.
    cf_holes_hdd_a_offsets = [-10, -2];
    // Config of the hooks used to secure the front panel
    cf_hook_hi_hook_length = wall;
    cf_hook_hi_base_length = wall/2;

    // Mainboard is at origin. These are derived automatically, DO NOT CHANGE!
    wall_b = wall+cf_thickness_back;
    case_origin = [
        motherboard_back_edge + cf_offset_back  - wall_b, // the back side, so it's just the space to the cutout. Ignoring additional thickness so it goes inwards
        -cf_space_right         - wall, // Just our custom offset to the right
        -miniitx_bottom_keepout - wall  // Respect mainboard keepout area
    ];
    case_size = [
        // Sum over distances, from back to front:
        // back-to-mainboard, mainboard, fan clearance, fan width, front clearence 
        abs(motherboard_back_edge+cf_offset_back)+miniitx[0]+cf_clearance_fans_mb+fan_definition[1] + wall + wall_b,
        // Space for LAN-card, mainboard, clearance for HDD, HDD, Dampeners for HDD
        cf_space_right+miniitx[1]+cf_clearance_hdd_a_mb+hdd_h+hdd_dampener_height+cf_thickness_hdd_a_bracket + 2*wall, 
        // Just the clearance+width of the vertical-mounted HDD on the side
        2*cf_clearance_hdd_a_case + hdd_w + 2*wall
    ];
    echo(str("Case Size: ", case_size));


    // Derived positions of all components. DO NOT CHANGE
    lan_card_location = pci_e_offset + [0, 0, miniitx[2]];
    hdd_a_location = [miniitx[0]-hdd_l+cf_offset_hdd_a, hdd_h+miniitx[1]+cf_clearance_hdd_a_mb, case_origin[2]+wall+cf_clearance_hdd_a_case+hdd_w];
    hdd_b_location = [miniitx[0]-hdd_l, hdd_w+cf_offset_hdd_b, case_origin[2]+case_size[2] - hdd_h - wall - cf_clearance_hdd_b];
    fan_front_a_location = [miniitx[0]+cf_clearance_fans_mb, 40,            case_size[2]/2+case_origin[2]];
    fan_front_b_location = [miniitx[0]+cf_clearance_fans_mb, miniitx[1]-40, case_size[2]/2+case_origin[2]];
    io_inlet_g_location = case_origin + [case_size[0]/2 - cf_size_IO_inlet_g[3]/2 + cf_offset_IO_inlet_g, 0, case_size[2]/2];
    length_ab = 210;
    length_c = 0;
    length_c_connection_structure = (case_origin[0]+case_size[0]-wall)-(hdd_a_location[0]+hdd_l+cf_clearance_hdd_a_case);
    delta_e_d = (case_origin[2] + case_size[2] - wall) - hdd_b_location[2];
    height_e = delta_e_d - hdd_dampener_height - M3_insert[0];
    thickness_f = cf_thickness_fan_bracket + fan_filter_size[0];
    hdd_a_dampener_locations = [
        for (i = cf_holes_hdd_a) [ 
            hdd_3_5_inch_bottom_thread_pos[i].x + sign(hdd_3_5_inch_bottom_thread_pos[i].x-50) * cf_holes_hdd_a_offsets[0], 
            hdd_3_5_inch_bottom_thread_pos[i].y + sign(hdd_3_5_inch_bottom_thread_pos[i].y-50) * cf_holes_hdd_a_offsets[1], 
            hdd_3_5_inch_bottom_thread_pos[i].z
        ]
    ];
    hook_hi_size = [cf_hook_hi_hook_length + cf_hook_hi_base_length, 4, 1];
    hook_hi_locations = [
        for (signs = [[0, 1, 1], [0, 1, -1], [0, -1, 1], [0, -1, -1]]) 
            [[fan_definition[1] + wall, signs.y*hole_spacing(80)/2 - signs.z*hook_hi_size[1]/2, signs.z*(case_size[2]-4*wall)/2], [signs.z > 0 ? 0 : 180, 180, 0], signs.y, signs.z]
    ];

    module hook() {
        cube([wall, 0, 0] + hook_hi_size);
        translate([wall + cf_hook_hi_base_length, 0, 0]) rotate([-90, 0, 0]) slope([cf_hook_hi_hook_length, hook_hi_size[2], hook_hi_size[1]]);
    }

    // Define case screw locations
    screw_offset_b = 8;
    screw_offset_f = 6;
    screw_offset_d_x = 10;
    screw_offset_d_z = 16;

    delta_16l_insert = screw_M3_16l[3] - M3_insert[0];
    delta_20l_insert = screw_M3_20l[3] - M3_insert[0];
    
    // Screw+Insert+Cutouts table
    // Fields: position, orientation, screw_type, components_involved, insert_type, insert_offset
    // - 0: position is always relative to the case origin!
    // - 1: orientation applied after position!
    // - 2: screw_type is [head_r, head_h, thread_r, thread_h, (cutout_chamfer_r, cutout_chamfer_h)]
    // - 3: components_involved is a string, each letter encoding whether cutouts must be applied
    // - 4: insert_type defines which insert is to be used, [height, radius, inner_thread_r, cutout_height, cutout_radius]. undef => no insert
    // - 5: insert_offset defines how far (along the screw thread) the insert is located. undef => no insert
    screws = [
        // Bottom (part a): Mainboard Screws
        [miniitx_mounting_holes[0] + [0,0,pcb_thickness] - case_origin, [0, 180, 0], screw_M3_05l, "a", M3_insert + M3_insert_padding, pcb_thickness],
        [miniitx_mounting_holes[1] + [0,0,pcb_thickness] - case_origin, [0, 180, 0], screw_M3_05l, "a", M3_insert + M3_insert_padding, pcb_thickness],
        [miniitx_mounting_holes[2] + [0,0,pcb_thickness] - case_origin, [0, 180, 0], screw_M3_05l, "a", M3_insert + M3_insert_padding, pcb_thickness],
        [miniitx_mounting_holes[3] + [0,0,pcb_thickness] - case_origin, [0, 180, 0], screw_M3_05l, "a", M3_insert + M3_insert_padding, pcb_thickness],
        // Back (part b): Screws
        [[wall_b/4, screw_offset_b,            screw_offset_b],               [0, 90, 0], screw_M3_08l, "ab", M3_insert, wall_b*0.75],
        [[wall_b/4, screw_offset_b,            -screw_offset_b+case_size[2]], [0, 90, 0], screw_M3_08l, "bd", M3_insert, wall_b*0.75],
        [[wall_b/4, -screw_offset_b+length_ab, screw_offset_b],               [0, 90, 0], screw_M3_08l, "ab", M3_insert, wall_b*0.75],
        [[wall_b/4, -screw_offset_b+length_ab, -screw_offset_b+case_size[2]], [0, 90, 0], screw_M3_08l, "bd", M3_insert, wall_b*0.75],
        // Back (part b): Screw above IO Shield
        [[wall_b/4, length_ab/2,               -screw_offset_b+case_size[2]], [0, 90, 0], screw_M3_08l, "bd", M3_insert, wall_b*0.75],
        // Back (part b): Screw to right side piece (g)
        [[wall_b/4, 5,                         case_size[2]/2],               [0, 90, 0], screw_M3_08l, "bg", M3_insert, wall_b*0.75],
        // Left (part c): Screws
        [[-screw_offset_d_x+case_size[0], length_ab+delta_20l_insert, screw_offset_d_z],               [90, 0, 0], screw_M3_20l, "ac", M3_insert, delta_20l_insert],
        [[screw_offset_d_x,               length_ab+delta_20l_insert, screw_offset_d_z],               [90, 0, 0], screw_M3_20l, "ac", M3_insert, delta_20l_insert],
        [[-screw_offset_d_x+case_size[0], length_ab+delta_20l_insert, -screw_offset_d_z+case_size[2]], [90, 0, 0], screw_M3_20l, "cd", M3_insert, delta_20l_insert],
        [[screw_offset_d_x,               length_ab+delta_20l_insert, -screw_offset_d_z+case_size[2]], [90, 0, 0], screw_M3_20l, "cd", M3_insert, delta_20l_insert],
        // Front (part f): Connections to right (part g)
        [[case_size[0]-wall-cf_size_front_pillar[0]+delta_16l_insert, wall+cf_size_front_pillar[1]/2, case_size[2]/2], [0, 270, 0], screw_M3_16l, "fg", M3_insert, delta_16l_insert],
        // Front (part f): Connections to right (part a,d)
        [[case_size[0]-wall-cf_size_front_pillar[0]+delta_16l_insert, wall+cf_size_front_pillar[1]/2, wall+screw_offset_f],              [0, 270, 0], screw_M3_16l, "af", M3_insert, delta_16l_insert],
        [[case_size[0]-wall-cf_size_front_pillar[0]+delta_16l_insert, wall+cf_size_front_pillar[1]/2, case_size[2]-screw_offset_f-wall], [0, 270, 0], screw_M3_16l, "df", M3_insert, delta_16l_insert],
        // Front (part f): Connections to left (part a,d)
        [[case_size[0]-screw_M3_05l[1], length_ab-screw_offset_f, wall+screw_offset_f],              [0, 270, 0], screw_M3_05l, "af", M3_insert, wall-screw_M3_05l[1]],
        [[case_size[0]-screw_M3_05l[1], length_ab-screw_offset_f, case_size[2]-screw_offset_f-wall], [0, 270, 0], screw_M3_05l, "df", M3_insert, wall-screw_M3_05l[1]],
        // Front (part f): Fan screws
        [fan_front_a_location - case_origin + [fan_definition[1]+cf_thickness_fan_bracket, hole_spacing(80)/2,   hole_spacing(80)/2], [0, 270, 0], screw_Fan, "f"],
        [fan_front_a_location - case_origin + [fan_definition[1]+cf_thickness_fan_bracket, -hole_spacing(80)/2,  hole_spacing(80)/2], [0, 270, 0], screw_Fan, "f"],
        [fan_front_a_location - case_origin + [fan_definition[1]+cf_thickness_fan_bracket, hole_spacing(80)/2,  -hole_spacing(80)/2], [0, 270, 0], screw_Fan, "f"],
        [fan_front_a_location - case_origin + [fan_definition[1]+cf_thickness_fan_bracket, -hole_spacing(80)/2, -hole_spacing(80)/2], [0, 270, 0], screw_Fan, "f"],
        [fan_front_b_location - case_origin + [fan_definition[1]+cf_thickness_fan_bracket, hole_spacing(80)/2,   hole_spacing(80)/2], [0, 270, 0], screw_Fan, "f"],
        [fan_front_b_location - case_origin + [fan_definition[1]+cf_thickness_fan_bracket, -hole_spacing(80)/2,  hole_spacing(80)/2], [0, 270, 0], screw_Fan, "f"],
        [fan_front_b_location - case_origin + [fan_definition[1]+cf_thickness_fan_bracket, hole_spacing(80)/2,  -hole_spacing(80)/2], [0, 270, 0], screw_Fan, "f"],
        [fan_front_b_location - case_origin + [fan_definition[1]+cf_thickness_fan_bracket, -hole_spacing(80)/2, -hole_spacing(80)/2], [0, 270, 0], screw_Fan, "f"],
    ];
    // Screws of part F that need some special handeling in parts H,I
    screws_f_handle_hi = [screws[14], screws[15], screws[16], screws[17], screws[18]];
    module impl_special_screw_cutouts_hi() {
        for(screw = screws_f_handle_hi) hull() {
            $fn=32;
            translate(case_origin + screw[0])             rotate(screw[1]) rotate([0, 180, 0]) cylinder(h=wall/2+screw[2][1], r=screw[2][0]*1.1);
            translate(case_origin + screw[0] + [0, 5, 0]) rotate(screw[1]) rotate([0, 180, 0]) cylinder(h=wall/2+screw[2][1], r=screw[2][0]*1.1);
        }
    }

    module impl_screw_cutouts(part) {
        // Iterate all screws, ignore those that do not contain part in component string
        for (screw_ = screws) if (search(part, screw_[3])) {
            // Translate + orient screw
            translate(screw_[0]+case_origin) rotate(screw_[1]) {
                // Add cutout for screw
                screw_cutout(screw_[2]);
                // Check if we have an insert for this screw
                if(!is_undef(screw_[4]) && !is_undef(screw_[5])) {
                    // Move to insert position (minus epsilon to ensure smooth rendering) and add cutout
                    translate([0, 0, screw_[5]-0.0001]) insert_cutout(screw_[4]);
                    // Print warning if insert is not deep enough: Thread_h-insert_offset-insert_h > 0
                    if(screw_[2][3] - screw_[5] - screw_[4][0] > 0)
                        echo(str("Warning - Insert not deep enough (by " , screw_[2][3] - screw_[5] - screw_[4][0], "mm): "), screw_);
                }
            }
        }
    }

    if(render_screws) {
        for (screw_ = screws) {
            translate(screw_[0]+case_origin) rotate(screw_[1]) render_screw(screw_[2]);
        }
        // HDD at the side
        translate(hdd_a_location) rotate([0,90,-90]) {
            for (i = cf_holes_hdd_a) {
                translate(hdd_3_5_inch_bottom_thread_pos[i] - [0,0,cf_thickness_hdd_a_bracket/2]) render_screw(screw_UNC_6_32);
            }
            for (pos = hdd_a_dampener_locations) {
                // Screw with the chassis
                translate(pos - [0,0,cf_thickness_hdd_a_bracket+hdd_dampener_height+(hdd_dampener_screw[3]-hdd_dampener_thread_depth)]) render_screw(hdd_dampener_screw);
                // Screw with the mounting bracket
                translate(pos - [0,0,hdd_dampener_screw[1]]) rotate([180, 0, 0]) render_screw(hdd_dampener_screw);
            }
        }
        
        // HDD at the top
        translate(hdd_b_location) rotate([0,0,-90]) {
            for (pos = hdd_3_5_inch_vertical_thread_pos) {
                translate(pos) rotate([0, 90 * (pos[0] > 0 ? -1 : 1), 0]) translate([0, 0, -cf_thickness_inner_walls_e/2]) render_screw(screw_UNC_6_32);
                // Screws to Dampener
                translate(pos - [(cf_thickness_inner_walls_e/2 + screw_UNC_6_32[1] + screw_M3_05l[0]*1.25) * (pos[0] > 0 ? -1 : 1), 0, (screw_M3_05l[3]-hdd_dampener_thread_depth)-height_e/2]) rotate([0, 0, 90]) render_screw(screw_M3_05l);
            }

        }
    }

    if(render_inserts) {
        for (screw_ = screws) if(!is_undef(screw_[4]) && !is_undef(screw_[5])) {
            translate(screw_[0]+case_origin) rotate(screw_[1]) translate([0, 0, screw_[5]]) render_insert(screw_[4]);
        }

        // Inserts for part E
        translate(hdd_b_location) rotate([0,0,-90]) {
            for (pos = hdd_3_5_inch_vertical_thread_pos) translate(pos) {
                si = (pos[0] > 0 ? -1 : 1);
                translate([(cf_thickness_inner_walls_e/2 + screw_UNC_6_32[1] + screw_M3_05l[0]*1.25) * -1 * si, 0, height_e-hdd_a10+hdd_dampener_height]) render_insert(M3_insert);
            }
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
            // Dampeners
            for (pos = hdd_a_dampener_locations) translate(pos - [0,0,cf_thickness_hdd_a_bracket+hdd_dampener_height]) 
                hdd_dampeners(hdd_dampener_height, hdd_dampener_diameter);
        }
        
        // HDD at the top
        translate(hdd_b_location) rotate([0,0,-90]) {
            hdd_3_5_inch();
            // Dampeners to Part E
            for (pos = hdd_3_5_inch_vertical_thread_pos) translate(pos) {
                si = (pos[0] > 0 ? -1 : 1);
                translate([(cf_thickness_inner_walls_e/2 + screw_UNC_6_32[1] + screw_M3_05l[0]*1.25) * -1 * si, 0, height_e-hdd_a10]) hdd_dampeners(hdd_dampener_height, hdd_dampener_diameter);
            }
        }

        // Front Fans
        translate(fan_front_a_location) rotate([0,90,0]) fan(fan_definition[0], fan_definition[1], fan_definition[2]);
        translate(fan_front_b_location) rotate([0,90,0]) fan(fan_definition[0], fan_definition[1], fan_definition[2]);

        // Fan filters
        translate(fan_front_a_location + [fan_definition[1]+cf_thickness_fan_bracket+fan_filter_size[0]/2,0,0]) color("white", 0.5) cube(fan_filter_size, center=true);
        translate(fan_front_b_location + [fan_definition[1]+cf_thickness_fan_bracket+fan_filter_size[0]/2,0,0]) color("white", 0.5) cube(fan_filter_size, center=true);

        // Power button
        translate(io_inlet_g_location + [0, cf_size_IO_inlet_g[1]/2, 0]) rotate([0, 90, 0]) power_button(); 
    }

    // ################## Part A: Bottom #####################################
    module part_a() difference() {
        union() {
            // Base plate
            translate([case_origin[0]+wall_b, case_origin[1], case_origin[2]]) cube([case_size[0]-wall_b, length_ab, wall]);

            // Connection structure for B,G
            d_pcie_cutout = 6.365;
            translate([case_origin[0]+wall_b, case_origin[1]+wall, case_origin[2]]) {
                _b = cf_thickness_connection_structures-wall;
                _a = _b-d_pcie_cutout;
                rotate([90, 0, 0]) translate([0, 0, -_a]) slope([36, 36, _a]);
                rotate([90, 0, 0]) translate([0, 0, -_b]) slope([36, 18.37, _b]);
            }
            // Connection structure for B,C
            translate([case_origin[0]+wall_b, case_origin[1]+length_ab, case_origin[2]]) {
                rotate([90, 0, 0]) slope([25, 36, cf_thickness_connection_structures]);
            }
            // Connection structure for C,F
            translate([case_origin[0]+case_size[0]-wall, case_origin[1]+length_ab, case_origin[2]]) {
                rotate([90, 0, 270]) slope([25, 36, length_c_connection_structure]);
            }
            // Connection structure for F
            translate([case_origin[0]+case_size[0]-wall-cf_size_front_pillar[0], case_origin[1]+wall, case_origin[2]]) {
                rotate([90, 0, 180]) slope([25, 36, cf_size_front_pillar[1]]);
            }

            // Mainboard standoffs
            translate([0, 0, -miniitx_bottom_keepout-wall]) for (hole = miniitx_mounting_holes) {
                translate(hole) cylinder(r = 5, h = miniitx_bottom_keepout+wall, $fn = 50);
            }
        }

        // Chassis screw cutouts
        impl_screw_cutouts("a");
    }

    // ################## Part B: Backside ###################################
    module part_b() difference() {
        union() {
            // The main plate
            translate([case_origin[0], case_origin[1], case_origin[2]]) cube([wall_b, length_ab, case_size[2]]);
            // Part that the GPU screws into
            translate(lan_card_location) pcie_bracket_support(true);
        }
        motherboard_back_panel_cutout();
        translate(lan_card_location) pcie_bracket_cutout(low_profile=true, clearance_above=cf_clearance_above_pcie_slot);

        // Hexagonal cutout
        l=34;
        ofs_w=4;
        translate([case_origin[0]-0.1, miniitx_hole_c[1]+7.52-ofs_w/2, 52]) {
            // #cube([wall_b+0.2, motherboard_back_panel_size[0]+ofs_w, l]);
            translate([0,0,l]) rotate([0, 90, 0]) linear_extrude(wall_b+0.2) {
                honeycomb_cutout(l,motherboard_back_panel_size[0]+ofs_w, 5, 1, true);
            }
        }

        offset_b = 2;
        // Save some material
        translate([case_origin[0], motherboard_back_panel_location[1], motherboard_back_panel_location[2]] - [0.0001, offset_b, offset_b])
            cube([wall_b-wall, motherboard_back_panel_size[0] + 2*offset_b, motherboard_back_panel_size[1] + 2*offset_b]);

        // Chassis screw cutouts
        impl_screw_cutouts("b");
    } 

    // ################## Part C: Side with HDD at the side ##################
    module part_c() difference() {
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

            // Pillar between A,D
            translate([case_origin[0]+wall_b, case_origin[1]+length_ab, case_origin[2] + wall]) {
                cube([10 - wall_b, case_size[1]-length_ab-wall, case_size[2]-2*wall]);
            }

            // Connection structure for A,D
            translate([hdd_a_location[0]+hdd_l+cf_clearance_hdd_a_case, case_origin[1]+case_size[1]-wall-(case_size[1]-length_ab-wall), case_origin[2]+wall]) {
                cube([length_c_connection_structure, case_size[1]-length_ab-wall, case_size[2]-2*wall]);
            }

            // Slope top
            translate(case_origin + case_size - [wall, wall, wall]) {
                rotate ([-90, 0, -90]) translate ([0, 0, -(case_size[0] - wall - wall_b)]) slope([7, case_size[1]-length_ab-wall, case_size[0] - wall - wall_b]);
            }

            // Slope bottom
            translate(case_origin + [case_size[0] - wall, case_size[1] - wall, wall]) {
                rotate ([90, 0, -90]) slope([7, case_size[1]-length_ab-wall, case_size[0] - wall - wall_b]);
            }
        }
        // Cutouts for HDD Mounting Bracket (Part J)
        translate(hdd_a_location) rotate([0,90,-90]) {
            for (pos = hdd_a_dampener_locations) {
                translate(pos - [0,0,cf_thickness_hdd_a_bracket+hdd_dampener_height+(hdd_dampener_screw[3]-hdd_dampener_thread_depth)]) screw_cutout(hdd_dampener_screw);
                // Dampener cutouts
                translate(pos - [0,0,cf_thickness_hdd_a_bracket+hdd_dampener_height]) scale([1.5, 1.5, 1]) hdd_dampeners(hdd_dampener_height, hdd_dampener_diameter);
            }
        }

        // Chassis screw cutouts
        impl_screw_cutouts("c");
    }

    // ################## Part D: Top ########################################
    module part_d() difference() {
        union() {
            // Base plate
            translate([case_origin[0]+wall_b, case_origin[1], case_origin[2]+case_size[2]-wall]) cube([case_size[0]-wall_b, length_ab, wall]);
            
            // Connection structure for B,C
            translate(case_origin + [wall_b, length_ab, case_size[2]-wall]) {
                rotate([0, 90, 270]) slope([36, 25, cf_thickness_connection_structures]);
            }
            // Connection structure for B,G
            tmp_support_height = 14;
            translate(case_origin + [wall_b, wall, case_size[2]-wall-tmp_support_height]) {
                slope([25, 35-wall, tmp_support_height]);
            }
            // Connection structure for B in the middle
            tmp_width = 40;
            translate(case_origin + [wall_b, length_ab/2-tmp_width/2, case_size[2]-wall]) {
                rotate([180, 0, 90]) beveled_cube(tmp_width, 25, tmp_support_height, 32, 5);
            }

            // Connection structure for E 
            translate(hdd_b_location) rotate([0,0,-90]) {
                for (pos = hdd_3_5_inch_vertical_thread_pos) translate(pos) {
                    si = (pos[0] > 0 ? -1 : 1);
                    translate([(cf_thickness_inner_walls_e/2 + screw_UNC_6_32[1] + screw_M3_05l[0]*1.25) * -1 * si, 0, height_e-hdd_a10+hdd_dampener_height]) cylinder(h=M3_insert[0], r=6);
                }
            }

            // Connection structure for C,F
            translate(case_origin + [case_size[0]-wall, length_ab, case_size[2]-wall]) {
                rotate([90, 90, 270]) slope([36, 22, length_c_connection_structure]);
            }

            // Connection structure for F, G
            translate(case_origin + [case_size[0]-wall-cf_size_front_pillar[0], wall, case_size[2]-wall]) {
                rotate([180, 90, 270]) slope([36, 25, cf_size_front_pillar[1]]);
            }
        }

        // Cutouts for part e
        translate(hdd_b_location) rotate([0,0,-90]) {
            for (pos = hdd_3_5_inch_vertical_thread_pos) translate(pos) {
                si = (pos[0] > 0 ? -1 : 1);
                translate([(cf_thickness_inner_walls_e/2 + screw_UNC_6_32[1] + screw_M3_05l[0]*1.25) * -1 * si, 0, height_e-hdd_a10+hdd_dampener_height]) insert_cutout(M3_insert);
            }
        }

        // Chassis screw cutouts
        impl_screw_cutouts("d");
    }

    // ################## Part E: Internal Top HDD Bracket ###################
    module part_e(render_all=true) translate(hdd_b_location) rotate([0,0,-90]) difference() {
        union() {
            for (pos = render_all ? hdd_3_5_inch_vertical_thread_pos : [hdd_3_5_inch_vertical_thread_pos[0]]) translate(pos) {
                si = (pos[0] > 0 ? -1 : 1);
                translate(-[cf_thickness_inner_walls_e/2 * si, 0, hdd_a10-height_e/2]) {
                    cube([cf_thickness_inner_walls_e, 12, height_e], center=true);
                    translate([(si*-14-cf_thickness_inner_walls_e)/2, 0, (height_e-cf_thickness_inner_walls_e)/2]) cube([14, 12, cf_thickness_inner_walls_e], center=true); 
                    translate([si*-cf_thickness_inner_walls_e, 0, (height_e-cf_thickness_inner_walls_e)/2-cf_thickness_inner_walls_e]) rotate([-90, si > 0 ?  90 : 0, 0]) slope([cf_thickness_inner_walls_e, cf_thickness_inner_walls_e, 12], center=true);
                }
            }
        }

        // Screws
        for (pos = hdd_3_5_inch_vertical_thread_pos) {
            si = (pos[0] > 0 ? -1 : 1);
            // Screws of HDD
            translate(pos) rotate([0, 90 * si, 0]) translate([0, 0, -cf_thickness_inner_walls_e/2]) screw_cutout(screw_UNC_6_32- [0.5,0,0,0]);
            // Screws to Dampener
            translate(pos - [(cf_thickness_inner_walls_e/2 + screw_UNC_6_32[1] + screw_M3_05l[0]*1.25) * si, 0, (screw_M3_05l[3]-hdd_dampener_thread_depth)-height_e/2]) rotate([0, 0, 90]) screw_cutout(screw_M3_05l);
        }
    }

    // ################## Part F: Internal Front with Fan mount ##############
    module part_f() difference() {
        // Hook vars
        hook_fac_y = 1.25;
        hook_fac_z = 2.5;
        hook_fac_z_out = 4;
        union() {
            // Inner fan bracket (kinda cursed)
            translate([miniitx[0]+cf_clearance_fans_mb+fan_definition[1], (fan_front_a_location[1]+fan_front_b_location[1])/2, case_origin[2]+case_size[2]/2]) {
                // The inner structure that covers the fans
                _length_f = 3;
                _width_f = 2*_length_f;
                _offset_f = _length_f;
                *rotate([0, 90, 0]) linear_extrude(cf_thickness_fan_bracket) for(y_sign = [-1, 1]) {
                    translate([0, y_sign*((miniitx[1]-2*fan_definition[0])/2+fan_definition[0]/2), 0]) offset($fn=20, r=-_offset_f) union() {
                        for(angle = [45, -45]) {
                            rotate(angle) square([(_length_f+fan_definition[0])*sqrt(2), _width_f + 2*_length_f], center=true);
                        }
                    }
                }
                // Plate between the crosses
                translate([cf_thickness_fan_bracket/2,0,0]) cube([cf_thickness_fan_bracket, (miniitx[1]-2*fan_definition[0])+wall, fan_definition[0]+wall], center=true);
                
            }
            // Outter area
            translate([miniitx[0]+cf_clearance_fans_mb+fan_definition[1], case_origin[1] + wall, case_origin[2] + wall]) cube([wall, cf_space_right + cf_space_fans_f, case_size[2]-2*wall]);
            translate([miniitx[0]+cf_clearance_fans_mb+fan_definition[1], miniitx[1] - cf_space_fans_f, case_origin[2] + wall]) cube([wall, length_ab - (wall + cf_space_right + miniitx[1] + length_c) + cf_space_fans_f, case_size[2]-2*wall]);
            translate([miniitx[0]+cf_clearance_fans_mb+fan_definition[1], case_origin[1] + wall, case_origin[2] + wall]) cube([wall, length_ab - (wall + length_c), (case_size[2]-fan_definition[0])/2 - wall + cf_space_fans_f]);
            translate([miniitx[0]+cf_clearance_fans_mb+fan_definition[1], case_origin[1] + wall, case_origin[2] + case_size[2] - (case_size[2]-fan_definition[0])/2 - cf_space_fans_f]) cube([wall, length_ab - (wall + length_c), (case_size[2]-fan_definition[0])/2 - wall + cf_space_fans_f]);

            // Add material around fan holes
            for(fan = [fan_front_a_location, fan_front_b_location]) {
                for(hole_y = [hole_spacing(80)/2, -hole_spacing(80)/2]) {
                    for(hole_z = [hole_spacing(80)/2, -hole_spacing(80)/2]) {
                        translate(fan + [fan_definition[1], hole_y, hole_z]) rotate([0, 90, 0]) cylinder(r=6, h=cf_thickness_fan_bracket, $fn=32);
                    }
                }
            }

            // Pillar
            translate([case_origin[0]+case_size[0]-wall-cf_size_front_pillar[0], case_origin[1]+wall, case_origin[2]+wall]) cube([cf_size_front_pillar[0], cf_size_front_pillar[1], case_size[2]-2*wall]);
        
            // Bottom profile
            translate(case_origin + [case_size[0]-wall-cf_size_profile[0], cf_size_front_pillar[1], wall]) cube([cf_size_profile[0], length_ab-cf_size_front_pillar[1], cf_size_profile[1]]);
            
            // Top profile
            translate(case_origin + [case_size[0]-wall-cf_size_profile[0], cf_size_front_pillar[1], case_size[2]-wall-cf_size_profile[1]]) cube([cf_size_profile[0], length_ab-cf_size_front_pillar[1], cf_size_profile[1]]);
        }
        // Dust Filters
        translate(fan_front_a_location + [fan_definition[1]+cf_thickness_fan_bracket+fan_filter_size[0]/2,0,0]) color("white", 0.5) cube(fan_filter_size, center=true);
        translate(fan_front_b_location + [fan_definition[1]+cf_thickness_fan_bracket+fan_filter_size[0]/2,0,0]) color("white", 0.5) cube(fan_filter_size, center=true);

        // Hooks
        hook_cutout_padding = 15; // Just some large number idc
        for(fan = [fan_front_a_location, fan_front_b_location]) for (h = hook_hi_locations) translate(fan + h[0]) rotate(h[1]) {
            // Cutout where hook goes through
            translate([-0.0005, -hook_hi_size[1]*(hook_fac_y-1)/2, 0]) cube([(wall+hook_hi_size[0])+hook_cutout_padding, hook_hi_size[1]*hook_fac_y, hook_hi_size[2]*hook_fac_z]);
            // Cutout where hook hooks
            translate([wall+cf_hook_hi_base_length-0.0005, -hook_hi_size[1]*(hook_fac_y-1)/2, -hook_hi_size[2]*(hook_fac_z_out-hook_fac_z)]) cube([cf_hook_hi_hook_length+hook_cutout_padding, hook_hi_size[1]*hook_fac_y, hook_hi_size[2]*(hook_fac_z_out-hook_fac_z)]);
            // Cutout to get hook out
            translate([-0.0005, -hook_hi_size[1]*(hook_fac_y-1)/2-hook_hi_size[1]*hook_fac_y*h[3], -hook_hi_size[2]*(hook_fac_z_out-hook_fac_z)]) cube([(wall+hook_hi_size[0])+hook_cutout_padding, hook_hi_size[1]*hook_fac_y, hook_hi_size[2]*hook_fac_z_out]);
        }

        // cut out conection structures from A,D for matching profiles
        part_a();
        part_d();

        // Chassis screw cutouts
        impl_screw_cutouts("f");
    }

    // ################## Part G: Side near PCIe slot ########################
    module part_g() difference() {
        union() {
            // Base plate
            translate(case_origin + [wall_b, 0, wall]) cube([case_size[0]-wall_b-cf_space_front_h, wall, case_size[2]-2*wall]);
        
            // Inlet and connection to F
            _wall_g = cf_thickness_inner_walls_IO_inlet_g;
            _size_g = [
                (case_origin[0]+case_size[0]-cf_size_front_pillar[0]-wall) - io_inlet_g_location[0] + _wall_g, 
                cf_size_front_pillar[1], 
                cf_size_IO_inlet_g[4]+2*_wall_g
            ];
            translate(case_origin + [case_size[0]-cf_size_front_pillar[0]-wall, wall, case_size[2]/2+_size_g[2]/2]) rotate([-90, 90, 0]) 
                beveled_cube(_size_g[2], _size_g[0]+_wall_g, _size_g[1], cf_size_IO_inlet_g[2], _size_g[0], cf_size_IO_inlet_g[1] + _wall_g - wall);

        
            // Bottom profile
            translate(case_origin + [wall_b, wall, wall]) cube([case_size[0]-wall_b-wall-cf_size_front_pillar[0], 7.235, cf_size_profile[1]]);
            
            // Top profile
            translate(case_origin + [wall_b, wall, case_size[2]-wall-cf_size_profile[1]]) cube([case_size[0]-wall_b-wall-cf_size_front_pillar[0], cf_size_profile[0], cf_size_profile[1]]);

            // Connection structure to B
            translate(case_origin + [wall_b, 0, case_size[2]/2-30/2]) rotate([-90, -90, 0]) beveled_cube(30, 20, wall+6, 24, 8);

            // Connection structure to F
            *translate(case_origin + [case_size[0]-cf_size_front_pillar[0]-wall, 0, case_size[2]/2+30/2]) rotate([-90, 90, 0]) beveled_cube(30, 20, wall+cf_size_front_pillar[1], 24, 8);
            // Larger version of the IO inlet
            *translate(io_inlet_g_location - [_wall_g, 0, cf_size_IO_inlet_g[4]/2+_wall_g]) rotate([-90, -90, 0]) resize([cf_size_IO_inlet_g[4]+2*_wall_g, cf_size_IO_inlet_g[3]+2*_wall_g, cf_size_IO_inlet_g[2]+wall_g]) beveled_cube(cf_size_IO_inlet_g[4], cf_size_IO_inlet_g[3], cf_size_IO_inlet_g[1], cf_size_IO_inlet_g[2], cf_size_IO_inlet_g[0]);
        }

        translate(io_inlet_g_location - [0, 0.0005, cf_size_IO_inlet_g[4]/2]) rotate([-90, -90, 0]) beveled_cube(cf_size_IO_inlet_g[4], cf_size_IO_inlet_g[3], cf_size_IO_inlet_g[1], cf_size_IO_inlet_g[2], cf_size_IO_inlet_g[0]);

        // Power button
        translate(io_inlet_g_location + [0.0001, cf_size_IO_inlet_g[1]/2, 0]) rotate([0, 90, 0]) power_button(); 

        // cut out conection structures from A,D for matching profiles
        part_a();
        part_d();

        // Chassis screw cutouts
        impl_screw_cutouts("g");
    }

    // ################## Part H: External Front, part on pillar #############
    module part_h() difference() {
        height_h = fan_filter_size[1] + 2*wall;
        length_h = wall+cf_space_right+miniitx[1]/2;
        offset_h = [miniitx[0]+cf_clearance_fans_mb+fan_definition[1]+cf_thickness_fan_bracket+fan_filter_size[0], -cf_space_right-wall, case_origin[2]];
        offset_h_f = (wall-cf_thickness_fan_bracket)-fan_filter_size[0];
        height_i = fan_filter_size[0]-(wall-cf_thickness_fan_bracket) + cf_thickness_fan_bracket;
        union() {
            translate([miniitx[0]+cf_clearance_fans_mb+fan_definition[1]+wall, miniitx[1]/2, case_origin[2]+wall/2]) {
                rotate([0, -90, 180]) beveled_cube(case_size[2]-wall, length_h, height_i, fan_filter_size[1], fan_filter_size[2]);
                translate([0, -fan_filter_size[1]+0.1, 0]) rotate([0, -90, 180]) beveled_cube(case_size[2]-wall, length_h-fan_filter_size[1]+0.1, height_i, fan_filter_size[1], length_h-fan_filter_size[1]-2);
            }
            // Area that overlays the pillar next to part G
            translate(offset_h + [offset_h_f - cf_space_front_h,0,wall]) cube([cf_space_front_h, wall, case_size[2]-2*wall]);
            
            // Hooks
            for (h = hook_hi_locations) translate(fan_front_a_location + h[0]) rotate(h[1]) {
                hook();
                delta = ((case_size[2]-2*wall) - fan_filter_size[1])/2;
                translate([0,-hook_hi_size[1],delta-wall-h[1][2]]) rotate([90, 180, -90]) beveled_cube(hook_hi_size[1]*3, delta, height_i, hook_hi_size[1]*2, delta*0.75, height_i*0.75); //cube([height_i, hook_hi_size[1]*2, 10]);
            }
        }

        translate(fan_front_a_location + [fan_definition[1]+cf_thickness_fan_bracket+fan_filter_size[0]-0.001,-fan_filter_size[1]/2,fan_filter_size[2]/2]) {
            rotate([0, 90, 0]) linear_extrude(cf_thickness_fan_bracket+0.002) {
                honeycomb_cutout(fan_filter_size[2], fan_filter_size[1], 5, 1, true);
            }
        }

        // Fan Filter
        translate(fan_front_a_location + [fan_definition[1]+cf_thickness_fan_bracket+fan_filter_size[0]/2+0.0005,0,0]) color("white", 0.5) cube(fan_filter_size + [0.001, 0, 0], center=true);

        // Chassis screw cutouts
        impl_screw_cutouts("h");

        // Special cutouts for screws of F
        impl_special_screw_cutouts_hi();
    }

    // ################## Part I: External Front, left part ##################
    module part_i() difference() {
        height_i = fan_filter_size[0]-(wall-cf_thickness_fan_bracket) + cf_thickness_fan_bracket;
        extra_lenght_i = 10;
        union() {
            translate([miniitx[0]+cf_clearance_fans_mb+fan_definition[1]+wall, miniitx[1]/2, case_origin[2]+case_size[2]-wall/2]) {
                rotate([0, 90, 0]) beveled_cube(case_size[2]-wall, length_ab/2+extra_lenght_i, height_i, fan_filter_size[1], fan_filter_size[2]+extra_lenght_i);
            }
            // Hooks
            for (h = hook_hi_locations) translate(fan_front_b_location + h[0]) rotate(h[1]) {
                hook();
                delta = ((case_size[2]-2*wall) - fan_filter_size[1])/2;
                translate([0,-hook_hi_size[1],delta-wall-h[1][2]]) rotate([90, 180, -90]) beveled_cube(hook_hi_size[1]*3, delta, height_i, hook_hi_size[1]*2, delta*0.75, height_i*0.75); //cube([height_i, hook_hi_size[1]*2, 10]);
            }
            
        }

        // Fan Filter
        translate(fan_front_b_location + [fan_definition[1]+cf_thickness_fan_bracket+fan_filter_size[0]/2+0.0005,0,0]) color("white", 0.5) cube(fan_filter_size + [0.001, 0, 0], center=true);

        // Hexagonal cutout
        translate(fan_front_b_location + [fan_definition[1]+cf_thickness_fan_bracket+fan_filter_size[0]-0.01,-fan_filter_size[1]/2,fan_filter_size[2]/2]) {
            rotate([0, 90, 0]) linear_extrude(cf_thickness_fan_bracket+0.02) {
                honeycomb_cutout(fan_filter_size[2], fan_filter_size[1], 5, 1, true);
            }
        }

        // Chassis screw cutouts
        impl_screw_cutouts("i");

        // Special cutouts for screws of F
        impl_special_screw_cutouts_hi();
    }

    // ################## Part J: Internal Side HDD Bracket ##################
    module part_j() {
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

    // Selection code
    if (search("a", render_parts)) color("tan") part_a();
    if (search("b", render_parts)) color("blue") part_b();
    if (search("c", render_parts)) color("orange") part_c();
    if (search("d", render_parts)) color("purple") part_d();
    if (search("e", render_parts)) color("IndianRed") part_e(render_all=true);
    if (search("f", render_parts)) color("#2596be") part_f();
    if (search("g", render_parts)) color("lime") part_g();
    if (search("h", render_parts)) color("white") part_h();
    if (search("i", render_parts)) color("AntiqueWhite") part_i();
    if (search("j", render_parts)) color("navy") part_j();
}

nas("hi", false, false, false, false);
