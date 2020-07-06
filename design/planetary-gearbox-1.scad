// Planetary gear bearing (customizable)

//

// clearance
tol=0.25;


M3_bolt_v_diam = 3.4;

M4_bolt_h_diam = 4.7;

M3_nut_v_diam = 6.7;


//End of edittable values

total_diameter_of_gearbox = 100;
// outer diameter of ring
D=75;
// thickness
T=10;

number_of_planets=3;
number_of_teeth_on_planets=7    ;
approximate_number_of_teeth_on_sun=11;
// pressure angle
P=45;//[30:60]
// number of teeth to twist across
nTwist=0.4;
// width of hexagonal hole
w=6.7;

DR=0.5*1;// maximum depth ratio of teeth

m=round(number_of_planets);
np=round(number_of_teeth_on_planets);
ns1=approximate_number_of_teeth_on_sun;
k1=round(2/m*(ns1+np));
k= k1*m%2!=0 ? k1+1 : k1;
ns=k*m/2-np;
echo(ns);
nr=ns+2*np;
pitchD=0.9*D/(1+min(PI/(2*nr*tan(P)),PI*DR/nr));
pitch=pitchD*PI/nr;
echo(pitch);
helix_angle=atan(2*nTwist*pitch/T);
echo(helix_angle);

phi=$t*360/m;


translate([0,0,10]){
    difference(){
        intersection(){
            difference(){
                cylinder(r=total_diameter_of_gearbox/2, h=20, center=true, $fn=100); 
                cylinder(r=D/2,h=50,center=true,$fn=100);
            }
            union(){
                translate([total_diameter_of_gearbox/2,0,0]){
                    cylinder(r=total_diameter_of_gearbox/2, h=50, center=true, $fn=6);
                }
                mirror([1,0,0]){
                    translate([total_diameter_of_gearbox/2,0,0]){
                        cylinder(r=total_diameter_of_gearbox/2, h=50, center=true, $fn=4);
                    }
                }
            }
        }
        
    translate([34,30,-15]){
        cylinder(r=M4_bolt_h_diam/2, h=30, $fn=100);
    }
    mirror([0,1,0]){
        translate([34,30,-15]){
            cylinder(r=M4_bolt_h_diam/2, h=30, $fn=100);
        }
    }
    translate([-39,22,-15]){
        cylinder(r=M4_bolt_h_diam/2, h=30, $fn=100);
    }
    mirror([0,1,0]){
        translate([-39,22,-15]){
            cylinder(r=M4_bolt_h_diam/2, h=30, $fn=100);
        }
    }
    }
}


  
translate([0,0,T/2]){
        union(){
            difference(){
                cylinder(r=D/2,h=T,center=true,$fn=100);
                herringbone(nr,pitch,P,DR,-tol,helix_angle,T+0.2,false);
                difference(){
                    translate([0,-D/2,0])rotate([90,0,0])monogram(h=10);
                    cylinder(r=D/2-0.25,h=T+2,center=true,$fn=100);
                }
            }
            rotate([0,0,(np+1)*180/ns+phi*(ns+np)*2/ns])
            difference(){
                mirror([0,1,0])
                    herringbone(ns,pitch,P,DR,tol,helix_angle,T,true);
                cylinder(r=2.5,h=50,center=true,$fn=100);
            }
            for(i=[1:m])rotate([0,0,i*360/m+phi])translate([pitchD/2*(ns+np)/nr,0,0])
                rotate([0,0,i*ns/m*360/np-phi*(ns+np)/np-phi])
                    herringbone(np,pitch,P,DR,tol,helix_angle,T,true);
        }
}

translate([0,0,14]){
    difference()
    {
        union(){
            difference()
            {
                cube(size=[19, 16, 10], center=true);
                cube(size=[22, 2, 10], center=true);
                cylinder(h=12, r=2.5, center=true, $fn=100);
                
                rotate([90, 0, 0]){
                    translate([5,1,0])cylinder(h=24, r=M3_bolt_v_diam/2, center=true, $fn=100);
                    translate([5,1,8])cylinder(h=2.5, r=3.5, center=true, $fn=100);
                    translate([5,1,-8])cylinder(h=M3_nut_v_diam/2, r=3.35, center=true, $fn=6);
                    mirror([1,0,0]){
                        translate([5,1,0])cylinder(h=24, r=M3_bolt_v_diam/2, center=true, $fn=100);
                        translate([5,1,8])cylinder(h=2.5, r=3.5, center=true, $fn=100);
                        translate([5,1,-8])cylinder(h=M3_nut_v_diam/2, r=3.35, center=true, $fn=6);
                    }
                }
            }
            
        }
//        rotate([0, 90, 0]){
//            translate([6,8,0])cylinder(h=20, r=3, center=true, $fn=4);
//            mirror([0,1,0]){
//                translate([6,8,0])cylinder(h=20, r=3, center=true, $fn=4);
//            }
//        }
    }
} 

module rack(
	number_of_teeth=15,
	circular_pitch=10,
	pressure_angle=28,
	helix_angle=0,
	clearance=0,
	gear_thickness=5,
	flat=false){
addendum=circular_pitch/(4*tan(pressure_angle));

flat_extrude(h=gear_thickness,flat=flat)translate([0,-clearance*cos(pressure_angle)/2])
	union(){
		translate([0,-0.5-addendum])square([number_of_teeth*circular_pitch,1],center=true);
		for(i=[1:number_of_teeth])
			translate([circular_pitch*(i-number_of_teeth/2-0.5),0])
			polygon(points=[[-circular_pitch/2,-addendum],[circular_pitch/2,-addendum],[0,addendum]]);
	}
}

