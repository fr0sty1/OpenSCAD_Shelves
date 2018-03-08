# OpenSCAD_Shelves

This repository holds a parametric OpenSCAD model for making shelving units from sheet goods (plywood) in almost any configuration you like.

# Customization

To customize the model you only need to edit a few of the parameters near the top of the file:

    board=5;    #this is the thickness of your sheet material (in mm).
    margin=.15; #this is the desired amount of 'slop' to add to the joints (negative value for interference fits)

    slotpct=.25; #slot depth as a proportion of the vertical support depth.
    tabpct=.3;   #width of rear tabs as a proportion of cavity width;

    #these are the dimensions of the internal volume of each cavity (in mm)
    wBox=220; #width of individual cavity
    hBox=130; #height
    dBox=255; #depth

    nCols=3; #how many columns
    nRows=6; #how many rows

The rest of the parameters are calculated from the dimensions you provided. If you want to tweak the `xMax` parameters to add (or remove some of the outside margins) feel free.

# Layout

When you are satisfied at the look of `whole_unit()`, render and export `one_of_each()` in a file format suitable to whatever CAD/CAM software you are using. Then cut out the desired number of each piece.

# Assembly

You assemble the unit by first slotting the supports onto the shelves (with the unit face-down) and then placing the back panel on and securing everything by placing wedgesinto the slots in the rear tabs to hold everything tight. If you don't need to break down the unit in the future you should feel free to add glue to all the joints as you assemble it.

#TODOs

* Add tabs/slots for the vertical supports to provide extra strength to the unit
* Render a 'test-slot' piece which has slots cut +/- some amount from the configured board+margin so you can do a quick test-fit of the slots on your material before cutting larger pieces.


