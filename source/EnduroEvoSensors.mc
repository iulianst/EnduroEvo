using Toybox.SensorHistory;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Lang;

class EnduroEvoSensors  {

    
    private var duration = new Time.Duration(3600);
    private var fontData, fontDataSmall;
    private var fontDataHeight, fontDataSmallHeight;
    private var mFgColor;
 

    hidden var mSensorSymbols = [
        :getTemperatureHistory,
        :getHeartRateHistory,
        :getTemperatureHistory,
        :getPressureHistory,
        :getElevationHistory,
       // :getOxygenSaturationHistory,
    ];

    var mSensorLabel = [
        "Body Temperature",
        "Heart Rate",
        "Temperature",
        "Pressure",
        "Elevation",        
        //"Oxygen Saturation",
    ];
    var mSensorLabelShort = [
        "Body Temp",
        "Heart Rate",
        "Temperature",
        "Pressure",
        "Elevation",        
       // "Pulse Ox",
    ];

    hidden var mSensorMin = [
        34,
        37,
        0,
        50000,
        0,        
       // 80,
    ];

    hidden var mSensorRange = [
        45,
        80,
        45,
        60000,
        6000,        
       // 20,
    ];

    function initialize() {   
        fontDataSmall = WatchUi.loadResource(Rez.Fonts.DataSmall);
        fontData = WatchUi.loadResource(Rez.Fonts.Data); 
        fontData = WatchUi.loadResource(Rez.Fonts.Data); 
        mFgColor = getApp().Properties.getValue("ForegroundColor");
    }

    function getIterator(index) {
        if ( ( Toybox has :SensorHistory ) && ( Toybox.SensorHistory has mSensorSymbols[index] ) ) {
            var getMethod = new Lang.Method( Toybox.SensorHistory, mSensorSymbols[index] );
            //return getMethod.invoke( {:period => 200});
            return getMethod.invoke( {});
        }
        return null;
    }

    function getTemperature(){
       
        if ( Toybox has :SensorHistory ) {

            var sensorIter = getIterator(2);
 
            if( sensorIter != null ) {
                
                var ret= sensorIter.next();
                while(null == ret)
                {
                    ret = sensorIter.next();
                }
                return ret.data;

            }
        }
    }

    function getHR(){
       
        if ( Toybox has :SensorHistory ) {

            var sensorIter = getIterator(1);
 
            if( sensorIter != null ) {
                
                var ret= sensorIter.next();
                while(null == ret)
                {
                    ret = sensorIter.next();
                }
                return ret.data;

            }
        }

    }
    function draw(dc,index) as Void {
        if (index==0){
            drawBodyTemp(dc);
        }else {
            drawSensor(dc,index);
        }
        
    }

    function getBodyTemp(Temp,HR) as Lang.Float {
        return 0.0100 * HR +0.0837 * Temp + 33.1735;
    }

    function drawBodyTemp(dc) as Void{

        var font = Graphics.FONT_GLANCE_NUMBER;
        var fontHeight = dc.getFontHeight(font);
        var font_small = Graphics.FONT_SMALL;
        var font_smallHeight = dc.getFontHeight(font_small);
        var font_xtiny = Graphics.FONT_XTINY;
        var font_xtinyHeight = dc.getFontHeight(font_xtiny);
        fontDataSmallHeight =  dc.getFontHeight(fontDataSmall);
        fontDataHeight =  dc.getFontHeight(fontData);

        
        if ( Toybox has :SensorHistory ) {
            var HRIter = getIterator(1);
            var TempIter = getIterator(2);
            if( HRIter != null && TempIter != null ) {
                var previousT = TempIter.next();
                var sampleT = TempIter.next();
                var previousHR = HRIter.next();
                var sampleHR = HRIter.next();
                var x = dc.getWidth()-30;
                var min = getBodyTemp(TempIter.getMin(),HRIter.getMin());
                var max = getBodyTemp(TempIter.getMax(),HRIter.getMax());               
                var firstSampleTime = null;
                var lastSampleTime = null;
                var graphBottom = dc.getHeight() - 30;
                var graphHeight = graphBottom - dc.getHeight()/3*2;
                //var dataOffset = mSensorMin[index].toFloat();
                //var dataScale = mSensorRange[index].toFloat();
                var dataOffset = min.toFloat();
                var dataScale = max.toFloat();
                var gotValidData = false;

                dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                //dc.drawRectangle(50, graphBottom-graphHeight, dc.getWidth()-100, graphBottom);
                while( null != sampleT && null != sampleHR) {

                    if( null == firstSampleTime ) {
                        firstSampleTime = previousT.when;
                    }

                    if( sampleT.data != null && previousT.data != null && sampleHR.data != null && previousHR.data != null ) {
                        lastSampleTime = sampleT.when;
                        var prevTemp = getBodyTemp( previousT.data, previousHR.data);
                        var Temp = getBodyTemp( sampleT.data, sampleHR.data);
                        //var y1 = graphBottom - (previous.data - dataOffset) / dataScale * graphHeight;
                        //var y2 = graphBottom - (sample.data - dataOffset) / dataScale * graphHeight;
                       var y1 = graphBottom -( prevTemp -dataOffset )/ ((dataScale-dataOffset)/graphHeight);
                        var y2 = graphBottom -( Temp -dataOffset )/ ((dataScale-dataOffset)/graphHeight);
                        dc.setPenWidth(2);
                        dc.drawLine(x, y1, x+1, y2);
                        gotValidData = true;
                    }

                    --x;
                    if(x<0) {x=0;}
                    previousT = sampleT;
                    previousHR = sampleHR;
                    sampleT = TempIter.next();
                    sampleHR = HRIter.next();
                }
                dc.setColor(mFgColor, Graphics.COLOR_TRANSPARENT);

                if( gotValidData ) {
                   

                    // draw the min/max hr values
                    if( max == null ) {
                        max = "";
                    } else {
                        max = max.format("%02.1f");
                    }
                    if( min == null ) {
                        min = "";
                    } else {
                        min = min.format("%02.1f");
                    }
                    

                    dc.drawText(dc.getWidth() / 2 -10, dc.getHeight()*2/3  /*- fontDataHeight*/, fontData, min, Graphics.TEXT_JUSTIFY_RIGHT);
                    dc.drawText(dc.getWidth() / 2 +10, dc.getHeight()*2/3  /*- fontDataHeight*/, fontData, max, Graphics.TEXT_JUSTIFY_LEFT);
                    // draw the data label
                    dc.drawText(dc.getWidth()/2, dc.getHeight() - font_xtinyHeight, font_xtiny, mSensorLabelShort[0], Graphics.TEXT_JUSTIFY_CENTER);

                }
                else {
                    var message = mSensorLabel[0] + "\nNo data available.";                    
                    dc.drawText(dc.getWidth()/2, dc.getHeight()/3*2+font_smallHeight , font_small, message, (Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER));
                }
            }
            else {
                var message = mSensorLabel[0] + "\nnot available";
                dc.drawText(dc.getWidth()/2, dc.getHeight()/3*2+font_smallHeight , font_small, message, (Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER));
            }

        } else {
            var message = "Sensor History\nNot Supported";
            dc.drawText(dc.getWidth()/2, dc.getHeight()/3*2+font_smallHeight , font_small, message, (Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER));
        }

        
    }


