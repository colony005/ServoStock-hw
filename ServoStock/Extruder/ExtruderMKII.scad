$fn=100;

use <../../../Vitamins/Vitamins/Actuators/StandardServo/StandardServo_Vitamin.scad>;
use <../../../Vitamins/Vitamins/Actuators/StandardServo/Servo_Connector_Vitamin.scad>;
use <../../../Vitamins/Vitamins/Fasteners/Screws/High_Low_Screw_Vitamin.scad>;
use <../../../Vitamins/Vitamins/Fasteners/ScrewsAsBolts/High_Low_Screw_As_Bolt_Vitamin.scad>;
use <../../../Vitamins/Vitamins/Structural/SealedBearings/SealedBearing608_Vitamin.scad>;
use <../../../Vitamins/Vitamins/Sensors/Encoders/Encoder_Vitamin.scad>;
use <../../../Vitamins/Vitamins/Sensors/Encoders/EncoderMagnet_Vitamin.scad>;
use <../../../Vitamins/Vitamins/Tools/Standard_Extruder_Spacing_Vitamin.scad>;
use <../../../Vitamins/Vitamins/Tools/Filament_Vitamin.scad>;
use <../../../Vitamins/Vitamins/Electronics/Hot_Ends/PrintrBotJHeadHotEnd_Vitamin.scad>;
use <MKIIwheel.scad>;
use <Extruder_Encoder_Keepaway.scad>;

//ExtruderTop(.4);
//ExtruderBottom(.4);

//ALIGNMENT TESTING:
module Extruder(){
translate([-ExtruderX(.4)/2,-ExFilZ(),ExtruderY(.4)+HiLoScrewLength(.4)+8]){
	rotate([-90,0,0]){
		ExtruderTop(.4);
		ExtruderBottom(.4);
		}
	}
}
Extruder();

//PRINTING:
module ExtruderPrint(){
	ExtruderBottom(.4);
	MKIIwheelprint();
	translate([ExtruderX(.4),0,ExtruderZ(.4)]){
		rotate([0,90,0]){
			ExtruderTop(.4);
		}
	}
}
//ExtruderPrint();

//core dimensions depend on the servo and filament.  
function ExtruderX(3dPrinterTolerance=.4) = StandardServoHeightAbvWings(.6)+FilamentDiam()+StandardServoNubHeight()+HiLoScrewDiameter(.4)*2+3dPrinterTolerance;
echo("ExtruderX is",(ExtruderX(.4)));
function ExtruderY(3dPrinterTolerance=.4) = StandardServoLength()+HiLoScrewHeadHeight(.4)+3dPrinterTolerance;
echo("ExtruderY is",(ExtruderY(.4)));
function ExtruderZ(3dPrinterTolerance=.4) = StandardServoThickness()+FilamentDiam()+3dPrinterTolerance;
echo("ExtruderZ is",(ExtruderZ(.4)));


//defining some standard vectors:

function WheelVector() = [ExtruderX(.4)-StandardServoNubHeight()*2-FilamentDiam()/2,StandardServoWingsHeight()+StandardServoCylinderDist()+1.1,ExtruderZ(.4)+FilamentDiam()+.2];
function HingeTopVector() = [ExtruderX(.4)/2,HiLoScrewDiameter(.4)/2+1,ExtruderZ(.4)+HiLoScrewDiameter(.4)/2+.9];
function HingeBottomVector() =[.9,HiLoScrewDiameter(.4)/2+1,ExtruderZ(.4)+HiLoScrewDiameter(.4)/2+.9];
function PinTopVector() = [ExtruderX(.4)/2,ExtruderY(.4)-HiLoScrewHeadHeight(.4)*2+1,ExtruderZ(.4)+HiLoScrewDiameter(.4)/2+.9];
function PinBottomVector() = [.9,ExtruderY(.4)-HiLoScrewHeadHeight(.4)*2+1,ExtruderZ(.4)+HiLoScrewDiameter(.4)/2+.9];
function StandardServoVector() = [StandardServoNubHeight()+StandardServoHeightAbvWings()+FilamentDiam()/2,0,StandardServoThickness()/2+FilamentDiam()+1];
function ExFilZ() = StandardServoThickness()/2+StandardServoNubDiam()+.4;
function FilamentVector() = [ExtruderX(.4)/2,FilamentHeight()/2,ExFilZ()];


