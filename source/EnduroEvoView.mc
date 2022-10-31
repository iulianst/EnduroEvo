using Toybox.Application;
using Toybox.ActivityMonitor;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Activity;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Weather;


var partialUpdatesAllowed = false;
var count =0;

class EnduroEvoView extends WatchUi.WatchFace {

    private var isAwake;
    private var scr_width;
    private var scr_height;
    private var cx;
    private var cy;
    private var fontWI;
    private var fontTime;
    private var fontData, fontText;
    private var sens = new EnduroEvoSensors();
    private var mBgColor; var mFgColor;
    private var mGDataIndex; 
    private var mMarker1Color;var mMarker2Color;var mMarker3Color; var mMarker4Color;
    private var mUseMil, mAlwaysOnSec, mTimeFontSize;
    private var curClip;
    private var mLatOffset = 60;
    private var mExH;
    private var mExBattery as Lang.Float;
    private var mActBattCons as Lang.Float;
    private var mExHR as Lang.Number;
    private var mDataFieldsIndex = new[8];
    private var mDataField = new EnduroEvoDataField();
    


    function initialize() {
        isAwake = true;
        mExH = 24;
        mExBattery=100.00;
        mActBattCons=0.00;
        mExHR = 40;

        partialUpdatesAllowed = ( Toybox.WatchUi.WatchFace has :onPartialUpdate );

        

        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        scr_width  = dc.getWidth();
        scr_height = dc.getHeight();
        cx = scr_width/2;
        cy = scr_height/2;

        
        
        ReadSettings();

        

        curClip = null;
        
        fontData = WatchUi.loadResource(Rez.Fonts.Data);
        fontText = WatchUi.loadResource(Rez.Fonts.Text);
        fontWI = WatchUi.loadResource(Rez.Fonts.WI);
        //fontTime = Graphics.FONT_SYSTEM_NUMBER_MEDIUM;
        //fontData = Graphics.FONT_GLANCE_NUMBER;

        
        //var a = scr_height/3*2-dc.getFontHeight(fontData);
        //var b = cy -dc.getFontHeight(fontData);
        //var c = cy; //+dc.getFontHeight(fontData);

        getApp().mYDataBL = cy; 
        getApp().mYDataTL = cy -dc.getFontHeight(fontData);
        //getApp().mYDataBL = scr_height/3*2-dc.getFontHeight(fontData);
        //getApp().mYDataTL = scr_height/3;

        

        //setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        
    }

    function ReadSettings() as Void { 
        mGDataIndex = getApp().Properties.getValue("GraphData");
        mBgColor = getApp().Properties.getValue("BackgroundColor");
        mFgColor = getApp().Properties.getValue("ForegroundColor");
        mMarker1Color = getApp().Properties.getValue("Marker1Color");
        mMarker2Color = getApp().Properties.getValue("Marker2Color");
        mMarker3Color = getApp().Properties.getValue("Marker3Color");
        mMarker4Color = getApp().Properties.getValue("Marker4Color");
        mUseMil = getApp().Properties.getValue("UseMilitaryFormat");
        mAlwaysOnSec = getApp().Properties.getValue("AlwaysOnSec");
        mTimeFontSize = getApp().Properties.getValue("TimeFontSize") as Numeric;
        switch (mTimeFontSize) {
            case 2:
                fontTime = WatchUi.loadResource(Rez.Fonts.TimeBig);
                break;
            case 1:
                fontTime = WatchUi.loadResource(Rez.Fonts.TimeMedium);
                break;
            default:
                fontTime = WatchUi.loadResource(Rez.Fonts.TimeSmall);
                break;
        }
        mDataFieldsIndex[0] = getApp().Properties.getValue("Field1Data") as Numeric;
        mDataFieldsIndex[1] = getApp().Properties.getValue("Field2Data") as Numeric;
        mDataFieldsIndex[2] = getApp().Properties.getValue("Field3Data") as Numeric;
        mDataFieldsIndex[3] = getApp().Properties.getValue("Field4Data") as Numeric;
        mDataFieldsIndex[4] = getApp().Properties.getValue("Field5Data") as Numeric;
        mDataFieldsIndex[5] = getApp().Properties.getValue("Field6Data") as Numeric;
        mDataFieldsIndex[6] = getApp().Properties.getValue("Field7Data") as Numeric;
    }

