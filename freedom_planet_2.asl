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
    vars.shouldSplit = false;
    
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

    var pathToFPSaves = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
    pathToFPSaves = Path.Combine(pathToFPSaves, @"..\LocalLow\GalaxyTrail\Freedom Planet 2\");
    vars.Log("pathToFPSaves: " + pathToFPSaves);

    vars.OnFileChanged = (FileSystemEventHandler)((object sender, FileSystemEventArgs e) => 
        {
            if (e.ChangeType != WatcherChangeTypes.Changed)
            {
            }
            else 
            {
                vars.Log("Changed: " + e.FullPath);
                if (!e.FullPath.Contains("global.json")) 
                {
                    // We're getting an event for a json file other than globals. Almost certainly a save file. Go ahead and split.
                    vars.shouldSplit = true;
                }
            }
        });

    vars.Log("dab");

    vars.PrepFileWatcher = (Action<string>)((string pathToFolder) =>
        {
            vars.watcher = new FileSystemWatcher(pathToFolder);

            vars.watcher.NotifyFilter = NotifyFilters.CreationTime
                                 | NotifyFilters.DirectoryName
                                 | NotifyFilters.FileName
                                 | NotifyFilters.LastWrite
                                 | NotifyFilters.Size;

            vars.watcher.Changed += new FileSystemEventHandler(vars.OnFileChanged);

            vars.watcher.Filter = "*.json";
            vars.watcher.IncludeSubdirectories = false;
            vars.watcher.EnableRaisingEvents = true;
        });

    vars.PrepFileWatcher(pathToFPSaves);
}

init 
{
    current.Event = "";
    current.Scene = "none";
    current.IsInLevel = false;
    current.timeEnabled = false;
    current.timeToggled = false;
    current.lastMapLocation = -1;

    vars.Unity.TryOnLoad = (Func<dynamic, bool>)(helper =>
    {
        var FPStage = helper.GetClass("Assembly-CSharp", "FPStage");
        var FPSaveManager = helper.GetClass("Assembly-CSharp", "FPSaveManager");
        
        vars.Unity.Make<double>(FPSaveManager.Static, FPSaveManager["playTime"]).Name = "playTime";
        vars.Unity.Make<int>(FPSaveManager.Static, FPSaveManager["lastMapLocation"]).Name = "lastMapLocation";
        
        vars.Unity.MakeString(FPStage.Static, FPStage["currentStage"], FPStage["stageName"]).Name = "stageName";
        vars.Unity.MakeString(FPStage.Static, FPStage["stageNameString"]).Name = "stageNameString";
        vars.Unity.Make<bool>(FPStage.Static, FPStage["timeEnabled"]).Name = "timeEnabled";
        
        vars.Unity.Make<float>(FPStage.Static, FPStage["frameTime"]).Name = "menuFrameTime";
        
        vars.Unity.Make<byte>(FPStage.Static, FPStage["currentStage"], FPStage["seconds"]).Name = "seconds";

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
    current.timeEnabled = vars.Unity["timeEnabled"].Current;
    if (current.IsInLevel && old.IsInLevel (!current.timeEnabled && old.timeEnabled)) {current.timeToggled = true;}

    if (vars.Unity["lastMapLocation"].Current != null && vars.Unity["lastMapLocation"].Current > -1) 
    {
        current.lastMapLocation = vars.Unity["lastMapLocation"].Current;
    }
	
	if (vars.Unity["stageNameString"].Current != null 
	    && !vars.Unity["stageNameString"].Current.Equals(""))
    {
        current.Scene = vars.Unity["stageNameString"].Current;
        current.IsInLevel = true;
        //vars.Log("Save file reports current stage as: " + vars.Unity["stageNameString"].Current);
    }
    else 
    {
        current.IsInLevel = false;
    }


    // Prevent bad splits from Restart Stage by clearing all flags on map's level select stage change.
    if (current.lastMapLocation != old.lastMapLocation)
	{
		vars.shouldSplit = false;
        current.timeToggled = false;
        current.IsInLevel = false;
        vars.Log("LastMap Changed. Resetting flags.");
	}
}

start
{
	return (vars.Unity["playTime"].Old <= 0 && vars.Unity["playTime"].Current > 0);
}

split
{
    if (!current.IsInLevel && old.IsInLevel //Just exited a level.
        && vars.shouldSplit // Save file has changed.
        && current.timeToggled) // The timer has changed from enabled to disabled since the last split.)
	{
        vars.shouldSplit = false;
        current.timeToggled = false;
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
	return true; // Force to always use what the game reports.
}

exit
{
    vars.watcher.Dispose();
	vars.Unity.Reset();
}

shutdown
{
    vars.watcher.Dispose();
	vars.Unity.Reset();
}

gameTime
{
    return TimeSpan.FromSeconds(vars.Unity["playTime"].Current / 60);
}