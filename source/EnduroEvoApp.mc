using Toybox.Application;
using Toybox.Lang;
using Toybox.WatchUi;

class EnduroEvoApp extends Application.AppBase {

    var mGraphIndex;
    var settingsMenu;
    var mMainView;

    var mYDataBL,mYDataTL;

    function initialize() {
        mGraphIndex = 0;
        settingsMenu = new EnduroEvoSettingsMenu();
        AppBase.initialize();
    }

     function getSettingsView() {
        return [ settingsMenu ,new EnduroEvoSettingsMenuDelegate()];
    } 

    //application start up
    function onStart(state as Dictionary?) as Void {
    }

    //application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    //Returns initial view of your application
    function getInitialView()  {
        mMainView = new EnduroEvoView();
        if( Toybox.WatchUi has :WatchFaceDelegate ) {
            return [mMainView, new EnduroEvoDelegate()];
        } else {
            return [mMainView];
        }
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        //System.println("ReadSettings");
        mMainView.ReadSettings();
        WatchUi.requestUpdate();
    }

}
// Returins the app object
function getApp() as EnduroEvoApp {
    return Application.getApp() as EnduroEvoApp;
}