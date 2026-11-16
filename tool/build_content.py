"""Builds the bundled Quran, tafsir and hadith assets.

Usage: python3 tool/build_content.py [cache_dir]

Sources, all fetched from GitHub and cached in cache_dir:
- Quran text and translations: github.com/fawazahmed0/quran-api
    ara-quranuthmanihaf  King Fahd Complex Uthmani Hafs text
    rus-elmirkuliev      Elmir Kuliev (Russian)
    eng-ummmuhammad      Saheeh International (English)
- Tafsir: github.com/spa5k/tafsir_api, Al-Mukhtasar in Russian, English, Arabic
- Hadith: github.com/fawazahmed0/hadith-api, Sahih al-Bukhari in Arabic,
  English (Muhsin Khan) and Russian (Abdullah Nirsha)
- Font: github.com/aliftype/amiri, Amiri Quran (SIL Open Font License)

- Transliteration: quran-api edition ara-quran-la1 (Latin); the Cyrillic one is
  derived from it letter by letter in this script
- Pages and juz: quran-api info.json (Madinah mushaf, 604 pages)
- Tajweed colouring: derived in tool/tajweed.py from the marks of the Uthmani
  text itself

The Quran text is written out exactly as received. The script refuses to
build if the structure is not 114 surahs and 6236 ayahs in every edition.
"""
import json
import re
import os
import sys
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import tajweed  # noqa: E402

RAW = "https://raw.githubusercontent.com"
QURAN = {
    "ar": "ara-quranuthmanihaf",
    "ru": "rus-elmirkuliev",
    "en": "eng-ummmuhammad",
}
TAFSIR = {
    "ru": "russian-mokhtasar",
    "en": "en-tafsir-al-mukhtasar",
    "ar": "ar-tafsir-al-mukhtasar",
}
HADITH = {"ar": "ara-bukhari", "en": "eng-bukhari", "ru": "rus-bukhari"}

TOTAL_AYAHS = 6236

# Length limits for the "hadith of the day" pool, in characters. Long
# narrations do not fit a notification or a single screen.
DAILY_EN_MIN, DAILY_EN_MAX = 60, 300
DAILY_RU_MAX = 600
DAILY_AR_MAX = 900

RU_NAMES = """Аль-Фатиха|Аль-Бакара|Аль Имран|Ан-Ниса|Аль-Маида|Аль-Анам|Аль-Араф|Аль-Анфаль|Ат-Тауба|Юнус|Худ|Юсуф|Ар-Рад|Ибрахим|Аль-Хиджр|Ан-Нахль|Аль-Исра|Аль-Кахф|Марьям|Та Ха|Аль-Анбия|Аль-Хаджж|Аль-Муминун|Ан-Нур|Аль-Фуркан|Аш-Шуара|Ан-Намль|Аль-Касас|Аль-Анкабут|Ар-Рум|Лукман|Ас-Саджда|Аль-Ахзаб|Саба|Фатыр|Йа Син|Ас-Саффат|Сад|Аз-Зумар|Гафир|Фуссылят|Аш-Шура|Аз-Зухруф|Ад-Духан|Аль-Джасия|Аль-Ахкаф|Мухаммад|Аль-Фатх|Аль-Худжурат|Каф|Аз-Зарият|Ат-Тур|Ан-Наджм|Аль-Камар|Ар-Рахман|Аль-Вакиа|Аль-Хадид|Аль-Муджадиля|Аль-Хашр|Аль-Мумтахана|Ас-Сафф|Аль-Джумуа|Аль-Мунафикун|Ат-Тагабун|Ат-Талак|Ат-Тахрим|Аль-Мульк|Аль-Калам|Аль-Хакка|Аль-Мааридж|Нух|Аль-Джинн|Аль-Муззаммиль|Аль-Муддассир|Аль-Кыяма|Аль-Инсан|Аль-Мурсалят|Ан-Наба|Ан-Назиат|Абаса|Ат-Таквир|Аль-Инфитар|Аль-Мутаффифин|Аль-Иншикак|Аль-Бурудж|Ат-Тарик|Аль-Аля|Аль-Гашия|Аль-Фаджр|Аль-Баляд|Аш-Шамс|Аль-Лейл|Ад-Духа|Аш-Шарх|Ат-Тин|Аль-Аляк|Аль-Кадр|Аль-Беййина|Аз-Зальзаля|Аль-Адият|Аль-Кариа|Ат-Такасур|Аль-Аср|Аль-Хумаза|Аль-Филь|Курейш|Аль-Маун|Аль-Каусар|Аль-Кафирун|Ан-Наср|Аль-Масад|Аль-Ихляс|Аль-Фаляк|Ан-Нас""".split("|")


