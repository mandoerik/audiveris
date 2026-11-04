> **English:** this is [Duly Noted](https://dulynoted.se)'s fork of [Audiveris](https://github.com/Audiveris/audiveris) (AGPL v3),
> kept as a short patch series on branch `dn-patches` on top of the upstream tag `5.11.0`. The patches make the `drumNotation`
> switch leave the pitched staves of a mixed sheet unchanged and fix a MusicXML export crash for drum parts that start in a G clef;
> see the commits and `dn/RELEASERUTIN.md`. The rest of this file is in Swedish. Upstream README: [README.upstream.md](README.upstream.md).

# audiveris-dn – Duly Noteds patchserie på Audiveris

Fork av [Audiveris](https://github.com/Audiveris/audiveris) (AGPL v3) för bättre trumigenkänning i
[Duly Noted](https://dulynoted.se). Inte en egen kodbas: grenen `dn-patches` är uppströms tagg `5.11.0` plus en
kort serie egna commits, som rebasas på varje ny uppströmsrelease. Hur det går till står i
[`dn/RELEASERUTIN.md`](dn/RELEASERUTIN.md).

- `upstream` = github.com/Audiveris/audiveris (bara hämtning). `origin` = github.com/mandoerik/audiveris, publik
  sedan 2026-11-04 (AGPL kräver att ändrad källkod kan lämnas ut); taggar `5.11.0-dnN` + GitHub-releaser med .deb.
- `dn/build-deb.sh` bygger samma .deb som uppströms release (jlink + jpackage) i Docker med Temurin JDK 25 på
  Ubuntu 24.04.
- `dn/smoke-test.sh` installerar en byggd .deb i en ren Ubuntu 24.04-container (`dpkg-deb -x` plus körtidsbiblioteken)
  och kör `Audiveris -version`.
- `dn/VERSION` = forkens suffix (`dn1`, `dn2` …), hamnar i .deb-filnamnet. Audiveris egen version ändras inte.

Uppströms README: [README.upstream.md](README.upstream.md).
