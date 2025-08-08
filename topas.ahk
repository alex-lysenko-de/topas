#Requires AutoHotkey v2.0
; TraySetIcon "Shell32.dll", 150

; Global variable for GUI
global MyGui := Gui()

; Settings file path
screenshotPath := A_Temp . "\topas_screenshot.png"
resultPath := A_Temp . "\topas_result"
logFilePath := A_Temp . "\topas_log.txt"
global SettingsFile := A_Temp . "\topas_settings.ini"

; Default values
global preserve_spaces := false
global psm_mode := "PSM_3"
global lang_eng := true
global lang_deu := false
global lang_rus := false
global lang_ukr := false
global lang_string := "eng"


; --- Informational window on first launch ---
helpStr := "This script is for Optical Character Recognition (OCR) from your screen.`n`n"
    . "How to use:`n"
    . "1. Press the key combination: CapsLock + PrintScreen`n"
    . "2. Select a rectangular area on your screen for text recognition.`n"
    . "3. Choose the recognition mode (PSM) and the language in the menu that appears.`n"
    . "4. Click 'copy to clipboard' or 'append to clipboard'  `n`n"
    . "The recognized text will be copied to your clipboard"

MsgBox(helpStr,	"TOPAS (Tesseract OCR ➕ AutoHotkey Script)", 64)


; --- Load settings from file ---
LoadSettings() {
    ; Declare global variables to access them in this function
    global preserve_spaces, psm_mode, lang_eng, lang_deu, lang_rus, lang_ukr
    
    ; Read from INI file if it exists
    if FileExist(SettingsFile) {
        preserve_spaces := IniRead(SettingsFile, "Settings", "PreserveSpaces", false)
        psm_mode := IniRead(SettingsFile, "Settings", "PSMMode", "PSM_3")
        lang_eng := IniRead(SettingsFile, "Settings", "LangEng", false)
        lang_deu := IniRead(SettingsFile, "Settings", "LangDeu", false)
        lang_rus := IniRead(SettingsFile, "Settings", "LangRus", false)
        lang_ukr := IniRead(SettingsFile, "Settings", "LangUkr", false)
    }
    
    ; Apply settings to GUI
    MyGui["PreserveSpace"].Value := preserve_spaces
    MyGui["PSM_3"].Value := (psm_mode = "PSM_3") ? 1 : 0
    MyGui["PSM_4"].Value := (psm_mode = "PSM_4") ? 1 : 0
    MyGui["PSM_5"].Value := (psm_mode = "PSM_5") ? 1 : 0
    MyGui["PSM_6"].Value := (psm_mode = "PSM_6") ? 1 : 0

    MyGui["Lang_eng"].Value := lang_eng
    MyGui["Lang_deu"].Value := lang_deu
    MyGui["Lang_rus"].Value := lang_rus
    MyGui["Lang_ukr"].Value := lang_ukr
}

; --- Save settings to file ---
SaveSettings(*) {
    ; Declare global variables to access them in this function
    global preserve_spaces, psm_mode, lang_eng, lang_deu, lang_rus, lang_ukr
    
    ; Write to INI file
    IniWrite(preserve_spaces, SettingsFile, "Settings", "PreserveSpaces")
    IniWrite(psm_mode, SettingsFile, "Settings", "PSMMode")
    IniWrite(lang_eng, SettingsFile, "Settings", "LangEng")
    IniWrite(lang_deu, SettingsFile, "Settings", "LangDeu")
    IniWrite(lang_rus, SettingsFile, "Settings", "LangRus")
    IniWrite(lang_ukr, SettingsFile, "Settings", "LangUkr")
}

MakeScreenshot(*) {
    ; Take a screenshot of the area
	; Compose command line
	if FileExist("screenshot.exe") {
		command := Format('screenshot.exe --screenshotPath "{}"', screenshotPath)
    } else {	
        command := Format('pythonw "screenshot.py" --screenshotPath "{}"', screenshotPath)
	}
	; Run the Python script
	RunWait(command)
}