    // Draw the watch face background
    // onUpdate uses this method to transfer newly rendered Buffered Bitmaps
    // to the main display.
    // onPartialUpdate uses this to blank the second hand from the previous
    // second before outputing the new one.
    

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get the current time and format it correctly
        //var timeFormat = "$1$:$2$:$3$";
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var dinfo = ActivityMonitor.getInfo();
        var actday = dinfo.activeMinutesDay.total;
        var actwk = dinfo.activeMinutesWeek.total;
        var actgoal = dinfo.activeMinutesWeekGoal;
        var actpercent   = (actwk.toFloat()/actgoal.toFloat()).toFloat();
        var actInfo = Activity.getActivityInfo();
        var timeBox = new [4];
        var pct=0.7;
        var x1 = (scr_width-(scr_width*pct))/2;
        var x2 = scr_width - (scr_width-(scr_width*pct))/2;

        var oConditions = Weather.getCurrentConditions();
        var wLocStr = "----";
        if (oConditions != null){
            wLocStr =  oConditions.observationLocationName;
        }
        if(wLocStr != null) { 
            wLocStr= wLocStr.substring(0, 3);
        }
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format(
                "$1$ $2$ $3$ $4$",
                [
                    today.day_of_week,
                    today.day,
                    today.month,
                    wLocStr
                ]
            );
        

        if (clockTime.hour != mExH) {
            var batt = System.getSystemStats().battery ;
            mExH = clockTime.hour;
            mActBattCons =  mExBattery - batt;
            mExBattery= batt;
        }

        View.onUpdate(dc);

        if(partialUpdatesAllowed) {
            dc.clearClip();
            }
        
        dc.setColor(mFgColor,mBgColor);
        dc.clear();
        /* // Draw a test pie
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        var c = getCoordinates(scr_width/2,220);
        var poly = [
            [c[0],c[1]],
            [c[0],scr_height],
            [scr_width,scr_height],
            [scr_width,0],
            [scr_width/2,0],
            [cx,cy],
        ];
        dc.fillPolygon(poly);
        */
        dc.setPenWidth(2);
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x1, scr_height/3 ,x2, scr_height/3);
        dc.drawLine(x1, scr_height/3*2 ,x2, scr_height/3*2);

        dc.setColor(mFgColor,Graphics.COLOR_TRANSPARENT);
    
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
                timeFormat = "$1$:$2$";
            }
        } else {
            if (mUseMil) {                
                timeFormat = "$1$$2$";
            }
        }   
        hours = hours.format("%02d");
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);

        dc.setColor(mFgColor,Graphics.COLOR_TRANSPARENT	);
        timeBox[0] = cx - dc.getTextDimensions(timeString, fontTime)[0]/2;
        timeBox[1] = scr_height/3-5;//cy - dc.getTextDimensions(timeString, fontTime)[1]/2 - 15;
        timeBox[2] = cx + dc.getTextDimensions(timeString, fontTime)[0]/2;
        timeBox[3] = cy + dc.getTextDimensions(timeString, fontTime)[1]/2 - 15 ;
       // dc.drawRectangle(timeBox[0], timeBox[1], timeBox[2]-timeBox[0],timeBox[3]-timeBox[1] );

        dc.drawText(cx,scr_height/3*2-dc.getFontHeight(fontText), fontText, dateString, Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawText(timeBox[0],timeBox[1], fontTime, timeString, Graphics.TEXT_JUSTIFY_LEFT);
   
        //Data Field 1    
        mDataField.drawField(dc, cx-10, scr_height/3 - dc.getFontHeight(fontData)*2+10, mDataFieldsIndex[0], Graphics.TEXT_JUSTIFY_RIGHT);
        //Data Field 2
        mDataField.drawField(dc, cx+10, scr_height/3 - dc.getFontHeight(fontData)*2+10, mDataFieldsIndex[1], Graphics.TEXT_JUSTIFY_LEFT);
        //Data Field 3
        mDataField.drawField(dc, cx-10, scr_height/3 - dc.getFontHeight(fontData), mDataFieldsIndex[2], Graphics.TEXT_JUSTIFY_RIGHT);
        //Data Field 4
        mDataField.drawField(dc, cx+10, scr_height/3 - dc.getFontHeight(fontData), mDataFieldsIndex[3], Graphics.TEXT_JUSTIFY_LEFT);
        //Data Field 5
        mDataField.drawField(dc, mLatOffset, getApp().mYDataTL, mDataFieldsIndex[4], Graphics.TEXT_JUSTIFY_RIGHT);
        //Data Field 6
        mDataField.drawField(dc, scr_width-mLatOffset, getApp().mYDataTL, mDataFieldsIndex[5], Graphics.TEXT_JUSTIFY_LEFT);
        var hr=actInfo.currentHeartRate;
        if (hr==null) {
            hr=mDataField.getHR();
            if (hr==null) {
                hr=0;
            }
        }

           

        var temp = sens.getTemperature();

        //sens.draw(dc,0);
        sens.draw(dc,mGDataIndex);
      

        drawMark(dc,0,10, Graphics.COLOR_WHITE);
        drawMark(dc,30,5, Graphics.COLOR_WHITE);
        drawMark(dc,60,5, Graphics.COLOR_WHITE);
        drawMark(dc,330,5, Graphics.COLOR_WHITE);
        drawMark(dc,300,5, Graphics.COLOR_WHITE);
        var angle_ring1 = (System.getSystemStats().battery *360/100);
        var angle_ring2 = (actpercent*360);   
        //var angle_ring3 = 60 * 360 / 120;
        var angle_ring3 = mDataField.getValue(14) * 360 / 120;

        drawHashIndicator(dc,dinfo.steps *360/dinfo.stepGoal,scr_width/2-10,10,mMarker1Color,0);
        drawHashIndicator(dc,angle_ring1,scr_width/2-1,10,mMarker2Color,3);
        drawHashIndicator(dc,angle_ring2,scr_width/2-1,10,mMarker3Color,2);
        drawHashIndicator(dc,angle_ring3,scr_width/2-1,10,mMarker4Color,1);
        
        dc.setColor(mFgColor,Graphics.COLOR_TRANSPARENT	);

        dc.drawText(mLatOffset, getApp().mYDataBL , fontData, hr.toString(), Graphics.TEXT_JUSTIFY_RIGHT);
        

        if( partialUpdatesAllowed && mAlwaysOnSec) {
            // If this device supports partial updates and they are currently
            // allowed run the onPartialUpdate method to draw the seconds
            onPartialUpdate( dc );
        } else if ( isAwake ) {
            dc.drawText(scr_width-mLatOffset, getApp().mYDataBL , fontData, clockTime.sec.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT);
            
        }
        else{
            dc.setColor(Graphics.COLOR_ORANGE,Graphics.COLOR_TRANSPARENT);
            mDataField.drawField(dc, scr_width-mLatOffset, getApp().mYDataBL, mDataFieldsIndex[6], Graphics.TEXT_JUSTIFY_LEFT);
            dc.setColor(mFgColor,Graphics.COLOR_TRANSPARENT	);
        }
  
    }

    function getWIIcon(index){    
        var charNul = -65 + 'A'; 
        return index +  charNul;        
    }

     function onPartialUpdate( dc ) {
        if(mAlwaysOnSec) {            
            var clockTime = System.getClockTime();
            var value = clockTime.sec.format("%02d");
            var ax= scr_width-mLatOffset;
            var ay = getApp().mYDataBL  ;
            var width = dc.getTextWidthInPixels(value, fontData);
            var height = dc.getFontHeight(fontData);
            dc.setClip(ax, ay, width, height);
            dc.setColor(mFgColor,mBgColor);
            dc.clear();
            dc.drawText(ax, ay, fontData, value, Graphics.TEXT_JUSTIFY_LEFT);              
            var HR =  Activity.getActivityInfo().currentHeartRate;
            if (HR==null) {HR=0;}
           // if (HR != mExHR){
                mExHR=HR;
                value=HR.toString();
                ax= mLatOffset;
                ay = getApp().mYDataBL  ;
                width = dc.getTextWidthInPixels(value, fontData);
                height = dc.getFontHeight(fontData);
                //dc.clearClip();
                dc.setClip(ax-width, ay, width, height);
                dc.setColor(mFgColor,mBgColor);
                dc.clear();
                dc.drawText(ax, ay, fontData, value, Graphics.TEXT_JUSTIFY_RIGHT);
           // }
        }
    }   


