@echo off

:: checkout the Batchography book

setlocal

if not defined IDASDK (
    echo IDASDK environment variable not set.
    goto :eof
)

if not exist %IDASDK%\src\cmake\bootstrap.cmake (
    echo IDA SDK cmake not found at %IDASDK%\src\cmake\bootstrap.cmake
    goto :eof
)

if "%1"=="clean" (
    if exist build rmdir /s /q build
    goto :eof
)

if not exist build cmake -B build -S . -A x64

if "%1"=="build" cmake --build build --config Release

echo.
echo All done!
echo.