//Thru-hole screw module:
module ThruholeScrew(teardrop=true, 3dPrinterTolerance=.4){
	module teardrop(radius, length, angle){
   	rotate([0, angle, 0]){ 
			union(){
   			linear_extrude(height = length, center = true, convexity = radius, twist = 0)
   			circle(r = radius, center = true, $fn = 30);
   			linear_extrude(height = length, center = true, convexity = radius, twist = 0)
   			projection(cut = false) rotate([0, -angle, 0]) translate([0, 0, radius * sin(45) * 1.5]) cylinder(h = radius * sin(45), r1 = radius * sin(45), r2 = 0, center = true, $fn = 30);
			}
		}
	}
if (teardrop==true){
	rotate([0,90,90]){
		teardrop(HiLoScrewDiameter(.4)/2,HiLoScrewLength()*4,90);	
	}
}else{
	rotate([0,0,90]){
		cylinder(h = HiLoScrewLength()*4,r = HiLoScrewDiameter(.4)/2);
	}
}
}


//alignment of the Carriage mounting screws:
function SVHS() = [(ExtruderX(.4)+StandardExtruderSpacing())/2,ExFilZ(),-HiLoScrewLength()*4]; //Screw Vector Hinge Side
function SVFS() = [(ExtruderX(.4)-StandardExtruderSpacing())/2,ExFilZ(),-HiLoScrewLength()*4]; //Screw Vector Feed Side

module ScrewPattern(3dPrinterTolerance=.4){
		translate(SVHS()){ThruholeScrew(true,.4);}
		translate(SVFS()){ThruholeScrew(true,.4);}
}
	

//Hot End and its connecting screws:
function HEScrewVector()=[HotEndLength()+HotEndRecessLength()/2-HotEndRecessOffset(),HotEndRecessDiam()+HiLoScrewDiameter(.4)/2-.25,HiLoScrewLength()/2-.5];
module HEscrews(){
	union(){
		HotEnd(false,.4);
		translate(HEScrewVector()){
			HiLoScrew(.4);
		}
		mirror([0,1,0]){
			translate(HEScrewVector()){
				HiLoScrew(.4);
			}
		}
	}
}


//hot end and carriage connector module:
module removalcube(anglecube=true){
	if(anglecube==true){	
		union(){
			cube([HiLoScrewLength(.4),ExtruderX(.4),ExtruderZ(.4)+5]);
			translate([0,15,ExtruderZ(.4)]){
				cube([HiLoScrewLength(.4),ExtruderX(.4),ExtruderZ(.4)/2]);
			}
			translate([ExtruderX(.4)/2+HiLoScrewDiameter(.4),15,-ExtruderY(.4)/4-HiLoScrewDiameter(.4)]){
				rotate([0,-45,0]){
					cube([HiLoScrewLength(.4)+4,ExtruderX(.4),ExtruderZ(.4)]);
				}
			}
		}
	}else{
		union(){
			cube([HiLoScrewLength(.4),ExtruderX(.4),ExtruderZ(.4)+5]);
			translate([0,15,ExtruderZ(.4)]){
				cube([HiLoScrewLength(.4),ExtruderX(.4),ExtruderZ(.4)/2]);
			}
		}
	}
}
module CarriageConnector(){
	difference(){
		translate([StandardExtruderSpacing()/2+ExtruderX(.4)-8,ExtruderY(.4),0]){
			rotate([0,0,90]){
				cube([HiLoScrewLength(.4),StandardExtruderSpacing()+ExtruderX(.4)-16,ExtruderZ(.4)+4]);
			}
		}
		translate([-ExtruderX(.4)+1.2,ExtruderY(.4)-HiLoScrewLength(.4)/2,-.5]){
			removalcube(false);
		}
		translate([ExtruderX(.4),ExtruderY(.4)-HiLoScrewLength(.4)/2,-.5]){
			removalcube(true);
		}
		rotate([90,0,0]){
			ScrewPattern(.4);
		}
		translate([ExtruderX(.4)/2,ExtruderY(.4)*2+HotEndRecessOffset()/4,ExFilZ()]){
			rotate([0,0,-90]){
				HEscrews();
			}
		}
		translate([ExtruderX(.4)/2+HiLoScrewHeadDiameter(.4),ExtruderY(.4)+HiLoScrewHeadDiameter(.4)/2-.5,ExFilZ()/2]){
			ThruholeScrew(false,.4);
		}
		translate([-StandardExtruderSpacing()/2+rad,ExtruderY(.4)+HiLoScrewLength(.4)/2-4,0]){
			HingeFillet();
		}
		translate([-StandardExtruderSpacing()/2+rad,ExtruderY(.4)+HiLoScrewLength(.4)+fRad/2+rad/2-.25,0]){
			rotate([0,0,-90]){
				HingeFillet();
			}
		}
	}
}