    function drawSensor(dc, index) as Void {      

        var font = Graphics.FONT_GLANCE_NUMBER;
        var fontHeight = dc.getFontHeight(font);
        var font_small = Graphics.FONT_SMALL;
        var font_smallHeight = dc.getFontHeight(font_small);
        var font_xtiny = Graphics.FONT_XTINY;
        var font_xtinyHeight = dc.getFontHeight(font_xtiny);
        fontDataSmallHeight =  dc.getFontHeight(fontDataSmall);
        fontDataHeight =  dc.getFontHeight(fontData);

        
        if ( Toybox has :SensorHistory ) {
            var sensorIter = getIterator(index);
            if( sensorIter != null ) {
                var previous = sensorIter.next();
                var sample = sensorIter.next();
                var x = dc.getWidth()-30;
                var min = sensorIter.getMin();
                var max = sensorIter.getMax();
                var firstSampleTime = null;
                var lastSampleTime = null;
                var graphBottom = dc.getHeight() - 30;
                var graphHeight = graphBottom - dc.getHeight()/3*2;
                var dataOffset = min.toFloat();
                var dataScale = max.toFloat();
                var gotValidData = false;

                dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                while( null != sample ) {

                    if( null == firstSampleTime ) {
                        firstSampleTime = previous.when;
                    }

                    if( sample.data != null && previous.data != null ) {
                        lastSampleTime = sample.when;
                        var y1 = graphBottom -( previous.data -dataOffset )/ ((dataScale-dataOffset)/graphHeight);
                        var y2 = graphBottom -( sample.data -dataOffset )/ ((dataScale-dataOffset)/graphHeight);
                        dc.setPenWidth(2);
                        dc.drawLine(x, y1, x+1, y2);
                        gotValidData = true;
                    }

                    --x;
                    if(x<0) {x=0;}
                    previous = sample;
                    sample = sensorIter.next();
                }
                dc.setColor(mFgColor, Graphics.COLOR_TRANSPARENT);

                if( gotValidData ) {
                   

                    // draw the min/max hr values
                    if( max == null ) {
                        max = "";
                    } else {
                        if (index==2) {max = max.format("%02.0f");}
                        else { max = max.format( "%d" );}
                    }
                    if( min == null ) {
                        min = "";
                    } else {
                        if (index==2) {min =min.format("%02.0f");}
                        else {min = min.format( "%d" );}
                    }
                    
                    if (index==3) {
                        dc.drawText(dc.getWidth() / 2 -10, dc.getHeight()*2/3  /*- fontDataSmallHeight*/, fontDataSmall, min, Graphics.TEXT_JUSTIFY_RIGHT);
                        dc.drawText(dc.getWidth() / 2 +10, dc.getHeight()*2/3 /*- fontDataSmallHeight*/, fontDataSmall, max, Graphics.TEXT_JUSTIFY_LEFT);
                    } else {
                        dc.drawText(dc.getWidth() / 2 -10, dc.getHeight()*2/3  /*- fontDataHeight*/, fontData, min, Graphics.TEXT_JUSTIFY_RIGHT);
                        dc.drawText(dc.getWidth() / 2 +10, dc.getHeight()*2/3  /*- fontDataHeight*/, fontData, max, Graphics.TEXT_JUSTIFY_LEFT);
                    }
                    // draw the data label
                    dc.drawText(dc.getWidth()/2, dc.getHeight() - font_xtinyHeight, font_xtiny, mSensorLabelShort[index], Graphics.TEXT_JUSTIFY_CENTER);
                }
                else {
                    var message = mSensorLabel[index] + "\nNo data available.";                    
                    dc.drawText(dc.getWidth()/2, dc.getHeight()/3*2+font_smallHeight , font_small, message, (Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER));
                }
            }
            else {
                var message = mSensorLabel[index] + "\nSensor not available";
                dc.drawText(dc.getWidth()/2, dc.getHeight()/3*2+font_smallHeight , font_small, message, (Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER));
            }

        } else {
            var message = "Sensor History\nNot Supported";
            dc.drawText(dc.getWidth()/2, dc.getHeight()/3*2+font_smallHeight , font_small, message, (Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER));
        }

        
    }

}