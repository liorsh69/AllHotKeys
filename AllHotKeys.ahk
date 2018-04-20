/* Writen by Lior Shitrit 2018
 * 
 * Check out my github profile for more upcoming projects
 * https://github.com/liorsh69
 * 
 * Free to use, copy and change with credits
 */

#NoEnv
#SingleInstance force
#Include <JSON>
#Include <AHKHID>

; +++++ AHKHID +++++
	; Create GUI to receive messages
    Gui, +LastFound
    hGui := WinExist()

    ; Intercept WM_INPUT messages
    WM_INPUT := 0xFF
    OnMessage(WM_INPUT, "InputMsg")

    ; Register Remote Control with RIDEV_INPUTSINK (so that data is received even in the background)
    r := AHKHID_Register(12, 1, hGui, RIDEV_INPUTSINK)
    InputMsg(wParam, lParam) {
        Local devh, iKey, sLabel
        Critical

        ; Get handle of device
        devh := AHKHID_GetInputInfo(lParam, II_DEVHANDLE)

        ; Check for error
        If (devh <> -1) ; Check that it is my HP remote
            And (AHKHID_GetDevInfo(devh, DI_DEVTYPE, True) = RIM_TYPEHID)
            And (AHKHID_GetDevInfo(devh, DI_HID_VENDORID, True) = 999)
            And (AHKHID_GetDevInfo(devh, DI_HID_PRODUCTID, True) = 3329)
            And (AHKHID_GetDevInfo(devh, DI_HID_VERSIONNUMBER, True) = 272) {

            ; Get data
            iKey := AHKHID_GetInputData(lParam, uData)>

            ; Check for error
            If (iKey <> -1) {
                ; Get keycode (located at the 6th byte)
                iKey := ((NumGet(uData, 0, "UChar")*65536) + (NumGet(uData, 1, "UChar")*256) + (NumGet(uData, 2, "UChar")))

                ; MsgBox, % iKey
                ; Call the appropriate sub if it exists
                If IsLabel(iKey)
                    Gosub, %iKey%
            }
        }
    }

; +++++ Init +++++
    Menu, Tray, Icon, icon/off.ico ; script icon - changed by AppMod
    global AppMod := false ; custom apllications modifier

    ; Read settings json file and assign to settingsJson
    ; for contributors: save your settings under privateSettings.json to protect your data
    if (FileExist("privateSettings.json")) {
        FileRead, settingsJson, privateSettings.json
    } else {
        FileRead, settingsJson, settings.json
    }
    
    
    ; Convert settingsJson to AHK object
    global settings := JSON.load(settingsJson)

; +++++ General Functions +++++

    /** Run exe
     * path: full path to exe file name
     * active: always running process - i.e explorer.exe
     * args: arguments to pass to process
     */
    runExe(path, active := false, args := ""){
        ;assign name & dir from path
        SplitPath, path, name
        SplitPath, path, dir

        ; check if file exists & exe is provided
        if (!FileExist(path) && dir != name){
            MsgBox % path " Not exsists"
            return
        }

        if (active){ ; run always running process
                Run, %path%
        }else{ ; run normal process with arguments
            if !WinExist("ahk_exe " . name)
                Run, %path% %args%
        }

        return
    }

    /* Double/Single click detection
     * returns | 1 - single click | 2 - double click | 0 - error
     */
    dblClick(){
        static Times = 0
        if (A_ThisHotkey != A_PriorHotkey){
            Times = 0
        }

        Times++
        if (Times = 2){
            SetTimer, Check, Off
            Goto, Check
        }

        SetTimer, Check, -250
        return 0

        Check:
            if (Times = 2){
                return 2
            } else {
                Times = 0
                return 1
            }
        return 0
    }

    /* Slow down mouse wheel
     * press - func to run for each turn
     */
    reduceWheelSpeed(press){
        static wheelTurns := 0
        threshold := 150
        sleepTimer := 325

        if (A_ThisHotkey != A_PriorHotkey){
            wheelTurns = 0
            Sleep, sleepTimer
            return
        }

        wheelTurns++
        tabsToMove := Mod(threshold, wheelTurns)

        if (tabsToMove >= 2){
            %press%()
            wheelTurns = 0
            Sleep, sleepTimer
            return
        }

        Sleep, sleepTimer
    }

    ; Quick way to use tooltips
    QuickToolTip(text, delay){
        ToolTip, %text%
        SetTimer ToolTipOff, %delay%
        return

        ToolTipOff:
            SetTimer ToolTipOff, Off
            ToolTip
            return
    }

    /** Change Audio Output Source
      * Using nircmd commands
      */
    toggleAudioSrc(){
        static src := 1

        if (src >= settings.audioSources.Length()) {
            src := 1
        } else {
            src++
        }

        args := % " setdefaultsounddevice " . settings.audioSources[src]

        runExe(settings.exe.nircmd, false, args)
        Return
    }

    /** alternate F keys
      * F1 = F13 ... F12 = F24
      */
    altFkey(key){
        index := StrReplace(key, "F") ; extract the F key number
        altKey := "F" . index + 12  ; add 12 to index and F to get the new F key
        return %altKey%
    }