//Fillet dimensions:

tHk = HiLoScrewDiameter(.4)+2;
fPer = HiLoScrewDiameter(.4)/2;
fRad = HiLoScrewDiameter(.4)*2;
rad = HiLoScrewDiameter(.4)/1.5+0.1;
//Fillet:
module HingeFillet(){
	difference(){
		translate([-0.1,-0.1,-0.1]){
			cube([fRad,fRad,ExtruderX(.4)]);
		}
		translate([fRad-.25,fRad-.25,-(0.1*2)]){
			cylinder(h=ExtruderX(.4)+1,r=rad);
		}
	}
}


//channel for bearing:
module BearingChannel(3dPrinterTolerance=.4){
	union(){
		translate([-608BallBearingDiam()/2,-608BallBearingDiam()/2+StandardServoNubDiam(.4)+.75,-ExtruderX(.4)/4]){
			cube([608BallBearingDiam(.4)/2,StandardServoNubDiam(.4)+2,ExtruderX(.4)]);
		}
		translate([4.5,0,0]){
			cylinder(h=wheelheight()*2,r=(608BallBearingDiam(.4)/2+608BallBearingInnerDiam(.4))/2);
		}
	}
}


//hinge module. Also serves as a pin:
module ExtruderHinge(){
	difference(){
		union(){
			translate([-HiLoScrewHeadDiameter(.4)/4+.5,0,0]){
				cylinder(h=ExtruderX(.4)/2-.9,r=HiLoScrewDiameter(.4)/2+1);
			}
			translate([-5,-HiLoScrewDiameter(.4)/2-1,0]){
				cube([HiLoScrewDiameter(.4)*2,HiLoScrewDiameter(.4)+2.19,ExtruderX(.4)/2-.9]);
			}
		}
		translate([-1,0,-1]){rotate([0,0,90]){ThruholeScrew(true,.4);}}
	}
}

//ExtruderHinge();

