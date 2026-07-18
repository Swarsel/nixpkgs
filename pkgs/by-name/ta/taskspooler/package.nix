{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  makeWrapper,
}:

stdenv.mkDerivation {
  pname = "taskspooler";
  version = "1.0.1";

  src = fetchurl {
    url = "https://vicerveza.homeunix.net/%7Eviric/wsgi-bin/hgweb.wsgi/ts/archive/7cf9a8bda6d3.tar.gz";
    sha256 = "11i21s8sdmjl4gy5f3dyfsxsmg1japgs4r5ym0b3jdyp99xhpbl1";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace "PREFIX?=/usr/local" "PREFIX=$out"
  '';

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/ts \
      --set-default TS_SLOTS "$(${coreutils}/bin/nproc --all)"
  '';

  meta = {
    description = "Simple single node task scheduler";
    homepage = "https://vicerveza.homeunix.net/~viric/wsgi-bin/hgweb.wsgi/ts";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.sheepforce ];
    platforms = lib.platforms.unix;
    mainProgram = "ts";
  };
}
