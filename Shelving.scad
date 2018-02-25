//Orientation:
//W = X
//D = Y

//material thickness
kerf=5;

//bounding box
dMax=350;
wMax=500;
hMax=500;

//cavity dimensions
wBox=230;
hBox=145;

//# of cavities
nCols=2;
nRows=4;

//shelf-support interface
shelfFront=80; // depth of slot in vertical members / supported length of shelves
tabDepth=25; //length of tab on back of shelves
tabWidth=50; //width of tab/slot


edge_offset = -1*(kerf/2+ (wMax - ((wBox+kerf)*nCols + kerf)) / 2);
//coordinates:
//0,0 is the front face and center of the kerf of the lefthand vertical support. (true? false?)

module slot(depth) {
    //slots are 'kerf' wide, and 'dMax' long (to prevent floating point math issues)
    //they are translated 1/2 kerf over and 'depth' back so any enclosing tranlate is moving the centerline of the slot.
    translate([-.5*kerf,depth]) square([kerf*1.02, dMax*1.001]);
}

module shelf_tab(width,depth) {
    //create the 'voids' use w/ difference() to make the tab/slot at the back
    //tabs are centered on the box to the right of 0,0 and translated to the back of dMax
    extra= (kerf + wBox - width) /2;

    //move the whole thing to the back of the box
    translate([0,dMax-depth]) {
        union() {
            difference() {
                //this is the whole rectangle
                square([wBox + kerf, depth + kerf]);

                //this is the tab
                translate([extra,0]) square([width, depth+kerf]);
            }

            //this is the slot
            translate([(wBox+kerf)/2, 0]) square([kerf,depth-2*kerf]);
        }
    }
}

module shelf() {
    difference () {
        //full sheet
        translate([edge_offset,0]) square([wMax,dMax]);

        //Vertical slots
        for (off = [0:wBox+kerf:wMax]) {
            translate([off,0]) slot(shelfFront);
        }
        //Rear tabs
        for (off = [0:wBox+kerf:wMax-wBox]) {
            translate([off,0]) shelf_tab(tabWidth,tabDepth+kerf);
        }
    }
}

module support() {
    difference () {
        //full sheet
        square([hMax,dMax-tabDepth]);

        //shelf slots
        for (off = [.5*kerf:hBox+kerf:hMax]) {
            translate([off,0]) slot(-1*(dMax-shelfFront));
        }
    }
}

module shelves() {
    for (voff = [0:hBox+kerf:hMax]) {
        translate([0,0,voff])linear_extrude(height= kerf) shelf();
    }
}

module supports() {
    for (hoff = [0:wBox+kerf:wMax]) {
        translate([hoff+.5*kerf,.5*kerf,0]) rotate([0,-90,0]) linear_extrude(height= kerf) support();
    }
}

module back() {
    difference() {
        translate([edge_offset,dMax+1.5*kerf-tabDepth,0]) rotate([90,0,0]) linear_extrude(height=kerf) square([hMax,wMax]);
        //translate this so it misses the pin slots
        translate([0,(tabDepth-2*kerf)*-1,0])shelves();
        translate([0,-0.01,0])supports();
    }
}

module one_of_each() {
	projection() translate([-1*edge_offset, dMax+kerf]) rotate([-90,0,0]) back();
	translate([-1*edge_offset, -1*(dMax+kerf)]) shelf();
	support();    
}

module whole_unit() {
	color(rands(0,1,3)) back();
	color(rands(0,.7,3)) shelves();
	color(rands(0,.9,3)) supports();
}
module collisions() {
	intersection() {
		shelves();
		supports();
	}
}
//one_of_each();
//whole_unit();
//back();
//collisions();
shelves();
