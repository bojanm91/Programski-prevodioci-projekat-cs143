# PA1 — Leksička analiza (Cool jezik)

Leksički analizator (skener) za programski jezik **Cool**, implementiran pomoću alata **Flex**.

## Šta radi

Skener čita izvorni kod i tokenizuje ga — prepoznaje i ispisuje sljedeće tokene:

| Tip tokena | Primjer |
|------------|---------|
| Cijeli brojevi | `42`, `0`, `9999` |
| String konstante | `"hello\nworld"` |
| Bool konstante | `true`, `fAlse` |
| Keywords | `if`, `CLASS`, `While` (case-insensitive) |
| Type identifikatori | `MyClass`, `Int` |
| Object identifikatori | `myVar`, `x` |
| Operatori | `<-`, `<=`, `=>`, `+`, `-`, `*`, `/`, `~`, `<`, `=` |
| Specijalni simboli | `( ) { } ; : . @ ,` |
| Komentari | `-- linija` i `(* blok *)` (sa ugnježđavanjem) |

## Error handling

Skener prijavljuje sljedeće greške:

- `EOF in string constant` — fajl završio unutar stringa
- `Unterminated string constant` — neescapeovan newline unutar stringa
- `String contains null character` — literalni null bajt u stringu
- `String constant too long` — string duži od 1024 karaktera
- `EOF in comment` — fajl završio unutar `(* *)` komentara
- `Unmatched *)` — zatvarajući komentar bez otvarajućeg
- `invalid character` — karakter koji ne počinje nijedan token

## Pokretanje

```bash
# Kompajliranje
flex pa1.l
gcc lex.yy.c -o skener

# Pokretanje na fajlu
./skener < proba.cool

# Ili direktno iz terminala
echo 'if x <- 42' | ./skener
```

## Struktura

```
pa1.l       — Flex pravila (leksička specifikacija)
proba.cool  — Test primjeri
```
