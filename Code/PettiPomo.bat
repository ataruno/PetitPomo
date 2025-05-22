@echo off
set "psscript=%~dp0PettiPomo.ps1"
powershell -windowstyle hidden -noprofile -executionpolicy bypass -file "%psscript%"