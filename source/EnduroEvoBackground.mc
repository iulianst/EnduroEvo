using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.WatchUi;

class Background extends WatchUi.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc as Dc) as Void {
        // Set the background color then call to clear the screen
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx= w/2;
        var cy= h/2;
        var pct=0.7;
        var x1 = (w-(w*pct))/2;
        var x2 = w - (w-(w*pct))/2;
        
        System.println("Backround: draw");
        dc.setColor(getApp().Properties.getValue("ForegroundColor") as Number, getApp().Properties.getValue("BackgroundColor") as Number);
        dc.clear();

        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x1, h/3 ,x2, h/3);
        dc.drawLine(x1, h/3*2 ,x2, h/3*2);
        
        
    }

}
