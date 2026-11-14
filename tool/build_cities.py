"""Builds assets/cities.tsv from the GeoNames cities15000 dump.

Usage: python3 tool/build_cities.py path/to/cities15000.json
The JSON comes from the `geonamescache` PyPI package (GeoNames data, CC BY 4.0).
Columns: name, country code, latitude, longitude, IANA timezone, population,
Cyrillic and Arabic alternate names (plus Latin ones for large cities)
joined with '|'. Rows are sorted by
population, largest first, so search results come out ranked.
"""
import json
import sys
import unicodedata


LATIN_ALT_MIN_POPULATION = 100_000


def script_of(text):
    for ch in text:
        if ch.isalpha():
            name = unicodedata.name(ch, "")
            if name.startswith("CYRILLIC"):
                return "cyr"
            if name.startswith("ARABIC"):
                return "ara"
            if name.startswith("LATIN"):
                return "lat"
            return "other"
    return "other"


def main():
    src = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else "assets/cities.tsv"
    with open(src, encoding="utf-8") as f:
        cities = list(json.load(f).values())
    cities.sort(key=lambda c: -c["population"])
    rows = 0
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        for c in cities:
            if not c.get("timezone"):
                continue
            alts = []
            seen = set()
            for a in c.get("alternatenames", []):
                a = a.strip()
                if not a or a in seen or "\t" in a or "|" in a:
                    continue
                script = script_of(a)
                # Latin spellings (Mecca for Makkah) are kept for large cities
                # only, to hold the file size down. Airport codes are dropped.
                latin_ok = (
                    script == "lat"
                    and c["population"] >= LATIN_ALT_MIN_POPULATION
                    and a != c["name"]
                    and not (len(a) <= 3 and a.isupper())
                )
                if script in ("cyr", "ara") or latin_ok:
                    seen.add(a)
                    alts.append(a)
            f.write("\t".join([
                c["name"],
                c["countrycode"],
                f'{c["latitude"]:.4f}',
                f'{c["longitude"]:.4f}',
                c["timezone"],
                str(c["population"]),
                "|".join(alts),
            ]) + "\n")
            rows += 1
    print(rows, "cities written to", out)


if __name__ == "__main__":
    main()
