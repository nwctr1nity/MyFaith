# MyFaith: ответы для Play Console

Собрано по коду версии 1.1.0 (ветка `claude/mushaf-dhikr`) 16 ноября 2026 года. Названия пунктов в консоли могут немного отличаться.

Тексты страницы лежат в `store/listing/<язык>/`: `title.txt` (до 30 знаков), `short_description.txt` (до 80), `full_description.txt` (до 4000). Теги `<b>` в полном описании Google Play показывает жирным.

## Что проверено в коде

| Что | Как в коде |
|---|---|
| Местоположение | `ACCESS_COARSE_LOCATION`, `LocationAccuracy.low`, только когда приложение открыто. Координаты используются в расчёте на телефоне и никуда не уходят |
| Сеть | `INTERNET` нужен только плееру чтецов: `just_audio` грузит mp3 с `everyayah.com/data/<чтец>/<сура><аят>.mp3`. Других адресов в коде нет |
| Хранение | `shared_preferences` на телефоне: настройки, город, закладки, счётчики |
| Реклама, аналитика, сбои | Нет: ни Firebase, ни Google Play Services, ни рекламных SDK в зависимостях |
| Аккаунты и вход | Нет |
| Платежи | Нет. Но в «Ещё» есть пункт «Поддержать проект» с реквизитами Kaspi, Т-Банк и USDT. **Перед загрузкой в Google Play его нужно убрать**, иначе это нарушение правил о платежах |

## Основные поля

| Поле | Значение |
|---|---|
| Название приложения | MyFaith: молитва, азан, Коран |
| Язык по умолчанию | Русский (ru-RU), переводы: English (en-US), Arabic (ar) |
| Приложение или игра | Приложение |
| Платное или бесплатное | Бесплатное |
| Категория | Стиль жизни (Lifestyle). Отдельной категории для религии в Google Play нет, Muslim Pro и похожие тоже в ней |
| Сайт | https://nwctr1nity.github.io/myfaith/ |
| Email | Обязателен и виден всем. Можно завести отдельный ящик для приложения |
| Политика конфиденциальности | https://nwctr1nity.github.io/myfaith/privacy/ |

## Статус продавца (Digital Services Act, ЕС)

**Не продавец (non-trader).** Приложение бесплатное, без покупок и рекламы, вы не занимаетесь им как бизнесом. Адрес и телефон тогда не публикуются.

## Безопасность данных (Data safety)

Вопрос 1. **Does your app collect or share any of the required user data types?** → **No**

После «No» анкета заканчивается, на странице будет «Разработчик не собирает данные».

Почему это честный ответ:

- Местоположение обрабатывается только на телефоне. По правилам Google данные, которые не покидают устройство, сбором не считаются.
- Запрос к everyayah.com содержит только номер аята и чтеца. Это адрес публичного файла, а не данные пользователя. IP-адрес в анкете отдельным типом данных не значится.
- Нет аккаунтов, аналитики, рекламы, отчётов о сбоях.

Если когда-нибудь добавите Firebase, Crashlytics, рекламу или вход, анкету придётся заполнить заново.

## Возрастной рейтинг (IARC)

| Вопрос | Ответ |
|---|---|
| Email для связи | Ваш email |
| Категория | Reference, News, or Educational (Справочники, новости, образование) |
| Насилие, кровь, страшные сцены | No |
| Сексуальный контент, нагота | No |
| Нецензурная лексика, грубый юмор | No |
| Наркотики, алкоголь, табак | No |
| Азартные игры, имитация азартных игр | No |
| Пользователи могут общаться или обмениваться контентом | No |
| Приложение делится местоположением пользователя с другими людьми | No |
| Покупка цифровых товаров | No |
| Свободный доступ в интернет (встроенный браузер) | No |
| Контент, созданный пользователями | No |

Ожидаемый результат: PEGI 3, ESRB Everyone, 0+. Окончательный рейтинг присвоит IARC.

## Остальные анкеты в разделе «Контент приложения»

| Анкета | Ответ |
|---|---|
| Реклама | No, my app does not contain ads |
| Доступ к приложению | All functionality is available without special access |
| Целевая аудитория | 13–15, 16–17, 18 и старше. Младше 13 не отмечать: тогда действуют правила для детских приложений |
| Привлекает ли приложение детей | No |
| Новостное приложение | No |
| Финансовые функции | My app doesn't provide any financial features (после удаления «Поддержать проект») |
| Здоровье | My app does not have any health features |
| Государственное приложение | No |
| Приложение для поиска контактов COVID-19 | No |

## Объявления о разрешениях

Google читает их на английском, тексты можно вставить как есть.

**Exact alarms (`USE_EXACT_ALARM`).** Выбрать «Alarm clock»:

> The app's core function is to play the adhan at the exact minute each prayer begins and to wake the user for suhoor and tahajjud at a time they set. A delay of a few minutes makes the call to prayer wrong, so exact alarms are required.

Риск: Google разрешает это разрешение только будильникам и календарям. Если отклонят, переведу приложение на `SCHEDULE_EXACT_ALARM`, которое пользователь включает сам.

**Full-screen intent (`USE_FULL_SCREEN_INTENT`).** Выбрать «Alarm»:

> Used only for the suhoor and tahajjud alarm clocks, which the user turns on and schedules. The alarm must wake a sleeping user and be visible on the lock screen.

**Foreground service, type Media playback (`FOREGROUND_SERVICE_MEDIA_PLAYBACK`):**

> At each prayer time the user has enabled, the app plays an adhan recording of 3 to 4 minutes. Playback starts from an exact alarm while the app is closed, and the notification has a Stop button. The service ends when the recording ends or the user stops it.

Нужна ссылка на видео 20–30 секунд (YouTube, можно «доступ по ссылке»): приложение закрыто, звучит азан, видно уведомление, нажимается кнопка «Остановить».

## Что нового в 1.1.0

Поле «Release notes», до 500 знаков на язык:

```
<ru-RU>
Мусхаф на 604 страницы, таджвид и транскрипция, чтение аятов голосами чтецов, зикры и дуа, 99 имён Аллаха и руководство по молитве.
</ru-RU>
<en-US>
A 604-page mushaf, color-coded tajweed and transliteration, ayah recitation by reciters, dhikr and duas, the 99 Names of Allah, and a prayer guide.
</en-US>
<ar>
مصحف من 604 صفحات، وتلوين التجويد والكتابة الصوتية، وتلاوة الآيات بأصوات القرّاء، والأذكار والأدعية، وأسماء الله الحسنى، ودليل الصلاة.
</ar>
```

## Политика конфиденциальности на GitHub Pages

Файл: `docs/privacy/index.html`, три языка на одной странице. Чтобы ссылка заработала:

1. Смержить этот PR в `main`.
2. На GitHub: Settings, Pages, Source: Deploy from a branch, Branch: `main`, папка `/docs`, Save.
3. Через минуту-две страница откроется по адресу https://nwctr1nity.github.io/myfaith/privacy/

GitHub Pages на бесплатном тарифе работает только для публичных репозиториев. Если сделаете репозиторий приватным, страница перестанет открываться.
