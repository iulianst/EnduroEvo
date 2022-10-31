class EnduroEvoDataField {
    var mValue;
    var mGoal;
    var mHasGoal;
    var mName;
    var mShortName;
    var mClass;
    var mMethod;
    
    // Weather Condition 0-53: day, 54-108: night
    private var mWIi = [61453,61442,61442,61448,61450,61520,61445,61618,61443,61622,61444,61449,61445,61448,61449,61448,61450,61450,61446,61446,61459,61618,61442,61453,61451,61449,61449,61451,61445,61443,61539,61449,61526,61538,61558,61570,61456,61570,61640,61622,61459,61555,61457,61450,61618,61459,61459,61459,61473,61618,61618,61450,61452,61557,61486,61574,61574,61480,61482,61520,61477,61620,61514,61486,61476,61495,61477,61480,61481,61480,61482,61482,61478,61478,61459,61620,61574,61486,61483,61481,61481,61483,61477,61514,61539,61481,61526,61538,61558,61570,61485,61570,61640,61486,61459,61555,61457,61482,61620,61459,61459,61459,61473,61620,61620,61482,61569,61557];

    var mLabel = [
        "None", "Active Minutes for the Day",
        "Active Minutes for the Week", "Active Minutes Weekly Goal",
        "Calories Burned so far for the Day", "Distance since midnight (cm)",
        "Floors Climbed", "Floor Climb Goal", "Floors Descended",
        "Vertical Distance of Floors Climbed (m)", "Vertical Distance of Floors Descended (m)",
        "Step Count Since Midnight", "Step Goal for the Day",
        "Battery Percentage",
        "Heart Rate", "Temperature (sens)", "Body Temperature", "Weather Cond&Temp", "Time to Recovery",
        "Move Bar", "Recovery Time", "Respiration Rate",
    ];

    var mShortLabel = [
        "None", "Act Minu",
        "Act Min Week", "Act Min Goal",
        "Calories", "Distance",
        "Floors", "Floor Goal", "Floors Desc",
        "Dist Climb", "Dist Desc",
        "Steps", "Step Goal",
        "Battery %",
        "Heart Rate", "Temp (sens)", "Body Temp", "Weather Temp", 
        "Move Bar", "Recovery Time", "Respiration Rate",
    ];

    var mXShortLabel = [
        "None", "Act",
        "AWK", "ActG",
        "Cal", "Dist",
        "Fl", "FlG", "FlD",
        "DistC", "DistD",
        "Stp", "StpG",
        "Batt",
        "HR", "TmpS", "BTmp","WTmp",
        "Move", "Recv", "Resp",
    ];

    function initialize() {    
    }

    function getLabel(index){
        return mLabel[index];
    }
    function getShortLabel(index){
        return mShortLabel[index];
    }

    function getStringValue(index){
        var val = getValue(index);
        if(val ==null) 
        {
            return "--";
        }
        switch(val) {
        case instanceof Number:
            return val.format("%02d");
        case instanceof Float:
            return val.format("%02.1f");
        default:
            return getValue(index).toString();
        }
    }

    function getHR() as Lang.Number{
        var HR =  Activity.getActivityInfo().currentHeartRate;
        if(HR != null) {return HR;}
        else {return 00;}
        var sHR = new EnduroEvoSensors().getHR();
        if(sHR != null) {return sHR;}
        return 0;
    }
    function getTemperature() {        
        var temp = new EnduroEvoSensors().getTemperature();
        if (temp== null) {return 0.0;}
        return temp;
    }
    function getBodyTemp() as Lang.Float {
        var HR = getHR(); if (HR== null) {HR=60;}
        var temp =  getTemperature(); if (temp== null) {return 0.0;}
        return 0.0100 *HR +0.0837 * temp + 33.1735;
    }

    function getValue(index){
        var am= ActivityMonitor.getInfo();
        switch (index) {
            case 0:
                return 0;
            case 1:
                return am.activeMinutesDay.total;
            case 2:
                return am.activeMinutesWeek.total;
            case 3:
                return am.activeMinutesWeekGoal;
            case 4:
                return am.calories;
            case 5:
                return am.distance;
            case 6:
                return am.floorsClimbed;
            case 7:
                return am.floorsClimbedGoal;
            case 8:
                return am.floorsDescended;
            case 9:
                return am.metersClimbed;
            case 10:
                return am.metersDescended;
            case 11:
                return am.steps;
            case 12:
                return am.stepGoal;
            case 13:
                return System.getSystemStats().battery; 
            case 14:
                return getHR();
            case 15:
                return getTemperature();
            case 16:
                return getBodyTemp();
            case 17:
                return null; //weather condition field, case handled in drawField(); 
            case 18:
                return am.moveBarLevel;
            case 19:
                return am.timeToRecovery;
            case 20:
                return am.respirationRate;

            default:
                return 0;          
        }
    }
    function drawField(dc, x, y, dataIndex, justify){

         var fontData = WatchUi.loadResource(Rez.Fonts.Data);
        
        if (dataIndex==17) {
            var WC = Weather.getCurrentConditions();
            if(WC!=null)
            {
                var fontWI = WatchUi.loadResource(Rez.Fonts.WI);
                // commented and replaced with the next line that fixes an intermitent error:
                //Error: Unexpected Type Error
                //Details: 'Failed invoking <symbol>'
                //replaced with the next line
                //var strTemp = WC.temperature.toString(); 
                var strTemp = WC.temperature!=null? WC.temperature.format("%d"): "--";
                var wdthTemp = dc.getTextWidthInPixels(strTemp, fontData)+5;
                var condition = WC.condition !=null? WC.condition: Weather.CONDITION_UNKNOWN;
                dc.drawText(x, y, fontData, strTemp, justify);
                dc.drawText(x+wdthTemp, y, fontWI, getWIIcon(mWIi[condition]), justify);
            }

        }else {
            
            dc.drawText(x, y, fontData, getStringValue(dataIndex), justify);
        }

        

    }
    function getWIIcon(index){    
        var charNul = -65 + 'A'; 
        return index +  charNul;        
    }
}