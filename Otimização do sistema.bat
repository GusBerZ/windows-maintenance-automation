@echo off
setlocal enabledelayedexpansion

:: Obter nome do computador
set "PCNAME=%COMPUTERNAME%"

:: Criar pasta de log
set "LOGDIR=%USERPROFILE%\Documents\LOG Script"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

:: Definir caminho do arquivo de log
set "LOGFILE=%LOGDIR%\%PCNAME%.txt"

:: Iniciar log
echo Arquivos e pastas excluídos da pasta TEMP: > "%LOGFILE%"
for %%F in ("%TEMP%\*.*") do (
    echo Excluído: %%F >> "%LOGFILE%"
    del /q /f "%%F"
)
for /d %%D in ("%TEMP%\*") do (
    echo Excluída pasta: %%D >> "%LOGFILE%"
    rd /s /q "%%D"
)

:: Listar arquivos da Lixeira do usuário antes de esvaziar
echo. >> "%LOGFILE%"
echo Arquivos excluídos da Lixeira: >> "%LOGFILE%"
echo (Os nomes abaixo são identificadores internos da Lixeira. Os nomes originais dos arquivos não são acessíveis sem permissões elevadas) >> "%LOGFILE%"
PowerShell -Command ^
  "$recycle = [IO.Path]::Combine($env:SystemDrive, '\$Recycle.Bin');" ^
  "$sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value;" ^
  "$userBin = Join-Path $recycle $sid;" ^
  "if (Test-Path $userBin) {" ^
  "Get-ChildItem -Path $userBin -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }" ^
  "} else { 'Lixeira do usuário não encontrada.' }" >> "%LOGFILE%"

:: Esvaziar a Lixeira
PowerShell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"

:: Abrir a janela do Windows Update
echo. >> "%LOGFILE%"
start ms-settings:windowsupdate
UsoClient StartInteractiveScan

echo.
echo ==================================================
echo        LIMPEZA E ATUALIZACOES CONCLUIDAS
echo ==================================================
echo Log salvo em: %LOGFILE%
echo.
echo Feito por: B.G - Suporte Tecnico
echo ==================================================
echo Pressione qualquer tecla para sair.
pause >nul
