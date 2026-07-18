{
  linuxHeaders,
  sourceProg,
  stdenv,
  unsecvars,
  debug ? false,
}:
# For testing:
# $ nix-build -E 'with import <nixpkgs> {}; pkgs.callPackage ./wrapper.nix { sourceProg = "${pkgs.hello}/bin/hello"; debug = true; }'
stdenv.mkDerivation {
  CFLAGS = [
    ''-DSOURCE_PROG="${sourceProg}"''
  ]
  ++ (
    if debug then
      [
        "-Werror"
        "-Og"
        "-g"
      ]
    else
      [
        "-Wall"
        "-O2"
      ]
  );

  buildInputs = [ linuxHeaders ];
  dontStrip = debug;
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    $CC $CFLAGS ${./wrapper.c} -I${unsecvars} -o $out/bin/security-wrapper
  '';

  name = "security-wrapper-${baseNameOf sourceProg}";
}
