# audiveris-dn – Duly Noteds patchserie på Audiveris

Fork av [Audiveris](https://github.com/Audiveris/audiveris) (AGPL v3) för bättre trumigenkänning i
Duly Noted. **Inte en egen kodbas:** grenen `dn-patches` är uppströms tagg `5.11.0` plus en kort serie
egna commits, som rebasas på varje ny uppströmsrelease. Hur det går till står i
[`dn/RELEASERUTIN.md`](dn/RELEASERUTIN.md).

- `upstream` = github.com/Audiveris/audiveris (bara hämtning). Ingen egen GitHub-remote än; när
  forken körs i prod ska den publiceras (AGPL kräver att ändrad källkod kan lämnas ut).
- `dn/build-deb.sh` bygger samma .deb som uppströms release (jlink + jpackage) i Docker med
  Temurin JDK 25 på Ubuntu 24.04. Prod-paketet byggs på x86_64 (VM 103 eller one); Mac-bygget är
  kompileringskontroll.
- `dn/VERSION` = forkens suffix (`dn1`, `dn2` …), hamnar i .deb-filnamnet. Audiveris egen version
  ändras inte.
- Duly Noteds `deploy/Dockerfile` hämtar i dag uppströms .deb från GitHub. Steget att låta den ta
  forkens .deb i stället görs i duly-noted, samordnat med den sessionen.
- Repot synkas mellan datorerna med Syncthing som resten av `~/Projects`; `build` och `.gradle`
  står i `.stignore`. Kör inte bygget på båda datorerna samtidigt.

Beslutet (Erik 2026-11-03): forka som patchserie, mät varje ny uppströmsrelease mot forken, stryk
patchar uppströms hunnit ikapp, skicka resten som pull requests.

Uppströms README: [README.upstream.md](README.upstream.md).
