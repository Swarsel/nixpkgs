{
  lib,
  fetchurl,
  buildDunePackage,
  callPackage,
  cmdliner,
  cppo,
  dune-build-info,
  fix,
  menhir,
  menhirLib,
  menhirSdk,
  merlin-extend,
  ppxlib,
}:

let
  param =
    if lib.versionAtLeast ppxlib.version "0.36" then
      {
        version = "3.18.0";
        hash = "sha256-T7pqFvVFUbeOHZDrLBZ/bulkyvU4O8LS+TzszH5k3EQ=";
      }
    else
      {
        version = "3.15.0";
        hash = "sha256-7D0gJfQ5Hw0riNIFPmJ6haoa3dnFEyDp5yxpDgX7ZqY=";
      };
in

buildDunePackage rec {
  inherit (param) version;
  pname = "reason";

  src = fetchurl {
    inherit (param) hash;
    url = "https://github.com/reasonml/reason/releases/download/${version}/reason-${version}.tbz";
  };

  nativeBuildInputs = [
    menhir
    cppo
  ];

  buildInputs = [
    dune-build-info
    fix
    menhirSdk
    merlin-extend
  ]
  ++ lib.optional (lib.versionAtLeast version "3.17") cmdliner;

  propagatedBuildInputs = [
    ppxlib
    menhirLib
  ];

  minimalOCamlVersion = "4.11";

  passthru.tests = {
    hello = callPackage ./tests/hello { };
  };

  meta = {
    description = "User-friendly programming language built on OCaml";
    homepage = "https://reasonml.github.io/";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://github.com/reasonml/reason";
  };
}
