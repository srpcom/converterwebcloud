@echo off
setlocal enabledelayedexpansion
echo ==========================================
echo           Git Auto Upload Script
echo ==========================================
echo.

:: Fix dubious ownership issue
git config --global --add safe.directory C:/pindah >nul 2>&1

:: ============================================
:: Step 1: Initialize git repo if not exists
:: ============================================
if not exist ".git" (
    echo [INFO] Git repository belum ada. Menginisialisasi...
    git init
    echo.
)

:: ============================================
:: Step 2: Set branch to main
:: ============================================
git branch -M main >nul 2>&1

:: ============================================
:: Step 3: Setup remote origin if not exists
:: ============================================
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo [INFO] Remote origin belum diatur. Menambahkan remote...
    git remote add origin https://github.com/srpcom/converterwebcloud.git
    echo [OK] Remote origin berhasil ditambahkan.
    echo.
) else (
    :: Verify remote URL is correct
    for /f "tokens=*" %%a in ('git remote get-url origin 2^>nul') do set "current_remote=%%a"
    if not "!current_remote!"=="https://github.com/srpcom/converterwebcloud.git" (
        echo [INFO] Remote URL berbeda, mengupdate...
        git remote set-url origin https://github.com/srpcom/converterwebcloud.git
        echo [OK] Remote URL berhasil diupdate.
        echo.
    )
)

:: ============================================
:: Step 4: Configure git user if not set
:: ============================================
for /f "tokens=*" %%a in ('git config user.name 2^>nul') do set "has_name=1"
if not defined has_name (
    echo [INFO] Git user.name belum dikonfigurasi.
    set /p "git_name=Masukkan Nama Git Anda (contoh: Nama Anda): "
    if not "!git_name!"=="" (
        git config --global user.name "!git_name!"
        echo [OK] user.name berhasil diset.
    )
    echo.
)

for /f "tokens=*" %%a in ('git config user.email 2^>nul') do set "has_email=1"
if not defined has_email (
    echo [INFO] Git user.email belum dikonfigurasi.
    set /p "git_email=Masukkan Email Git Anda (contoh: username@users.noreply.github.com): "
    if not "!git_email!"=="" (
        git config --global user.email "!git_email!"
        echo [OK] user.email berhasil diset.
    )
    echo.
)

:: ============================================
:: Step 5: Commit message
:: ============================================
set /p "commit_msg=Masukkan pesan commit (Enter untuk default 'update'): "

:: Default message if empty
if "!commit_msg!"=="" (
    set "commit_msg=update"
)

:: ============================================
:: Step 6: Git add, commit, push
:: ============================================
echo.
echo [1/3] Running [git add .]...
git add .

echo.
echo [2/3] Running [git commit -m "!commit_msg!"]...
git commit -m "!commit_msg!"

echo.
echo [3/3] Running [git push]...

:: Check if upstream is already set
git rev-parse --abbrev-ref @{upstream} >nul 2>&1
if errorlevel 1 (
    echo [INFO] Push pertama kali, setting upstream branch...
    git push -u origin main --force
) else (
    git push
)

echo.
echo ==========================================
echo        Upload process finished!
echo ==========================================
echo.
pause
endlocal
