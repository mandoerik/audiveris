# Releaserutin – när uppströms Audiveris släpper en ny version

Forken är **uppströms + en kort patchserie**, aldrig en egen kodbas. Varje patch är en commit på
`dn-patches` med ett mätt skäl i commit-texten. Varje ny uppströmsversion prövas så här, på test
(VM 103), aldrig direkt i prod.

## 1. Hämta och rebasa

```bash
git fetch upstream --tags
git branch dn-patches-5.11.0 dn-patches          # spara den gamla serien
git rebase --onto <ny tagg> 5.11.0 dn-patches    # flytta serien till den nya taggen
```

Krockar en patch: lös den eller lägg den åt sidan (`git rebase --skip`) och skriv upp det i
tabellen nedan. Krockar `dn/`-commiten löses alltid, den rör bara egna filer.

## 2. Bygg tre paket på VM 103

| Variant | Innehåll |
|---|---|
| A | dagens prod: gamla taggen + gamla serien (`dn-patches-5.11.0`) |
| B | ren ny tagg, utan patchar |
| C | ny tagg + rebasad serie (`dn-patches`) |

`dn/build-deb.sh` på respektive utcheckning (resultat i `dn/build/`), följt av `dn/smoke-test.sh`,
som installerar paketet som duly-noteds Dockerfile gör och kör `Audiveris -version`. B bygger man
enklast genom att hämta uppströms färdiga .deb från GitHub-releasen.

## 3. Mät alla tre i Duly Noteds testmiljö

Samma omgång som för en OCR-ändring: regress, `facit_all`, orkester- och trumsetbänken
(`tools/facit_realbook.py`), `export_check`, ackordjämförelse, torrkörning på one. Baslinje = A.

## 4. Avgör patch för patch, inte forken som helhet

- B läser lika bra eller bättre på det patchen rättade → **stryk patchen**.
- Patchen ger fortfarande vinst och rebasar rent → behåll.
- Uppströms har byggt om området → skriv om, eller acceptera förlusten tills vidare.

Tom serie efter en release = tillbaka på ren uppströms. Det är den normala vägen ut, inte ett
misslyckande.

## 5. Skicka patchar uppströms

Varje patch som kan skrivas allmänt (inte DN-specifik) läggs som pull request mot
`Audiveris/audiveris`. Mergad uppströms → lämnar serien av sig själv vid nästa release.
Patchar som förblir privata är en återkommande rebasekostnad.

## Regel för vad som får bli en patch

Forka bara för sådant Duly Noted **inte kan göra utifrån**: symboler Audiveris inte ser alls eller
slänger före export. Allt Audiveris läser men exporterar fel eller ofullständigt rättas i
`omrnotes`/`heads`/`perc` i duly-noted – de lagren behöver ingen rebase, bara ommätning.

## Fälla vid bygget

Uppströms `collectJars` (packaging/build.gradle) kör bara när `packaging/build/jars` saknas, så ett andra bygge i samma
träd packar den gamla jar:en. `dn/build-deb.sh` rensar `jars/` och `dist/` före varje bygge och vägrar om paketets jar
inte är den nybyggda. Upptäckt 2026-11-03 när tre paket visade sig ha identisk jar.

## Patchserien just nu

| # | Commit | Vad | Mätt vinst | Uppströms-PR |
|---|---|---|---|---|
| 0 | dn/ | bygg- och rutinfiler, ingen kodändring | – | – |
| 2 | `e5a62de` | `drumNotation` lämnar G-/F-/C-notraderna på samma ark orörda: standardnotrader får mallhuvudena som utan brytaren (`ShapeSet.getProcessedShapes(sheet, coll, drumStaff)`, `NoteHeadsBuilder.stdTemplateNotesAll`), och `BlackHeadSizer` mäter huvudstorleken ur standardnotradernas fläckar i stället för att hoppas över (`SpotsBuilder`) | se `slagverk/anteckningar/audiveris-patch-2.md` | ej skickad |
| 2b | `0ed1203` | Speltecknen (o, ø, +) blir `PlayingInter` bara för glyfer på slagverksrader (`InterFactory`); tidigare prövades de mot ackord på alla notrader när brytaren var på | se samma rapport | ej skickad |
| 1 | `a76e19a` | Exporten kraschade (NPE på `current.instrumentMap`) när trumstämmans första system börjar i G-klav och ett senare i slagverksklav; en logisk stämma är trumstämma så snart något systemparti är det, och notexporten tål en saknad karta (`PartwiseBuilder`) | se samma rapport | ej skickad |
