<#
.SYNOPSIS
    Проверка и интерактивное обновление программ через Winget (check-updates.ps1)
.DESCRIPTION
    Проверяет наличие Winget, выводит список доступных обновлений для установленных программ
    и запрашивает явное подтверждение пользователя перед запуском массового обновления.
    Проект создан для обучающего видео YouTube-канала «Домашний Сервер».
#>

# Настройка кодировки вывода консоли в UTF-8 для корректного отображения кириллицы
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Проверка доступных обновлений программ (Winget)" -ForegroundColor Cyan
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
    Write-Host "  2. Найдите «Установщик приложений» (App Installer) от Microsoft Corporation." -ForegroundColor Gray
    Write-Host "  3. Нажмите «Установить» или «Обновить»." -ForegroundColor Gray
    Write-Host "  4. Перезапустите PowerShell и повторите попытку." -ForegroundColor Gray
    exit 1
}

$wingetVersion = & winget --version 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($wingetVersion)) {
    Write-Host "[ОШИБКА] Не удалось определить версию Winget (код выхода: $LASTEXITCODE)." -ForegroundColor Red
    Write-Host "Обновите «Установщик приложений» (App Installer) через Microsoft Store." -ForegroundColor Yellow
    exit 1
}

Write-Host "[ОК] Winget найден. Версия: $wingetVersion" -ForegroundColor Green
Write-Host ""

# ------------------------------------------------------------
# ШАГ 2. Проверка прав администратора (информационно)
# ------------------------------------------------------------
$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[ПРИМЕЧАНИЕ] Скрипт запущен без прав администратора." -ForegroundColor Yellow
    Write-Host "Для просмотра списка обновлений права администратора не обязательны," -ForegroundColor Gray
    Write-Host "но если вы решите запустить обновление, система может запросить подтверждение UAC." -ForegroundColor Gray
    Write-Host ""
}

# ------------------------------------------------------------
# ШАГ 3. Получение списка доступных обновлений
# ------------------------------------------------------------
Write-Host "[2/3] Поиск доступных обновлений для установленных программ..." -ForegroundColor Yellow
Write-Host ""

& winget upgrade --accept-source-agreements
$checkExitCode = $LASTEXITCODE

Write-Host ""
if ($checkExitCode -ne 0) {
    Write-Host "[ВНИМАНИЕ] Команда winget upgrade завершилась с кодом: $checkExitCode." -ForegroundColor Yellow
    Write-Host "Возможные причины: нет доступных обновлений, отсутствует интернет или требуется обновление источников Winget." -ForegroundColor Gray
}

Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "Чтобы обновить все поддерживаемые программы вручную, используется команда:" -ForegroundColor White
Write-Host "  winget upgrade --all --accept-package-agreements --accept-source-agreements" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

# ------------------------------------------------------------
# ШАГ 4. Запрос явного подтверждения на массовое обновление
# ------------------------------------------------------------
Write-Host "[3/3] Массовое обновление НЕ запускается автоматически без вашего согласия." -ForegroundColor Yellow
$answer = Read-Host "Выполнить обновление всех поддерживаемых программ прямо сейчас? (введите Д или Y для подтверждения, любая другая клавиша — отмена)"

if ($answer -match '^(Д|д|Да|да|Y|y|Yes|yes)$') {
    Write-Host ""
    Write-Host "Запуск обновления всех поддерживаемых программ..." -ForegroundColor Green
    & winget upgrade --all --accept-package-agreements --accept-source-agreements
    $upgradeAllExitCode = $LASTEXITCODE

    Write-Host ""
    if ($upgradeAllExitCode -eq 0) {
        Write-Host "[УСПЕХ] Процедура массового обновления завершена без ошибок." -ForegroundColor Green
    } else {
        Write-Host "[ВНИМАНИЕ] Массовое обновление завершилось с кодом: $upgradeAllExitCode." -ForegroundColor Yellow
        Write-Host "Часть программ могла обновиться успешно, а часть — потребовать закрытия запущенных окон или ручного обновления." -ForegroundColor Gray
    }
} else {
    Write-Host ""
    Write-Host "[ОТМЕНА] Массовое обновление отменено пользователем. Изменения в систему не вносились." -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Работа скрипта завершена." -ForegroundColor Cyan
