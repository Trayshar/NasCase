// Parametric Mini-ITX Case
// https://github.com/eclecticc/ParametricCase
//
// BSD 2-Clause License
// Copyright (c) 2018, Nirav Patel, http://eclecti.cc
//
// Convenience defaults that apply across all modules

// Some default convenience variables
extra = 1.0;
// Thickness of case walls
wall = 2.4;
// Default PCB thickness for motherboard and GPU
pcb_thickness = 1.57;


module slope(size, center=false) {
    translate(center ? size/-2 : [0, 0, 0]) linear_extrude(size[2]) polygon([[0,0], [0, size[1]], [size[0], 0]]);
}

module beveled_cube(x,y,z,inner_x,inner_y,inner_z=undef) {
    _inner_z = inner_z ? inner_z : z;
    delta_x = (x-inner_x)/2;
    points = [
        [ 0,               0,        0 ],  //0
        [ x,               0,        0 ],  //1
        [ x,               y,        0 ],  //2
        [ 0,               y,        0 ],  //3
        [ delta_x,         0,        z ],  //4
        [ delta_x+inner_x, 0,        z ],  //5
        [ delta_x+inner_x, inner_y,  _inner_z ],  //6
        [ delta_x,         inner_y,  _inner_z ]   //7
    ]; 

    faces = [
        [ 0, 1, 2, 3 ], // bottom
        [ 4, 5, 1, 0 ], // front
        [ 7, 6, 5, 4 ], // top
        [ 5, 6, 2, 1 ], // right
        [ 6, 7, 3, 2 ], // back
        [ 7, 4, 0, 3 ]  // left
    ];
    polyhedron(points, faces);
}

// beveled_cube(12, 12, 5, 4, 10);
// slope([10, 8, 1], center=true);