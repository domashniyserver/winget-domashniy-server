# Автоматическая установка программ в Windows 11 через Winget

Комплект безопасных PowerShell-скриптов для быстрой настройки чистой Windows 11.  
Материалы к выпуску YouTube-канала **«Домашний Сервер»**.

## Состав комплекта
* `install-basic.ps1` — базовый набор (7-Zip, VLC Media Player, Mozilla Firefox, Bitwarden)
* `install-work.ps1` — набор для работы (7-Zip, Mozilla Firefox, Bitwarden, LibreOffice)
* `install-study.ps1` — набор для учёбы (7-Zip, Mozilla Firefox, LibreOffice, VLC Media Player, Obsidian)
* `check-updates.ps1` — проверка доступных обновлений и обновление программ после подтверждения
* `README.txt` — подробная текстовая инструкция

## Быстрый старт
1. Скачайте готовый архив `winget-domashniy-server.zip` из раздела **Releases** справа.
2. Распакуйте архив, например в `C:\Scripts\winget-domashniy-server`.
3. Откройте **Терминал (Администратор)**, перейдите в папку и запустите нужный скрипт:

```powershell
cd C:\Scripts\winget-domashniy-server
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\install-basic.ps1"
