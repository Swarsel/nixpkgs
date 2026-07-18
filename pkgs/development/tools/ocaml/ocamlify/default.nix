{
  lib,
  fetchurl,
  buildDunePackage,
  camlp-streams,
}:

buildDunePackage (finalAttrs: {
  pname = "ocamlify";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/gildor478/ocamlify/releases/download/v${finalAttrs.version}/ocamlify-${finalAttrs.version}.tbz";
    hash = "sha256-u0pGiwLR/5N0eRv+eSkdR71snyiSDPwh8JwuxbcXIGA=";
  };

  propagatedBuildInputs = [
    camlp-streams
  ];

  doCheck = true;
  dontStrip = true;

  meta = {
    description = "Include files in OCaml code";
    homepage = "https://github.com/gildor478/ocamlify";
    license = lib.licenses.lgpl21;
    mainProgram = "ocamlify";
  };
})