// Compute a bounding box from the passed in points
function getBoundingBox( points ) {
    var min = [9999,9999];
    var max = [0,0];
     for (var i = 0; i < points.size(); ++i) {
            if(points[i][0] < min[0]) {
                min[0] = points[i][0];
            }
            if(points[i][1] < min[1]) {
                min[1] = points[i][1];
            }
            if(points[i][0] > max[0]) {
                max[0] = points[i][0];
            }
            if(points[i][1] > max[1]) {
                max[1] = points[i][1];
            }
    }
    return [min, max];
}

    function drawHashIndicator(dc as Dc or Null, angle, rad, len, color, shape){
        // If gets dc == null will return coordinates 
        // otherwise will draaw and return coordinates
        var cos = new [5];
        var sin = new [5];
        for (var i=0; i<=4;i++){              
            cos[i] = Math.cos(Math.toRadians(angle-90+(i*3)-6));  
            sin[i] = Math.sin(Math.toRadians(angle-90+(i*3)-6));
        }
        // triangle
         
        var x = new [7];
        var y = new [7];
        switch (shape){
            case 0:   //triangle     
            x[1] = cx + (rad-len) * cos[0];
            y[1] = cy + (rad-len) * sin[0];
            x[0] = cx + (rad) * cos[2];
            y[0] = cy + (rad) * sin[2];
            x[2] = cx + (rad-len) * cos[4];
            y[2] = cy + (rad-len) * sin[4];
            x[3] = cx + (rad-len) * cos[4];
            y[3] = cy + (rad-len) * sin[4];
            x[4] = cx + (rad-len) * cos[4];
            y[4] = cy + (rad-len) * sin[4];
            x[5] = cx + (rad-len) * cos[4];
            y[5] = cy + (rad-len) * sin[4];
            x[6] = cx + (rad-len) * cos[4];
            y[6] = cy + (rad-len) * sin[4];
            break;        
            case 1: // arrow point
            x[0] = cx + (rad-len) * cos[0];
            y[0] = cy + (rad-len) * sin[0];
            x[1] = cx + (rad-len) * cos[1];
            y[1] = cy + (rad-len) * sin[1];
            x[2] = cx + (rad-len+5) * cos[2];
            y[2] = cy + (rad-len+5) * sin[2];
            x[3] = cx + (rad-len) * cos[3];
            y[3] = cy + (rad-len) * sin[3];
            x[4] = cx + (rad-len) * cos[4];
            y[4] = cy + (rad-len) * sin[4];
            x[5] = cx + (rad) * cos[2];
            y[5] = cy + (rad) * sin[2];
            x[6] = cx + (rad) * cos[2];
            y[6] = cy + (rad) * sin[2];
            break;
            case 2: // arrow end1
            x[0] = cx + (rad-len) * cos[0];
            y[0] = cy + (rad-len) * sin[0];
            x[1] = cx + (rad-len) * cos[1];
            y[1] = cy + (rad-len) * sin[1];
            x[2] = cx + (rad-len+5) * cos[2];
            y[2] = cy + (rad-len+5) * sin[2];
            x[3] = cx + (rad-len) * cos[3];
            y[3] = cy + (rad-len) * sin[3];
            x[4] = cx + (rad-len) * cos[4];
            y[4] = cy + (rad-len) * sin[4];
            x[5] = cx + (rad) * cos[3];
            y[5] = cy + (rad) * sin[3];
            x[6] = cx + (rad) * cos[1];
            y[6] = cy + (rad) * sin[1];
            break;
            case 3: // arrow end1
            x[0] = cx + (rad-len) * cos[0];
            y[0] = cy + (rad-len) * sin[0];
            x[1] = cx + (rad-len) * cos[1];
            y[1] = cy + (rad-len) * sin[1];
            x[2] = cx + (rad-len+5) * cos[2];
            y[2] = cy + (rad-len+5) * sin[2];
            x[3] = cx + (rad-len) * cos[3];
            y[3] = cy + (rad-len) * sin[3];
            x[4] = cx + (rad-len) * cos[4];
            y[4] = cy + (rad-len) * sin[4];
            x[5] = cx + (rad) * cos[4];
            y[5] = cy + (rad) * sin[4];
            x[6] = cx + (rad) * cos[0];
            y[6] = cy + (rad) * sin[0];
            break;
            default:
            break;
        }
        var result = new[7];
        for( var i =0; i<7; i++){
            result[i] = [x[i],y[i]];
        }
        if (null != dc){
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);	
            dc.fillPolygon(result);
        }
        return result;
    }

    function drawMark(dc, angle, len, color){
        var rad = cx-1;
        var theta = Math.toRadians(angle-90); 
        var cos = Math.cos(theta) ;  
        var sin = Math.sin(theta);   
        var x2 = cx + rad * cos;
        var y2 = cy + rad * sin;
        var x1 = cx + (rad-len) * cos;
        var y1 = cy + (rad-len) * sin;

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);	
        dc.drawLine(x1, y1, x2, y2);
    }

    function getCoordinates(rad, angle){
        var theta = Math.toRadians(angle-90); 
        var cos = Math.cos(theta) ;  
        var sin = Math.sin(theta);   
        var x = cx + rad * cos;
        var y = cy + rad * sin;
        return [x,y];
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {

    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        isAwake = true;
        WatchUi.requestUpdate();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        isAwake = false;
        WatchUi.requestUpdate();
    }

}

class EnduroEvoDelegate extends WatchUi.WatchFaceDelegate {

    function initialize() {
        WatchFaceDelegate.initialize();
    }

    // The onPowerBudgetExceeded callback is called by the system if the
    // onPartialUpdate method exceeds the allowed power budget. If this occurs,
    // the system will stop invoking onPartialUpdate each second, so we set the
    // partialUpdatesAllowed flag here to let the rendering methods know they
    // should not be rendering a second hand.
    function onPowerBudgetExceeded(powerInfo) {
        System.println( "Average execution time: " + powerInfo.executionTimeAverage );
        System.println( "Allowed execution time: " + powerInfo.executionTimeLimit );
        partialUpdatesAllowed = false;
    }
}
