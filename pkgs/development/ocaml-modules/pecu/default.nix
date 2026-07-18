{
  lib,
  fetchurl,
  alcotest,
  astring,
  buildDunePackage,
  crowbar,
  fmt,
  ocaml,
}:

buildDunePackage (finalAttrs: {
  pname = "pecu";
  version = "0.7";

  src = fetchurl {
    url = "https://github.com/mirage/pecu/releases/download/v${finalAttrs.version}/pecu-${finalAttrs.version}.tbz";
    hash = "sha256-rXR3tbFkKNM8MkQAZ2hJU9lO+qQ/qvYghXkYus6f13g=";
  };

  # crowbar availability
  doCheck = lib.versionAtLeast ocaml.version "4.08";

  checkInputs = [
    fmt
    alcotest
    crowbar
    astring
  ];

  minimalOCamlVersion = "4.03";

  meta = {
    description = "Encoder/Decoder of Quoted-Printable (RFC2045 & RFC2047)";
    homepage = "https://github.com/mirage/pecu";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
