@echo off
set "psscript=%~dp0PetitPomo.ps1"
powershell -windowstyle hidden -noprofile -executionpolicy bypass -file "%psscript%"