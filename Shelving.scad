//Orientation:
//W = X
//D = Y

//material thickness
board= 5;
margin=1; //amount smaller material is than kerf, negative value for interference fit
kerf_board_step = .01 * board; //This seems to be a suitable guess at a step value.
kerf_board_min = -2; //how many kerf_board_steps under to start
kerf_board_max =  5; //how many kerf_board_steps over to go

//kerf is actual size of slots cut
kerf=board+margin;

//support %
slotpct=.25;
tabpct=.2;
//cavity dimensions (sized for 6qt sterilite)
wBox=220;
hBox=130;
dBox=315;

//Replacement for cardboard organizer
//wBox=255;
//hBox=70;
//dBox=255;

//# of cavities
nCols=3;
nRows=5;

//shelf-support interface
shelfFront=dBox*slotpct; // depth of slot in vertical members / supported length of shelves
tabDepth=4*board+margin; //length of tab on back of shelves
tabWidth=2*board+wBox*tabpct; //width of tab/slot

//bounding box
dMax=dBox+board+tabDepth;
wMax=nCols*(wBox+board)+5*board+margin;
hMax=nRows*(hBox+board)+.5*hBox+board;



edge_offset = -1*(board/2+ (wMax - ((wBox+board)*nCols + board)) / 2);
//coordinates:
//0,0 is the front face and center of the kerf/board of the lefthand vertical support. (true? false?)

module slot(depth) {
    //slots are 'kerf' wide, and 'dMax' long (to prevent floating point math issues)
    //they are translated 1/2 kerf over and 'depth' back so any enclosing tranlate is moving the centerline of the slot.
    translate([-.5*kerf,depth+.5*margin]) square([kerf, dMax]);
}

module shelf_tabs() {
    for (off = [0:wBox+board:wMax-wBox]) {
        translate([off,0]) shelf_tab(tabWidth,tabDepth+.5*board);
    }
}

module shelf_tab(width,depth) {
    //create the 'voids' use w/ difference() to make the tab/slot at the back
    //tabs are centered on the box to the right of 0,0 and translated to the back of dMax
    sides= (board + wBox - width) /2;

    //move the whole thing to the back of the box
    translate([0,dMax-depth]) {
        union() {
            difference() {
                //this is the whole rectangle
                square([wBox + board, depth + board]);

                //this is the tab
                translate([sides,0]) square([width, depth+board]);
            }

            //this is the slot
            translate([(board+wBox)/2-.5*kerf, 0]) square([kerf,depth-2*board]);
        }
    }
}

module shelf() {
    difference () {
        //full sheet
        translate([edge_offset,0]) square([wMax,dMax]);

        //Vertical slots
        for (off = [0:wBox+board:wMax]) {
            translate([off,0]) slot(shelfFront-margin);
        }
        //Rear tabs
        shelf_tabs();
        //trim sides
        translate([edge_offset, shelfFront+3*board]) square([-1*edge_offset,dMax]);
        translate([wMax+edge_offset*2, shelfFront+3*board]) square([-1*edge_offset,dMax]);
    }
}

module support() {
    union() {
        difference () {
            //full sheet
            square([hMax,dMax-tabDepth]);

            //shelf slots
            for (off = [.5*board:hBox+board:hMax]) {
                translate([off,0]) slot(shelfFront-dMax);
            }
        }

        //shelf tabs

        for (off = [(hBox+board)/4:hBox+board:hMax-.5*hBox]) {
            translate ([off,dMax-(tabDepth+.01)]) square([.5*hBox, 2*board+margin]);
        }
    }
}

module shelves() {
    for (voff = [0:hBox+board:hMax]) {
        translate([0,0,voff])linear_extrude(height= board) shelf();
    }
}

module supports() {
    for (hoff = [-.5*margin:wBox+board:wMax]) {
        translate([hoff+.5*kerf,0,0]) rotate([0,-90,0]) linear_extrude(height= board) support();
    }
}

module back_slots() {
    //These are the openings to get 'differenced', bottom-left at 0,0

    offset(delta=margin) projection(cut=true) rotate([-90,0,0]) translate([-1*edge_offset,-1*(dMax+board-tabDepth),0]) union() { 
        //translate shelves forward so the section misses the pin slots
        translate([0,(tabDepth-2*board)*-1,0])shelves();
        //tranlate suppots forward by epsilon so that they don't collide with back
        translate([0,-.01,0])supports();
    }
}

module back() {
    translate([edge_offset,dMax+board-tabDepth,0]) rotate([90,0,0]) linear_extrude(height=board) {
        difference() {
            square([wMax,hMax]);
            back_slots();
        }
    }
}

module kerf_board(){
    num_slots = kerf_board_max - kerf_board_min + 1;
    translate([0,-1*(dMax+board+(num_slots*2+3)*kerf)])
    difference() {
        square([(num_slots+2)*kerf,(num_slots*2+1)*kerf]);
        for (i = [kerf_board_min:1:kerf_board_max]) {
        translate([-0.01,(2+i)*2*kerf+kerf]) square([4*kerf,i*kerf_board_step+kerf]);
        }
    }
}
module one_of_each() {
    projection() translate([-1*edge_offset, dMax+board]) rotate([-90,0,0]) back();
    translate([-1*edge_offset, -1*(dMax+board)]) shelf();
    support();
    kerf_board();
    pegs();
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

module simple_peg() {
    translate([0,0]) linear_extrude(height=5) hull() {
        circle(3);
        translate([35,0]) { 
            circle(3);
            translate([3,8.5]) circle(3);
        }
    }
}
module scalloped_peg() {
    //TODO: Parameterize this in terms of kerf
    translate([0,-30]) linear_extrude(height=5) difference() {
        projection() simple_peg();
        translate([2,8]) rotate([0,0,15]) union() for(i=[0:8:60]) {
            translate([i,0]) circle(6.5);
        }
    } 
}

module pegs() {
    translate([80,-1*(dMax+board+5*kerf)]) {
        simple_peg();
        scalloped_peg();
        translate([0,-30]) scale([1,.7,1]) scalloped_peg();
    }
}
//debug:
echo("making ", nCols,"x", nRows+1," unit with ", board,"mm material");
echo("wMax=", wMax, " dMax=",dMax, "hMax=",hMax);
echo("wMax=", wMax/25.4, "in dMax=",dMax/25.4, "in hMax=",hMax/25.4, "in");
one_of_each();
//kerf_board();
//whole_unit();
//color([.8,.8,.2])back();
//color([.2,.8,.8])shelves();
//color([.8,.2,.8])supports();
//color([.1,.9,.2])collisions();
//pegs();
