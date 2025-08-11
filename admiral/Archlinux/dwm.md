










##  config.h
### Keys
```
{ 0, XF86XK_AudioRaiseVolume, spawn, SHCMD("pactl set-sink-volume 0 +3%") },  // Увеличение громкости
{ 0, XF86XK_AudioLowerVolume, spawn, SHCMD("pactl set-sink-volume 0 -3%") },  // Уменьшение громкости
{ 0, XF86XK_AudioMute, spawn, SHCMD("pactl set-sink-mute 0 toggle") },       // Отключение звука
{ 0, XF86XK_AudioPlay, spawn, SHCMD("playerctl play-pause") },               // Пауза/воспроизведение
{ 0, XF86XK_AudioNext, spawn, SHCMD("playerctl next") },                    // Следующий трек
{ 0, XF86XK_AudioPrev, spawn, SHCMD("playerctl previous") },                 // Предыдущий трек
{ 0, XF86XK_AudioMicMute, spawn, SHCMD("pactl set-source-mute 1 toggle") }, // Отключение микрофона
{ 0, XF86XK_MonBrightnessUp, spawn, SHCMD("brightnessctl set +5%") },       // Увеличение яркости
{ 0, XF86XK_MonBrightnessDown, spawn, SHCMD("brightnessctl set 5%-") },     // Уменьшение яркости
```
## search name app info
Открываем приложение 

В консоли пишем
```
xprop | grep WM_CLASS
```
Кликаем на приложение
`WM_CLASS(STRING) = "obsidian", "obsidian"`

и название класса добавляем в config.h