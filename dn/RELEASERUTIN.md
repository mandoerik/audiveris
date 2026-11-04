# Releaserutin – när uppströms Audiveris släpper en ny version

Forken är **uppströms + en kort patchserie**, aldrig en egen kodbas. Varje patch är en commit på
`dn-patches` med ett mätt skäl i commit-texten. Varje ny uppströmsversion prövas i testmiljön innan
den tas i drift.

## 1. Hämta och rebasa

```bash
git fetch upstream --tags
git branch dn-patches-5.11.0 dn-patches          # spara den gamla serien
git rebase --onto <ny tagg> 5.11.0 dn-patches    # flytta serien till den nya taggen
```

Krockar en patch: lös den eller lägg den åt sidan (`git rebase --skip`) och skriv upp det i
tabellen nedan. Krockar `dn/`-commiten löses alltid, den rör bara egna filer.

## 2. Bygg tre paket

| Variant | Innehåll |
|---|---|
| A | dagens drift: gamla taggen + gamla serien (`dn-patches-5.11.0`) |
| B | ren ny tagg, utan patchar |
| C | ny tagg + rebasad serie (`dn-patches`) |

`dn/build-deb.sh` på respektive utcheckning (resultat i `dn/build/`), följt av `dn/smoke-test.sh`.
B bygger man enklast genom att hämta uppströms färdiga .deb från GitHub-releasen.

## 3. Mät alla tre mot samma facit

Samma provbänk för alla tre, baslinje = A: slag och toner rätt mot facit, takter rätt, exporter
byte för byte där de ska vara identiska. Audiveris är inte deterministisk med trådparallellism; för
byte-jämförelser krävs `-constant org.audiveris.omr.util.OmrExecutors.useParallelism=false`.

## 4. Avgör patch för patch, inte forken som helhet

- B läser lika bra eller bättre på det patchen rättade → **stryk patchen**.
- Patchen ger fortfarande vinst och rebasar rent → behåll.
- Uppströms har byggt om området → skriv om, eller acceptera förlusten tills vidare.

Tom serie efter en release = tillbaka på ren uppströms. Det är den normala vägen ut, inte ett
misslyckande.

## 5. Skicka patchar uppströms

Varje patch som kan skrivas allmänt läggs som pull request mot `Audiveris/audiveris`.
Mergad uppströms → lämnar serien av sig själv vid nästa release. Patchar som förblir privata
är en återkommande rebasekostnad.

## Publicering (AGPL)

Forken är publik på https://github.com/mandoerik/audiveris (remote `origin`; `upstream` =
Audiveris/audiveris). Varje version som tas i drift: tagga toppen av `dn-patches` med `5.11.0-dnN`
(N ur `dn/VERSION`), pusha gren + tagg, bygg x86_64-.deb:en ur taggen (`dn/build-deb.sh`, på en
x86_64-värd eller med `PLATFORM=linux/amd64`) och lägg den med sha256 på en GitHub-release
(`gh release create 5.11.0-dnN dn/build/*.deb`). Det som körs i drift ska alltid finnas som tagg +
release. Första: `5.11.0-dn1` (2026-11-04).

## Fälla vid bygget

Uppströms `collectJars` (packaging/build.gradle) kör bara när `packaging/build/jars` saknas, så ett
andra bygge i samma träd packar den gamla jar:en. `dn/build-deb.sh` rensar `jars/` och `dist/` före
varje bygge och vägrar om paketets jar inte är den nybyggda.

## Regel för vad som får bli en patch

Forka bara för sådant som **inte kan göras utifrån**: symboler Audiveris inte ser alls eller slänger
före export. Allt Audiveris läser men exporterar fel eller ofullständigt rättas i appens egna lager
ovanpå exporten – de behöver ingen rebase, bara ommätning.

## Patchserien just nu

Mätt på en provbänk med 48 trumsetstämmor (104 notsidor, 33 927 facitslag) i tre notfonter.

| # | Commit | Vad | Mätt vinst | Uppströms-PR |
|---|---|---|---|---|
| 0 | dn/ | bygg- och rutinfiler, ingen kodändring | – | – |
| 2 | `e5a62de` | `drumNotation` lämnar G-/F-/C-notraderna på samma ark orörda: standardnotrader får mallhuvudena som utan brytaren (`ShapeSet.getProcessedShapes(sheet, coll, drumStaff)`, `NoteHeadsBuilder.stdTemplateNotesAll`) | se 2c (mäts som helhet) | ej skickad |
| 2b | `0ed1203` | Speltecknen (o, ø, +) blir `PlayingInter` bara för glyfer på slagverksrader (`InterFactory`); tidigare prövades de mot ackord på alla notrader när brytaren var på | se 2c | ej skickad |
| 2c | `58597e8` | Huvudstorleken (`BlackHeadSizer`) mäts ur alla fläckar även med `drumNotation`, som utan brytaren – att mäta bara ur standardnotraderna gav andra mallstorlekar och därmed andra huvudrutor på tonhöjdsraderna | 2+2b+2c med appens arkvisa trumläsning och dess skydd: 14 390 → 17 726 slag rätt av 33 927 (42,4 → 52,2 %); ark som skyddet avvisade 41 → 0 av 84. Ark utan slagverksklav läses byte-identiskt med brytaren av (29 av 29 provade PDF:er) | ej skickad |
| 1 | `a76e19a` | Exporten kraschade (NPE på `current.instrumentMap`) när trumstämmans första system börjar i G-klav och ett senare i slagverksklav; en logisk stämma är trumstämma så snart något systemparti är det, och notexporten tål en saknad karta (`PartwiseBuilder`) | brytaren på alla ark: +1 121 slag (17 318 → 18 439); fem stämmor får export där ingen fanns | ej skickad |
