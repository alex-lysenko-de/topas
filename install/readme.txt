Direct link to download tesseract-ocr-w64-setup.exe using wget
https://github.com/tesseract-ocr/tesseract/releases/download/5.5.0/tesseract-ocr-w64-setup-5.5.0.20241111.exe

You can run build_all.cmd to create an Installer
It does following:

1. compiles screenshot.py into screenshot.exe

2. compiles topas.ahk into topas.exe

3. opens the file topas.iss in Inno Setup Compiler. 
You should select  menu : "Build"->"Compile" to create the setup file.




