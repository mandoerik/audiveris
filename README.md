# Audiveris – Duly Noted patch series

Fork of [Audiveris](https://github.com/Audiveris/audiveris) (AGPL-3.0) used by [Duly Noted](https://dulynoted.se).
Branch `dn-patches` is the upstream tag `5.11.0` plus a few commits (`git log 5.11.0..dn-patches`), rebased on
each upstream release. Upstream README: [README.upstream.md](README.upstream.md).

**Patches**

- `drumNotation` leaves the pitched (G/F/C clef) staves of a sheet unchanged: standard staves get the same head
  templates, playing-sign handling and head sizing as without the switch (`ShapeSet`, `NoteHeadsBuilder`,
  `SpotsBuilder`, `InterFactory`).
- No `NullPointerException` in the MusicXML export when a drum part starts in a G clef and switches to the
  percussion clef later (`PartwiseBuilder`).

**Build**

`dn/build-deb.sh` builds the same `.deb` as the upstream release (jlink + jpackage) in Docker with Temurin JDK 25
on Ubuntu 24.04; `PLATFORM=linux/amd64` builds for x86_64 on another host. `dn/smoke-test.sh` installs a built
`.deb` in a clean container and runs `Audiveris -version`. Releases carry the `.deb` and its SHA-256.

Note: upstream's `collectJars` and `customJre` tasks run only when `packaging/build/jars` and
`packaging/build/custom-jre` are missing, so the script removes them before every build.
