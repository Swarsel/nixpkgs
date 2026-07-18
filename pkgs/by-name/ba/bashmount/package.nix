{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  cryptsetup,
  eject,
  gnugrep,
  gnused,
  less,
  makeWrapper,
  udisks,
  util-linux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bashmount";
  version = "4.3.2";

  src = fetchFromGitHub {
    owner = "jamielinux";
    repo = "bashmount";
    tag = finalAttrs.version;
    sha256 = "1irw47s6i1qwxd20cymzlfw5sv579cw877l27j3p66qfhgadwxrl";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp bashmount $out/bin

    mkdir -p $out/etc
    cp bashmount.conf $out/etc

    mkdir -p $out/share/man/man1
    gzip -c -9 bashmount.1 > bashmount.1.gz
    cp bashmount.1.gz $out/share/man/man1

    mkdir -p $out/share/doc/bashmount
    cp COPYING $out/share/doc/bashmount
    cp NEWS    $out/share/doc/bashmount
  '';

  postFixup = ''
    wrapProgram $out/bin/bashmount \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          cryptsetup
          eject
          gnugrep
          gnused
          less
          udisks
          util-linux
        ]
      }
  '';

  meta = {
    description = "Menu-driven bash script for the management of removable media with udisks";
    homepage = "https://github.com/jamielinux/bashmount";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.koral ];
    platforms = lib.platforms.all;
    mainProgram = "bashmount";
  };
})
