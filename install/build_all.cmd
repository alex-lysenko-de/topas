call ahk2exe.cmd
pause
call py2exe.cmd
pause
copy setup_tesseract.cmd .\dist\setup_tesseract.cmd
start topas.iss /wait
pause
powershell -Command "Get-FileHash .\Output\Topas_setup_v1.0.exe -Algorithm SHA256 > Topas_setup_v1.0.sha256.txt"

