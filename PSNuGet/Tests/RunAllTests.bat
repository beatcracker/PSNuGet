@echo off
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command "Import-Module -Name Pester ; Invoke-Pester -Path '%~dp0'"
pause