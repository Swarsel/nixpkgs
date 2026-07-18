{
  buildDunePackage,
  eio,
  fmt,
  logs,
  uring,
}:

buildDunePackage {
  inherit (eio)
    meta
    src
    patches
    version
    ;

  pname = "eio_linux";

  propagatedBuildInputs = [
    eio
    fmt
    logs
    uring
  ];

  dontStrip = true;
  minimalOCamlVersion = "5.0";
}
