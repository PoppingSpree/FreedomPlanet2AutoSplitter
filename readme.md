## What is This?

This is an auto-splitter for Freedom Planet 2, meant for use with LiveSplit. This was tested with FP2 version 1.1.5r.

## How to Use
First, you must place the file "UnityASL.bin" in your LiveSplit install's components folder.
You can download UnityASL.bin here: https://github.com/just-ero/asl-help/blob/main/lib/UnityASL.bin
Where the components folder is depends on where you installed LiveSplit.
For exmaple, for me it was at `D:\Unsorted\Downloads\LiveSplit_1.7.6\Components\`

Then, download freedom_planet_2.asl. Save it anywhere that is convenient for you. Then in LiveSplit, click:
LiveSplit -> Edit Layout -> Add -> Control -> Scriptable Auto Splitter

Then in the box where it asks for a file, you point it at the copy of freedom_planet_2.asl you just downloaded.

### Start Condition
The timer will auto-start when you start a new Classic Mode file as soon as the file's timer starts.

### Split Condition
The splitter will attempt to split the following conditions are met:

1: You are in a playable stage, and the stage timer has stopped (You beat the stage.)

2: After beating a stage, the save file has updated at least once. (Typically, also happens after beating a stage.)

3: While both prior conditions have been met, you exit the stage to level select/map.

4: The last stage chosen the map has _not_ changed since the last auto-split. (Restarting a stage should _not_ cause an auto-split. Returning to map _might_.) 