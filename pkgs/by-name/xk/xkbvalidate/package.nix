{
  lib,
  libxkbcommon,
  runCommandCC,
}:

runCommandCC "xkbvalidate"
  {
    pname = "xkbvalidate";
    version = lib.trivial.release;
    buildInputs = [ libxkbcommon ];

    meta = {
      description = "NixOS tool to validate X keyboard configuration";
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.aszlig ];
      platforms = lib.platforms.unix;
      mainProgram = "xkbvalidate";
    };
  }
  ''
    mkdir -p "$out/bin"
    $CC -std=c11 -Wall -pedantic -lxkbcommon ${./xkbvalidate.c} \
      -o "$out/bin/xkbvalidate"
  ''
