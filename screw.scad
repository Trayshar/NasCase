// Some screw stuff

module render_screw(top_r=2, top_h=1, thread_r=0.5, thread_h=4) {
    // Handle passing all params as array
    if(is_list(top_r) && len(top_r) >= 4) {
        render_screw(top_r[0], top_r[1], top_r[2], top_r[3]);
    } else {
        assert(is_num(top_r) && is_num(top_h) && is_num(thread_r) && is_num(thread_h), "Incorrect types!");
        // Actual module begins here
        $fn = 50;
        color("DarkGrey"){
            cylinder(h = thread_h, r = thread_r);
            translate([0, 0, -top_h]) difference() {
                cylinder(h = top_h, r = top_r);
                cube([top_r, top_r/4, top_h], center=true);
                cube([top_r/4, top_r, top_h], center=true);
            }
        }
    }
}

module screw_cutout(top_r=2, top_h=1, thread_r=0.5, thread_h=4, chamfer_r=0.5, chamfer_h=0) {
    // Handle passing all params as array
    if(is_list(top_r) && len(top_r) >= 4) {
        screw_cutout(top_r[0], top_r[1], top_r[2], top_r[3], top_r[4] ? top_r[4] : 0, top_r[5] ? top_r[5] : 0);
    } else {
        assert(is_num(top_r) && is_num(top_h) && is_num(thread_r) && is_num(thread_h) && is_num(chamfer_r) && is_num(chamfer_h), "Incorrect types!");
        // Actual module begins here
        $fn = 50;
        translate([0, 0, -0.001]) cylinder(h = chamfer_h, r1 = chamfer_r+0.001, r2 = thread_r+0.001);
        translate([0, 0, -0.001-chamfer_h]) cylinder(h = thread_h*1.1-chamfer_h, r = thread_r+0.001);
        translate([0, 0, -top_h*50+0.001]) cylinder(h = top_h*50, r = 1.25*top_r);
    }
}

module render_insert(height=5.7, radius=2.3, inner_thread_radius=1.5) {
    // Handle passing all params as array
    if(is_list(height) && len(height) >= 3) {
        render_insert(height[0], height[1], height[2]);
    } else {
        assert(is_num(height) && is_num(radius) && is_num(inner_thread_radius), "Incorrect types!");
        // Actual module begins here
        $fn = 50;
        color("Gold") difference() {
            cylinder(h=height, r=radius);
            translate([0, 0, -0.0001]) cylinder(h=height+0.0002, r=inner_thread_radius);
        }
    }
}

module insert_cutout(height=5.7, radius=2.3) {
    // Handle passing all params as array
    if(is_list(height) && len(height) >= 5) {
        // Assume [h, r, inner_thread_r, cutout_h, cutout_r]
        insert_cutout(height[3], height[4]);
    } else {
        assert(is_num(height) && is_num(radius), "Incorrect types!");
        // Actual module begins here
        $fn = 50;
        cylinder(h=height, r=radius);
    }
}

// Test measurements of Plasfast/M3
screw_Plasfast = [5.6/2, 2.1, 3/2*0.86, 10, 3/2+0.1, 2];
screw_M3_black = [7/2, 1.6, 1.5, 5];

*difference() {
    translate([-5, -5, 0]) cube([10,10,6]);
    translate([0, 0, 5]) rotate([0, 180, 0]) screw_cutout(screw_Plasfast);
}

M3_insert = [5.7, 4.6/2, 1.5, 5.85, 4/2]; // 5.7mm height, 4.6mm diameter, M3 thread, 6mm cutout height, 4mm cutout diameter
M3_insert_padding = [0, 0, 0, 0, 0.2];
c=3;
o=7.5;
h = 8;
*difference() {
    cube([o*c, o, h]);
    for (i = [0:c])  {
        spec = M3_insert+M3_insert_padding; 
        translate([o/2+o*i, o/2, h-spec[3] + 0.001]) #insert_cutout(spec);
    }
}

screw_Fan =    [5.5/2, 0.25, 1.5+0.6, 8, 5.5/2+0.4, 1.5];
difference() {
    translate([-6, -6, 0]) cube([12,12,1.8]);
    translate([0, 0, 1.8]) rotate([0, 180, 0]) screw_cutout(screw_Fan);
}