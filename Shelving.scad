//constants
kerf = 5;
width = 220;
height = 140;
depth = 325;
rows = 2;
cols = 4;
hmax = 500;
wmax = 500;
dmax = 350;
tab = 20;


//shelf
translate( [-wmax/2,0,0]){
	cube([wmax,dmax,kerf],0);
}

