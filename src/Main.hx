package;

import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.FPS;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.display.Tilesheet;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.Lib;
import nme.ui.Accelerometer;
import phx.Body;
import phx.col.AABB;
import phx.col.SortedList;
import phx.Polygon;
import phx.Shape;
import phx.Vector;
import phx.World;


class Main extends Sprite {
	
	
	private var logo:Bitmap;
	public static var sw:Int;
	public static var sh:Int;
	public static var ax:Float;
	public static var ay:Float;
	public static var az:Float;
	public static var bData:BitmapData;
	static public inline var PHYSICS_SCALE:Float = 1 / 30;
	var tilesheet:Tilesheet;
	var drawList:Array<Float>;
	var s:Sprite;
	var rect:Rectangle;
	private var world:World;
	public static inline var BOX_SIZE:Int = 20;
	public static var shape:Shape;
	
	public function new () {
		super ();
		addEventListener (Event.ADDED_TO_STAGE, this_onAddedToStage);
	}

	private function construct () {

		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		bData = Assets.getBitmapData("assets/nme.png");
		stage.addEventListener(MouseEvent.CLICK, logo_click);
		
		resize ();
		
		var size = new AABB( -1000, -1000, 1000, 1000);
		var bf = new SortedList();
		world = new World(size, bf);
		world.gravity = new Vector(0, 0.9);
		world.sleepEpsilon = 0;
		
		createBox(-20, 0, 40, sh, false);
		createBox(sw-20, 0, 40, sh, false);
		createBox(0, -20, sw, 40, false);
		createBox(0, sh-20, sw, 40, false);
		
		rect = new Rectangle (0, 0, bData.width, bData.height);
		tilesheet = new Tilesheet(bData);
		tilesheet.addTileRect(rect);
		
		s = new Sprite();
		drawList = new Array<Float>();
		addChild(s);
		
		for (i in 0...100) {
			createBox(Math.random() * stage.stageWidth, Math.random() * stage.stageHeight, BOX_SIZE, BOX_SIZE, true);
		}
		
		//addChild (logo);
		
		var f = new FPS();
		f.textColor = 0xFF0000;
		f.y = -3;
		f.x = 20;
		addChild(f);
		
		stage.addEventListener (Event.RESIZE, stage_onResize);
		stage.addEventListener (Event.ENTER_FRAME, update);
		
		ax = ay = 0;
		
		shape = Shape.makeBox(BOX_SIZE, BOX_SIZE);
	}
	
	private function createBox (x:Float, y:Float, width:Float, height:Float, dynamicBody:Bool):Body {
		if (dynamicBody) {
			var b:Body = new Body(x, y);
			var shape:Shape = Shape.makeBox(width, height);
			//shape.material.friction = 0.5;
			b.addShape(shape);
			
			//b.addShape(new phx.Circle(width/2, new Vector(0,0)));
			b.updatePhysics();
			world.addBody(b);
			return b;
		} else {
			world.addStaticShape(Shape.makeBox(width, height, x, y));
			return null;
		}
	}
	
	private function update(e:Event) {
		
		
		#if !flash
		var acc = Accelerometer.get();
		if (acc != null) {
			ax = acc.x;
			ay = -acc.y;
			az = acc.z;
		} else {
			ay = 0.2;
		}
		world.gravity.set(ax, ay);
		#end
		
		world.step(0.5,3);
		world.step(0.5,3);
		//world.step(1,10);
		
        //var g = nme.Lib.current.graphics;
        //g.clear();
        //var fd = new phx.FlashDraw(g);
        //fd.drawCircleRotation = true;
        //fd.drawWorld(world);
		
		var i = 0;
		for (c in world.bodies) {
			drawList[i++] = c.x - Math.cos(c.a+Math.PI/4) * BOX_SIZE / Math.sqrt(2);
			drawList[i++] = c.y - Math.sin(c.a+Math.PI/4) * BOX_SIZE / Math.sqrt(2);
			drawList[i++] = 0;
			drawList[i++] = 0.15;
			drawList[i++] = -c.a;
		}
		s.graphics.clear();
		tilesheet.drawTiles(s.graphics, drawList, false, Tilesheet.TILE_SCALE | Tilesheet.TILE_ROTATION);
		//s.graphics.drawTiles(tilesheet, drawList, false, Graphics.TILE_SCALE | Graphics.TILE_ROTATION);
	}
	
	private function logo_click(e:MouseEvent):Void 
	{
		//if (logo.hitTestPoint(e.stageX, e.stageY)) {
			for (i in 0...50) {
				var b = createBox(e.stageX, e.stageY, BOX_SIZE, BOX_SIZE, true);
				b.setSpeed(Math.random()*20-10, Math.random()*20-10);
			}
		//}
	}
	
	
	private function resize () {
		//logo.x = (stage.stageWidth - logo.width) / 2;
		//logo.y = (stage.stageHeight - logo.height) / 2;
		sw = stage.stageWidth;
		sh = stage.stageHeight;
	}
	
	private function stage_onResize (event:Event):Void {
		resize ();
	}
	
	private function this_onAddedToStage (event:Event):Void {
		removeEventListener(Event.ADDED_TO_STAGE, this_onAddedToStage);
		construct ();
	}
	
	public static function main () {
		Lib.current.addChild (new Main ());
	}
}
