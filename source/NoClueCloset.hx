package;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import flixel.FlxSprite;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.system.System;
import openfl.events.Event;
import sys.thread.Thread;
import flixel.FlxBasic;
import openfl.display.Bitmap;
import flixel.FlxG;
import haxe.Json;
import lime.ui.Window;
import lime.app.Application;
import lime.ui.WindowAttributes;

class NoClueCloset 
{   
    public static var debuggin:Bool = false;
    public static function start()
    {
        Sys.println("");
        Sys.println("noclue closet opened!");
        Sys.println("");

        for(i in Sys.args()){
            if(i.toLowerCase() == "nocluebruh") debuggin = true;
        }
    } 

    //unused mechanic
    public static function new_popup_window(w:Int, h:Int, title:String)
    {
        final atrr:WindowAttributes = {
			width: w,
			height: h,
			resizable: false,
			alwaysOnTop: true,
			title: title,
			frameRate: 0,
			context: {vsync: false, type: "opengles"},
			allowHighDPI: true
		};
        return Application.current.createWindow(atrr);
    }
}

typedef Popup__Info__animation = {
    var n:String;
    var f:Int;
    var l:Bool;
}
typedef Popup__Info =
{
    var graphic:String;
    var cA:Popup__Info__animation;
    var oA:Popup__Info__animation;
    var iA:Popup__Info__animation;
    var cr:Rectangle;
    var scale:Float;
} 

typedef Popup_Settings ={
    var interval:Float;
    var maxPopups:Int;
    var maxPopups_n:Int;
    var cooldown:Int ;
} 

class Popup extends FlxSprite
{
    public static var popupCount:Int = 0;
    public static var currentPopups:Array<Popup> = [];
    public static var popupSongs:Map<String, Popup_Settings> = [
        'diagraphephobia'=> {
            interval: 2,
            maxPopups: 8,
            maxPopups_n: 15,
            cooldown: 3
        }
    ];

    public static var availablePopups:Array<Popup__Info> = [{
        graphic: 'pop-up',
        cA: {n:'click', f: 24, l:false},
        oA: {n:'popup', f: 24, l:false},
        iA: {n:'popup0013', f: 24, l:false},
        cr: new Rectangle(290, 460, 340, 88),
        scale: 0.4
    }];

    public var popup_index:Int = 0;
    public var clickRect:Rectangle;

    private var closing:Bool = false;

    public function new()
    {
        super();

        if(PlayState.instance!=null) cameras = [PlayState.instance.camOther];
        
        popup_index = FlxG.random.int(0, availablePopups.length-1);
        final curr:Popup__Info = availablePopups[popup_index];

        frames = Paths.getSparrowAtlas('popups/' + curr.graphic);
        animation.addByPrefix('a', curr.oA.n, curr.oA.f, curr.oA.l);
        animation.addByPrefix('b', curr.iA.n, curr.iA.f, curr.iA.l);
        animation.addByPrefix('c', curr.cA.n, curr.cA.f, curr.cA.l);
        graphic.persist = true;

        animation.finishCallback = function (n:String){
            if(n == 'a') animation.play('b');
            else if(n == 'c')
            {
                destroy();
                FlxG.state.remove(this, true);
            }
        }
        
        animation.play('a');

        scale.set(curr.scale, curr.scale);
        updateHitbox();

        clickRect = new Rectangle(curr.cr.x * curr.scale,curr.cr.y * curr.scale,curr.cr.width * curr.scale,curr.cr.height * curr.scale);
        popupCount++;

        x = FlxG.random.float(0, FlxG.width - width);
        y = FlxG.random.float(0, FlxG.height - height);
        currentPopups.insert(0, this);
    }

    public static function u_p_d_a_t_e(elapsed:Float){
        if(!FlxG.mouse.justPressed) return;
        
        final pos = FlxG.mouse.getScreenPosition(PlayState.instance.camOther);
        for(i in currentPopups){
            if(pos.x >= i.x && pos.x < i.x + i.width && pos.y > i.y && pos.y < i.y + i.height){
                if(pos.x >= i.clickRect.x + i.x && pos.y >= i.clickRect.y + i.y && pos.x < i.clickRect.x + i.x + i.clickRect.width && pos.y < i.clickRect.y + i.y + i.clickRect.height) 
                {
                    i.animation.play('c');
                    currentPopups.remove(i);
                    popupCount--;
                    i.closing = true;
                }
                break;
            }
        }
    }

    public static function clear(){
        currentPopups = [];
        popupCount = 0;
    }
}


/*
//unused mechanic
typedef PopableFrame = 
{
    var path:String;
    var title:String;
    var scale:Float;

    @:optional var bm:BitmapData;
}
//
class PopUpWindow extends FlxBasic
{
    public static var windows:Array<PopUpWindow> = [];
    public static var windowLimit:Int = 5;

    public static var loadedData:Array<PopableFrame> = null;
    private var window:Window;

    private var xx:Int = 0;
    private var yy:Int = 0;
    private var rage:Int = 0;

    public static function addPopup()
    {
        if(windows.length > windowLimit)
            windows[FlxG.random.int(0, windows.length-1)].move();
        else FlxG.state.add(new PopUpWindow());
    }

    public function new()
    {
        super();

        final frame:PopableFrame = loadedData[FlxG.random.int(0, loadedData.length-1)];

        final img:Bitmap = new Bitmap(frame.bm.clone());
        img.scaleX = frame.scale;
        img.scaleY = frame.scale;
        var mainWindow = Application.current.window;

        window = NoClueCloset.new_popup_window(
            Math.floor(img.width), 
            Math.floor(img.height),
            frame.title
        ); 
        window.stage.addChild(img);
        rage = FlxG.random.int(5, 20);

        window.onClose.add(()->{
            mainWindow.focus();
            closin = true;
            FlxG.state.remove(this, true);
            destroy();
        });
        mainWindow.onClose.add(window.close);
        windows.push(this);

        move();
        mainWindow.focus();
    }

    public function move()
    {
        xx = FlxG.random.int(0, Math.round(Application.current.window.display.bounds.width - window.width));
        yy = FlxG.random.int(0, Math.round(Application.current.window.display.bounds.height - window.height));
    }

    var closin = false;
    var f = .0;
    override function update(elapsed:Float) {
        f+=elapsed;
        while (f > 1/40){
            //fixed updated babyyy
            //not 60+ fps cuz thats kinda fast lol
            window.move(xx + FlxG.random.int(-rage, rage),yy + FlxG.random.int(-rage, rage));
            f-=1/40;
        }
        super.update(elapsed);
    }

    override function destroy() 
    {
        if(!closin)
            window.close();
        
        window.stage.removeChildAt(0);
        windows.remove(this);
        super.destroy();
    }
}*/