/*
Notes: 

// Based on FashionPoliceSquad's Auto-Splitter by Corvimae: https://github.com/Corvimae/FPS-Autosplitter/blob/main/FashionPoliceSquad.asl
// and The Stanley Parable Ultra Deluxe Auto-Splitter by NikoHeartTTV: https://github.com/Nikoheartttv/TheStanleyParableUltraDeluxe_Autosplitter/blob/main/TSPUD_AutoSplitter.asl
    

Total File Time in the credits is directly pulled from:
    FPSaveManager.playTime
(with the exception of debug mode, which uses the stage time + a random amount of time.)
Fullgames probably want to use this and show a notice to switch to game time.
ILs probably specifically don't want to use this and should probably instead use:  
    if (FPSaveManager.timeRecord[stageOrder[j]] > 0)

*/

state("FP2")
{

}

startup
{
    vars.Log = (Action<object>)(output => print("[FP2] " + output));
    vars.Unity = Assembly.Load(File.ReadAllBytes(@"Components\UnityASL.bin")).CreateInstance("UnityASL.Unity");
    vars.Unity.LoadSceneManager = true;
    
    settings.Add("any", true, "Any%");
    settings.Add("true-ending", false, "True Ending");
    settings.Add("boss-rush", false, "Boss Rush");
    settings.Add("extra", false, "Extra Content");
    
    
    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {
        var mbox = MessageBox.Show(
            "The Freedom Planet 2 Auto-Splitter uses in-game time from the active save file.\nWould you like to switch to it?",
            "LiveSplit | Freedom Planet 2",
            MessageBoxButtons.YesNo);

        if (mbox == DialogResult.Yes)
            timer.CurrentTimingMethod = TimingMethod.GameTime;
    }
}

init 
{
    current.Event = "";
    current.Scene = -1;

    vars.Unity.TryOnLoad = (Func<dynamic, bool>)(helper =>
    {        
        var FPStage = helper.GetClass("Assembly-CSharp", "FPStage");
        var FPSaveManager = helper.GetClass("Assembly-CSharp", "FPSaveManager");
        
        vars.Unity.Make<double>(FPSaveManager.Static, FPSaveManager["currentSave"], FPSaveManager["playTime"]).Name = "playTime";

        return true;
    });

    vars.Unity.Load(game);

}

update
{
	if (!vars.Unity.Loaded)
	{
	    return false;
	}

	vars.Unity.Update();  
    current.Scene = vars.Unity.Scenes.Active.Name;
    current.isLoading = (current.Scene.Equals("Loading"));
}

start
{
	return (old.Scene != "ClassicMenu" && current.Scene == "ClassicMenu")
            || (old.Scene != "Cutscene_NewGame" && current.Scene == "Cutscene_NewGame");
}

split
{
	if (old.Scene != "ClassicMenu" && current.Scene == "ClassicMenu")
	    || (old.Scene != "Cutscene_NewGame" && current.Scene == "Cutscene_NewGame")
	{
		vars.Log("Scene changed: " + old.Scene + " -> " + current.Scene);

    return true;
	}

  return false;
}

reset
{
  return old.Scene != "MainMenu" && current.Scene == "MainMenu";
}

isLoading
{
	return current.isLoading;
}

exit
{
	vars.Unity.Reset();
}

shutdown
{
	vars.Unity.Reset();
}

gameTime
{
    return TimeSpan.FromMilliseconds(vars.Unity["playTime"].Current)
}