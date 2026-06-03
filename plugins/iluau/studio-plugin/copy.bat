@echo off
setlocal

set "DESTINO=C:\Users\diogo\AppData\Local\Roblox\Plugins"
set "ORIGEM=C:\Users\diogo\IdeaProjects\iluau\plugins\iluau\studio-plugin\iLuau.plugin.lua"

echo Removendo arquivo antigo...
if exist "%DESTINO%\iLuau.plugin.lua" (
    del /f /q "%DESTINO%\iLuau.plugin.lua"
)

echo Copiando novo arquivo...
copy /y "%ORIGEM%" "%DESTINO%\"

if %errorlevel% equ 0 (
    echo.
    echo Arquivo copiado com sucesso.
) else (
    echo.
    echo Erro ao copiar o arquivo.
)

endlocal
