<#
.SYNOPSIS
    Установка набора программ для учёбы (install-study.ps1)
.DESCRIPTION
    Устанавливает учебный комплект ПО для Windows 11: 7-Zip, Mozilla Firefox, LibreOffice, VLC Media Player, Obsidian.
    Проект создан для обучающего видео YouTube-канала «Домашний Сервер».
    Скрипт использует официальный пакетный менеджер Microsoft Winget.
    Совместим с Windows 11 и Windows PowerShell 5.1 / PowerShell 7+.
#>

# Настройка кодировки вывода консоли в UTF-8 для корректного отображения кириллицы
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Установка набора программ для учёбы (install-study.ps1)" -ForegroundColor Cyan
Write-Host "  Канал «Домашний Сервер» — Автоматизация Windows 11" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# ШАГ 1. Проверка наличия утилиты Winget
# ------------------------------------------------------------
Write-Host "[1/3] Проверка наличия менеджера пакетов Winget..." -ForegroundColor Yellow

$wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
if (-not $wingetCmd) {
    Write-Host "[ОШИБКА] Утилита Winget не найдена в системе!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Как установить или обновить Winget:" -ForegroundColor White
    Write-Host "  1. Откройте приложение Microsoft Store в Windows 11." -ForegroundColor Gray
    Write-Host "  2. Найдите приложение «Установщик приложений» (App Installer) от Microsoft Corporation." -ForegroundColor Gray
    Write-Host "  3. Нажмите «Установить» или «Обновить»." -ForegroundColor Gray
    Write-Host "  4. После завершения перезапустите терминал PowerShell и повторите запуск скрипта." -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Проверка версии Winget
$wingetVersion = & winget --version 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($wingetVersion)) {
    Write-Host "[ОШИБКА] Winget обнаружен, но не удалось получить его версию (код выхода: $LASTEXITCODE)." -ForegroundColor Red
    Write-Host "Попробуйте обновить «Установщик приложений» (App Installer) через Microsoft Store." -ForegroundColor Yellow
    exit 1
}

Write-Host "[ОК] Winget найден. Текущая версия: $wingetVersion" -ForegroundColor Green
Write-Host ""

# ------------------------------------------------------------
# ШАГ 2. Проверка прав администратора
# ------------------------------------------------------------
Write-Host "[2/3] Проверка прав запуска PowerShell..." -ForegroundColor Yellow

$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[ВНИМАНИЕ] Скрипт запущен БЕЗ прав администратора!" -ForegroundColor Yellow
    Write-Host "Некоторые программы могут запросить подтверждение UAC или завершиться с ошибкой." -ForegroundColor Yellow
    Write-Host "Рекомендуется запускать PowerShell от имени администратора." -ForegroundColor Yellow
} else {
    Write-Host "[ОК] PowerShell запущен от имени администратора." -ForegroundColor Green
}
Write-Host ""

# ------------------------------------------------------------
# ШАГ 3. Список программ для установки
# ------------------------------------------------------------
$apps = @(
    @{ Name = "7-Zip"; Id = "7zip.7zip" },
    @{ Name = "Mozilla Firefox"; Id = "Mozilla.Firefox" },
    @{ Name = "LibreOffice"; Id = "TheDocumentFoundation.LibreOffice" },
    @{ Name = "VLC Media Player"; Id = "VideoLAN.VLC" },
    @{ Name = "Obsidian"; Id = "Obsidian.Obsidian" }
)

# Списки для формирования итогового отчёта
$installedList = New-Object System.Collections.Generic.List[string]
$skippedList   = New-Object System.Collections.Generic.List[string]
$failedList    = New-Object System.Collections.Generic.List[string]

Write-Host "[3/3] Начинаем проверку и установку программ (всего в списке: $($apps.Count))..." -ForegroundColor Yellow
Write-Host ""

foreach ($app in $apps) {
    $appName = $app.Name
    $appId   = $app.Id

    Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Программа : $appName" -ForegroundColor White
    Write-Host "ID пакета : $appId" -ForegroundColor Gray

    # Предварительная проверка: установлен ли пакет уже в системе
    $null = & winget list --id "$appId" --exact --source winget --accept-source-agreements 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[ПРОПУЩЕНО] Программа «$appName» уже установлена в системе." -ForegroundColor Cyan
        $skippedList.Add("$appName ($appId)")
        continue
    }

    Write-Host "Выполняется установка через Winget..." -ForegroundColor Yellow

    # Запуск установки с точным идентификатором и принятием лицензионных соглашений
    & winget install --id "$($app.Id)" --exact --source winget --accept-package-agreements --accept-source-agreements
    $installExitCode = $LASTEXITCODE

    # Проверка кода завершения процесса Winget
    if ($installExitCode -eq 0) {
        Write-Host "[УСПЕХ] Программа «$appName» успешно установлена." -ForegroundColor Green
        $installedList.Add("$appName ($appId)")
    }
    elseif ($installExitCode -eq -1978335189) {
        # Код 0x8A15002B (-1978335189): подходящее обновление не найдено / пакет уже актуален
        Write-Host "[ПРОПУЩЕНО] Программа «$appName» уже установлена и не требует действий." -ForegroundColor Cyan
        $skippedList.Add("$appName ($appId)")
    }
    else {
        Write-Host "[ОШИБКА] Не удалось установить «$appName». Код завершения Winget: $installExitCode" -ForegroundColor Red
        $failedList.Add("$appName ($appId) — код ошибки: $installExitCode")
    }
}

# ------------------------------------------------------------
# ИТОГОВЫЙ ОТЧЁТ
# ------------------------------------------------------------
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ИТОГОВЫЙ ОТЧЁТ ВЫПОЛНЕНИЯ СКРИПТА" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Успешно установлено ($($installedList.Count)):" -ForegroundColor Green
if ($installedList.Count -gt 0) {
    foreach ($item in $installedList) { Write-Host "  + $item" -ForegroundColor Green }
} else {
    Write-Host "  (нет)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Пропущено / уже установлено ($($skippedList.Count)):" -ForegroundColor Cyan
if ($skippedList.Count -gt 0) {
    foreach ($item in $skippedList) { Write-Host "  = $item" -ForegroundColor Cyan }
} else {
    Write-Host "  (нет)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Не удалось установить ($($failedList.Count)):" -ForegroundColor Red
if ($failedList.Count -gt 0) {
    foreach ($item in $failedList) { Write-Host "  ! $item" -ForegroundColor Red }
} else {
    Write-Host "  (ошибок нет)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Работа скрипта завершена." -ForegroundColor Cyan