RunOCR(*) {
	global psm_mode, preserve_spaces
	psm := SubStr(psm_mode, 5, 1)
    preserve := (preserve_spaces)? ' -c "preserve_interword_spaces=1" ' : ' '
	
	;-------------------------------------- Remove Result file -----------------------------------------------
	ResultFileName := resultPath . '.txt'
	if (FileExist(ResultFileName)) {
		; ---  FileDelete(ResultFileName) ---- TODO: remove this line
	}
	;------------------------------ Try to recognize text using Tesseract -----------------------------------
    Target := " /c tesseract " . screenshotPath . " " . resultPath . " -l " . lang_string . "  --psm " . psm . preserve .  " > " . logFilePath
	; Run tesseract
	RunWait A_ComSpec . Target ,  , "Hide" 
    ; Sleep 1000
	
    ;--------------------------------------- Check results --------------------------------------------------
	if FileExist(ResultFileName) {	
	    FileEncoding ("UTF-8")
        ResText := FileRead(ResultFileName)
		MyGui["MemoField"].Value := ResText
	} else if FileExist(logFilePath) {
	    FileEncoding ("UTF-8")
        ResText := FileRead(logFilePath)
		MyGui["MemoField"].Value := ResText
	} else {
	    MyGui["MemoField"].Value := "Fail: Something went really wrong..."
	}
}

; --- Creating GUI ---
InitMyGui(*) {
    MyGui.Title := "TOPAS (Tesseract OCR ➕ AutoHotkey Script)"
    MyGui.OnEvent("Close", MyGui_OnClose)

    ; CheckBox for preserve_interword_spaces
    cbPreserve := MyGui.Add("CheckBox", "x10 y10 vPreserveSpace", "Preserve interword spaces")
    cbPreserve.OnEvent("Click", GuiControl_Changed)

    ; Text and Radio buttons (PSM mode)
    MyGui.Add("Text", "xm y+10", "Page Segmentation Mode (PSM):")

    rb3 := MyGui.Add("Radio", "xm y+5 vPSM_3", "PSM-3 auto (Default)")
    rb3.OnEvent("Click", GuiControl_Changed)

    rb4 := MyGui.Add("Radio", "xm y+5 vPSM_4", "PSM-4 single column")
    rb4.OnEvent("Click", GuiControl_Changed)

    rb5 := MyGui.Add("Radio", "xm y+5 vPSM_5", "PSM-5 single vertical block")
    rb5.OnEvent("Click", GuiControl_Changed)

    rb6 := MyGui.Add("Radio", "xm y+5 vPSM_6", "PSM-6 single block")
    rb6.OnEvent("Click", GuiControl_Changed)


    MyGui["PSM_3"].Value := 1

    ; Languages
    MyGui.Add("Text", "x250 y40", "Recognition languages:")

    cbLangEng := MyGui.Add("CheckBox", "x250 y+5 vLang_eng", "English")
    cbLangEng.OnEvent("Click", GuiControl_Changed)

    cbLangDeu := MyGui.Add("CheckBox", "x250 y+5 vLang_deu", "German")
    cbLangDeu.OnEvent("Click", GuiControl_Changed)

    cbLangRus := MyGui.Add("CheckBox", "x250 y+5 vLang_rus", "Russian")
    cbLangRus.OnEvent("Click", GuiControl_Changed)

    cbLangUkr := MyGui.Add("CheckBox", "x250 y+5 vLang_ukr", "Ukrainian")
    cbLangUkr.OnEvent("Click", GuiControl_Changed)

    ; OCR Result
    MyGui.Add("Text", "xm y+15", "OCR Result:")
    MyGui.Add("Edit", "xm y+5 w500 h250 VScroll HScroll ReadOnly vMemoField", "OCR text will appear here...").SetFont("s11", "Courier New")

    ; Button "Copy to clipboard"
    btnCopy := MyGui.Add("Button", "Default xm y+20 w150 h30", "Copy to Clipboard")
    btnCopy.OnEvent("Click", ButtonCopy_Click)
	btnCopy.GetPos(&x, &y, &w, &h)
	
	; Button "Append to clipboard"
	btnAppend := MyGui.Add("Button", "y" . y . " x+10 w150 h30", "Append to Clipboard")
	btnAppend.OnEvent("Click", ButtonAppend_Click)
	
}
; --- Hotkey for showing GUI ---
CapsLock & PrintScreen::
{
	MakeScreenshot()
	LoadSettings()
    MyGui.Show()
	RunOCR()
}


