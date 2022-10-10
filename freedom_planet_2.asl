/*
Notes: 
This AutoSplitter REQUIRES Just-Ero's UnityASL component: https://github.com/just-ero/asl-help/blob/main/Components/UnityASL.bin
Download it and copy it into your LiveSplit install's Components folder. For example ```LiveSplit_1.7.6\Components\```

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

state("Freedom Planet 2")
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
    current.Scene = "none";

    vars.Unity.TryOnLoad = (Func<dynamic, bool>)(helper =>
    {        
        var FPStage = helper.GetClass("Assembly-CSharp", "FPStage");
        var FPSaveManager = helper.GetClass("Assembly-CSharp", "FPSaveManager");
        var FPPlayer = helper.GetClass("Assembly-CSharp", "FPPlayer");
        var FPMenu = helper.GetClass("Assembly-CSharp", "FPMenu");
        var FPAudio = helper.GetClass("Assembly-CSharp", "FPAudio");
        
        //vars.Unity.Make<double>(FPSaveManager.Static, FPSaveManager["currentSave"], FPSaveManager["playTime"]).Name = "playTime";
        vars.Unity.Make<double>(FPSaveManager.Static, FPSaveManager["playTime"]).Name = "playTime";
        vars.Unity.MakeString(FPStage.Static, FPStage["currentStage"], FPStage["stageName"]).Name = "stageName";
        vars.Unity.MakeString(FPStage.Static, FPStage["stageNameString"]).Name = "stageNameString";
        vars.Unity.Make<bool>(FPStage.Static, FPStage["timeEnabled"]).Name = "timeEnabled";
        
        vars.Unity.Make<float>(FPStage.Static, FPStage["frameTime"]).Name = "menuFrameTime";
        
        vars.Unity.Make<byte>(FPStage.Static, FPStage["currentStage"], FPStage["seconds"]).Name = "seconds";
        
        vars.Unity.Make<bool>(FPAudio.Static, FPAudio["isJinglePlaying"]).Name = "isJinglePlaying";
        vars.Unity.Make<int>(FPAudio.Static, FPAudio["currentJingle"]).Name = "currentJingleID"; //ID 1 is Victory
        
        // if FPAudio.currentJingle = 1 and it's currently playing 1 then we're probably in the victory state. FPStage.timeEnabled is also probably false; and FPStage should not be empty.
        

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
	
	//vars.Log("timeEnabled: " + vars.Unity["timeEnabled"].Current);
	//vars.Log("seconds: " + vars.Unity["seconds"].Current);
	
	
	//vars.Log("playTime: " + vars.Unity["playTime"].Current);
	//vars.Log("vars.Unity:" + vars.Unity);
	//vars.Log("vars.Unity.Scenes:" + vars.Unity.Scenes);
	
	//vars.Log("stageName: " + vars.Unity["stageName"].Current);
	//vars.Log("stageNameString: " + vars.Unity["stageNameString"].Current);
	
	//vars.Log("vars.Unity.Scenes.Active:" + vars.Unity.Scenes.Active);
	//vars.Log("vars.Unity.Scenes.Active.Name:" + vars.Unity.Scenes.Active.Name);
	
	if (vars.Unity["stageNameString"].Current != null 
	    && !vars.Unity["stageNameString"].Current.Equals(""))
    {
        current.Scene = vars.Unity["stageNameString"].Current;
        vars.Log("Save file reports current stage as: " + vars.Unity["stageNameString"].Current);
    }
}

start
{
	return (vars.Unity["playTime"].Old <= 0 && vars.Unity["playTime"].Current > 0);
}

split
{
	if (vars.Unity["isJinglePlaying"].Current
	    && vars.Unity["currentJingleID"].Current == 1
	    && vars.Unity["currentJingleID"].Old != 1
	    && !vars.Unity["stageNameString"].Current.Equals("")) 
	{
	    return true;
	}

  return false;
}

reset
{
  return old.Scene != "MainMenu" && current.Scene == "MainMenu"; // As is, this will never trigger because FPStage does not have a name at the menu.
}

isLoading
{
	//return current.isLoading;
	return true; // Force to always use what the game reports.
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
    return TimeSpan.FromSeconds(vars.Unity["playTime"].Current);
}