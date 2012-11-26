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
	// Storage of the NME logo bitmap
	public static var bitmapLogo:BitmapData;

	// StageWidth
	public static var sw:Int;
	// StageHeight
	public static var sh:Int;

	static public inline var PHYSICS_SCALE:Float = 1 / 30;
	var tilesheet:Tilesheet;
	var drawList:Array<Float>;
	var rect:Rectangle;
	private var world:World;
	public static inline var BOX_SIZE:Int = 20;

	private function construct () {
		// Setup stage.
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		// Store stage height/width
		resize ();
		
		var size = new AABB( -1000, -1000, 1000, 1000);
		var bf = new SortedList();
		world = new World(size, bf);
		world.gravity = new Vector(0, 0.9);
		//world.sleepEpsilon = 0;
			
		// Create world bounds.
		createBox(-20, 0, 40, sh, false);
		createBox(sw - 20, 0, 40, sh, false);
		createBox(0, -20, sw, 40, false);
		createBox(0, sh-20, sw, 40, false);
		
		// Init drawList for drawTiles
		drawList = new Array<Float>();
		// Load logo bitmap image
		bitmapLogo = Assets.getBitmapData("assets/nme.png");
		// Create a new Tilesheet using the bitmap logo data
		tilesheet = new Tilesheet(bitmapLogo);
		// Create a rectangle specifying the bitmap on the tilesheet (normally there is more than one image per tilesheet.
		rect = new Rectangle (0, 0, bitmapLogo.width, bitmapLogo.height);
		// Add the Rectangle as the first Tile
		tilesheet.addTileRect(rect);
		
		// Create the initial 100 on-screen boxes.
		for (i in 0...100) {
			createBox(Math.random() * stage.stageWidth, Math.random() * stage.stageHeight, BOX_SIZE, BOX_SIZE, true);
		}
				
		// Add FPS display
		var f = new FPS();
		f.textColor = 0xFF0000;
		f.y = -3;
		f.x = 20;
		addChild(f);

		// Add Event listeners
		stage.addEventListener(MouseEvent.CLICK, stage_onClick);
		stage.addEventListener(Event.RESIZE, stage_onResize);
		stage.addEventListener(Event.ENTER_FRAME, update);
	}
	
	private function createBox (x:Float, y:Float, width:Float, height:Float, dynamicBody:Bool):Body {
		if (dynamicBody) {
			// Create a new phyaxe Body
			var b:Body = new Body(x, y);
			// Create a new physaxe Shape, without a shape the body is nothing.
			var shape:Shape = Shape.makeBox(width, height);
			// Specify the friction coefficient of the shape
			shape.material.friction = 0.5;
			// Add the shape to the Body.
			b.addShape(shape);

			// Circle test.
			//b.addShape(new phx.Circle(width/2, new Vector(0,0)));
			// Update physics after changing the Body's Shape.
			b.updatePhysics();
			// Add the Body to the World
			world.addBody(b);
			return b;
		}
		else {
			// Create a Static non-moving shape.
			world.addStaticShape(Shape.makeBox(width, height, x, y));
			return null;
		}
	}
	
	private function update(e:Event) {
		
		// If not Flash, attempt to use Accelerometer data
		#if !flash
		var acc = Accelerometer.get();
		if (acc != null) {
			var ax = acc.x;
			var ay = -acc.y;
			//var az = acc.z;
			// Set gravity vector
			world.gravity.set(ax, ay);
		}
		#end
		
		world.step(1,10);
		
        //var g = nme.Lib.current.graphics;
        //g.clear();
        //var fd = new phx.FlashDraw(g);
        //fd.drawCircleRotation = true;
        //fd.drawWorld(world);
		
		// Create the drawList for drawTiles
		var i = 0;
		var box_sqrt = BOX_SIZE / Math.sqrt(2);
		for (c in world.bodies) {
			drawList[i++] = c.x - Math.cos(c.a+Math.PI/4) * box_sqrt;
			drawList[i++] = c.y - Math.sin(c.a+Math.PI/4) * box_sqrt;
			drawList[i++] = 0;
			drawList[i++] = 0.15;
			drawList[i++] = -c.a;
		}
		// Clear the current display
		this.graphics.clear();
		// Draw the tiles. http://code.google.com/p/nekonme/source/browse/trunk/nme/display/Tilesheet.hx?r=1600
		tilesheet.drawTiles(this.graphics, drawList, false, Tilesheet.TILE_SCALE | Tilesheet.TILE_ROTATION);
	}
	
	/**
	 * Stage onClick listener, creates new boxes on click.
	 * @param	event
	 */
	private function stage_onClick(event:MouseEvent):Void {
		for (i in 0...50) {
			// Create a new box at the mouse x/y
			var b = createBox(event.stageX, event.stageY, BOX_SIZE, BOX_SIZE, true);
			// Set a random speed/direction.
			b.setSpeed(Math.random() * 20 - 10, Math.random() * 20 - 10);
		}
	}
	
	
	/**
	 * Stage onResize event listener
	 * @param	event
	 */
	private function stage_onResize (event:Event):Void {
		// @todo: Actually resize the content.
		resize();
	}

	/**
	 * Called by resize listener, stores stage info.
	 */
	private function resize () {
		// @todo remove?
		sw = stage.stageWidth;
		sh = stage.stageHeight;
	}

	/**
	 * Program execution entry function
	 */
	public static function main () {
		// Add Main() class to the stage.
		Lib.current.addChild (new Main ());
	}

	/**
	 * Main class constructor function
	 */
	public function new () {
		super ();
		// Add a listener to wait for the stage to be available.
		addEventListener (Event.ADDED_TO_STAGE, this_onAddedToStage);
	}
	
	/**
	 * Event.ADDED_TO_STAGE listener, insantiaites remainder of program.
	 * @param	event
	 */
	private function this_onAddedToStage (event:Event):Void {
		// Remove self as a listener.
		removeEventListener(Event.ADDED_TO_STAGE, this_onAddedToStage);
		// Call program constructor, which expects existing stage.
		construct();
	}
}
