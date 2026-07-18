{
  lib,
  stdenv,
  buildDunePackage,
  dune-configurator,
  eio,
  fmt,
  iomux,
  logs,
}:

buildDunePackage {
  inherit (eio)
    meta
    src
    patches
    version
    ;

  pname = "eio_posix";

  buildInputs = [
    dune-configurator
  ];

  propagatedBuildInputs = [
    eio
    fmt
    logs
    iomux
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_CFLAGS_COMPILE = "-Wno-implicit-function-declaration";
  };

  dontStrip = true;
  minimalOCamlVersion = "5.0";
}
