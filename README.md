# Programski prevodioci — Projekat

Implementacija kompajlera za programski jezik **Cool** (Classroom Object-Oriented Language).

Projekat se sastoji od 4 faze, svaka pokriva jednu komponentu kompajlera.

## Struktura

```
I dio/
  PA1/        — Leksička analiza (skener)
  PA1.pdf     — Specifikacija zadatka
  WA1f.pdf    — Pismeni zadatak 1

II dio/
  PA2.pdf     — Specifikacija zadatka (parser)
  WA2.pdf     — Pismeni zadatak 2

cool-manual.pdf  — Cool language manual
```

## Faze projekta

| Faza | Opis | Status |
|------|------|--------|
| PA1 | Leksička analiza (Flex) | Završeno |
| PA2 | Parsiranje (Bison) | |
| PA3 | Semantička analiza | |
| PA4 | Generisanje koda | |

## PA1 — Leksička analiza

Skener tokenizuje Cool izvorni kod koristeći **Flex**.

```bash
cd "I dio/PA1"
flex pa1.l
gcc lex.yy.c -o skener
./skener < proba.cool
```

Više detalja u [I dio/PA1/README.md](I%20dio/PA1/README.md).
