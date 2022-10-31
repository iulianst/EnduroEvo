using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;

class EnduroEvoSettingsMenu extends WatchUi.Menu2 {
    var mFontSizeLabel = ["Small","Medium", "Big"];
    function initialize() {
        var usemil=getApp().Properties.getValue("UseMilitaryFormat");
        var AlwaysOnSec=getApp().Properties.getValue("AlwaysOnSec");
        var sens =  new EnduroEvoSensors();
        var selectedLabel = sens.mSensorLabel[getApp().Properties.getValue("GraphData")];
        var selelctedFont = mFontSizeLabel[getApp().Properties.getValue("TimeFontSize") as Numeric];
        Menu2.initialize(null);
        Menu2.setTitle(new DrawableMenuTitle());
        Menu2.addItem( new WatchUi.MenuItem("Graph Data", selectedLabel , "GraphData",null));
		Menu2.addItem(new WatchUi.MenuItem("Colors", null,"Colors", null));
        Menu2.addItem(new WatchUi.MenuItem("Data Fields", null,"DataFields", null));
        Menu2.addItem(new WatchUi.MenuItem("Time Font Size", selelctedFont,"TimeFontSize", null));
        Menu2.addItem(new WatchUi.ToggleMenuItem("Always On Seconds", "impats battery life","AlwaysOnSec",AlwaysOnSec, null));
        Menu2.addItem(new WatchUi.ToggleMenuItem("Military Format", "for 24 Hour Time","UseMil",usemil, null));
    }    
}


class DrawableMenuTitle extends WatchUi.Drawable {
    var mIsTitleSelected = false;

    function initialize() {
        Drawable.initialize({});
    }

    function setSelected(isTitleSelected) {
        mIsTitleSelected = isTitleSelected;
    }

    // Draw the application icon and main menu title
    function draw(dc) {
        var spacing = 2;
        var appIcon = WatchUi.loadResource(Rez.Drawables.gear);
        var bitmapWidth = appIcon.getWidth();
        var labelWidth = dc.getTextWidthInPixels("Settings", Graphics.FONT_SMALL);

        var bitmapX = (dc.getWidth() - (bitmapWidth + spacing + labelWidth)) / 2;
        if(bitmapX <0) {bitmapX=0;}
        var bitmapY = (dc.getHeight() - appIcon.getHeight()) / 2;
        var labelX = bitmapX + bitmapWidth + spacing;
        var labelY = dc.getHeight() / 2;

        dc.clearClip();
        var bkColor = mIsTitleSelected ? Graphics.COLOR_BLUE : Graphics.COLOR_BLACK;
        dc.setColor(bkColor, bkColor);
        dc.clear();
        dc.drawBitmap(bitmapX, bitmapY, appIcon);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(labelX, labelY, Graphics.FONT_SMALL, "Settings", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