; +++++ Modifiers +++++
    ; AppMod
        ; AppMod Functions
        ; object key: key to assign function to
        ; object value: function name to run
        global funcArr:= {"F1": "switchToExplorer", "F2": "switchToChrome", "F3": "switchToCode", "F4": "switchToPremiere", "F5": "toggleAudioSrc"}

        ^+XButton1:: ; Ctrl+Shift+Mouse4(back) - Toggle AppMod
            toggleAppMod(){
                AppMod := !AppMod

                if (AppMod) { ; Enable actions
                    Menu, Tray, Icon, icon/on.ico

                    ; Windows Switcher Hotkeys
                    for key, func in funcArr {
                        Hotkey, %key%, %func%, On
                    }
                } else { ; Disable actions 
                    Menu, Tray, Icon, icon/off.ico
                        
                    ; Windows Switcher Hotkeys
                    for key, func in funcArr {
                        Hotkey, %key%, %func%, Off
                    }
                }
            }
            return

; +++++ Media Player Actions +++++
    DetectHiddenWindows, On
    !Left::Media_Prev
    !Right::Media_Next
    !Space::Media_Play_Pause

    ; +++++ F10-PRO Remote +++++
        149763: ; CALL UP - screen saver (black screen)
            Run, C:\Windows\system32\scrnsave.scr /s, hide
        Return

        149507: ; Change Audio Source
            toggleAudioSrc()
        Return

        150019: ; CALL DOWN - Play/Pause
            send {Media_Play_Pause}
        Return

        147456: ; MENU - Open Subtitles and move window to second screen
            send d
            Sleep, 75
            send >#+{Left}
        Return

        150275: ; Smart Assistant
            smartAssistant()
        Return

            ;TODO: use local name variable for app
            ; SplitPath, path, name
            smartAssistant(){
                if (dblClick() = 2 ){
                    if (WinExist("ahk_exe VideoExplorer.exe")){
                        ; Close Video Explorer
                        Process, Close, VideoExplorer.exe
                    }else{
                        ; Run Video Explorer
                        runExe(settings.exe.videoExplorer)
                    }
                    return
                }else{
                    ; Put Video Explorer on front
                    if (!WinActive("ahk_exe VideoExplorer.exe")){
                        WinActivate ahk_exe VideoExplorer.exe
                        
                    }

                    ; Close MPC if running
                    if (WinExist("ahk_exe mpc-hc64.exe")){
                        Process, Close, mpc-hc64.exe
                    }
                }
            
            }
            

        ;TODO: find a way to prefent default
        139522: ; GO (on F10-Pro keyboard)
            
        Return

; +++++ VSCode Actions +++++
    #IfWinActive, ahk_exe Code.exe
        /*  Mouse4
        *   single click - unfold line, double click - unfold all
        */
        XButton1::
            unfold(){
                if (dblClick() = 2){ ; double click - unfold all
                    send ^k
                    send ^j
                    return
                }else{ ; single click - unfold line
                    send {Click}
                    send ^+]
                    return
                }
            }

        /*  Mouse5
        *   single click - fold line, double click - fold all
        */
        XButton2::
            fold(){
                if (dblClick() = 2){ ; double click - fold all
                    send ^k
                    send ^0
                    return
                }else{ ; single click - fold line
                    send {Click}
                    send ^+[
                    return
                }
            }

        /*  Alt+Mouse4
        *   unfold line recursively
        */
        !XButton1::
            send {Click}
            send ^k
            send ^]
            return

        /*  Alt+Mouse5
        *   unfold line recursively
        */
        !XButton2::
            send {Click}
            send ^k
            send ^[
            return
    #If

; +++++ Chrome +++++
    #IfWinActive, ahk_exe chrome.exe
        #MaxHotkeysPerInterval, 100

        tabRight(){
            send ^{tab}
        }
        tabLeft(){
            send ^+{tab}
        }

        ; swipe trackpad to navigate between tabs
        ; edit reduceWheelSpeed function to change the speed of the swipe

        WheelRight::
            reduceWheelSpeed(tabRight())
            return

        WheelLeft::
            reduceWheelSpeed(tabLeft())
            return
    #If
; +++++ Windows Application Switcher +++++
    ; +++++ Applications With AppMod Modifier +++++
        switchToExplorer(){
            if AppMod {
                IfWinNotExist, ahk_class CabinetWClass
                    runExe(settings.exe.explorer, true)
                GroupAdd, explorers, ahk_class CabinetWClass
                if WinActive("ahk_exe explorer.exe")
                    GroupActivate, explorers, r
                else
                    WinActivate ahk_class CabinetWClass
            }
        }
        switchToChrome(){
            if AppMod {
                runExe(settings.exe.chrome)
                if WinActive("ahk_exe chrome.exe")
                    Sendinput ^{tab}
                else
                    WinActivate ahk_exe chrome.exe
            }
        }
        switchToCode(){
            if AppMod {
                runExe(settings.exe.code)
                if !WinActive("ahk_exe Code.exe")
                    WinActivate ahk_exe Code.exe
            }
        }
        switchToPremiere(){
            if AppMod {
                runExe(settings.exe.premierePro)
                if !WinActive("ahk_class Premiere Pro")
                    WinActivate ahk_class Premiere Pro
            }
        }

    ^XButton2::Send !{Esc} ; Ctrl+Mouse5(forward) - Activate previous window
    ^XButton1::Send !{tab} ; Ctrl+Mouse4(back) - Activate last window
; +++++ F keys +++++

    ; use alternate F keys only with CapsLock modifier
    ; keys can be mapped to any program
    ; some laptops keyboard are limited - like my own(support only 16 function keys)
    #If, GetKeyState("CapsLock", "T") && !AppMod
        F1::
        F2::
        F3::
        F4::
        F5::
        F6::
        F7::
        F8::
        F9::
        F10::
        F11::
        F12::
            key := altFkey(A_ThisHotkey)
            Sendinput {Blind}{%key%}
            return
    #If