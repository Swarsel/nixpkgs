{
  lib,
  fetchurl,
  alcotest,
  astring,
  bos,
  buildDunePackage,
  dune-configurator,
  fmt,
  fpath,
  optint,
  rresult,
}:

buildDunePackage (finalAttrs: {
  pname = "checkseum";
  version = "0.5.3";

  src = fetchurl {
    url = "https://github.com/mirage/checkseum/releases/download/v${finalAttrs.version}/checkseum-${finalAttrs.version}.tbz";
    hash = "sha256-uIwRmUNBITo1wj80Fou6enS/P4kFH3e+s52COtzhpTE=";
  };

  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    optint
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    bos
    astring
    fmt
    fpath
    rresult
  ];

  meta = {
    description = "ADLER-32 and CRC32C Cyclic Redundancy Check";
    homepage = "https://github.com/mirage/checkseum";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "checkseum.checkseum";
  };
})
