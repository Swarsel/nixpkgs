{
  lib,
  stdenv,
  fetchurl,
  libx11,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "runningx";
  version = "1.0";

  src = fetchurl {
    url = "http://www.fiction.net/blong/programs/mutt/autoview/RunningX.c";
    sha256 = "1mikkhrx6jsx716041qdy3nwjac08pxxvxyq2yablm8zg9hrip0d";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libx11 ];

  buildPhase = ''
    cc -O2 -o RunningX $(pkg-config --cflags --libs x11) $src
  '';

  installPhase = ''
    mkdir -p "$out"/bin
    cp -vai RunningX "$out/bin"
  '';

  dontUnpack = true;

  meta = {
    description = "Program for testing if X is running";
    homepage = "http://www.fiction.net/blong/programs/mutt/";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.unix;
    mainProgram = "RunningX";
  };
}
