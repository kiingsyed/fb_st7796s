# Список изменений

Изменения относительно оригинального проекта драйвера https://github.com/Sergey1560/fb_st7796s

* Установлена частота шины 25МГц вместо 6.25 (быстрее обновление экрана)
* исправлено зависание при вызове blank() (выключение дисплея по таймауту
* исправлен конфликт с вентилятором по GPIO
* исправлена калибровка сенсора тачскрина, установлены коэффициенты калибровки, подходящие большинству медвежьих экранов
* добавлена защита от зависания АЦП тачскрина

Кроме того, полностью автоматизирован процесс установки - добавлен скрипт ```install.sh```, а также ```switch_to_landscape.sh``` для настройки экрана в альбомной ориентации