module monogram(h=1)
linear_extrude(height=h,center=true)
translate(-[3,2.5])union(){
	difference(){
		translate([1,10])square([2,3]);
	}
}

module herringbone(
	number_of_teeth=15,
	circular_pitch=10,
	pressure_angle=28,
	depth_ratio=1,
	clearance=0,
	helix_angle=0,
	gear_thickness=5,
    hollow_centre = true){
union(){
	gear(number_of_teeth,
		circular_pitch,
		pressure_angle,
		depth_ratio,
		clearance,
		helix_angle,
		gear_thickness/2,
        false,
        hollow_centre);
	mirror([0,0,1])
		gear(number_of_teeth,
			circular_pitch,
			pressure_angle,
			depth_ratio,
			clearance,
			helix_angle,
			gear_thickness/2,
            false,
            hollow_centre);
}}

module gear (
	number_of_teeth=15,
	circular_pitch=10,
	pressure_angle=28,
	depth_ratio=1,
	clearance=0,
	helix_angle=0,
	gear_thickness=5,
	flat=false,
    hollow_centre=true){
difference(){
    pitch_radius = number_of_teeth*circular_pitch/(2*PI);
    twist=tan(helix_angle)*gear_thickness/pitch_radius*180/PI;

    flat_extrude(h=gear_thickness,twist=twist,flat=flat)
        gear2D (
            number_of_teeth,
            circular_pitch,
            pressure_angle,
            depth_ratio,
            clearance);
    if(hollow_centre == true){
        cylinder (h = 20, r=M4_bolt_h_diam/2, center = true, $fn=100);
    }
}
}

module flat_extrude(h,twist,flat){
	if(flat==false)
		linear_extrude(height=h,twist=twist,slices=twist/6)children(0);
	else
		children(0);
}

module gear2D (
	number_of_teeth,
	circular_pitch,
	pressure_angle,
	depth_ratio,
	clearance){
pitch_radius = number_of_teeth*circular_pitch/(2*PI);
base_radius = pitch_radius*cos(pressure_angle);
depth=circular_pitch/(2*tan(pressure_angle));
outer_radius = clearance<0 ? pitch_radius+depth/2-clearance : pitch_radius+depth/2;
root_radius1 = pitch_radius-depth/2-clearance/2;
root_radius = (clearance<0 && root_radius1<base_radius) ? base_radius : root_radius1;
backlash_angle = clearance/(pitch_radius*cos(pressure_angle)) * 180 / PI;
half_thick_angle = 90/number_of_teeth - backlash_angle/2;
pitch_point = involute (base_radius, involute_intersect_angle (base_radius, pitch_radius));
pitch_angle = atan2 (pitch_point[1], pitch_point[0]);
min_radius = max (base_radius,root_radius);

intersection(){
	rotate(90/number_of_teeth)
		circle($fn=number_of_teeth*3,r=pitch_radius+depth_ratio*circular_pitch/2-clearance/2);
	union(){
		rotate(90/number_of_teeth)
			circle($fn=number_of_teeth*2,r=max(root_radius,pitch_radius-depth_ratio*circular_pitch/2-clearance/2));
		for (i = [1:number_of_teeth])rotate(i*360/number_of_teeth){
			halftooth (
				pitch_angle,
				base_radius,
				min_radius,
				outer_radius,
				half_thick_angle);		
			mirror([0,1])halftooth (
				pitch_angle,
				base_radius,
				min_radius,
				outer_radius,
				half_thick_angle);
		}
	}
}}

module halftooth (
	pitch_angle,
	base_radius,
	min_radius,
	outer_radius,
	half_thick_angle){
index=[0,1,2,3,4,5];
start_angle = max(involute_intersect_angle (base_radius, min_radius)-5,0);
stop_angle = involute_intersect_angle (base_radius, outer_radius);
angle=index*(stop_angle-start_angle)/index[len(index)-1];
p=[[0,0],
	involute(base_radius,angle[0]+start_angle),
	involute(base_radius,angle[1]+start_angle),
	involute(base_radius,angle[2]+start_angle),
	involute(base_radius,angle[3]+start_angle),
	involute(base_radius,angle[4]+start_angle),
	involute(base_radius,angle[5]+start_angle)];

difference(){
	rotate(-pitch_angle-half_thick_angle)polygon(points=p);
	square(2*outer_radius);
}}

// Mathematical Functions
//===============

// Finds the angle of the involute about the base radius at the given distance (radius) from it's center.
//source: http://www.mathhelpforum.com/math-help/geometry/136011-circle-involute-solving-y-any-given-x.html

function involute_intersect_angle (base_radius, radius) = sqrt (pow (radius/base_radius, 2) - 1) * 180 / PI;

// Calculate the involute position for a given base radius and involute angle.

function involute (base_radius, involute_angle) =
[
	base_radius*(cos (involute_angle) + involute_angle*PI/180*sin (involute_angle)),
	base_radius*(sin (involute_angle) - involute_angle*PI/180*cos (involute_angle))
];
