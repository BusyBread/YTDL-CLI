@echo off
REM CMD Wrapper to bypass execution policy
set script="%~dp0Invoke-YTDL.ps1"
powershell.exe -nologo -noprofile -executionpolicy bypass -file %script%