RU_MEANINGS = """Открывающая|Корова|Семейство Имрана|Женщины|Трапеза|Скот|Преграды|Трофеи|Покаяние|Юнус|Худ|Юсуф|Гром|Ибрахим|Хиджр|Пчёлы|Ночной перенос|Пещера|Марьям|Та Ха|Пророки|Паломничество|Верующие|Свет|Различение|Поэты|Муравьи|Рассказ|Паук|Римляне|Лукман|Земной поклон|Союзники|Сава|Творец|Йа Син|Выстроившиеся в ряды|Сад|Толпы|Прощающий|Разъяснены|Совет|Украшения|Дым|Коленопреклонённые|Барханы|Мухаммад|Победа|Комнаты|Каф|Рассеивающие|Гора|Звезда|Месяц|Милостивый|Событие|Железо|Препирающаяся|Сбор|Испытуемая|Ряды|Собрание|Лицемеры|Взаимное обделение|Развод|Запрещение|Власть|Письменная трость|Неминуемое|Ступени|Нух|Джинны|Закутавшийся|Завернувшийся|Воскресение|Человек|Посылаемые|Весть|Вырывающие|Нахмурился|Скручивание|Раскалывание|Обвешивающие|Разверзнется|Созвездия|Ночной путник|Всевышний|Покрывающее|Заря|Город|Солнце|Ночь|Утро|Раскрытие|Смоковница|Сгусток крови|Предопределение|Ясное знамение|Землетрясение|Скачущие|Великое бедствие|Страсть к приумножению|Предвечернее время|Хулитель|Слон|Курейшиты|Мелочь|Изобилие|Неверующие|Помощь|Пальмовые волокна|Очищение веры|Рассвет|Люди""".split("|")

# Latin to Cyrillic for the transliteration, longest patterns first. The
# result is a reading aid, not a scholarly transcription.
_CYR = [
    ("llaah", "ллях"), ("laah", "лях"), ("sh", "ш"), ("kh", "х"), ("gh", "г"),
    ("th", "с"), ("dh", "з"), ("aaa", "а"), ("aa", "а"), ("eee", "и"),
    ("ee", "и"), ("ooo", "у"), ("oo", "у"), ("ai", "ай"), ("ay", "ай"),
    ("aw", "ау"), ("ya", "я"), ("yu", "ю"), ("iy", "ий"), ("y", "й"),
    ("a", "а"), ("b", "б"), ("c", "к"), ("d", "д"), ("e", "е"), ("f", "ф"),
    ("g", "г"), ("h", "х"), ("i", "и"), ("j", "дж"), ("k", "к"), ("l", "л"),
    ("m", "м"), ("n", "н"), ("o", "о"), ("q", "к"), ("r", "р"), ("s", "с"),
    ("t", "т"), ("u", "у"), ("w", "в"), ("x", "кс"), ("z", "з"), ("'", "’"),
]


def cyrillic(latin):
    out = []
    i = 0
    low = latin.lower()
    while i < len(latin):
        for src, dst in _CYR:
            if low.startswith(src, i):
                if latin[i].isupper():
                    dst = dst[0].upper() + dst[1:]
                out.append(dst)
                i += len(src)
                break
        else:
            out.append(latin[i])
            i += 1
    return "".join(out)


def fetch(cache, name, url):
    path = os.path.join(cache, name)
    if not os.path.exists(path) or os.path.getsize(path) == 0:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        print("fetch", url)
        with urllib.request.urlopen(url, timeout=180) as r, open(path, "wb") as f:
            f.write(r.read())
    return path


def load(cache, name, url):
    with open(fetch(cache, name, url), encoding="utf-8") as f:
        return json.load(f)


def dump(path, value):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(value, f, ensure_ascii=False, separators=(",", ":"))


def fix(arabic):
    # The source puts a space between an open fathatan (U+08F0) and the alif
    # or alif maqsura that carries it, which splits one word in two when it
    # is shown in a standard font. No letter or mark is changed.
    return re.sub("\u08f0 (?=[\u0627\u0649])", "\u08f0", arabic)


