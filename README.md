# AllHotKeys

My personal [AutoHotKey](https://autohotkey.com) script that I use to enhance productivity.

## Usage

1.  Download and install [AutoHotKey](https://autohotkey.com)
2.  [Download](https://github.com/liorsh69/AllHotKeys/archive/master.zip) and extract the zip to any folder
3.  Edit settings.json to your own paths
4.  Run AllHotKeys.ahk

*   Use Ctrl+Shift+Mouse button 4(back) to toggle AppMod Modifier(taskbar icon will change as well)
*   Use CapsLock to toggle F13-F24 with the normal F keys (F1=F13 ... F12=F24)

### Run At Startup (optional)

1.  Press Windows key and run shell:startup
2.  Add a shortcut to AllHotKeys.ahk

#### Media Control

Control any music/video app (Spotify, MPC, etc...) <br/>

Alt+Space: Play/Pause <br/>
Alt+Right Arrow Key(->): Next Track <br/>
Alt+Left Arrow Key(<-): Previous Track <br/>

##### F10-PRO Remote

CALL UP: activate screen saver (or black screen) <br/>
Change Audio Source: well.. change audio source <br/>
CALL DOWN: Play/Pause <br/>
MENU: (in MPC: Open Subtitles and) move window to second screen <br/>
Smart Assistant: Open custom app <br/>

#### Chrome

Swipe trackpad left or right to change tabs <br/>

#### AppMod Modifier:

Move between apps using F keys <br/>

Default: <br/>
F1: explorer file browser <br/>
F2: Chrome <br/>
F3: VS Code <br/>
F4: Adobe Premiere <br/>
F5: toggle audio output <br/>

#### VS Code:

Mouse button 4(back) - unfold line <br/>
Double click to unfold all <br/>

Mouse button 5(back) - fold line <br/>
Double click to fold all <br/>

Ctrl+Mouse button 4(back) - unfold block <br/>
Ctrl+Mouse button 5(back) - fold block <br/>

## Contributing

When contributing to this repository, please **first discuss** the change you wish to make via **issue or email** with me before making a change.

*   When writing/rewriting make sure to comment with as much information as you can
*   Make sure to test as you write to prevent any errors
*   **always** Push to dev branch
*   If approved - the changes are going to get tested using dev branch
*   Create & use privateSettings.json for your own settings

## TODO:

[x] Custom modifier - AppMod <br/>
[x] CapsLock modifier <br/>
[x] Integrate AHKHID (used for F10-PRO remote) <br/>
[x] Chrome - swipe to move between tabs <br/>
[] F10-PRO: GO button - find a way to prevent default <br/>
[] F10-PRO: Smart Assistant function - use SplitPath to allow easy use with any other app

## Dependencies

This script is using AHK script dependencies that saved me a lot of time <br/>

*   [AHKHID](https://github.com/jleb/AHKHID) - AHK implementation of the HID functions
*   [AutoHotkey-JSON](https://github.com/cocobelgica/AutoHotkey-JSON) - JSON module for AutoHotkey
*   [NirCmd](https://www.nirsoft.net/utils/nircmd.html) - Windows command line tool
