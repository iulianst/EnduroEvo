using Toybox.WatchUi;


class EnduroEvoSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
	var mSensIndex = 0;
	var mFontSizeLabel = ["Small","Medium", "Big"];
	var mFontIndex=0;
    function initialize() {
		mSensIndex = getApp().Properties.getValue("GraphData") as Numeric;
		mFontIndex = getApp().Properties.getValue("TimeFontSize") as numeric;
        Menu2InputDelegate.initialize();
    }

  	function onSelect(item) {
  		var id=item.getId();
		
        if(id.equals("GraphData")) {
			var sens =  new EnduroEvoSensors();
        	//var selectedLabel = sens.mSensorLabel[id];
			mSensIndex++; 
			if( mSensIndex > sens.mSensorLabel.size()-1 ) {mSensIndex = 0;}
			//if(mSensIndex > 7) {mSensIndex=0;}
			item.setSubLabel(sens.mSensorLabel[mSensIndex]);
			getApp().Properties.setValue("GraphData", mSensIndex);
			getApp().onSettingsChanged();
        	WatchUi.requestUpdate();
		} else if( item.getId().equals("Colors") ) {
            // When the icon menu item is selected, push a new menu that demonstrates
            // left and right custom icon menus
            var iconMenu = new WatchUi.Menu2({:title=>"Colors"});
            var drawable1 = new CustomIcon(getApp().Properties.getValue("BackgroundColor"));
            var drawable2 = new CustomIcon(getApp().Properties.getValue("ForegroundColor"));
            var drawable3 = new CustomIcon(getApp().Properties.getValue("Marker1Color"));
			var drawable4 = new CustomIcon(getApp().Properties.getValue("Marker2Color"));
			var drawable5 = new CustomIcon(getApp().Properties.getValue("Marker3Color"));
			var drawable6 = new CustomIcon(getApp().Properties.getValue("Marker4Color"));

            iconMenu.addItem(new WatchUi.IconMenuItem("Background", drawable1.getString(), 1, drawable1, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
			iconMenu.addItem(new WatchUi.IconMenuItem("Foreground", drawable2.getString(), 2, drawable2, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            iconMenu.addItem(new WatchUi.IconMenuItem("Marker 1", drawable3.getString(), 3, drawable3, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            iconMenu.addItem(new WatchUi.IconMenuItem("Marker 2", drawable4.getString(), 4, drawable4, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
			iconMenu.addItem(new WatchUi.IconMenuItem("Marker 3", drawable5.getString(), 5, drawable5, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
			iconMenu.addItem(new WatchUi.IconMenuItem("Marker 4", drawable6.getString(), 6, drawable6, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            WatchUi.pushView(iconMenu, new EnduroEvoSettingsL2Delegate(), WatchUi.SLIDE_UP );
		} else if(item.getId().equals("TimeFontSize")) {
			mFontIndex++; 
			if(mFontIndex > 2) {mFontIndex=0;}
			item.setSubLabel(mFontSizeLabel[mFontIndex]);
			getApp().Properties.setValue("TimeFontSize", mFontIndex);
			getApp().onSettingsChanged();
        	WatchUi.requestUpdate();
		
		} else if(item.getId().equals("AlwaysOnSec")) {
			getApp().Properties.setValue("AlwaysOnSec",item.isEnabled());
			getApp().onSettingsChanged();
        	WatchUi.requestUpdate();
		
        } else if(item.getId().equals("UseMil")) {
			getApp().Properties.setValue("UseMilitaryFormat",item.isEnabled());
			getApp().onSettingsChanged();
        	WatchUi.requestUpdate();
		}
		else if(item.getId().equals("DataFields")) {
			var Menu = new WatchUi.Menu2({:title=>"Fields Data"});     
			var dataLabels  = new EnduroEvoDataField().mShortLabel;    
			var selectedLabel = dataLabels[getApp().Properties.getValue("Field1Data")];
            Menu.addItem( new WatchUi.MenuItem("Field 1 Data", selectedLabel , 6,null));
			selectedLabel = dataLabels[getApp().Properties.getValue("Field2Data")];
			Menu.addItem( new WatchUi.MenuItem("Field 2 Data", selectedLabel , 7,null));
			selectedLabel = dataLabels[getApp().Properties.getValue("Field3Data")];
			Menu.addItem( new WatchUi.MenuItem("Field 3 Data", selectedLabel , 8,null));
			selectedLabel = dataLabels[getApp().Properties.getValue("Field4Data")];
			Menu.addItem( new WatchUi.MenuItem("Field 4 Data", selectedLabel , 9,null));
			selectedLabel = dataLabels[getApp().Properties.getValue("Field5Data")];
			Menu.addItem( new WatchUi.MenuItem("Field 5 Data", selectedLabel , 10,null));
			selectedLabel = dataLabels[getApp().Properties.getValue("Field6Data")];
			Menu.addItem( new WatchUi.MenuItem("Field 6 Data", selectedLabel , 11,null));
			selectedLabel = dataLabels[getApp().Properties.getValue("Field7Data")];
			Menu.addItem( new WatchUi.MenuItem("Field 7 Data", selectedLabel , 12,null));
			Menu.pushView(Menu, new EnduroEvoSettingsL2Delegate(), WatchUi.SLIDE_UP );
		}
	}
  	
  	function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return false;
    }
}

class EnduroEvoSettingsL2Delegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }
  	function onSelect(item) {
			if(item instanceof IconMenuItem) {
				item.setSubLabel(item.getIcon().nextState());
				if(item.getId()==1) {getApp().Properties.setValue("BackgroundColor", item.getIcon().getColor());}
				if(item.getId()==2) {getApp().Properties.setValue("ForegroundColor", item.getIcon().getColor());}
				if(item.getId()==3) {getApp().Properties.setValue("Marker1Color", item.getIcon().getColor());}
				if(item.getId()==4) {getApp().Properties.setValue("Marker2Color", item.getIcon().getColor());}
				if(item.getId()==5) {getApp().Properties.setValue("Marker3Color", item.getIcon().getColor());}
				if(item.getId()==6) {getApp().Properties.setValue("Marker4Color", item.getIcon().getColor());}

			}
		else if(item instanceof MenuItem) {
			var str = Lang.format("Field$1$Data", [item.getId()-5]);
			var dataLabels  = new EnduroEvoDataField().mShortLabel;
			var selectedIbdex = getApp().Properties.getValue(str);
			selectedIbdex++;
			if( selectedIbdex >= dataLabels.size() ) {selectedIbdex = 0;}

			item.setSubLabel(dataLabels[selectedIbdex]);
			getApp().Properties.setValue(str, selectedIbdex);
		}
		getApp().onSettingsChanged();
        WatchUi.requestUpdate();
	}
  	
  	function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return false;
    }
}

class CustomIcon extends WatchUi.Drawable {
    const mColorStrings = ["White","Light Gray","Dark Gray","Black","Red","Dark Red","Orange","Yellow","Green","Dark Green","Blue","Dark Blue","Purple","Pink"];
    const mColors = [Graphics.COLOR_WHITE,Graphics.COLOR_LT_GRAY,Graphics.COLOR_DK_GRAY,Graphics.COLOR_BLACK,Graphics.COLOR_RED,
        Graphics.COLOR_DK_RED,Graphics.COLOR_ORANGE,Graphics.COLOR_YELLOW,Graphics.COLOR_GREEN,Graphics.COLOR_DK_GREEN,
        Graphics.COLOR_BLUE,Graphics.COLOR_DK_BLUE,Graphics.COLOR_PURPLE,Graphics.COLOR_PINK];
    var mIndex;

    function initialize( color as Lang.Number or Null) {
        Drawable.initialize({});
		if(null != color) {mIndex =  mColors.indexOf(color);}
        else { mIndex = 0;}
    }

    // Advance to the next color state for the drawable
    function nextState() {
        mIndex++;
        if(mIndex >= mColors.size()) {
            mIndex = 0;
        }
        return mColorStrings[mIndex];
    }

    // Return the color string for the menu to use as it's sublabel
    function getString() {
        return mColorStrings[mIndex];
    }
	function getColor() {
        return mColors[mIndex];
    }
	function setColor(color as Lang.Number) {
        mIndex =  mColors.indexOf(color);
    }

    // Set the color for the current state and use dc.clear() to fill
    // the drawable area with that color
    function draw(dc) {
		dc.clearClip();
        var color = mColors[mIndex];
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2-2);
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		dc.drawCircle(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2-1);
    }
}
