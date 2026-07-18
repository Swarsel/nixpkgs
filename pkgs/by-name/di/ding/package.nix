{
  lib,
  stdenv,
  fetchurl,
  aspell,
  aspellDicts,
  buildEnv,
  fortune,
  gnugrep,
  makeWrapper,
  tk,
  tre,
}:
let
  aspellEnv = buildEnv {
    name = "env-ding-aspell";

    paths = [
      aspell
      aspellDicts.de
      aspellDicts.en
    ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ding";
  version = "1.9";

  src = fetchurl {
    url = "https://ftp.tu-chemnitz.de/pub/Local/urz/ding/ding-${finalAttrs.version}.tar.gz";
    hash = "sha256-aabIH894WihsBTo1LzIBzIZxxyhRYVxLcHpDQwmwmOU=";
  };

  patches = [ ./dict.patch ];
  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    aspellEnv
    fortune
    gnugrep
    tk
    tre
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/dict
    mkdir -p $out/share/man/man1
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/32x32/apps

    for f in ding ding.1; do
      sed -i "s@/usr/share@$out/share@g" "$f"
    done

    sed -i "s@/usr/bin/fortune@fortune@g" ding

    sed -i "s@/usr/bin/ding@$out/bin/ding@g" ding.desktop

    cp -v ding $out/bin/
    cp -v de-en.txt $out/share/dict/
    cp -v ding.1 $out/share/man/man1/
    cp -v ding.png $out/share/icons/hicolor/32x32/apps
    cp -v ding.desktop $out/share/applications/

    wrapProgram $out/bin/ding --prefix PATH : ${
      lib.makeBinPath [
        gnugrep
        aspellEnv
        tk
        fortune
      ]
    } --prefix ASPELL_CONF : "\"prefix ${aspellEnv};\""
  '';

  meta = {
    description = "Simple and fast dictionary lookup tool";
    homepage = "https://www-user.tu-chemnitz.de/~fri/ding/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.exi ];
    platforms = lib.platforms.linux; # homepage says: unix-like except darwin
    mainProgram = "ding";
  };
})