def build_quran(cache):
    info = load(cache, "qinfo.json", f"{RAW}/fawazahmed0/quran-api/1/info.json")
    chapters = info["chapters"]
    assert len(chapters) == 114 and len(RU_NAMES) == 114
    counts = [len(c["verses"]) for c in chapters]
    assert sum(counts) == TOTAL_AYAHS

    by_lang = {}
    for lang, edition in QURAN.items():
        data = load(
            cache,
            f"q_{edition}.json",
            f"{RAW}/fawazahmed0/quran-api/1/editions/{edition}.min.json",
        )["quran"]
        assert len(data) == TOTAL_AYAHS, (edition, len(data))
        surahs = [[] for _ in range(114)]
        for row in data:
            surahs[row["chapter"] - 1].append((row["verse"], row["text"]))
        for i, rows in enumerate(surahs):
            assert [v for v, _ in rows] == list(range(1, counts[i] + 1)), (edition, i + 1)
            assert all(t.strip() for _, t in rows) or lang != "ar", (edition, i + 1)
        by_lang[lang] = [[fix(t) if lang == "ar" else t for _, t in rows] for rows in surahs]

    assert len(RU_MEANINGS) == 114
    latin_rows = load(
        cache,
        "q_ara-quran-la1.json",
        f"{RAW}/fawazahmed0/quran-api/1/editions/ara-quran-la1.min.json",
    )["quran"]
    assert len(latin_rows) == TOTAL_AYAHS
    latin = [[] for _ in range(114)]
    for row in latin_rows:
        latin[row["chapter"] - 1].append(row["text"].strip())
    assert [len(x) for x in latin] == counts

    index = []
    for i, c in enumerate(chapters):
        arabic = c["arabicname"]
        index.append({
            "n": i + 1,
            "name": c["name"],
            "en": c["englishname"],
            "ru": RU_NAMES[i],
            "ruM": RU_MEANINGS[i],
            "ar": arabic,
            "ayahs": counts[i],
            "makkan": c["revelation"].lower().startswith("mec")
            or c["revelation"].lower().startswith("mak"),
        })
        surah = {lang: by_lang[lang][i] for lang in QURAN}
        surah["tl"] = latin[i]
        surah["tc"] = [cyrillic(t) for t in latin[i]]
        surah["tj"] = [tajweed.spans(a) for a in surah["ar"]]
        dump(f"assets/quran/s/{i + 1:03d}.json", surah)
    dump("assets/quran/surahs.json", index)

    def starts(key):
        refs = info[key]["references"]
        return [[r["start"]["chapter"], r["start"]["verse"]] for r in refs]

    pages, juzs = starts("pages"), starts("juzs")
    assert len(pages) == 604 and len(juzs) == 30
    assert pages == sorted(pages) and juzs == sorted(juzs)
    dump("assets/quran/layout.json", {"pages": pages, "juz": juzs})
    tajweed.report()
    print("quran: 114 surahs,", TOTAL_AYAHS, "ayahs,", len(QURAN), "editions")
    return counts


def build_tafsir(cache, counts):
    for lang, slug in TAFSIR.items():
        missing = 0
        for n in range(1, 115):
            rows = load(
                cache,
                f"taf/{slug}/{n}.json",
                f"{RAW}/spa5k/tafsir_api/main/tafsir/{slug}/{n}.json",
            )
            if isinstance(rows, dict):
                rows = rows.get("ayahs", [])
            texts = [""] * counts[n - 1]
            for row in rows:
                a = int(row["ayah"])
                if 1 <= a <= len(texts):
                    texts[a - 1] = (row.get("text") or "").strip()
            missing += sum(1 for t in texts if not t)
            dump(f"assets/tafsir/{lang}/{n:03d}.json", texts)
        print(f"tafsir {lang}: ayahs without own text: {missing}")


def clean(text):
    return text.replace("\\n", "\n").replace("\r", "").strip()


def build_hadith(cache):
    editions = {}
    for lang, edition in HADITH.items():
        data = load(
            cache,
            f"h_{edition}.json",
            f"{RAW}/fawazahmed0/hadith-api/1/editions/{edition}.min.json",
        )["hadiths"]
        editions[lang] = {
            h["hadithnumber"]: clean(h["text"])
            for h in data
            if isinstance(h["hadithnumber"], int)
        }
    pool = []
    for n in sorted(editions["en"]):
        en = editions["en"].get(n, "")
        ru = editions["ru"].get(n, "")
        ar = editions["ar"].get(n, "")
        if not (en and ru and ar):
            continue
        if not (DAILY_EN_MIN <= len(en) <= DAILY_EN_MAX):
            continue
        if len(ru) > DAILY_RU_MAX or len(ar) > DAILY_AR_MAX:
            continue
        pool.append({"n": n, "ar": ar, "en": en, "ru": ru})
    dump("assets/hadith/daily.json", pool)
    print("hadith of the day pool:", len(pool), "of", len(editions["en"]))


def build_font(cache):
    src = fetch(cache, "AmiriQuran.ttf", f"{RAW}/aliftype/amiri/main/fonts/AmiriQuran.ttf")
    os.makedirs("assets/fonts", exist_ok=True)
    with open(src, "rb") as f, open("assets/fonts/AmiriQuran.ttf", "wb") as out:
        out.write(f.read())
    fetch(cache, "OFL.txt", f"{RAW}/aliftype/amiri/main/OFL.txt")
    with open(os.path.join(cache, "OFL.txt"), "rb") as f, open(
        "assets/fonts/AmiriQuran-OFL.txt", "wb"
    ) as out:
        out.write(f.read())


def main():
    cache = sys.argv[1] if len(sys.argv) > 1 else ".content_cache"
    os.makedirs(cache, exist_ok=True)
    counts = build_quran(cache)
    build_tafsir(cache, counts)
    build_hadith(cache)
    build_font(cache)


if __name__ == "__main__":
    main()
