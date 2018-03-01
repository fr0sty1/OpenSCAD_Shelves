//Orientation:
//W = X
//D = Y

//material thickness
kerf=7;
margin=.10; //amound smaller material is than kerf

//cavity dimensions
//Replacement for cardboard organizer
//wBox=255;
//hBox=70;
//dBox=255;

wBox=220;
hBox=130;
dBox=315;
//# of cavities
nCols=3;
nRows=5;


//shelf-support interface
shelfFront=80; // depth of slot in vertical members / supported length of shelves
tabDepth=4*kerf; //length of tab on back of shelves
tabWidth=75; //width of tab/slot

//bounding box
dMax=dBox+kerf+tabDepth;
wMax=nCols*(wBox+kerf)+50;
hMax=nRows*(hBox+kerf)+70;



edge_offset = -1*(kerf/2+ (wMax - ((wBox+kerf)*nCols + kerf)) / 2);
//coordinates:
//0,0 is the front face and center of the kerf of the lefthand vertical support. (true? false?)

module slot(depth) {
    //slots are 'kerf' wide, and 'dMax' long (to prevent floating point math issues)
    //they are translated 1/2 kerf over and 'depth' back so any enclosing tranlate is moving the centerline of the slot.
    translate([-.5*kerf,depth+margin]) square([kerf, dMax]);
}

module shelf_tabs() {
    for (off = [0:wBox+kerf:wMax-wBox]) {
        translate([off,0]) shelf_tab(tabWidth-margin,tabDepth+.5*kerf);
    }
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
            translate([(wBox)/2, 0]) square([kerf,depth-2*kerf]);
        }
    }
}

module shelf() {
    difference () {
        //full sheet
        translate([edge_offset,0]) square([wMax,dMax]);

        //Vertical slots
        for (off = [0:wBox+kerf:wMax]) {
            translate([off,0]) slot(shelfFront-margin);
        }
        //Rear tabs
        shelf_tabs();
        //trim sides
        translate([edge_offset, shelfFront+3*kerf]) square([-1*edge_offset,dMax]);
        translate([wMax+edge_offset*2, shelfFront+3*kerf]) square([-1*edge_offset,dMax]);
    }
}

module support() {
    difference () {
        //full sheet
        square([hMax,dMax-tabDepth]);

        //shelf slots
        for (off = [.5*kerf:hBox+kerf:hMax]) {
            translate([off,0]) slot(shelfFront-dMax);
        }
    }
}

module shelves() {
    for (voff = [.5*margin:hBox+kerf:hMax]) {
        translate([0,0,voff])linear_extrude(height= kerf-margin) shelf();
    }
}

module supports() {
    for (hoff = [-.5*margin:wBox+kerf:wMax]) {
        translate([hoff+.5*kerf,0,0]) rotate([0,-90,0]) linear_extrude(height= kerf-margin) support();
    }
}

module back() {
    difference() {
        translate([edge_offset,dMax+kerf-tabDepth,0]) rotate([90,0,0]) linear_extrude(height=kerf-margin) square([wMax,hMax]);

        //translate this so it misses the pin slots
        translate([0,(tabDepth-2*kerf)*-1,0])shelves();
        //move suppots forward enough that they don't interfere with back
        translate([0,-1*margin,0])supports();
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
        back();
    }
}
//debug:
echo("making ", nCols,"x", nRows+1," unit with ", kerf,"mm material");
echo("wMax=", wMax, " dMax=",dMax, "hMax=",hMax);
echo("wMax=", wMax/25.4, "in dMax=",dMax/25.4, "in hMax=",hMax/25.4, "in");
//one_of_each();
//whole_unit();
//color([.3,.4,.5])back();
//color([.5,.1,.2])shelves();
color([.1,.9,.2])collisions();
//supports();
