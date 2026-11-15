"""Tajweed colouring derived from the Madinah (KFGQPC) Uthmani text.

That orthography already writes the rules into the text: a noon that is
pronounced clearly carries a sukun and one that is hidden or merged carries
nothing, tanween is drawn "open" when it is hidden or merged, a small meem
marks iqlab, a maddah sign marks every obligatory lengthening. This module
only reads those marks; it never changes the text.

`spans(ayah)` returns a flat list [start, length, kind, ...] of UTF-16
offsets. A span always covers whole letters with their marks, so colouring
never separates a mark from its letter.
"""
import collections
import unicodedata

MADD_LAZIM, MADD_MUTTASIL, MADD_MUNFASIL, MADD_ARID, GHUNNAH, QALQALAH, SILENT = range(7)

FATHA, DAMMA, KASRA, SHADDA = "َ", "ُ", "ِ", "ّ"
SUKUN = "ۡ"  # the Madinah mushaf sukun (a small head of khah)
MADDAH = "ٓ"
DAGGER_ALIF = "ٰ"
SILENT_MARKS = "ْ۠"  # round and rectangular zero: not pronounced
OPEN_TANWEEN = "ࣰࣱࣲ"
TANWEEN = "ًٌٍ" + OPEN_TANWEEN
SMALL_MEEM = "ۭۢ"
VOWELS = FATHA + DAMMA + KASRA + SHADDA + SUKUN + TANWEEN + MADDAH + DAGGER_ALIF
QALQALAH_LETTERS = "قطبجد"
LONG = "اوىي"
IGNORED = "۞۩‏"

counts = collections.Counter()


class Cluster:
    __slots__ = ("start", "end", "base", "marks", "word", "first")

    def __init__(self, start, base, word, first):
        self.start, self.end, self.base = start, start + 1, base
        self.marks, self.word, self.first = "", word, first

    def has(self, chars):
        return any(m in chars for m in self.marks)

    @property
    def bare(self):
        return not self.has(VOWELS + SILENT_MARKS + "ٕٔ")


def clusters(text):
    out, word, first = [], 0, True
    for i, ch in enumerate(text):
        if ch == " ":
            word += 1
            first = True
        elif ch in IGNORED:
            continue
        elif unicodedata.category(ch) == "Mn":
            if out and out[-1].end == i:
                out[-1].marks += ch
                out[-1].end = i + 1
        else:
            out.append(Cluster(i, ch, word, first))
            first = False
    return out


def spans(text):
    cs = clusters(text)
    kinds = {}

    def mark(i, kind):
        kinds.setdefault(i, kind)

    def following(i):
        """The next pronounced letter after cluster i."""
        j = i + 1
        while j < len(cs) and (
            cs[j].has(SILENT_MARKS)
            or cs[j].base == "ـ"
            or (cs[j].base in "اٱى" and cs[j].bare and not cs[j].has(MADDAH))
        ):
            j += 1
        return cs[j] if j < len(cs) else None

    def vocative(i):
        """The ya of address and the ha of attention are separate words
        written joined to the next one, so their madd is munfasil."""
        c = cs[i]
        if c.base not in "يه" or not c.has(DAGGER_ALIF):
            return False
        if c.first:
            return True
        prev = cs[i - 1]
        return prev.first and prev.base in "وفأا" and prev.word == c.word

    for i, c in enumerate(cs):
        nxt = cs[i + 1] if i + 1 < len(cs) else None
        after = following(i)

        # Obligatory lengthening, written with a maddah sign.
        if c.has(MADDAH):
            vowel_letter = c.base in LONG + "ۥۦ" or c.has(DAGGER_ALIF)
            same_word = nxt is not None and nxt.word == c.word
            if not vowel_letter or (same_word and nxt.has(SHADDA + SUKUN)) or (
                same_word and nxt.bare and nxt.base not in "اٱءوي"
            ):
                mark(i, MADD_LAZIM)
            elif same_word and not vocative(i):
                mark(i, MADD_MUTTASIL)
            else:
                mark(i, MADD_MUNFASIL)
            continue

        if c.has(SILENT_MARKS):
            mark(i, SILENT)
            continue

        # Noon and meem with a shadda are held with nasalisation.
        if c.base in "نم" and c.has(SHADDA):
            mark(i, GHUNNAH)
            continue

        if c.has(SMALL_MEEM):  # iqlab of a noon or of tanween
            mark(i, GHUNNAH)
            continue

        if c.base == "ن" and c.bare and after is not None:
            if after.has(SHADDA):
                mark(i, GHUNNAH if after.base in "يو" else SILENT)
            else:
                mark(i, GHUNNAH)  # ikhfa
            continue

        if c.has(OPEN_TANWEEN) and after is not None:
            if after.has(SHADDA):
                if after.base in "يو":
                    mark(cs.index(after), GHUNNAH)
            else:
                mark(i, GHUNNAH)  # ikhfa
            continue

        if c.base == "م" and c.bare and after is not None:
            if after.base == "ب":
                mark(i, GHUNNAH)  # ikhfa shafawi
            elif after.base == "م" and after.has(SHADDA):
                mark(i, SILENT)
            continue

        if c.base in QALQALAH_LETTERS and c.has(SUKUN):
            mark(i, QALQALAH)
            continue

        # A letter written without any mark before a doubled one is merged
        # into it: the lam of the article before a sun letter, and so on.
        if (
            c.bare
            and c.base not in LONG + "ٱةءـۥۦ"
            and nxt is not None
            and nxt.has(SHADDA)
        ):
            mark(i, SILENT)

    # When stopping at the end of the ayah.
    if len(cs) >= 2:
        last = len(cs) - 1
        while last > 0 and cs[last].base in "اى" and cs[last].bare:
            last -= 1
        end, before = cs[last], cs[last - 1]
        if end.base in QALQALAH_LETTERS and not end.has(TANWEEN):
            mark(last, QALQALAH)
        if last == len(cs) - 1 and end.base not in LONG and not end.has(SHADDA + MADDAH):
            prev = cs[last - 2] if last >= 2 else None
            long_alif = before.base == "ا" and before.bare
            long_waw = before.base == "و" and before.bare and prev is not None and prev.has(DAMMA)
            long_yeh = before.base in "يى" and before.bare and prev is not None and prev.has(KASRA)
            if (long_alif or long_waw or long_yeh) and before.word == end.word:
                mark(last - 1, MADD_ARID)
            elif before.has(DAGGER_ALIF) and before.word == end.word and not before.has(MADDAH):
                mark(last - 1, MADD_ARID)

    out = []
    for i in sorted(kinds):
        counts[kinds[i]] += 1
        c = cs[i]
        if out and out[-1] == kinds[i] and out[-3] + out[-2] == c.start:
            out[-2] += c.end - c.start
        else:
            out += [c.start, c.end - c.start, kinds[i]]
    return out


def report():
    names = ["madd lazim", "madd muttasil", "madd munfasil", "madd at stop",
             "ghunnah", "qalqalah", "silent"]
    print("tajweed:", ", ".join(f"{names[k]} {counts[k]}" for k in sorted(counts)))
