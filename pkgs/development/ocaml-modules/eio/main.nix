{
  lib,
  stdenv,
  buildDunePackage,
  eio,
  eio_linux,
  eio_posix,
}:

buildDunePackage {
  inherit (eio)
    meta
    src
    patches
    version
    ;

  pname = "eio_main";

  propagatedBuildInputs = [
    eio_posix
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    eio_linux
  ];

  dontStrip = true;
  minimalOCamlVersion = "5.0";
}
