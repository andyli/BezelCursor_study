package bezelcursor.world;

using Std;
using Lambda;
import nme.geom.*;
import com.haxepunk.*;
import com.haxepunk.utils.*;
import nape.callbacks.*;
import nape.constraint.*;
import nape.geom.*;
import nape.phys.*;
import nape.shape.*;
import nape.space.*;
import org.casalib.util.*;

import bezelcursor.entity.*;
import bezelcursor.model.*;
using bezelcursor.Main;

class GenerateTaskBlockDataWorld extends World {
	var space:Space;
	var bodys:Array<Body>;
	
	var targetSize:{width:Float, height:Float};
	var targetSeperation:Float;
	var stageRect:Rectangle;
	var numOfTargets:Int;
	
	override public function begin():Void {
		super.begin();
		
		targetSize = TaskBlockDataGenerator.current.targetSizes[0];
		targetSeperation = TaskBlockDataGenerator.current.targetSeperations[0];
		stageRect = TaskBlockDataGenerator.current.stageRect;
		
		numOfTargets = Math.round(Math.max((stageRect.width / (targetSize.width + targetSeperation)) * (stageRect.height / (targetSize.height + targetSeperation)) * 0.7, 12));
		
		
		space = new Space(Broadphase.SWEEP_AND_PRUNE);
		space.worldLinearDrag = 0;
		
		var wallWidth = 50;
		
		//up
		var body = new Body(BodyType.STATIC);
		body.shapes.add(new Polygon(Polygon.rect(-wallWidth, -wallWidth, stageRect.width + wallWidth*2, wallWidth)));
		body.space = space;
		//left
		var body = new Body(BodyType.STATIC);
		body.shapes.add(new Polygon(Polygon.rect(-wallWidth, -wallWidth, wallWidth, stageRect.height + wallWidth*2)));
		body.space = space;
		//right
		var body = new Body(BodyType.STATIC);
		body.shapes.add(new Polygon(Polygon.rect(stageRect.width, -wallWidth, wallWidth, stageRect.height + wallWidth*2)));
		body.space = space;
		//bottom
		var body = new Body(BodyType.STATIC);
		body.shapes.add(new Polygon(Polygon.rect(-wallWidth, stageRect.height, stageRect.width + wallWidth*2, wallWidth)));
		body.space = space;
		
		var cm = HXP.engine.asMain().cursorManager;
		cm.cursorsEnabled = false;
		
		bodys = [];
		for (i in 0...numOfTargets) {
			var rect = GeomUtil.randomlyPlaceRectangle(
				stageRect, 
				new Rectangle(0, 0, targetSize.width, targetSize.height), 
				false
			);
			
			var body = new Body();
			
			var shape = new Circle(Math.max(rect.width + targetSeperation*0.5, rect.height + targetSeperation*0.5)*0.5);
			shape.material.dynamicFriction = 0;
			shape.material.staticFriction = 0;
			shape.material.rollingFriction = 0;
			body.shapes.add(shape);
			
			var shape = new Polygon(Polygon.box(rect.width + targetSeperation, rect.height + targetSeperation));
			shape.material.dynamicFriction = 0;
			shape.material.staticFriction = 0;
			shape.material.rollingFriction = 0;
			body.shapes.add(shape);
			
			body.position.x = rect.x;
			body.position.y = rect.y;
			body.allowRotation = false;
			body.align();
			body.space = space;
			bodys.push(body);
			
			var target = new Target();
			target.resize(targetSize.width.int(), targetSize.height.int());
			target.alpha = 0.5;
			body.graphic = cast target;
			add(target);
		}
	}
	
	public function replace():Void {
		for (body in bodys) {
			var rect = GeomUtil.randomlyPlaceRectangle(
				stageRect, 
				new Rectangle(0, 0, targetSize.width + TaskBlockDataGenerator.current.targetSeperations[0], targetSize.height + TaskBlockDataGenerator.current.targetSeperations[0]), 
				false
			);
			body.position.x = rect.x;
			body.position.y = rect.y;
		}
	}
	
	override public function update():Void {
		space.step(1/30);
		
		for (i in 0...numOfTargets) {
			var body = bodys[i];
			var target:Target = body.graphic;
			
			target.x = Math.round(body.position.x - targetSize.width * 0.5);
			target.y = Math.round(body.position.y - targetSize.height * 0.5);
		}

		if (space.liveBodies.length == 0) {
			if (Input.mouseDown || space.bodies.exists(function(body) {
				for (arbiter in body.arbiters) {
					for (contact in arbiter.collisionArbiter.contacts) {
						if (contact.penetration > 1) return true;
					}
				}
				return false;
			})) {
				replace();
			} else {
				
			}
		}
		
		super.update();
	}
	
	override public function end():Void {
		
		super.end();
	}
}