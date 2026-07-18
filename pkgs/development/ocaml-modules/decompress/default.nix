{
  lib,
  fetchurl,
  alcotest,
  astring,
  base64,
  bigstringaf,
  bos,
  buildDunePackage,
  camlzip,
  checkseum,
  cmdliner,
  crowbar,
  ctypes,
  fmt,
  optint,
  rresult,
}:

buildDunePackage (finalAttrs: {
  pname = "decompress";
  version = "1.5.3";

  src = fetchurl {
    url = "https://github.com/mirage/decompress/releases/download/v${finalAttrs.version}/decompress-${finalAttrs.version}.tbz";
    hash = "sha256-+R5peL7/P8thRA0y98mcmfHoZUtPsYQIdB02A1NzrGA=";
  };

  buildInputs = [ cmdliner ];

  propagatedBuildInputs = [
    optint
    checkseum
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    astring
    bigstringaf
    bos
    ctypes
    fmt
    camlzip
    base64
    crowbar
    rresult
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Pure OCaml implementation of Zlib";
    homepage = "https://github.com/mirage/decompress";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "decompress.pipe";
  };
})