GuiControl_Changed(ctrl, *) {
	MyGui["MemoField"].Value := ""
	ReadMyGui()
   	RunOCR()
}


ReadMyGui() {
    global psm_mode, preserve_spaces, lang_eng, lang_deu, lang_rus, lang_ukr, lang_string, MyGui

    ; Get PSM mode from radio buttons
    if MyGui["PSM_3"].Value {
        psm_mode := "PSM_3"
    }
    else if MyGui["PSM_4"].Value {
        psm_mode := "PSM_4"
    }
    else if MyGui["PSM_5"].Value {
        psm_mode := "PSM_5"
    }
    else if MyGui["PSM_6"].Value {
        psm_mode := "PSM_6"
    }

    ; Get selected languages
    selected_langs := []

    lang_eng := MyGui["Lang_eng"].Value

    lang_deu := MyGui["Lang_deu"].Value

    lang_rus := MyGui["Lang_rus"].Value

    lang_ukr := MyGui["Lang_ukr"].Value
    

    if lang_eng
        selected_langs.Push("eng")
    if lang_deu
        selected_langs.Push("deu")
    if lang_rus
        selected_langs.Push("rus")
    if lang_ukr
        selected_langs.Push("ukr")

    lang_string := ""
    for lang in selected_langs {
        lang_string .= (lang_string == "" ? "" : "+") . lang
    }
    

    preserve_spaces := MyGui["PreserveSpace"].Value ? true : false
    
}

ShowCurrentSettings() {
    ; Declare global variables to access them in this function
    global psm_mode, lang_string, preserve_spaces
    
    ; Show current settings
    settings_text := "=== Current OCR Settings ===`n`n"
    settings_text .= "PSM Mode: " . psm_mode . "`n"
    settings_text .= "Languages: " . lang_string . "`n"
    settings_text .= "Preserve spaces: " . (preserve_spaces ? "Yes" : "No") . "`n`n"
    settings_text .= "Settings saved to: " . SettingsFile
    
    MsgBox(settings_text, "OCR Settings")
}


DoClose(mode) {
	; Read current settings from GUI
	ReadMyGui()
    ; Save settings to file
    SaveSettings()

	if (mode = 1) {
	    A_Clipboard := MyGui["MemoField"].Value
	} else if (mode = 2) {
		A_Clipboard := A_Clipboard . "`n`n" . MyGui["MemoField"].Value
	}
    ; Clear Memo
	MyGui["MemoField"].Value := ""  
    MyGui.Hide()
}

ButtonCopy_Click(*) {
	DoClose(1)
}

ButtonAppend_Click(*) {
	DoClose(2)
}

; --- Window close handler ---
MyGui_OnClose(*)
{
	DoClose(0)
}
; --- System Tray setup (recommended approach) ---
; Add our own menu items at the beginning
A_TrayMenu.Insert("1&", "Open Settings", TrayOpen)
A_TrayMenu.Insert("2&") ; Separator
; Set default action for double-click on tray icon
A_TrayMenu.Default := "Open Settings"
; --- Tray menu handlers ---
TrayOpen(*)
{
    LoadSettings() ; Reload settings before showing GUI
    MyGui.Show()
}
TrayExit(*)
{
    ExitApp
}

; Initialize GUI and load saved settings
InitMyGui()
LoadSettings()

; Make script persistent
Persistent