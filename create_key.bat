@echo off
set "PYTHONW=C:\Users\Nitro 5\AppData\Local\Programs\Python\Python313\pythonw.exe"
if exist "%PYTHONW%" (
    start "" "%PYTHONW%" "%~dp0tools\create_key_gui.py"
) else (
    start "" pythonw "%~dp0tools\create_key_gui.py"
)