//The extruder top.  This is the mount for the Idler Wheel, bearing, and encoder:
module ExtruderTop(3dPrinterTolerance=.4){
difference(){
	union(){
		translate([ExtruderX(.4)/2+608BallBearingHeight(.4)/2-offsetheight(),0,ExtruderZ(.4)]){
			cube([ExtruderX(.4)/2-3,ExtruderY(.4),ExtruderZ(.4)+ExtruderZ(.4)/5]);
		}
		translate(HingeTopVector()){
			rotate([0,90,0]){
				ExtruderHinge(.4);
			}
		}
		translate(WheelVector()){
			translate([offsetheight()-.1,-608BallBearingDiam(.4)/2-7,-2]){
				rotate([0,90,0]){
					cube([ExtruderX(.4)/5,608BallBearingDiam(.4)+14,ExtruderX(.4)/2-3]);
				}
			}
		}
		translate([ExtruderX(.4)/2+608BallBearingHeight(.4)/2-offsetheight(),ExtruderY(.4),ExtruderZ(.4)+5]){
			cube([ExtruderX(.4)/2-608BallBearingHeight(.4)/2+offsetheight(),HiLoScrewDiameter(.4)*2-1,HiLoScrewLength(.4)/2]);
		}
	}
	union(){
		translate(WheelVector()){
			rotate([180,90,0]){
				MKIIwheel(.4);
			}
		}
		translate(WheelVector()){
			translate([offsetheight()+608BallBearingHeight(.4),0,0]){
				rotate([180,90,0,]){
					608BearingKeepaway(.4);
				}
			}
		}
		translate(WheelVector()){
			translate([MKIIwheelheight(),0,0]){
				rotate([180,90,0]){
					cylinder(h=MagnetLength(),r=608BallBearingInnerDiam(.4)/2);
				}
			}
		}
	}
	translate(HingeTopVector()){
		translate([HiLoScrewLength(.4),0,1]){
			rotate([0,-90,0]){
				ThruholeScrew(false,.4);
			}
		}
	}
	translate(PinTopVector()){
		translate([HiLoScrewHeadDiameter(.4)/2-2,HiLoScrewHeadDiameter(.4)/3,HiLoScrewLength(.4)/2+.15]){
			cube([ExtruderX(.4)/2,HiLoScrewHeadDiameter(.4)*2,HiLoScrewHeadDiameter(.4)*2]);
		}
	}
	translate(PinTopVector()){
		translate([HiLoScrewHeadDiameter(.4),HiLoScrewHeadDiameter(.4)+.75,HiLoScrewLength(.4)/2+.2]){
			HiLoBolt(.4,HiLoScrewHeadDiameter(.4)*2);
		}
	}
	translate(WheelVector()){
		translate([ExtruderX(.4)/2-2.3,0,0]){
			rotate([180,-90,0]){
				rotate(a=-90,v=[0,0,1]){
					Encoder(true);
				}
			}
		}
	}
	translate(HingeTopVector()){
		translate([0,-fRad,-fRad]){
			rotate([90,0,90]){
				HingeFillet();
			}
		}
		translate([2.85,fRad,-fRad]){
			rotate([90,0,-90]){
				HingeFillet();
			}
		}
	}
}
} 


//The extruder bottom.  This includes the servo,screws, hot end, and filament subtractions:
module ExtruderBottom(3dPrinterTolerance=.4){
	difference(){
			union(){
				cube([ExtruderX(.4),ExtruderY(.4),ExtruderZ(.4)]);
				translate(HingeBottomVector()){
					rotate([0,90,0]){
						ExtruderHinge(.4);
					}	
				}
				
				CarriageConnector();
			}
//cutout for top to adjust:
		translate([ExtruderX(.4)/2+3,-1,ExtruderZ(.4)/2]){
			cube([ExtruderX(.4)/2-2,ExtruderY(.4)+1,ExtruderZ(.4)]);
		}
		translate([0,StandardServoWingsHeight()+StandardServoCylinderDist()+1.1,0]){
//Servo:
			translate(StandardServoVector()){
				rotate([0,90,0]){
					StandardServoMotor(true,2,true,.4);
				}
			}	
//The opening for the idler wheel bearing to fit in:
			translate([StandardServoHeightAbvWings()/2+FilamentDiam()*2,0,608BallBearingDiam()-2]){
				rotate([0,-90,180]){
					BearingChannel();
				}
			}
					
			translate(FilamentVector()){
				rotate([90,0,0]){
					FilamentTeardrop();
				}
			}//The Filament
			//translate(FilamentVector()){
				//rotate([90,0,0]){
					//Filament(.4);}}
		}
	}
}
