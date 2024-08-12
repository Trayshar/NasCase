// Some screw stuff

module screw(top_r=2, top_h=1, thread_r=0.5, thread_h=4) {
    // Handle passing all params as array
    if(is_list(top_r) && len(top_r) >= 4) {
        screw(top_r[0], top_r[1], top_r[2], top_r[3]);
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

// Test measurements
screw_Plasfast = [5.6/2, 2.1, 3/2*0.86, 10, 3/2+0.1, 2];
screw_M3_black = [7/2, 1.6, 1.5, 5];

difference() {
    translate([-5, -5, 0]) cube([10,10,6]);
    translate([0, 0, 5]) rotate([0, 180, 0]) screw_cutout(screw_Plasfast);
}
